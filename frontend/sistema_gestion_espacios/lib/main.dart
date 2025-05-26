// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/asignatura_provider.dart';
import 'providers/programa_provider.dart';
import 'providers/cohorte_provider.dart';
import 'providers/horario_provider.dart';
import 'providers/salon_provider.dart';
import 'screens/auth/login_view.dart';
import 'screens/salones_screen.dart';
import 'screens/asignaturas_screen.dart';
import 'screens/programas_screen.dart';
import 'screens/cohortes_screen.dart';
import 'screens/horarios_screen.dart';
import 'theme/app_theme.dart';
import 'screens/actualizar_usuario_screen.dart';
import 'screens/ajustes_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AsignaturaProvider()),
        ChangeNotifierProvider(create: (_) => ProgramaProvider()),
        ChangeNotifierProvider(create: (_) => CohorteProvider()),
        ChangeNotifierProvider(create: (_) => HorarioProvider()),
        ChangeNotifierProvider(create: (_) => SalonProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Sistema de Gestión de Espacios Físicos Académicos',
        theme: AppTheme.defaultTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isAuthenticated) {
      return const LoginView();
    }

    return const HomePage();
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isDrawerOpen = false;

  final List<Widget> _pages = [
    const SalonesScreen(),
    const AsignaturasScreen(),
    const ProgramasScreen(),
    const CohortesScreen(),
    const HorariosScreen(),
  ];

  void _onMenuSelected(String value) async {
    if (value == 'logout') {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginView()),
          (route) => false,
        );
      }
    } else if (value == 'settings') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const AjustesScreen()),
      );
    }
  }

  void _onDestinationSelected(int index) {
    setState(() {
      if (index < 0 || index >= _pages.length) {
        _selectedIndex = 0;
      } else {
        _selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Validar el índice seleccionado para evitar errores
    if (_selectedIndex < 0 || _selectedIndex >= _pages.length) {
      _selectedIndex = 0;
    }
    final authProvider = Provider.of<AuthProvider>(context);
    final usuario = authProvider.usuarioActual;
    final String nombreUsuario =
        usuario != null ? '${usuario.nombre} ${usuario.apellido}' : 'Usuario';
    final String iniciales = usuario != null
        ? (usuario.nombre.isNotEmpty ? usuario.nombre[0] : '') +
            (usuario.apellido.isNotEmpty ? usuario.apellido[0] : '')
        : 'US';

    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isDrawerOpen ? 280 : 70,
            child: Column(
              children: [
                Expanded(
                  child: NavigationRail(
                    extended: _isDrawerOpen,
                    backgroundColor: AppTheme.primaryColor,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _onDestinationSelected,
                    useIndicator: true,
                    indicatorColor: Colors.white.withOpacity(0.2),
                    selectedIconTheme: const IconThemeData(
                      color: Colors.white,
                      size: 28,
                    ),
                    unselectedIconTheme: IconThemeData(
                      color: Colors.white.withOpacity(0.7),
                      size: 24,
                    ),
                    selectedLabelTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                    ),
                    leading: Column(
                      children: [
                        const SizedBox(height: 20),
                        IconButton(
                          icon: Icon(
                            _isDrawerOpen
                                ? Icons.chevron_left
                                : Icons.chevron_right,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            setState(() {
                              _isDrawerOpen = !_isDrawerOpen;
                            });
                          },
                        ),
                        const SizedBox(height: 20),
                        if (_isDrawerOpen)
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Sistema de Gestión de Espacios ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.meeting_room),
                        label: Text('Salones'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.book),
                        label: Text('Asignaturas'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.school),
                        label: Text('Programas'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.group_work),
                        label: Text('Cohortes'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.schedule),
                        label: Text('Horarios'),
                      ),
                      // NavigationRailDestination(
                      //   icon: Icon(Icons.notifications),
                      //   label: Text('Notificaciones'),
                      // ),
                    ],
                  ),
                ),
                // Menú de usuario abajo del todo, integrado visualmente
                _isDrawerOpen
                    ? Container(
                        color: AppTheme.primaryColor,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: ClipRect(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 22,
                                backgroundColor: AppTheme.primaryColor,
                                child: Text(
                                  iniciales.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              Flexible(
                                child: Text(
                                  nombreUsuario,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              SizedBox(
                                width: 40,
                                child: PopupMenuButton<String>(
                                  color: Colors.white,
                                  icon: const Icon(Icons.keyboard_arrow_down,
                                      color: Colors.white),
                                  onSelected: _onMenuSelected,
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'settings',
                                      child: Text('Ajustes'),
                                    ),
                                    const PopupMenuItem(
                                      value: 'logout',
                                      child: Text('Cerrar sesión'),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(
                        color: AppTheme.primaryColor,
                        width: double.infinity,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              iniciales.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _pages[_selectedIndex],
          ),
        ],
      ),
    );
  }
}
