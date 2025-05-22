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
      builder: (context) => AlertDialog(
        title: Text(salon == null ? 'Nuevo Salón' : 'Editar Salón'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacidadController,
                decoration: const InputDecoration(labelText: 'Capacidad'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _tipoSeleccionado,
                decoration: const InputDecoration(labelText: 'Tipo'),
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
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Disponible'),
                value: _disponibilidad,
                onChanged: (value) {
                  setState(() => _disponibilidad = value);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: _guardarSalon,
            child: const Text('Guardar'),
          ),
        ],
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
        } else {
          await SalonService.createSalon(salon);
        }
        if (mounted) {
          Navigator.pop(context);
          _cargarSalones();
          _mostrarMensaje('Salón guardado exitosamente');
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gestión de Salones',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _mostrarFormulario(),
                        icon: const Icon(Icons.add),
                        label: const Text('Nuevo Salón'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _salones.length,
                    itemBuilder: (context, index) {
                      final salon = _salones[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            salon.nombre,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Text(
                                'Capacidad: ${salon.capacidad} - Tipo: ${salon.tipo}',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                salon.disponibilidad
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: salon.disponibilidad
                                    ? Colors.green
                                    : AppTheme.accentColor,
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => _mostrarFormulario(salon),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _eliminarSalon(salon.id!),
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
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _capacidadController.dispose();
    super.dispose();
  }
} 