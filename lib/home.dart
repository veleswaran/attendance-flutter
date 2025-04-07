import 'package:attendance/attendance_card.dart';
import 'package:attendance/google_map_flutter.dart';
import 'package:flutter/material.dart';

List<Map<String, dynamic>> recentActivities = [
  {
    "date": "Yesterday",
    "time": "09:00 AM - 06:00 PM",
    "status": "Present",
    "color": Colors.green,
    "emoji": "🟢"
  },
  {
    "date": "Jan 15, 2025",
    "time": "09:00 AM - 06:00 PM",
    "status": "Late",
    "color": Colors.orange,
    "emoji": "🟠"
  },
  {
    "date": "Yesterday",
    "time": "09:00 AM - 06:00 PM",
    "status": "Present",
    "color": Colors.green,
    "emoji": "🟢"
  },
  {
    "date": "Jan 15, 2025",
    "time": "09:00 AM - 06:00 PM",
    "status": "Late",
    "color": Colors.orange,
    "emoji": "🟠"
  },
];

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Home> {
  double latitude = 0.0;
  double longitude = 0.0;
  void updateLocation(double lat, double lon) {
    setState(() {
      latitude = lat;
      longitude = lon;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AttendanceCard(latitude: latitude, longitude: longitude),
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Location Status",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child:SizedBox(
                        height: 150, 
                        child: GoogleMapFlutter(onLocationFetched: updateLocation), 
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text("📍 Within Zone",
                        style: TextStyle(color: Colors.green)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
           
            const SizedBox(height: 16),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Recent Activity",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),

                    // Using map() to generate ListTile items dynamically
                    Column(
                      children: recentActivities.map((activity) {
                        return ListTile(
                          leading: Icon(Icons.circle,
                              color: activity["color"], size: 10),
                          title: Text(activity["date"]),
                          subtitle: Text(activity["time"]),
                          trailing: Text(
                              "${activity["emoji"]} ${activity["status"]}",
                              style: TextStyle(color: activity["color"])),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),      
    );
  }
}
