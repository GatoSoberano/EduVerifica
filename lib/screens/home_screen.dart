import 'package:flutter/material.dart';
import 'education_screen.dart';
import 'glossary_screen.dart';
import 'simulator_screen.dart';
import 'verified_sources_screen.dart';
import 'profile_screen.dart';
import 'news_feed_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const EducationScreen(),      // Módulo educativo
    const NewsFeedScreen(),       // NUEVO: Feed de noticias verificadas
    const GlossaryScreen(),       // Glosario
    const SimulatorScreen(),      // Simulador
    const VerifiedSourcesScreen(), // Fuentes verificadas
    const ProfileScreen()         // Perfil
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.menu_book_rounded),
      activeIcon: Icon(Icons.menu_book),
      label: 'Aprende',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.feed_rounded),  // NUEVO: Icono de noticias
      activeIcon: Icon(Icons.feed),
      label: 'Noticias',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.library_books_rounded),
      activeIcon: Icon(Icons.library_books),
      label: 'Glosario',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.quiz_rounded),
      activeIcon: Icon(Icons.quiz),
      label: 'Simulador',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.verified_rounded),
      activeIcon: Icon(Icons.verified),
      label: 'Fuentes',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_rounded),
      activeIcon: Icon(Icons.person),
      label: 'Perfil',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.fact_check, color: Theme.of(context).primaryColor),
            const SizedBox(width: 8),
            const Text('EduVerifica'),
          ],
        ),
        centerTitle: true,
        elevation: 1,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              // TODO: Implementar notificaciones
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Color.fromRGBO(0, 0, 0, 0.1), // Corregido: sin withOpacity
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
          items: _navItems,
        ),
      ),
    );
  }
}