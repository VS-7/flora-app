// lib/presentation/views/screens/main_screen.dart
import 'package:flutter/material.dart';
import 'activity_form_screen.dart';
import 'payment_form_screen.dart';
import 'user_registration_screen.dart';
import 'home_screen.dart';
import '../components/glass_bottom_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    ActivityFormScreen(selectedDate: DateTime.now()),
    PaymentFormScreen(selectedDate: DateTime.now()),
    const UserRegistrationScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: GlassBottomBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        floatingActionButton:
            null, // O FloatingActionButton já está definido acima
      ),
    );
  }
}
