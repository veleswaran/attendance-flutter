import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Report extends StatefulWidget {
  const Report({super.key});

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  List<Map<String, dynamic>> recentActivities = [];

  // Map status to color and emoji
  Map<String, dynamic> statusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'check in':
        return {'color': Colors.green, 'emoji': '🟢'};
      case 'late':
        return {'color': Colors.orange, 'emoji': '🟠'};
      case 'check out':
        return {'color': Colors.red, 'emoji': '🔴'};
      default:
        return {'color': Colors.grey, 'emoji': '⚪'};
    }
  }

  void getReport() async {
    final url = Uri.parse(
        'https://9guqhw473j.execute-api.ap-south-2.amazonaws.com/clockin_production/clockin');
    try {
      final response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      });

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        data.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
        final List<Map<String, dynamic>> formatted = data.map((entry) {
          final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(entry['timestamp']);

          final String date = "${dateTime.day.toString().padLeft(2, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.year}";
          final String time = "${TimeOfDay.fromDateTime(dateTime).format(context)}";

          String status = entry['clockin_status'] == true ? 'Check in' : 'Check out';
          final statusData = statusStyle(status);

          return {
            'user': entry['user'],
            'date': date,
            'time': time,
            'status': status,
            'latitude': entry['latitude'],
            'longitude': entry['longitude'],
            'color': statusData['color'],
            'emoji': statusData['emoji'],
          };
        }).toList();

        setState(() {
          recentActivities = formatted;
        });
      } else {
        print("Error: ${response.statusCode}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    getReport();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Activity",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...recentActivities.map((activity) {
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.person, size: 20, color: activity["color"]),
                        const SizedBox(width: 8),
                        Text(
                          activity['user'],
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          "${activity["emoji"]} ${activity["status"]}",
                          style: TextStyle(
                              color: activity["color"],
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 6),
                        Text(activity['date']),
                        const SizedBox(width: 12),
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 6),
                        Text(activity['time']),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16),
                        const SizedBox(width: 6),
                        Text(
                            "Lat: ${activity['latitude']}, Long: ${activity['longitude']}"),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
