import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Attendance Page',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AttendancePage(),
    );
  }
}

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String _employeeName = "Loading...";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user') ?? prefs.getString('user_profile');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        final firstName = user['firstName']?.toString() ?? '';
        final lastName = user['lastName']?.toString() ?? '';
        
        String name = "Employee";
        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          name = '$firstName $lastName'.trim();
        } else if (user['name'] != null) {
          name = user['name'].toString();
        }
        
        if (mounted) {
          setState(() {
            _employeeName = name;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _employeeName = "Employee";
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _employeeName = "Employee";
        });
      }
    }
  }

  final List<Map<String, dynamic>> attendanceList = const [
    {
      'date': '21 May 2026',
      'status': 'Present',
      'checkIn': '09:00 AM',
      'checkOut': '05:00 PM',
      'color': Colors.green,
    },
    {
      'date': '20 May 2026',
      'status': 'Absent',
      'checkIn': '--',
      'checkOut': '--',
      'color': Colors.red,
    },
    {
      'date': '19 May 2026',
      'status': 'Present',
      'checkIn': '09:15 AM',
      'checkOut': '05:10 PM',
      'color': Colors.green,
    },
    {
      'date': '18 May 2026',
      'status': 'Late',
      'checkIn': '10:05 AM',
      'checkOut': '05:00 PM',
      'color': Colors.orange,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Attendance'),
        centerTitle: true,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Attendance Summary',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Employee Name: $_employeeName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Present: 22 Days',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const Text(
                    'Absent: 2 Days',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            
            Expanded(
              child: ListView.builder(
                itemCount: attendanceList.length,
                itemBuilder: (context, index) {

                  final attendance = attendanceList[index];

                  return Card(
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),

                      leading: CircleAvatar(
                        backgroundColor: attendance['color'],
                        child: Icon(
                          attendance['status'] == 'Present'
                              ? Icons.check
                              : attendance['status'] == 'Absent'
                              ? Icons.close
                              : Icons.access_time,
                          color: Colors.white,
                        ),
                      ),

                      title: Text(
                        attendance['date'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 5),
                          Text('Status: ${attendance['status']}'),
                          Text('Check In: ${attendance['checkIn']}'),
                          Text('Check Out: ${attendance['checkOut']}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

    );
  }
}