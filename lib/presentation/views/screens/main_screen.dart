import 'package:flutter/material.dart';
import '../components/glass_bottom_bar.dart';
import 'home_screen.dart';
import 'product_screen.dart';
import 'employee_screen.dart';
import 'talhao_screen.dart';
import 'harvest_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ProductScreen(),
    const EmployeeScreen(),
    const TalhaoScreen(),
    const HarvestScreen(),
    const SettingsScreen(),
    // Adicionar mais telas quando necessário
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens.isNotEmpty ? _screens[_currentIndex] : Container(),
      bottomNavigationBar: GlassBottomBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        floatingActionButton: null,
      ),
    );
  }
}
