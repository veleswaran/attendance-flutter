import 'package:attendance/home.dart';
import 'package:attendance/reports.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

List<Map<String, dynamic>> recentActivities = [
  {"date": "Yesterday", "time": "09:00 AM - 06:00 PM", "status": "Present", "color": Colors.green, "emoji": "🟢"},
  {"date": "Jan 15, 2025", "time": "09:00 AM - 06:00 PM", "status": "Late", "color": Colors.orange, "emoji": "🟠"},
  {"date": "Yesterday", "time": "09:00 AM - 06:00 PM", "status": "Present", "color": Colors.green, "emoji": "🟢"},
  {"date": "Jan 15, 2025", "time": "09:00 AM - 06:00 PM", "status": "Late", "color": Colors.orange, "emoji": "🟠"},
];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double latitude = 0.0;
  double longitude = 0.0;
   void updateLocation(double lat, double lon) {
    setState(() {
      latitude = lat;
      longitude = lon;
    });
  }
  int _selectedIndex = 0;

  // Screens for each tab
  static const List<Widget> _screens = [
    Center(child: Home()),
    Center(child: Text('Calendar')),
    Center(child: Report()),
    Center(child: Text('Person')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Padding(
          padding: EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundImage: AssetImage('user.jpeg'),
          ),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome, Veleswaran",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            Text("Full Stack Developer, Engineer",
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        actions: const [
          Icon(Icons.notifications, color: Colors.black),
          SizedBox(width: 10),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: "Home"),
          NavigationDestination(
              icon: Icon(Icons.calendar_month), label: "Calendar"),
          NavigationDestination(icon: Icon(Icons.list), label: "Reports"),
          NavigationDestination(icon: Icon(Icons.person), label: "Person"),
        ],
      ),
    );
  }
}