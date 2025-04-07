import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AttendanceCard extends StatefulWidget {
  final double latitude;
  final double longitude;
  const AttendanceCard(
      {super.key, required this.latitude, required this.longitude});

  @override
  _AttendanceCardState createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<AttendanceCard> {
  String checkInTime = "--:--";
  String checkOutTime = "--:--";
  String workHours = "0h 0m";
  Timer? timer;
  DateTime? startTime;
  bool isCheckedIn = false;

  void _checkIn() async {
    if (isCheckedIn) return;
    setState(() {
      startTime = DateTime.now();
      checkInTime =
          "${startTime!.hour}:${startTime!.minute.toString().padLeft(2, '0')}";
      isCheckedIn = true;
    });

    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      final now = DateTime.now();
      final duration = now.difference(startTime!);
      setState(() {
        workHours = "${duration.inHours}h ${duration.inMinutes.remainder(60)}m";
      });
    });

    final url = Uri.parse(
        'https://9guqhw473j.execute-api.ap-south-2.amazonaws.com/clockin_production/clockin');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: jsonEncode({
        "user": "veleswaran",
        "latitude": widget.latitude,
        "longitude": widget.longitude,
        "clockin_status": false,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Check-in successful!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Check-in failed!")),
      );
    }
  }

  void _checkOut() async {
    if (!isCheckedIn || startTime == null) return;

    setState(() {
      timer?.cancel();
      final endTime = DateTime.now();
      checkOutTime =
          "${endTime.hour}:${endTime.minute.toString().padLeft(2, '0')}";
      isCheckedIn = false;
      startTime = null;
    });
    final url = Uri.parse(
        'https://9guqhw473j.execute-api.ap-south-2.amazonaws.com/clockin_production/clockin');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: jsonEncode({
        "user": "veleswaran",
        "latitude": widget.latitude,
        "longitude": widget.longitude,
        "clockin_status": true,
        "timestamp": DateTime.now().millisecondsSinceEpoch,
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Check-out successful!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Check-out failed!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Today's Status",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  isCheckedIn ? "🟢 Checked In" : "🔴 Checked Out",
                  style:
                      TextStyle(color: isCheckedIn ? Colors.green : Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Check In",
                        style: TextStyle(color: Colors.grey)),
                    Text(
                      checkInTime,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Check Out",
                        style: TextStyle(color: Colors.grey)),
                    Text(
                      checkOutTime,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Work Hours",
                        style: TextStyle(color: Colors.grey)),
                    Text(
                      workHours,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isCheckedIn ? Colors.grey : Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isCheckedIn ? null : _checkIn,
                    child: const Text(
                      "🕒 Check In",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isCheckedIn ? Colors.red : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isCheckedIn ? _checkOut : null,
                    child: const Text(
                      "🚪 Check Out",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
