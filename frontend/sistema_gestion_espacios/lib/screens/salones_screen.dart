import 'package:flutter/material.dart';
import '../models/salon.dart';
import '../services/salones_service.dart';
import '../theme/app_theme.dart';

class SalonesScreen extends StatefulWidget {
  const SalonesScreen({super.key});

  @override
  State<SalonesScreen> createState() => _SalonesScreenState();
}

class _SalonesScreenState extends State<SalonesScreen> {
  final List<Salon> _salones = [];
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _capacidadController = TextEditingController();
  String _tipoSeleccionado = 'Aula';
  bool _disponibilidad = true;
  int? _salonEditandoId;

  @override
  void initState() {
    super.initState();
    _cargarSalones();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _capacidadController.dispose();
    super.dispose();
  }

  Future<void> _cargarSalones() async {
    setState(() => _isLoading = true);
    try {
      final salones = await SalonService.getSalones();
      setState(() {
        _salones.clear();
        _salones.addAll(salones);
      });
    } catch (e) {
      _mostrarError('Error al cargar salones: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarFormulario([Salon? salon]) {
    if (salon != null) {
      _salonEditandoId = salon.id;
      _nombreController.text = salon.nombre;
      _capacidadController.text = salon.capacidad.toString();
      _tipoSeleccionado = salon.tipo;
      _disponibilidad = salon.disponibilidad;
    } else {
      _salonEditandoId = null;
      _nombreController.clear();
      _capacidadController.clear();
      _tipoSeleccionado = 'Aula';
      _disponibilidad = true;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.3,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                salon == null ? 'Nuevo Salón' : 'Editar Salón',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: const Icon(Icons.meeting_room),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _capacidadController,
                      decoration: InputDecoration(
                        labelText: 'Capacidad',
                        prefixIcon: const Icon(Icons.people),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Campo requerido' : null,
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _tipoSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Tipo',
                        prefixIcon: const Icon(Icons.category),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: ['Aula', 'Laboratorio', 'Auditorio', 'Sala de Reuniones']
                          .map((tipo) => DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _tipoSeleccionado = value);
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: SwitchListTile(
                        title: const Text(
                          'Disponible',
                          style: TextStyle(fontSize: 16),
                        ),
                        value: _disponibilidad,
                        activeColor: AppTheme.primaryColor,
                        onChanged: (value) {
                          setState(() => _disponibilidad = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _guardarSalon,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _guardarSalon() async {
    if (_formKey.currentState?.validate() ?? false) {
      final salon = Salon(
        id: _salonEditandoId,
        nombre: _nombreController.text,
        capacidad: int.parse(_capacidadController.text),
        tipo: _tipoSeleccionado,
        disponibilidad: _disponibilidad,
      );

      try {
        if (_salonEditandoId != null) {
          await SalonService.updateSalon(_salonEditandoId!, salon);
          _mostrarMensaje('Salón actualizado exitosamente');
        } else {
          await SalonService.createSalon(salon);
          _mostrarMensaje('Salón creado exitosamente');
        }
        if (mounted) {
          Navigator.pop(context);
          _cargarSalones();
        }
      } catch (e) {
        _mostrarError('Error al guardar salón: $e');
      }
    }
  }

  Future<void> _eliminarSalon(int id) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este salón?'),
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
        await SalonService.deleteSalon(id);
        _cargarSalones();
        _mostrarMensaje('Salón eliminado exitosamente');
      } catch (e) {
        _mostrarError('Error al eliminar salón: $e');
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Salones',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF2F789D),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _salones.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.meeting_room_outlined,
                        size: 64,
                        color: const Color(0xFF2F789D).withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No hay salones registrados',
                        style: TextStyle(
                          fontSize: 18,
                          color: const Color(0xFF2F789D).withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () => _mostrarFormulario(),
                        icon: const Icon(Icons.add),
                        label: const Text('Agregar Salón'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F789D),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _salones.length,
                  itemBuilder: (context, index) {
                    final salon = _salones[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: StatefulBuilder(
                          builder: (context, setState) {
                            bool isHovered = false;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              transform: Matrix4.identity()
                                ..translate(0.0, isHovered ? -8.0 : 0.0, 0.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: isHovered 
                                        ? const Color(0xFF2F789D).withOpacity(0.3)
                                        : Colors.grey.withOpacity(0.1),
                                    spreadRadius: isHovered ? 2 : 1,
                                    blurRadius: isHovered ? 12 : 4,
                                    offset: Offset(0, isHovered ? 4 : 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {},
                                  onHover: (hovered) {
                                    setState(() {
                                      isHovered = hovered;
                                    });
                                  },
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.all(16),
                                    leading: CircleAvatar(
                                      backgroundColor: salon.disponibilidad
                                          ? const Color(0xFF4CAF50)
                                          : Colors.grey,
                                      child: Icon(
                                        _getIconForTipo(salon.tipo),
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(
                                      salon.nombre,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.people,
                                              size: 16,
                                              color: AppTheme.textSecondaryColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Capacidad: ${salon.capacidad}',
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
                                              Icons.category,
                                              size: 16,
                                              color: AppTheme.textSecondaryColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Tipo: ${salon.tipo}',
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
                                              salon.disponibilidad
                                                  ? Icons.check_circle
                                                  : Icons.cancel,
                                              size: 16,
                                              color: salon.disponibilidad
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              salon.disponibilidad
                                                  ? 'Disponible'
                                                  : 'No disponible',
                                              style: TextStyle(
                                                color: salon.disponibilidad
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Tooltip(
                                          message: 'Editar salón',
                                          child: IconButton(
                                            icon: const Icon(Icons.edit),
                                            color: const Color(0xFF2196F3),
                                            onPressed: () => _mostrarFormulario(salon),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Tooltip(
                                          message: 'Eliminar salón',
                                          child: IconButton(
                                            icon: const Icon(Icons.delete),
                                            color: const Color(0xFFE53935),
                                            onPressed: () => _eliminarSalon(salon.id!),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: const Color(0xFF81C784),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Salón'),
      ),
    );
  }

  IconData _getIconForTipo(String tipo) {
    switch (tipo) {
      case 'Aula':
        return Icons.meeting_room;
      case 'Laboratorio':
        return Icons.science;
      case 'Auditorio':
        return Icons.theater_comedy;
      case 'Sala de Reuniones':
        return Icons.groups;
      default:
        return Icons.meeting_room;
    }
  }
} 