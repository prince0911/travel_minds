import 'package:flutter/material.dart';
import 'package:travel_minds/features/dashboard/screens/explore_screen.dart';
import 'package:travel_minds/features/dashboard/screens/home_screen.dart';
import 'package:travel_minds/features/personalization/screens/profile_screen.dart';

class BottomNavigationScreen extends StatefulWidget {
  final int selectedIndex;// Accept initial index

  const BottomNavigationScreen({super.key, this.selectedIndex = 0,});

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigationScreen> {
  late int currentindex; // Use `late` to initialize in `initState`
  late List<Widget> screen;

  void onTap(int index) {
    setState(() {
      currentindex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    currentindex = widget.selectedIndex; // Set initial tab index
    screen = [
      HomeScreen(),
      ExploreScreen(),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screen[currentindex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: false,
        onTap: onTap,
        currentIndex: currentindex,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.travel_explore_rounded), label: "Explore"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
