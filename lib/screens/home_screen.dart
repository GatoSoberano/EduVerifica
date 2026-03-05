import 'package:flutter/material.dart';
import 'education_screen.dart';
import 'glossary_screen.dart';
import 'simulator_screen.dart';
import 'profile_screen.dart';
import 'news_feed_screen.dart';
import 'verify_screen.dart'; // <-- Este import debe estar
import '../screens/verified_sources_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const EducationScreen(),
    const NewsFeedScreen(),
    const GlossaryScreen(), //stas son las pantallas
    const SimulatorScreen(),
    const VerifyScreen(), 
    const VerifiedSourcesScreen(),
    const ProfileScreen(),
  ];

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.menu_book_rounded),
      label: 'Aprende',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.feed_rounded),
      label: 'Noticias',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.library_books_rounded),
      label: 'Glosario',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.quiz_rounded),
      label: 'Simulador',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.search_rounded),
      label: 'Verificar',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.book_online),
      label: 'Fuentes',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_rounded),
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
              // TODO: Implementar notificaciones (puedes ignorar este warning)
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