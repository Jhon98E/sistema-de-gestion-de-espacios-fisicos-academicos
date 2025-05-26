import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/horario_provider.dart';
import '../providers/programa_provider.dart';
import '../providers/asignatura_provider.dart';
import '../providers/cohorte_provider.dart';
import '../providers/salon_provider.dart';
import '../models/horario.dart';
import '../models/asignatura_programa_cohorte.dart';
import '../models/asignatura_programa_cohorte_detalle.dart';
import '../models/salon.dart';
import '../theme/app_theme.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _diaSemanaController = TextEditingController();
  final _horaInicioController = TextEditingController();
  final _horaFinController = TextEditingController();
  final _jornadaController = TextEditingController();
  int? _horarioEditandoId;
  late TabController _tabController;
  bool _isLoading = true;

  // Controllers para asignaturas-programas-cohortes
  final _asignaturaProgramaCohorteFormKey = GlobalKey<FormState>();
  int? _asignaturaProgramaId;
  int? _salonId;
  int? _horarioId;
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();

  final List<String> _diasSemana = [
    'Lunes',
    'Martes',
    'Miércoles',
    'Jueves',
    'Viernes',
    'Sábado',
    'Domingo'
  ];

  final List<String> _jornadas = ['diurno', 'nocturno'];

  final List<Map<String, String>> _intervalos = [
    {'label': '8 am – 12 m', 'inicio': '08:00:00', 'fin': '12:00:00'},
    {'label': '12 pm – 6 pm', 'inicio': '12:00:00', 'fin': '18:00:00'},
    {'label': '6 pm–10 pm', 'inicio': '18:00:00', 'fin': '22:00:00'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _diasSemana.length, vsync: this);
    
    Future.microtask(() async {
      final horarioProvider = Provider.of<HorarioProvider>(context, listen: false);
      final programaProvider = Provider.of<ProgramaProvider>(context, listen: false);
      final asignaturaProvider = Provider.of<AsignaturaProvider>(context, listen: false);
      final cohorteProvider = Provider.of<CohorteProvider>(context, listen: false);
      final salonProvider = Provider.of<SalonProvider>(context, listen: false);

      try {
        await horarioProvider.loadHorarios();
        await programaProvider.loadProgramas();
        await asignaturaProvider.loadAsignaturas();
        await cohorteProvider.loadCohortes();
        await salonProvider.loadSalones();

        await programaProvider.loadAsignaturasProgramas(asignaturaProvider.asignaturas, programaProvider.programas);
        await horarioProvider.loadAsignaturasProgramasCohortes();
        
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al cargar datos: $e')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    });

    _fechaInicioController.text = DateTime.now().toIso8601String().split('T')[0];
    _fechaFinController.text = DateTime.now().add(const Duration(days: 180)).toIso8601String().split('T')[0];
    
    // Cargar asignaturas-programas existentes después de que el widget esté construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarAsignaturasProgramas();
    });
  }

  @override
  void dispose() {
    _diaSemanaController.dispose();
    _horaInicioController.dispose();
    _horaFinController.dispose();
    _jornadaController.dispose();
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      controller.text = '$hour:$minute:00';
    }
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T')[0];
    }
  }

  void _mostrarFormularioHorario([Horario? horario]) {
    if (horario != null) {
      _horarioEditandoId = horario.id;
      _diaSemanaController.text = horario.diaSemana;
      _horaInicioController.text = horario.horaInicio;
      _horaFinController.text = horario.horaFin;
      _jornadaController.text = horario.jornada;
    } else {
      _horarioEditandoId = null;
      _diaSemanaController.clear();
      _horaInicioController.clear();
      _horaFinController.clear();
      _jornadaController.clear();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(horario == null ? 'Nuevo Horario' : 'Editar Horario'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _diaSemanaController.text.isEmpty
                      ? null
                      : _diaSemanaController.text,
                  decoration: InputDecoration(
                    labelText: 'Día de la Semana',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: _diasSemana.map((dia) {
                    return DropdownMenuItem(
                      value: dia,
                      child: Text(dia),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _diaSemanaController.text = value!);
                  },
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _horaInicioController,
                  decoration: InputDecoration(
                    labelText: 'Hora de Inicio',
                    prefixIcon: const Icon(Icons.access_time),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  readOnly: true,
                  onTap: () => _selectTime(_horaInicioController),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _horaFinController,
                  decoration: InputDecoration(
                    labelText: 'Hora de Fin',
                    prefixIcon: const Icon(Icons.access_time),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  readOnly: true,
                  onTap: () => _selectTime(_horaFinController),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _jornadaController.text.isEmpty
                      ? null
                      : _jornadaController.text,
                  decoration: InputDecoration(
                    labelText: 'Jornada',
                    prefixIcon: const Icon(Icons.schedule),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  items: _jornadas.map((jornada) {
                    return DropdownMenuItem(
                      value: jornada,
                      child: Text(jornada.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _jornadaController.text = value!);
                  },
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _guardarHorario,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Future<void> _guardarHorario() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<HorarioProvider>(context, listen: false);
      final nuevoHorario = Horario(
        id: _horarioEditandoId,
        diaSemana: _diaSemanaController.text,
        horaInicio: _horaInicioController.text,
        horaFin: _horaFinController.text,
        jornada: _jornadaController.text,
      );

      try {
        if (_horarioEditandoId != null) {
          await provider.updateHorario(_horarioEditandoId!, nuevoHorario);
          _mostrarMensaje('Horario actualizado exitosamente');
        } else {
          await provider.createHorario(nuevoHorario);
          _mostrarMensaje('Horario creado exitosamente');
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        _mostrarError('Error al guardar horario: $e');
      }
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: AppTheme.accentColor,
      ),
    );
  }

  void _mostrarMensaje(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _cargarAsignaturasProgramas() async {
    if (!mounted) return;
    
    try {
      await Provider.of<HorarioProvider>(context, listen: false).loadAsignaturasProgramas();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar asignaturas-programas: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Horarios', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF2B7A99),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    indicator: BoxDecoration(
                      color: Color(0xFF2B7A99), // Azul oscuro para la activa
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.black87, // Negro para las inactivas
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
                    tabs: _diasSemana.map((d) => Tab(text: d)).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _diasSemana.map((dia) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _intervalos.map((intervalo) {
                return Expanded(
                  child: IntervaloColumn(
                    dia: dia,
                    intervalo: intervalo,
                  ),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioHorario(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class IntervaloColumn extends StatelessWidget {
  final String dia;
  final Map<String, String> intervalo;
  const IntervaloColumn({required this.dia, required this.intervalo});

  @override
  Widget build(BuildContext context) {
    final List<Color> coloresAsignaciones = [
      Colors.green,
      Colors.blue,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.brown,
    ];
    return Consumer<HorarioProvider>(
      builder: (context, provider, child) {
        // Buscar los horarios que coincidan con el día y el intervalo
        final horarios = provider.horarios.where((h) => 
          h.diaSemana == dia && 
          h.horaInicio == intervalo['inicio'] && 
          h.horaFin == intervalo['fin']
        ).toList();

        // Buscar las asignaciones para estos horarios
        final asignaciones = provider.asignaturasProgramasCohortes.where((a) => 
          horarios.any((h) => h.id == a.horarioId)
        ).toList();

        final salones = Provider.of<SalonProvider>(context, listen: false).salones;

        return Column(
          children: [
            Text(intervalo['label']!, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...asignaciones.asMap().entries.map((entry) {
              final idx = entry.key;
              final a = entry.value;
              final salon = salones.firstWhere(
                (s) => s.id == a.salonId,
                orElse: () => Salon(id: 0, nombre: 'Desconocido', capacidad: 0, tipo: '', disponibilidad: false)
              );
              final color = coloresAsignaciones[idx % coloresAsignaciones.length];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    minimumSize: const Size(double.infinity, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => InfoAsignacionModal(asignacion: a, salon: salon),
                    );
                  },
                  child: Text(salon.nombre, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              );
            }),
            if (asignaciones.isEmpty)
              OutlinedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ModalAsignarSalon(
                    dia: dia,
                    intervalo: intervalo,
                  ),
                ),
                child: const Icon(Icons.add),
              ),
            if (asignaciones.isNotEmpty)
              OutlinedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) => ModalAsignarSalon(
                    dia: dia,
                    intervalo: intervalo,
                  ),
                ),
                child: const Icon(Icons.add),
              ),
          ],
        );
      },
    );
  }
}

class InfoAsignacionModal extends StatelessWidget {
  final AsignaturaProgramaCohorte asignacion;
  final Salon salon;
  const InfoAsignacionModal({required this.asignacion, required this.salon});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Detalle de Asignación', style: TextStyle(fontWeight: FontWeight.bold)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Salón: ${salon.nombre}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Fecha inicio: ${asignacion.fechaInicio}'),
          Text('Fecha fin: ${asignacion.fechaFin}'),
          const SizedBox(height: 8),
          Text('ID Asignatura-Programa: ${asignacion.asignaturaProgramaId}'),
          Text('ID Horario: ${asignacion.horarioId}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cerrar'),
        ),
      ],
    );
  }
}

class ModalAsignarSalon extends StatefulWidget {
  final String dia;
  final Map<String, String> intervalo;
  const ModalAsignarSalon({required this.dia, required this.intervalo});

  @override
  State<ModalAsignarSalon> createState() => _ModalAsignarSalonState();
}

class _ModalAsignarSalonState extends State<ModalAsignarSalon> {
  final _formKey = GlobalKey<FormState>();
  int? asignaturaProgramaId;
  List<int> cohortesSeleccionadas = [];
  int? salonId;
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fechaInicioController.text = DateTime.now().toIso8601String().split('T')[0];
    _fechaFinController.text = DateTime.now().add(const Duration(days: 180)).toIso8601String().split('T')[0];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cargarAsignaturasProgramas();
    });
  }

  Future<void> _cargarAsignaturasProgramas() async {
    if (!mounted) return;
    try {
      await Provider.of<HorarioProvider>(context, listen: false).loadAsignaturasProgramas();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar asignaturas-programas: $e')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _fechaInicioController.dispose();
    _fechaFinController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      controller.text = picked.toIso8601String().split('T')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final horarioProvider = Provider.of<HorarioProvider>(context, listen: false);
    final cohorteProvider = Provider.of<CohorteProvider>(context, listen: false);
    final salonProvider = Provider.of<SalonProvider>(context, listen: false);

    // Filtrar salones disponibles para este horario
    final asignacionesExistentes = horarioProvider.asignaturasProgramasCohortes.where((a) =>
      // Buscar asignaciones en el mismo día, intervalo y fechas
      horarioProvider.horarios.any((h) =>
        h.id == a.horarioId &&
        h.diaSemana == widget.dia &&
        h.horaInicio == widget.intervalo['inicio'] &&
        h.horaFin == widget.intervalo['fin']
      )
    ).toList();
    final salonesOcupados = asignacionesExistentes.map((a) => a.salonId).toSet();
    final salonesDisponibles = salonProvider.salones.where((s) => !salonesOcupados.contains(s.id)).toList();

    return AlertDialog(
      title: const Text('Asignar Materia y Grupos'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_isLoading)
                const CircularProgressIndicator(),
              if (!_isLoading) ...[
                DropdownButtonFormField<int>(
                  value: asignaturaProgramaId,
                  decoration: const InputDecoration(
                    labelText: 'Asignatura-Programa',
                    border: OutlineInputBorder(),
                  ),
                  items: horarioProvider.asignaturasProgramas.map((ap) => 
                    DropdownMenuItem(
                      value: ap['id'] as int,
                      child: Text('${ap['asignatura_nombre']} - ${ap['programa_nombre']}')
                    )
                  ).toList(),
                  onChanged: (v) => setState(() => asignaturaProgramaId = v),
                  validator: (value) => value == null ? 'Seleccione una asignatura-programa' : null,
                ),
                const SizedBox(height: 12),
                salonesDisponibles.isEmpty
                  ? const Text('No hay salones disponibles para este horario', style: TextStyle(color: Colors.red))
                  : DropdownButtonFormField<int>(
                      value: salonId,
                      decoration: const InputDecoration(
                        labelText: 'Salón',
                        border: OutlineInputBorder(),
                      ),
                      items: salonesDisponibles.map((s) => 
                        DropdownMenuItem(value: s.id, child: Text(s.nombre))
                      ).toList(),
                      onChanged: (v) => setState(() => salonId = v),
                      validator: (value) => value == null ? 'Seleccione un salón' : null,
                    ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fechaInicioController,
                  decoration: InputDecoration(
                    labelText: 'Fecha de Inicio',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(_fechaInicioController),
                    ),
                  ),
                  readOnly: true,
                  validator: (value) => value?.isEmpty ?? true ? 'Seleccione una fecha de inicio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fechaFinController,
                  decoration: InputDecoration(
                    labelText: 'Fecha de Fin',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(_fechaFinController),
                    ),
                  ),
                  readOnly: true,
                  validator: (value) => value?.isEmpty ?? true ? 'Seleccione una fecha de fin' : null,
                ),
                const SizedBox(height: 12),
                const Text('Seleccione los grupos (cohortes):'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: cohorteProvider.cohortes.map((cohorte) {
                    final isSelected = cohortesSeleccionadas.contains(cohorte.id);
                    return FilterChip(
                      label: Text(cohorte.nombre),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            cohortesSeleccionadas.add(cohorte.id!);
                          } else {
                            cohortesSeleccionadas.remove(cohorte.id!);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : () async {
            if (_formKey.currentState?.validate() ?? false) {
              if (cohortesSeleccionadas.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Seleccione al menos un grupo')),
                );
                return;
              }

              try {
                // 1. Buscar si ya existe el horario
                Horario? horarioExistente;
                try {
                  horarioExistente = horarioProvider.horarios.firstWhere(
                    (h) =>
                      h.diaSemana == widget.dia &&
                      h.horaInicio == widget.intervalo['inicio'] &&
                      h.horaFin == widget.intervalo['fin'] &&
                      h.jornada == 'diurno',
                  );
                } catch (_) {
                  horarioExistente = null;
                }

                Horario horario;
                if (horarioExistente != null) {
                  horario = horarioExistente;
                  print('Usando horario existente: [32m${horario.id}[0m');
                } else {
                  horario = await horarioProvider.createHorario(Horario(
                    id: null,
                    diaSemana: widget.dia,
                    horaInicio: widget.intervalo['inicio']!,
                    horaFin: widget.intervalo['fin']!,
                    jornada: 'diurno'
                  ));
                  print('Horario creado: [32m${horario.id}[0m');
                }

                // 2. Crear la asignación de asignatura-programa-cohorte
                print('Asignación a guardar:');
                print({
                  "asignatura_programa_id": asignaturaProgramaId,
                  "salon_id": salonId,
                  "horario_id": horario.id,
                  "fecha_inicio": _fechaInicioController.text,
                  "fecha_fin": _fechaFinController.text,
                });
                var asignacion = await horarioProvider.createAsignaturaProgramaCohorte(
                  AsignaturaProgramaCohorte(
                    id: null,
                    asignaturaProgramaId: asignaturaProgramaId!,
                    salonId: salonId!,
                    horarioId: horario.id!,
                    fechaInicio: _fechaInicioController.text,
                    fechaFin: _fechaFinController.text,
                  )
                );
                print('Asignación creada: ${asignacion.id}');

                // Si el id es null, buscar la asignación más reciente por los datos enviados
                if (asignacion.id == null) {
                  print('El id de la asignación es null, intentando buscar la asignación creada...');
                  await horarioProvider.loadAsignaturasProgramasCohortes();
                  final asignacionBuscada = horarioProvider.asignaturasProgramasCohortes.lastWhere(
                    (a) => a.asignaturaProgramaId == asignaturaProgramaId &&
                          a.salonId == salonId &&
                          a.horarioId == horario.id &&
                          a.fechaInicio == _fechaInicioController.text &&
                          a.fechaFin == _fechaFinController.text,
                    orElse: () => AsignaturaProgramaCohorte(
                      id: null,
                      asignaturaProgramaId: asignaturaProgramaId!,
                      salonId: salonId!,
                      horarioId: horario.id!,
                      fechaInicio: _fechaInicioController.text,
                      fechaFin: _fechaFinController.text,
                    ),
                  );
                  asignacion = asignacionBuscada;
                  print('Asignación encontrada: ${asignacion.id}');
                }

                // 3. Crear los detalles para cada cohorte seleccionada
                for (int i = 0; i < cohortesSeleccionadas.length; i++) {
                  final cohorteId = cohortesSeleccionadas[i];
                  print('Guardando detalle $i: asignatura_programa_cohorte_id=${asignacion.id}, cohorte_id=$cohorteId');
                  try {
                    await horarioProvider.createAsignaturaProgramaCohorteDetalle(
                      AsignaturaProgramaCohorteDetalle(
                        id: null,
                        asignaturaProgramaCohorteId: asignacion.id!,
                        cohorteId: cohorteId,
                      )
                    );
                    print('Detalle $i guardado correctamente');
                  } catch (e) {
                    print('Error guardando detalle $i: $e');
                  }
                }

                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Asignación creada exitosamente')),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
} 