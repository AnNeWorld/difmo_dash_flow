import 'package:flutter/material.dart';
import 'package:dashflow/core/api/api_service.dart';
import 'package:dashflow/company/services/api_service.dart' as company_api;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:dashflow/features/activities/pages/attendance_history_page.dart';
import 'package:dashflow/company/components/shared/app_drawer.dart';

class AttendanceManagementScreen extends StatefulWidget {
  const AttendanceManagementScreen({super.key});

  @override
  State<AttendanceManagementScreen> createState() =>
      _AttendanceManagementScreenState();
}

class _AttendanceManagementScreenState
    extends State<AttendanceManagementScreen> {
  bool _isLoading = true;
  List<dynamic> _employees = [];
  List<Map<String, dynamic>> _attendanceDataList = [];
  List<Map<String, dynamic>> _filteredDataList = [];
  Map<String, String> _idToName = {};

  int _totalEmployees = 0;
  int _presentCount = 0;
  int _absentCount = 0;
  int _lateCount = 0;

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final Map<String, String> idToName = {};
      List<dynamic> fetchedEmployees = [];

      try {
        final prefs = await SharedPreferences.getInstance();
        final userStr = prefs.getString('user');
        String companyId = '';
        if (userStr != null) {
          final u = jsonDecode(userStr);
          companyId =
              u['companyId']?.toString() ??
              u['company']?['_id']?.toString() ??
              u['company']?.toString() ??
              '';
        }

        try {
          final usersList = await company_api.ApiService().getAllUsers();
          for (var u in usersList) {
            final f = u['firstName']?.toString() ?? '';
            final l = u['lastName']?.toString() ?? '';
            final name = '$f $l'.trim();
            if (name.isNotEmpty) {
              for (final id in [u['_id']?.toString(), u['id']?.toString()]) {
                if (id != null && id.isNotEmpty) idToName[id] = name;
              }
            }
          }
        } catch (_) {}

        try {
          final empList = await company_api.ApiService().getAllEmployees(
            companyId: companyId.isNotEmpty ? companyId : null,
          );
          fetchedEmployees.addAll(empList);
          for (var e in empList) {
            final f = e['firstName']?.toString() ?? '';
            final l = e['lastName']?.toString() ?? '';
            final name = '$f $l'.trim();
            if (name.isNotEmpty) {
              final ids = <String>[];
              if (e['_id'] != null) ids.add(e['_id'].toString());
              if (e['id'] != null) ids.add(e['id'].toString());
              final uRef = e['userId'] ?? e['user'];
              if (uRef is Map) {
                final uid = uRef['_id']?.toString() ?? uRef['id']?.toString();
                if (uid != null && uid.isNotEmpty) ids.add(uid);
              } else if (uRef is String && uRef.isNotEmpty)
                ids.add(uRef);
              for (final id in ids) idToName[id] = name;
            }
          }
        } catch (_) {}

        try {
          final savedEmpListStr =
              prefs.getString('local_mock_employees') ?? '[]';
          final List<dynamic> savedEmpList = jsonDecode(savedEmpListStr);
          fetchedEmployees.addAll(savedEmpList);
          for (var e in savedEmpList) {
            final f = e['firstName']?.toString() ?? '';
            final l = e['lastName']?.toString() ?? '';
            final name = '$f $l'.trim();
            if (name.isNotEmpty) {
              final ids = <String>[];
              if (e['_id'] != null) ids.add(e['_id'].toString());
              if (e['id'] != null) ids.add(e['id'].toString());
              for (final id in ids) idToName[id] = name;
            }
          }
          if (userStr != null) {
            final cu = jsonDecode(userStr);
            final fName = cu['firstName']?.toString() ?? '';
            final lName = cu['lastName']?.toString() ?? '';
            final name = '$fName $lName'.trim();
            if (name.isNotEmpty) {
              final cuIds = [
                cu['_id']?.toString(),
                cu['id']?.toString(),
              ].where((id) => id != null && id.isNotEmpty).cast<String>();
              for (final id in cuIds) {
                idToName[id] = name;
              }
            }
          }
        } catch (_) {}
      } catch (_) {}

      if (mounted) setState(() => _idToName = idToName);

      List<dynamic> employees = fetchedEmployees;
      try {
        final coreEmployees = await ApiService.getEmployees();
        for (var e in coreEmployees) {
          final id1 = e['id']?.toString() ?? e['_id']?.toString();
          bool exists = false;
          if (id1 != null && id1.isNotEmpty) {
            exists = employees.any((item) {
              final id2 = item['id']?.toString() ?? item['_id']?.toString();
              return id1 == id2;
            });
          }
          if (!exists) {
            employees.add(e);
          }
        }
      } catch (_) {}

      if (employees.isEmpty) {
        try {
          final prefs = await SharedPreferences.getInstance();
          final userStr = prefs.getString('user');
          if (userStr != null) {
            final userObj = jsonDecode(userStr);
            userObj['_id'] ??= userObj['id'] ?? 'self-user';
            employees.add(userObj);
          }
        } catch (_) {}
      }

      List<Map<String, dynamic>> combinedList = [];
      int present = 0;
      int absent = 0;
      int lateCount = 0;

      final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      List<dynamic> companyAttendance = [];
      try {
        companyAttendance = await ApiService.getAllCompanyAttendance(
          startDate: todayStr,
          endDate: todayStr,
        );
      } catch (e) {
        debugPrint("Error fetching company attendance: $e");
      }

      Map<String, dynamic> attendanceMap = {};
      for (var att in companyAttendance) {
        if (att is Map<String, dynamic>) {
          final empId =
              att['employeeId']?.toString() ??
              att['employee']?['id']?.toString() ??
              att['employee']?['_id']?.toString();
          if (empId != null) {
            attendanceMap[empId] = att;

            // If this employee is not in the employees list, add them!
            bool exists = employees.any((e) {
              return (e['id']?.toString() ?? e['_id']?.toString()) == empId;
            });
            if (!exists && att['employee'] != null) {
              employees.add(att['employee']);
            }
          }
        }
      }

      for (var emp in employees) {
        final empId = emp['id']?.toString() ?? emp['_id']?.toString() ?? '';
        if (empId.isEmpty) continue;

        final att = attendanceMap[empId];
        String status = 'Absent';

        if (att != null) {
          status = att['status']?.toString() ?? 'Absent';
          // Normalize status
          if (status.toLowerCase() == 'checked-in' ||
              status.toLowerCase() == 'active' ||
              status.toLowerCase() == 'checked-out' ||
              status.toLowerCase() == 'present' ||
              status.toLowerCase() == 'completed') {
            status = 'Present';
          }
        }

        if (status.toLowerCase() == 'present') {
          if (att != null &&
              (att['isLate'] == true ||
                  att['status']?.toString().toLowerCase() == 'late')) {
            lateCount++;
            status = 'Late';
          } else {
            present++;
          }
        } else {
          absent++;
        }

        Map<String, dynamic> employeeData = emp;
        if (att != null && att['employee'] is Map) {
          employeeData = att['employee'];
        }

        combinedList.add({
          'employee': employeeData,
          'attendance': att,
          'status': status,
        });
      }

      if (mounted) {
        setState(() {
          _employees = employees;
          _attendanceDataList = combinedList;
          _filteredDataList = combinedList;
          _totalEmployees = employees.length;
          _presentCount = present;
          _absentCount = absent;
          _lateCount = lateCount;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading attendance: $e')));
      }
    }
  }

  void _filterEmployees(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredDataList = _attendanceDataList;
      });
    } else {
      setState(() {
        _filteredDataList = _attendanceDataList.where((data) {
          final emp = data['employee'];
          String name = "${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}"
              .trim();
          if (name.isEmpty) name = emp['name']?.toString() ?? '';
          if (name.isEmpty) {
            final eId = emp['_id']?.toString() ?? emp['id']?.toString() ?? '';
            name = _idToName[eId] ?? '';
          }
          return name.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    }
  }

  Future<void> _adminAction(
    Map<String, dynamic> emp,
    dynamic att,
    String currentStatus,
  ) async {
    final empId = emp['id']?.toString() ?? emp['_id']?.toString() ?? '';
    if (empId.isEmpty) return;

    bool isCheckedIn =
        att != null &&
        (att['checkIn'] != null ||
            att['checkInTime'] != null ||
            att['inTime'] != null ||
            att['clockIn'] != null);
    bool isCheckedOut =
        att != null &&
        (att['checkOut'] != null ||
            att['checkOutTime'] != null ||
            att['outTime'] != null ||
            att['clockOut'] != null);
    bool canCheckIn = !isCheckedIn;
    bool canCheckOut = isCheckedIn && !isCheckedOut;

    if (!canCheckIn && !canCheckOut) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Employee has already completed their attendance for today.',
          ),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (canCheckIn) {
        await ApiService.checkIn(empId, 0.0, 0.0, 'Office', 'Admin Check-In');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Checked In Successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (canCheckOut) {
        final attendanceId =
            att['id']?.toString() ?? att['_id']?.toString() ?? '';
        if (attendanceId.isNotEmpty) {
          await ApiService.checkOut(attendanceId, 0.0, 0.0, 'Admin Check-Out');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Checked Out Successfully!'),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: No Attendance ID found.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      await _fetchData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),
      drawer: const AppDrawer(activeRoute: 'Attendance'),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text("Attendance Management"),
        backgroundColor: const Color(0xff1D4ED8),
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildStatsRow(),
                    const SizedBox(height: 16),
                    _buildSearchBar(),
                    const SizedBox(height: 16),
                    ..._filteredDataList
                        .map((data) => _buildEmployeeCard(data))
                        .toList(),
                    if (_filteredDataList.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          "No employees found",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatsRow() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                "Total Employees",
                _totalEmployees.toString(),
                Icons.people_alt_outlined,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                "Present Today",
                _presentCount.toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _statCard(
                "Absent Today",
                _absentCount.toString(),
                Icons.cancel_outlined,
                Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                "Late Today",
                _lateCount.toString(),
                Icons.access_time_outlined,
                Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  count,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterEmployees,
        decoration: const InputDecoration(
          icon: Icon(Icons.search, color: Colors.grey),
          hintText: "Search Employee...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(Map<String, dynamic> data) {
    final emp = data['employee'];
    final att = data['attendance'];
    final status = data['status'];

    String name = "${emp['firstName'] ?? ''} ${emp['lastName'] ?? ''}".trim();
    if (name.isEmpty) name = emp['name']?.toString() ?? '';

    // Prioritize 'user' map if it exists
    final userMap = emp['user'] is Map ? emp['user'] : null;
    if (name.isEmpty && userMap != null) {
      final f = userMap['firstName']?.toString() ?? '';
      final l = userMap['lastName']?.toString() ?? '';
      name = '$f $l'.trim();
      if (name.isEmpty) name = userMap['name']?.toString() ?? '';
    }

    // Check nested employee map just in case
    if (name.isEmpty && emp['employee'] is Map) {
      final eMap = emp['employee'];
      final f = eMap['firstName']?.toString() ?? '';
      final l = eMap['lastName']?.toString() ?? '';
      name = '$f $l'.trim();
      if (name.isEmpty && eMap['user'] is Map) {
        final uMap = eMap['user'];
        final uf = uMap['firstName']?.toString() ?? '';
        final ul = uMap['lastName']?.toString() ?? '';
        name = '$uf $ul'.trim();
      }
    }

    // Fallback: look up by employee/user ID in our users map
    if (name.isEmpty) {
      final eId = emp['_id']?.toString() ?? emp['id']?.toString() ?? '';
      final uId = (emp['userId'] is String) ? emp['userId'] : '';
      name = _idToName[eId] ?? _idToName[uId] ?? 'Unknown Employee';
    }

    String designation = 'Employee';
    if (emp['designation'] is String) {
      designation = emp['designation'];
    } else if (emp['designation'] is Map) {
      designation = emp['designation']['name']?.toString() ?? 'Employee';
    }

    String checkIn = '--:--';
    String checkOut = '--:--';

    String dateStr = 'Today';
    if (att != null) {
      String? attDate = att['date'] ?? att['createdAt'];
      if (attDate != null) {
        try {
          dateStr = DateFormat(
            'MMM dd, yyyy',
          ).format(DateTime.parse(attDate).toLocal());
        } catch (_) {}
      }

      String? inStr =
          att['checkIn'] ??
          att['checkInTime'] ??
          att['inTime'] ??
          att['clockIn'] ??
          att['createdAt'];
      if (inStr != null) {
        try {
          if (inStr.contains('T')) {
            checkIn = DateFormat(
              'hh:mm a',
            ).format(DateTime.parse(inStr).toLocal());
          } else if (attDate != null) {
            final datePart = attDate.contains('T')
                ? attDate.split('T')[0]
                : attDate;
            checkIn = DateFormat(
              'hh:mm a',
            ).format(DateTime.parse("${datePart}T$inStr").toLocal());
          } else {
            checkIn = inStr;
          }
        } catch (_) {
          if (inStr.length < 15) checkIn = inStr;
        }
      }

      String? outStr =
          att['checkOut'] ??
          att['checkOutTime'] ??
          att['outTime'] ??
          att['clockOut'];
      if (outStr != null) {
        try {
          if (outStr.contains('T')) {
            checkOut = DateFormat(
              'hh:mm a',
            ).format(DateTime.parse(outStr).toLocal());
          } else if (attDate != null) {
            final datePart = attDate.contains('T')
                ? attDate.split('T')[0]
                : attDate;
            checkOut = DateFormat(
              'hh:mm a',
            ).format(DateTime.parse("${datePart}T$outStr").toLocal());
          } else {
            checkOut = outStr;
          }
        } catch (_) {
          if (outStr.length < 15) checkOut = outStr;
        }
      }
    }

    Color statusColor = Colors.grey;
    Color statusBg = Colors.grey.withOpacity(0.1);
    if (status == 'Present') {
      statusColor = Colors.green;
      statusBg = Colors.green.withOpacity(0.1);
    } else if (status == 'Absent') {
      statusColor = Colors.red;
      statusBg = Colors.red.withOpacity(0.1);
    } else if (status == 'Late') {
      statusColor = Colors.orange;
      statusBg = Colors.orange.withOpacity(0.1);
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AttendanceHistoryPage(
              employeeId: emp['id']?.toString() ?? emp['_id']?.toString() ?? '',
              userName: name,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xff1D4ED8).withOpacity(0.1),
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      color: Color(0xff1D4ED8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (emp['customId'] != null || emp['employeeId'] != null)
                        Text(
                          (emp['customId'] ?? emp['employeeId']).toString(),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            dateStr,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTimeCol("Check In", checkIn, Icons.login, Colors.green),
                _buildTimeCol(
                  "Check Out",
                  checkOut,
                  Icons.logout,
                  Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _adminAction(emp, att, status),
                icon: Icon(
                  (att != null &&
                          (att['checkIn'] != null ||
                              att['checkInTime'] != null ||
                              att['inTime'] != null ||
                              att['clockIn'] != null) &&
                          (att['checkOut'] == null &&
                              att['checkOutTime'] == null &&
                              att['outTime'] == null &&
                              att['clockOut'] == null))
                      ? Icons.logout
                      : Icons.login,
                  size: 16,
                ),
                label: Text(
                  (att != null &&
                          (att['checkIn'] != null ||
                              att['checkInTime'] != null ||
                              att['inTime'] != null ||
                              att['clockIn'] != null) &&
                          (att['checkOut'] == null &&
                              att['checkOutTime'] == null &&
                              att['outTime'] == null &&
                              att['clockOut'] == null))
                      ? 'Admin Check Out'
                      : 'Admin Check In',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff1D4ED8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCol(String label, String time, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }
}
