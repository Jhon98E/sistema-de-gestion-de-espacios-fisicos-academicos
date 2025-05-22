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
    const ProgramasScreen(),
    const CohortesScreen(),
    const Center(child: Text('Notificaciones')),
    const HorariosScreen(),
    const Center(child: Text('Cohortes')),
    const AsignaturasScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isDrawerOpen ? 250 : 70,
            child: NavigationRail(
              extended: _isDrawerOpen,
              backgroundColor: AppTheme.primaryColor,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  _selectedIndex = index;
                });
              },
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
                      _isDrawerOpen ? Icons.chevron_left : Icons.chevron_right,
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
                  icon: Icon(Icons.school),
                  label: Text('Programas'),
                ),
                 NavigationRailDestination(
                  icon: Icon(Icons.group_work),
                  label: Text('Cohortes'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.notifications),
                  label: Text('Notificaciones'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.schedule),
                  label: Text('Horarios'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.groups),
                  label: Text('Cohortes'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.book),
                  label: Text('Asignaturas'),
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

