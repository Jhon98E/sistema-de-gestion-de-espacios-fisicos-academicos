import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
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
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;
  late TabController _tabController;

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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = _focusedDay;
    _tabController = TabController(length: 2, vsync: this);
    
    Future.microtask(() async {
      final horarioProvider = Provider.of<HorarioProvider>(context, listen: false);
      final programaProvider = Provider.of<ProgramaProvider>(context, listen: false);
      final asignaturaProvider = Provider.of<AsignaturaProvider>(context, listen: false);
      final cohorteProvider = Provider.of<CohorteProvider>(context, listen: false);
      final salonProvider = Provider.of<SalonProvider>(context, listen: false);

      await horarioProvider.loadHorarios();
      await programaProvider.loadProgramas();
      await asignaturaProvider.loadAsignaturas();
      await cohorteProvider.loadCohortes();
      await salonProvider.loadSalones();

      await programaProvider.loadAsignaturasProgramas(asignaturaProvider.asignaturas, programaProvider.programas);

      await horarioProvider.loadAsignaturasProgramasCohortes();
      await horarioProvider.loadAsignaturasProgramasCohortesDetalles();
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

  void _mostrarFormularioAsignaturaProgramaCohorte([AsignaturaProgramaCohorte? asignacion]) {
    _asignaturaProgramaId = null;
    _salonId = null;
    _horarioId = null;
    _fechaInicioController.clear();
    _fechaFinController.clear();

    if (asignacion != null) {
      _asignaturaProgramaId = asignacion.asignaturaProgramaId;
      _salonId = asignacion.salonId;
      _horarioId = asignacion.horarioId;
      _fechaInicioController.text = asignacion.fechaInicio;
      _fechaFinController.text = asignacion.fechaFin;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(asignacion == null ? 'Nueva Asignación' : 'Editar Asignación'),
        content: SingleChildScrollView(
          child: Form(
            key: _asignaturaProgramaCohorteFormKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<ProgramaProvider>(
                  builder: (context, programaProvider, child) {
                    if (programaProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (programaProvider.error != null) {
                       return Center(child: Text('Error al cargar asignaturas-programas: ${programaProvider.error}'));
                    }
                    return DropdownButtonFormField<int>(
                      value: _asignaturaProgramaId,
                      decoration: InputDecoration(
                        labelText: 'Asignatura-Programa',
                        prefixIcon: const Icon(Icons.book),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: programaProvider.asignaturasProgramas.map((ap) {
                        return DropdownMenuItem(
                          value: ap.id,
                          child: Text('${ap.nombreAsignatura} - ${ap.nombrePrograma}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _asignaturaProgramaId = value);
                      },
                      validator: (value) =>
                          value == null ? 'Seleccione una asignatura-programa' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<SalonProvider>(
                  builder: (context, salonProvider, child) {
                    if (salonProvider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                     if (salonProvider.error != null) {
                       return Center(child: Text('Error al cargar salones: ${salonProvider.error}'));
                    }
                    return DropdownButtonFormField<int>(
                      value: _salonId,
                      decoration: InputDecoration(
                        labelText: 'Salón',
                        prefixIcon: const Icon(Icons.meeting_room),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: salonProvider.salones.map((salon) {
                        return DropdownMenuItem(
                          value: salon.id,
                          child: Text(salon.nombre),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _salonId = value);
                      },
                      validator: (value) =>
                          value == null ? 'Seleccione un salón' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                Consumer<HorarioProvider>(
                  builder: (context, horarioProvider, child) {
                    return DropdownButtonFormField<int>(
                      value: _horarioId,
                      decoration: InputDecoration(
                        labelText: 'Horario',
                        prefixIcon: const Icon(Icons.schedule),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: horarioProvider.horarios.map((horario) {
                        return DropdownMenuItem(
                          value: horario.id,
                          child: Text('${horario.diaSemana} ${horario.horaInicio}-${horario.horaFin}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _horarioId = value);
                      },
                      validator: (value) =>
                          value == null ? 'Seleccione un horario' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fechaInicioController,
                  decoration: InputDecoration(
                    labelText: 'Fecha Inicio',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(_fechaInicioController),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fechaFinController,
                  decoration: InputDecoration(
                    labelText: 'Fecha Fin',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(_fechaFinController),
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
            onPressed: _guardarAsignaturaProgramaCohorte,
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

  Future<void> _guardarAsignaturaProgramaCohorte() async {
    if (_asignaturaProgramaCohorteFormKey.currentState?.validate() ?? false) {
      final provider = Provider.of<HorarioProvider>(context, listen: false);

      final int? asignacionId = null;
      final nuevaAsignacion = AsignaturaProgramaCohorte(
        id: asignacionId,
        asignaturaProgramaId: _asignaturaProgramaId!,
        salonId: _salonId!,
        horarioId: _horarioId!,
        fechaInicio: _fechaInicioController.text,
        fechaFin: _fechaFinController.text,
      );

      try {
        if (asignacionId != null) {
          _mostrarMensaje('Asignación actualizada exitosamente');
        } else {
          await provider.createAsignaturaProgramaCohorte(nuevaAsignacion);
          _mostrarMensaje('Asignación creada exitosamente');
        }
        
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        _mostrarError('Error al guardar asignación: $e');
      }
    }
  }

  Future<void> _eliminarHorario(int id) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este horario?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmacion ?? false) {
      try {
        await Provider.of<HorarioProvider>(context, listen: false)
            .deleteHorario(id);
        _mostrarMensaje('Horario eliminado exitosamente');
      } catch (e) {
        _mostrarError('Error al eliminar horario: $e');
      }
    }
  }

  Future<void> _eliminarAsignaturaProgramaCohorte(int id) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar esta asignación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmacion ?? false) {
      try {
        await Provider.of<HorarioProvider>(context, listen: false)
            .deleteAsignaturaProgramaCohorte(id);
        _mostrarMensaje('Asignación eliminada exitosamente');
      } catch (e) {
        _mostrarError('Error al eliminar asignación: $e');
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
        backgroundColor: AppTheme.secondaryColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfYear = DateTime(now.year, 1, 1);
    final lastDayFiveYearsLater = DateTime(now.year + 5, 12, 31);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Horarios',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Horarios'),
            Tab(text: 'Asignaciones'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab de Horarios
          Consumer<HorarioProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${provider.error}',
                        style: const TextStyle(color: Color(0xFF2F789D)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => provider.loadHorarios(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F789D),
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              return SafeArea(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: TableCalendar(
                        firstDay: firstDayOfYear,
                        lastDay: lastDayFiveYearsLater,
                        focusedDay: _focusedDay,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onFormatChanged: (format) {
                          setState(() {
                            _calendarFormat = format;
                          });
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                        calendarStyle: const CalendarStyle(
                          selectedDecoration: BoxDecoration(
                            color: Color(0xFF2F789D),
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: Color(0xFF2F789D),
                            shape: BoxShape.circle,
                          ),
                        ),
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Mes',
                          CalendarFormat.week: 'Semana',
                        },
                      ),
                    ),
                    Expanded(
                      child: provider.horarios.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay horarios registrados',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.horarios.length,
                              itemBuilder: (context, index) {
                                final horario = provider.horarios[index];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: ListTile(
                                    title: Text(
                                      horario.diaSemana,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              size: 16,
                                              color: AppTheme.textSecondaryColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Inicio: ${horario.horaInicio}',
                                              style: TextStyle(
                                                color: AppTheme.textSecondaryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(
                                              Icons.access_time,
                                              size: 16,
                                              color: AppTheme.textSecondaryColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Fin: ${horario.horaFin}',
                                              style: TextStyle(
                                                color: AppTheme.textSecondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.schedule,
                                              size: 16,
                                              color: AppTheme.textSecondaryColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Jornada: ${horario.jornada.toUpperCase()}',
                                              style: TextStyle(
                                                color: AppTheme.textSecondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _mostrarFormularioHorario(horario),
                                          color: AppTheme.primaryColor,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => _eliminarHorario(horario.id!),
                                          color: AppTheme.accentColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
          // Tab de Asignaciones
          Consumer<HorarioProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (provider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${provider.error}',
                        style: const TextStyle(color: Color(0xFF2F789D)),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          provider.loadAsignaturasProgramasCohortes();
                          provider.loadAsignaturasProgramasCohortesDetalles();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F789D),
                        ),
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                );
              }

              return SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: provider.asignaturasProgramasCohortes.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay asignaciones registradas',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: provider.asignaturasProgramasCohortes.length,
                              itemBuilder: (context, index) {
                                final asignacion = provider.asignaturasProgramasCohortes[index];
                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: ListTile(
                                    title: Text(
                                      'Asignación #${asignacion.id}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: AppTheme.textSecondaryColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Inicio: ${asignacion.fechaInicio}',
                                              style: TextStyle(
                                                color: AppTheme.textSecondaryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Icon(
                                              Icons.calendar_today,
                                              size: 16,
                                              color: AppTheme.textSecondaryColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Fin: ${asignacion.fechaFin}',
                                              style: TextStyle(
                                                color: AppTheme.textSecondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () => _mostrarFormularioAsignaturaProgramaCohorte(asignacion),
                                          color: AppTheme.primaryColor,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () => _eliminarAsignaturaProgramaCohorte(asignacion.id!),
                                          color: AppTheme.accentColor,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_tabController.index == 0) {
            _mostrarFormularioHorario();
          } else {
            _mostrarFormularioAsignaturaProgramaCohorte();
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
} 