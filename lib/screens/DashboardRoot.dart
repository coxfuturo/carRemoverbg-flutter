import 'package:flutter/material.dart';
import 'home_page.dart';
import 'profile_page.dart';

class DashboardRoot extends StatefulWidget {
  const DashboardRoot({super.key});

  @override
  State<DashboardRoot> createState() => _DashboardRootState();
}

class _DashboardRootState extends State<DashboardRoot> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    MyHomePage(),     // index 0
    ProfileScreen(),  // index 1
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),

      /// BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // ✅ important
        backgroundColor: const Color(0xFF07121E),
        selectedItemColor: const Color(0xFF29B6F6),
        unselectedItemColor: Colors.white54,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,


        onTap: (index) {
          setState(() {
            _currentIndex = index; // ✅ change page
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.photo),
            label: "My Cars",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }

}

