import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cohorte_provider.dart';
import '../providers/programa_provider.dart';
import '../models/cohorte.dart';
import '../models/programa.dart';
import '../theme/app_theme.dart';

class CohortesScreen extends StatefulWidget {
  const CohortesScreen({super.key});

  @override
  State<CohortesScreen> createState() => _CohortesScreenState();
}

class _CohortesScreenState extends State<CohortesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();
  int? _cohorteEditandoId;
  int? _programaSeleccionadoId;
  String? _estadoSeleccionado;

  final List<String> _estadosCohorte = ['Activa', 'Inactiva', 'Finalizada'];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CohorteProvider>(context, listen: false).loadCohortes();
      Provider.of<ProgramaProvider>(context, listen: false).loadProgramas();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
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

  void _mostrarFormularioCohorte([Cohorte? cohorte]) {
    if (cohorte != null) {
      _cohorteEditandoId = cohorte.id;
      _nombreController.text = cohorte.nombre;
      _fechaInicioController.text = cohorte.fechaInicio;
      _fechaFinController.text = cohorte.fechaFin;
      _estadoSeleccionado = cohorte.estado;

      final programaProvider = Provider.of<ProgramaProvider>(context, listen: false);
      if (programaProvider.programas.any((p) => p.id == cohorte.programaId)) {
        _programaSeleccionadoId = cohorte.programaId;
      } else {
        _programaSeleccionadoId = null;
      }
    } else {
      _cohorteEditandoId = null;
      _nombreController.clear();
      _programaSeleccionadoId = null;
      _fechaInicioController.clear();
      _fechaFinController.clear();
      _estadoSeleccionado = null;
    }

    showDialog(
      context: context,
      builder: (context) => CohorteFormDialog(cohorte: cohorte),
    );
  }

  Future<void> _guardarCohorte() async {
    if (_formKey.currentState?.validate() ?? false) {
      final provider = Provider.of<CohorteProvider>(context, listen: false);
      final nuevaCohorte = Cohorte(
        id: _cohorteEditandoId,
        nombre: _nombreController.text,
        programaId: _programaSeleccionadoId!,
        fechaInicio: _fechaInicioController.text,
        fechaFin: _fechaFinController.text,
        estado: _estadoSeleccionado!,
      );

      try {
        if (_cohorteEditandoId != null) {
          await provider.updateCohorte(_cohorteEditandoId!, nuevaCohorte);
          _mostrarMensaje('Cohorte actualizada exitosamente');
        } else {
          await provider.createCohorte(nuevaCohorte);
          _mostrarMensaje('Cohorte creada exitosamente');
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        _mostrarError('Error al guardar cohorte: $e');
      }
    }
  }

  Future<void> _eliminarCohorte(int id) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Está seguro de eliminar esta cohorte?'),
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
        await Provider.of<CohorteProvider>(context, listen: false)
            .deleteCohorte(id);
        _mostrarMensaje('Cohorte eliminada exitosamente');
      } catch (e) {
        _mostrarError('Error al eliminar cohorte: $e');
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
          'Cohortes',
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
      body: Consumer<CohorteProvider>(
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
                    onPressed: () => provider.loadCohortes(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F789D),
                    ),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.cohortes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_work_outlined,
                    size: 64,
                    color: const Color(0xFF2F789D).withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay cohortes registradas',
                    style: TextStyle(
                      fontSize: 18,
                      color: const Color(0xFF2F789D).withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _mostrarFormularioCohorte(),
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Cohorte'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F789D),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.cohortes.length,
            itemBuilder: (context, index) {
              final cohorte = provider.cohortes[index];
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
                                  cohorte.nombre[0].toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                cohorte.nombre,
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
                                        Icons.school,
                                        size: 16,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: FutureBuilder<Programa?>(
                                          future: Provider.of<ProgramaProvider>(context, listen: false).getProgramaById(cohorte.programaId), // You might need to add getProgramaById to ProgramaProvider
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return const Text('Cargando programa...');
                                            } else if (snapshot.hasError) {
                                              return Text('Error al cargar programa: ${snapshot.error}');
                                            } else if (snapshot.hasData && snapshot.data != null) {
                                               return Text(
                                                'Programa: ${snapshot.data!.nombre}',
                                                style: TextStyle(
                                                  color: AppTheme.textSecondaryColor,
                                                ),
                                              );
                                            } else {
                                              return const Text('Programa no encontrado');
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Inicio: ${cohorte.fechaInicio}',
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
                                        'Fin: ${cohorte.fechaFin}',
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
                                        Icons.info_outline,
                                        size: 16,
                                        color: AppTheme.textSecondaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Estado: ${cohorte.estado}',
                                        style: TextStyle(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Tooltip(
                                    message: 'Editar cohorte',
                                    child: IconButton(
                                      icon: const Icon(Icons.edit),
                                      color: const Color(0xFF2196F3),
                                      onPressed: () => _mostrarFormularioCohorte(cohorte),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Tooltip(
                                    message: 'Eliminar cohorte',
                                    child: IconButton(
                                      icon: const Icon(Icons.delete),
                                      color: const Color(0xFFE53935),
                                      onPressed: () => _eliminarCohorte(cohorte.id!),
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
        onPressed: () => _mostrarFormularioCohorte(),
        backgroundColor: const Color(0xFF2F789D),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Cohorte'),
      ),
    );
  }
}

class CohorteFormDialog extends StatefulWidget {
  final Cohorte? cohorte;

  const CohorteFormDialog({super.key, this.cohorte});

  @override
  State<CohorteFormDialog> createState() => _CohorteFormDialogState();
}

class _CohorteFormDialogState extends State<CohorteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaFinController = TextEditingController();
  int? _programaSeleccionadoId;
  String? _estadoSeleccionado;
  int? _cohorteEditandoId;

  final List<String> _estadosCohorte = ['Activa', 'Inactiva', 'Finalizada'];

  @override
  void initState() {
    super.initState();
    _cohorteEditandoId = widget.cohorte?.id;
    _nombreController.text = widget.cohorte?.nombre ?? '';
    _fechaInicioController.text = widget.cohorte?.fechaInicio ?? '';
    _fechaFinController.text = widget.cohorte?.fechaFin ?? '';

    // Validate and initialize selected estado
    if (widget.cohorte?.estado != null && _estadosCohorte.contains(widget.cohorte!.estado)) {
       _estadoSeleccionado = widget.cohorte!.estado;
    } else {
       _estadoSeleccionado = null; // Set to null if estado is null or not in the expected list
       if (widget.cohorte?.estado != null) {
         print('Warning: Unexpected cohorte.estado value: ${widget.cohorte!.estado}'); // Log unexpected values
       }
    }

    // Initialize selected program ID if editing a cohorte and programs are already loaded
    final programaProvider = Provider.of<ProgramaProvider>(context, listen: false);
    if (widget.cohorte != null && widget.cohorte!.programaId != null) {
       // Try to find the program in the currently loaded list
       // This might be empty initially, the Consumer will handle updates later.
       final programa = programaProvider.programas.firstWhere(
          (p) => p.id == widget.cohorte!.programaId,
          orElse: () => null as Programa, // Use orElse to return null if not found
       );
       _programaSeleccionadoId = programa?.id; // Set ID only if program was found
    }

     // Ensure programs are loaded if they aren't already
    if (programaProvider.programas.isEmpty && !programaProvider.isLoading && programaProvider.error == null) {
       Future.microtask(() => programaProvider.loadProgramas());
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
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

  Future<void> _guardarCohorte() async {
    if (_formKey.currentState?.validate() ?? false) {
      final cohorteProvider = Provider.of<CohorteProvider>(context, listen: false);
      final cohorteGuardar = Cohorte(
        id: _cohorteEditandoId,
        nombre: _nombreController.text,
        programaId: _programaSeleccionadoId!,
        fechaInicio: _fechaInicioController.text,
        fechaFin: _fechaFinController.text,
        estado: _estadoSeleccionado!,
      );

      try {
        if (_cohorteEditandoId != null) {
          await cohorteProvider.updateCohorte(_cohorteEditandoId!, cohorteGuardar);
          // _mostrarMensaje('Cohorte actualizada exitosamente'); // Use ScaffoldMessenger in the screen
        } else {
          await cohorteProvider.createCohorte(cohorteGuardar);
          // _mostrarMensaje('Cohorte creada exitosamente'); // Use ScaffoldMessenger in the screen
        }
        if (mounted) {
          Navigator.pop(context, true); // Indicate success
        }
      } catch (e) {
         // _mostrarError('Error al guardar cohorte: $e'); // Use ScaffoldMessenger in the screen
          if (mounted) {
             Navigator.pop(context, false); // Indicate failure
          }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.4,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.cohorte == null ? 'Nueva Cohorte' : 'Editar Cohorte',
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nombreController,
                      decoration: InputDecoration(
                        labelText: 'Nombre',
                        prefixIcon: const Icon(Icons.label_outline),
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
                    Consumer<ProgramaProvider>(
                      builder: (context, programaProvider, child) {
                        // Handle loading and error states for programs
                        if (programaProvider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        } else if (programaProvider.error != null) {
                          return Center(child: Text('Error al cargar programas: ${programaProvider.error}'));
                        } else if (programaProvider.programas.isEmpty) {
                           return const Text('No hay programas disponibles para asignar.');
                        } else {
                          // Programs are loaded and available.
                          // Determine the initial selected value based on the cohorte being edited.
                          int? initialProgramaIdForDropdown = _programaSeleccionadoId; // Use the state value

                          if (widget.cohorte != null && widget.cohorte!.programaId != null) {
                              // Validate the cohorte's programaId is an int before trying to find it
                              if (widget.cohorte!.programaId is int) {
                                 // Try to find the program in the loaded list
                                 final programa = programaProvider.programas.firstWhere(
                                    (p) => p.id == widget.cohorte!.programaId,
                                    orElse: () => null as Programa, // Use orElse to return null if not found
                                 );
                                 // If found, use its ID as the initial value for the dropdown
                                 if (programa != null) {
                                    initialProgramaIdForDropdown = programa.id;
                                 } else {
                                    // If the program ID from cohorte is an int but not found in the list,
                                    // set initial value to null to avoid assertion error.
                                    initialProgramaIdForDropdown = null;
                                 }
                              } else {
                                 // If cohorte's programaId is not an int (e.g., "hola"),
                                 // set initial value to null to avoid assertion error.
                                 initialProgramaIdForDropdown = null;
                                 // Consider logging a warning here about unexpected data format.
                                 print('Warning: cohorte.programaId is not an integer: ${widget.cohorte!.programaId}');
                              }
                          }
                           // If adding a new cohorte or cohorte.programaId is null/invalid,
                           // initialProgramaIdForDropdown is already null or reflects a previous selection.

                          // --- Debugging print --- poner print(initialProgramaIdForDropdown) aqui
                          print('Dropdown value being set: $initialProgramaIdForDropdown');
                          print('Available program IDs: ${programaProvider.programas.map((p) => p.id).toList()}');
                          // ---------------------

                          return DropdownButtonFormField<int>(
                            // Use the determined initial value for this build cycle
                            value: initialProgramaIdForDropdown,
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
                              // Update the local state when a new program is selected
                              setState(() => _programaSeleccionadoId = value);
                            },
                            validator: (value) =>
                                value == null ? 'Seleccione un programa' : null,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
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
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      value: _estadoSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: const Icon(Icons.info_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50],
                      ),
                      items: _estadosCohorte.map((estado) {
                        return DropdownMenuItem(
                          value: estado,
                          child: Text(estado),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _estadoSeleccionado = value);
                      },
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
                    onPressed: () => Navigator.pop(context, false), // Indicate cancellation
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
                    onPressed: _guardarCohorte,
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
} 