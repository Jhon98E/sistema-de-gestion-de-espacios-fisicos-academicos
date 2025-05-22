import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/programa_provider.dart';
import '../providers/asignatura_provider.dart';
import '../models/programa.dart';
import '../models/asignatura_programa.dart';
import '../models/asignatura.dart';
import '../theme/app_theme.dart';

class ProgramasScreen extends StatefulWidget {
  const ProgramasScreen({super.key});

  @override
  State<ProgramasScreen> createState() => _ProgramasScreenState();
}

class _ProgramasScreenState extends State<ProgramasScreen> {
  final _formKey = GlobalKey<FormState>();
  final _asignacionFormKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _codigoController = TextEditingController();
  int? _programaEditandoId;
  int? _programaSeleccionadoId;
  int? _asignaturaSeleccionadaId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<ProgramaProvider>(context, listen: false).loadProgramas();
      Provider.of<AsignaturaProvider>(context, listen: false).loadAsignaturas();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _codigoController.dispose();
    super.dispose();
  }

  void _mostrarFormularioPrograma([Programa? programa]) {
    if (programa != null) {
      _programaEditandoId = programa.id;
      _nombreController.text = programa.nombre;
      _descripcionController.text = programa.descripcion;
      _codigoController.text = programa.codigoPrograma;
    } else {
      _programaEditandoId = null;
      _nombreController.clear();
      _descripcionController.clear();
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
                programa == null ? 'Nuevo Programa' : 'Editar Programa',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F789D),
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
                        prefixIcon: const Icon(Icons.school),
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
                      controller: _descripcionController,
                      decoration: InputDecoration(
                        labelText: 'Descripción',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      maxLines: 3,
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
                    onPressed: _guardarPrograma,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F789D),
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

  void _mostrarFormularioAsignacion() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.3,
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Asignar Asignatura a Programa',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F789D),
                  ),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _asignacionFormKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Consumer<ProgramaProvider>(
                        builder: (context, programaProvider, child) {
                          return DropdownButtonFormField<int>(
                            value: _programaSeleccionadoId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Programa',
                              prefixIcon: const Icon(Icons.school),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            items: programaProvider.programas.map((programa) {
                              return DropdownMenuItem(
                                value: programa.id,
                                child: Text(
                                  programa.nombre,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _programaSeleccionadoId = value);
                            },
                            validator: (value) =>
                                value == null ? 'Seleccione un programa' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      Consumer<AsignaturaProvider>(
                        builder: (context, asignaturaProvider, child) {
                          return DropdownButtonFormField<int>(
                            value: _asignaturaSeleccionadaId,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: 'Asignatura',
                              prefixIcon: const Icon(Icons.book),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                            ),
                            items: asignaturaProvider.asignaturas.map((asignatura) {
                              return DropdownMenuItem(
                                value: asignatura.id,
                                child: Text(
                                  asignatura.nombre,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _asignaturaSeleccionadaId = value);
                            },
                            validator: (value) =>
                                value == null ? 'Seleccione una asignatura' : null,
                          );
                        },
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
                      onPressed: _guardarAsignacion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F789D),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Asignar',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _guardarPrograma() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<ProgramaProvider>(context, listen: false);
      final nuevoPrograma = Programa(
        id: _programaEditandoId,
        nombre: _nombreController.text,
        descripcion: _descripcionController.text,
        codigoPrograma: _codigoController.text,
      );

      try {
        if (_programaEditandoId != null) {
          await provider.updatePrograma(_programaEditandoId!, nuevoPrograma);
          _mostrarMensaje('Programa actualizado exitosamente');
        } else {
          await provider.createPrograma(nuevoPrograma);
          _mostrarMensaje('Programa creado exitosamente');
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        _mostrarError('Error al guardar programa: $e');
      }
    }
  }

  Future<void> _guardarAsignacion() async {
    if (_asignacionFormKey.currentState?.validate() ?? false) {
      final provider = Provider.of<ProgramaProvider>(context, listen: false);
      final nuevaAsignacion = AsignaturaPrograma(
        asignaturaId: _asignaturaSeleccionadaId!,
        programaId: _programaSeleccionadoId!,
      );

      try {
        await provider.asignarAsignatura(nuevaAsignacion);
        await provider.loadAsignaturasProgramas();
        _mostrarMensaje('Asignatura asignada exitosamente');
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        print('Error detallado al asignar asignatura: $e');
        _mostrarError('Error al asignar asignatura: $e');
      }
    }
  }

  Future<void> _eliminarPrograma(int id) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar este programa?'),
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
        await Provider.of<ProgramaProvider>(context, listen: false)
            .deletePrograma(id);
        _mostrarMensaje('Programa eliminado exitosamente');
      } catch (e) {
        _mostrarError('Error al eliminar programa: $e');
      }
    }
  }

  Future<void> _eliminarAsignacion(int id) async {
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
        await Provider.of<ProgramaProvider>(context, listen: false)
            .deleteAsignaturaPrograma(id);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Programas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: const Color(0xFF2F789D),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<ProgramaProvider>(
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
                    onPressed: () => provider.loadProgramas(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F789D),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.programas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: const Color(0xFF2F789D).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay programas registrados',
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color(0xFF2F789D).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarFormularioPrograma(),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Programa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F789D),
                    ),
                  ),
                ],
              ),
            );
          }

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                Container(
                  color: const Color(0xFF2F789D),
                  child: const TabBar(
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    indicatorColor: Colors.white,
                    tabs: [
                      Tab(text: 'Programas'),
                      Tab(text: 'Asignaturas por Programa'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      // Tab de Programas
                      ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.programas.length,
                        itemBuilder: (context, index) {
                          final programa = provider.programas[index];
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
                                            backgroundColor: const Color(0xFF2F789D),
                                            child: Text(
                                              programa.nombre[0].toUpperCase(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          title: Text(
                                            programa.nombre,
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
                                                    Icons.description,
                                                    size: 16,
                                                    color: AppTheme.textSecondaryColor,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      programa.descripcion,
                                                      style: TextStyle(
                                                        color: AppTheme.textSecondaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.tag,
                                                    size: 16,
                                                    color: AppTheme.textSecondaryColor,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Código: ${programa.codigoPrograma}',
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
                                                message: 'Editar programa',
                                                child: IconButton(
                                                  icon: const Icon(Icons.edit),
                                                  color: const Color(0xFF2196F3),
                                                  onPressed: () => _mostrarFormularioPrograma(programa),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Tooltip(
                                                message: 'Eliminar programa',
                                                child: IconButton(
                                                  icon: const Icon(Icons.delete),
                                                  color: const Color(0xFFE53935),
                                                  onPressed: () => _eliminarPrograma(programa.id!),
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
                      // Tab de Asignaturas por Programa
                      ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.asignaturasProgramas.length,
                        itemBuilder: (context, index) {
                          final asignacion = provider.asignaturasProgramas[index];
                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF2F789D),
                                child: const Icon(
                                  Icons.book,
                                  color: Colors.white,
                                ),
                              ),
                              title: Consumer2<AsignaturaProvider, ProgramaProvider>(
                                builder: (context, asignaturaProvider, programaProvider, child) {
                                  final asignatura = asignaturaProvider.asignaturas.firstWhere(
                                    (a) => a.id == asignacion.asignaturaId,
                                    orElse: () => Asignatura(
                                      id: 0,
                                      nombre: 'Asignatura no encontrada',
                                      codigoAsignatura: 'N/A',
                                    ),
                                  );
                                  final programa = programaProvider.programas.firstWhere(
                                    (p) => p.id == asignacion.programaId,
                                    orElse: () => Programa(
                                      id: 0,
                                      nombre: 'Programa no encontrado',
                                      descripcion: '',
                                      codigoPrograma: 'N/A',
                                    ),
                                  );

                                  final asignaturaNombre = asignatura.nombre;
                                  final programaNombre = programa.nombre;

                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        asignaturaNombre,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Programa: $programaNombre',
                                        style: TextStyle(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                color: const Color(0xFFE53935),
                                onPressed: () => _eliminarAsignacion(asignacion.id!),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () => _mostrarFormularioAsignacion(),
            backgroundColor: const Color(0xFFBA68C8),
            icon: const Icon(Icons.add),
            label: const Text('Asignar Asignatura'),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            onPressed: () => _mostrarFormularioPrograma(),
            backgroundColor: const Color(0xFF2F789D),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo Programa'),
          ),
        ],
      ),
    );
  }
} 