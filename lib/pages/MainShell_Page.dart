import 'package:flutter/material.dart';
import 'home_page.dart';
import 'register_page.dart';
import 'others_page.dart';
import 'suchana_page.dart';
import 'karyakram_page.dart'; // ✅ create this file

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int currentIndex = 0;

  // ✅ Use IndexedStack to preserve page state
  final List<Widget> pages = [
    HomePage(),
    const SuchanaPage(),
    const RegisterPage(),
    const KaryakramPage(),
    const OthersPage(),
  ];

  void onTap(int index) {
    if (currentIndex == index) return; // ✅ avoid unnecessary rebuild
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ✅ Keeps page state alive
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,

        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,

        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.campaign), // better icon
            label: "Suchana",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 28),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.event_available), // better icon
            label: "Karyakram",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu),
            label: "Aru",
          ),
        ],
      ),
    );
  }
}