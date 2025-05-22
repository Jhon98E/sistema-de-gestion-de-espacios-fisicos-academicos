import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../providers/horario_provider.dart';
import '../models/horario.dart';
import '../theme/app_theme.dart';

class HorariosScreen extends StatefulWidget {
  const HorariosScreen({super.key});

  @override
  State<HorariosScreen> createState() => _HorariosScreenState();
}

class _HorariosScreenState extends State<HorariosScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diaSemanaController = TextEditingController();
  final _horaInicioController = TextEditingController();
  final _horaFinController = TextEditingController();
  final _jornadaController = TextEditingController();
  int? _horarioEditandoId;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  CalendarFormat _calendarFormat = CalendarFormat.week;

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
    Future.microtask(() =>
        Provider.of<HorarioProvider>(context, listen: false).loadHorarios());
  }

  @override
  void dispose() {
    _diaSemanaController.dispose();
    _horaInicioController.dispose();
    _horaFinController.dispose();
    _jornadaController.dispose();
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
      ),
      body: Consumer<HorarioProvider>(
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarFormularioHorario(),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
} 