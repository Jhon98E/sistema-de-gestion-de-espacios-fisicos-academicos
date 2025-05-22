import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/asignatura_provider.dart';
import '../models/asignatura.dart';
import '../theme/app_theme.dart';

class AsignaturasScreen extends StatefulWidget {
  const AsignaturasScreen({super.key});

  @override
  State<AsignaturasScreen> createState() => _AsignaturasScreenState();
}

class _AsignaturasScreenState extends State<AsignaturasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _codigoController = TextEditingController();
  int? _asignaturaEditandoId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => 
      Provider.of<AsignaturaProvider>(context, listen: false).loadAsignaturas()
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  void _mostrarFormulario([Asignatura? asignatura]) {
    if (asignatura != null) {
      _asignaturaEditandoId = asignatura.id;
      _nombreController.text = asignatura.nombre;
      _codigoController.text = asignatura.codigoAsignatura;
    } else {
      _asignaturaEditandoId = null;
      _nombreController.clear();
      _codigoController.clear();
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
                asignatura == null ? 'Nueva Asignatura' : 'Editar Asignatura',
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
                        prefixIcon: const Icon(Icons.book),
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
                      controller: _codigoController,
                      decoration: InputDecoration(
                        labelText: 'Código',
                        prefixIcon: const Icon(Icons.tag),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Campo requerido' : null,
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
                    onPressed: _guardarAsignatura,
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

  Future<void> _guardarAsignatura() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<AsignaturaProvider>(context, listen: false);
      final nuevaAsignatura = Asignatura(
        id: _asignaturaEditandoId,
        nombre: _nombreController.text,
        codigoAsignatura: _codigoController.text,
      );

      try {
        if (_asignaturaEditandoId != null) {
          await provider.updateAsignatura(_asignaturaEditandoId!, nuevaAsignatura);
          _mostrarMensaje('Asignatura actualizada exitosamente');
        } else {
          await provider.createAsignatura(nuevaAsignatura);
          _mostrarMensaje('Asignatura creada exitosamente');
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        _mostrarError('Error al guardar asignatura: $e');
      }
    }
  }

  Future<void> _eliminarAsignatura(Asignatura asignatura) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text('¿Está seguro de eliminar la asignatura ${asignatura.nombre}?'),
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
        await Provider.of<AsignaturaProvider>(context, listen: false)
            .deleteAsignatura(asignatura.id!);
        _mostrarMensaje('Asignatura eliminada exitosamente');
      } catch (e) {
        _mostrarError('Error al eliminar asignatura: $e');
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
    return Theme(
      data: AppTheme.asignaturasTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Asignaturas'),
          backgroundColor: AppTheme.asignaturasTheme.primaryColor,
        ),
        body: Consumer<AsignaturaProvider>(
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
                      style: TextStyle(color: AppTheme.asignaturasTheme.colorScheme.tertiary),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => provider.loadAsignaturas(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.asignaturasTheme.primaryColor,
                      ),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (provider.asignaturas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.book_outlined,
                      size: 64,
                      color: AppTheme.asignaturasTheme.primaryColor.withOpacity(0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay asignaturas registradas',
                      style: TextStyle(
                        fontSize: 18,
                        color: AppTheme.asignaturasTheme.primaryColor.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _mostrarFormulario(),
                      icon: const Icon(Icons.add),
                      label: const Text('Agregar Asignatura'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.asignaturasTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.asignaturas.length,
              itemBuilder: (context, index) {
                final asignatura = provider.asignaturas[index];
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
                                    ? AppTheme.asignaturasTheme.primaryColor.withOpacity(0.3)
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
                                  backgroundColor: AppTheme.asignaturasTheme.primaryColor,
                                  child: Text(
                                    asignatura.nombre[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  asignatura.nombre,
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
                                          Icons.tag,
                                          size: 16,
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Código: ${asignatura.codigoAsignatura}',
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
                                    Tooltip(
                                      message: 'Editar asignatura',
                                      child: IconButton(
                                        icon: const Icon(Icons.edit),
                                        color: const Color(0xFF2196F3),
                                        onPressed: () => _mostrarFormulario(asignatura),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Tooltip(
                                      message: 'Eliminar asignatura',
                                      child: IconButton(
                                        icon: const Icon(Icons.delete),
                                        color: const Color(0xFFE53935),
                                        onPressed: () => _eliminarAsignatura(asignatura),
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
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _mostrarFormulario(),
          backgroundColor: AppTheme.asignaturasTheme.colorScheme.secondary,
          icon: const Icon(Icons.add),
          label: const Text('Nueva Asignatura'),
        ),
      ),
    );
  }
} 