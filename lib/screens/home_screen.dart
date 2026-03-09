import 'package:flutter/material.dart';
import 'education_screen.dart';
import 'glossary_screen.dart';
import 'simulator_screen.dart';
import 'profile_screen.dart';
import 'news_feed_screen.dart';
import 'verify_screen.dart';
import 'verified_sources_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Las pantallas NO deben incluir Scaffold propio; heredan el de HomeScreen.
  static const List<Widget> _screens = [
    EducationScreen(),
    NewsFeedScreen(),
    GlossaryScreen(),
    SimulatorScreen(),
    VerifyScreen(),
    VerifiedSourcesScreen(),
    ProfileScreen(),
  ];

  static const List<BottomNavigationBarItem> _navItems = [
    BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Aprende'),
    BottomNavigationBarItem(icon: Icon(Icons.feed_rounded), label: 'Noticias'),
    BottomNavigationBarItem(icon: Icon(Icons.library_books_rounded), label: 'Glosario'),
    BottomNavigationBarItem(icon: Icon(Icons.quiz_rounded), label: 'Simulador'),
    BottomNavigationBarItem(icon: Icon(Icons.search_rounded), label: 'Verificar'),
    BottomNavigationBarItem(icon: Icon(Icons.book_online), label: 'Fuentes'),
    BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Perfil'),
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
            tooltip: 'Notificaciones',
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        items: _navItems,
      ),
    );
  }
}