import 'package:dashflow/features/task/task_page.dart';
import 'package:flutter/material.dart';
import 'package:dashflow/features/dashboard/pages/home_page_locations.dart';
import 'package:iconsax/iconsax.dart';
import 'package:dashflow/core/api/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:dashflow/features/auth/pages/login_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dashflow/features/activities/pages/location_page.dart';

import 'package:dashflow/features/employees/pages/employees_list_screen.dart';
import 'package:dashflow/features/payslip/pages/payslip_list_screen.dart';
import 'package:dashflow/features/leaves/pages/leaves_screen.dart';
import 'package:dashflow/features/activities/pages/attendance_history_page.dart';
import 'dart:math' as math;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  void showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  bool isPopUpVisible = false;
  String attendanceStatus = "Clock-In"; // Clock-In or Clock-Out
  String? attendanceId;
  String? employeeId;
  bool isLoading = true;

  // User Data
  String userName = "Loading...";
  String userRole = "Employee";
  String userEmail = "";
  // sdfsd
  // Time Info
  String clockInTime = "--:--";
  String clockOutTime = "--:--";
  String workingHours = "--h --m";
  String currentDate = "";
  String currentTime = "";

  DateTime? checkInDateTime;
  DateTime? checkOutDateTime;

  // Activity History
  List<dynamic> activityHistory = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _updateDateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateDateTime();
    });
    _fetchAttendanceStatus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateDateTime() {
    final now = DateTime.now();
    if (mounted) {
      setState(() {
        currentDate = DateFormat('EEEE, dd MMMM').format(now);
        currentTime = DateFormat('hh:mm:ss a').format(now);

        if (attendanceStatus == "Clock-Out" && checkInDateTime != null) {
          final duration = now.difference(checkInDateTime!);
          final hours = duration.inHours;
          final minutes = duration.inMinutes.remainder(60);
          workingHours = "${hours}h ${minutes}m (Live)";
        }
      });
    }
  }

  DateTime? _parseUtcTime(String? dateStr, String? timeStr) {
    // debugPrint("Parsing time: date=$dateStr, time=$timeStr");
    if (dateStr == null || timeStr == null) return null;
    try {
      // Ensure date is YYYY-MM-DD
      final datePart = dateStr.contains('T') ? dateStr.split('T')[0] : dateStr;
      // Construct ISO string (Treat as local)
      final isoStr = "${datePart}T$timeStr";
      final dt = DateTime.parse(isoStr);
      // debugPrint("Parsed $isoStr to $dt");
      return dt;
    } catch (e) {
      debugPrint("Error parsing time: $e");
      return null;
    }
  }

  Future<void> _fetchAttendanceStatus() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        final userId = user['id'];

        if (mounted) {
          setState(() {
            employeeId = userId; // Setting it directly from user data
            userName = _capitalize(
              "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim(),
            );
            if (userName.isEmpty) userName = "User";
            userEmail = user['email'] ?? '';
            if (user['roles'] != null) {
              if (user['roles'] is List && user['roles'].isNotEmpty) {
                final firstRole = user['roles'][0];
                if (firstRole is Map) {
                  userRole = _capitalize(firstRole['name'] ?? "Employee");
                } else {
                  userRole = _capitalize(firstRole.toString());
                }
              } else if (user['roles'] is String) {
                userRole = _capitalize(user['roles']);
              }
            }
          });
        }

        // Get today's attendance using the assigned employeeId
        if (employeeId != null) {
          final attendance = await ApiService.getTodayAttendance(employeeId!);
          debugPrint("RAW ATTENDANCE DATA: $attendance"); // DEBUG LOG

          if (attendance != null) {
            String? date = attendance['date'];
            String? checkInStr = attendance['checkInTime'];
            String? checkOutStr = attendance['checkOutTime'];

            debugPrint("ID: ${attendance['id']}"); // DEBUG LOG
            debugPrint(
              "Date: $date, CheckIn: $checkInStr, CheckOut: $checkOutStr",
            ); // DEBUG LOG

            DateTime? checkIn = _parseUtcTime(date, checkInStr);
            DateTime? checkOut = _parseUtcTime(date, checkOutStr);

            if (mounted) {
              setState(() {
                checkInDateTime = checkIn;
                checkOutDateTime = checkOut;

                if (checkIn != null) {
                  clockInTime = DateFormat('hh:mm a').format(checkIn);
                }
                if (checkOut != null) {
                  clockOutTime = DateFormat('hh:mm a').format(checkOut);
                  attendanceStatus = "Completed";

                  // Calculate working hours
                  final duration = checkOut.difference(checkIn!);
                  final hours = duration.inHours;
                  final minutes = duration.inMinutes.remainder(60);
                  workingHours = "${hours}h ${minutes}m";
                } else {
                  attendanceStatus = "Clock-Out";
                  attendanceId = attendance['id'];
                  debugPrint("Set attendanceId to $attendanceId"); // DEBUG LOG
                }
              });
            }
          } else {
            if (mounted) {
              setState(() {
                checkInDateTime = null;
                checkOutDateTime = null;
                attendanceStatus = "Clock-In";
                clockInTime = "--:--";
                clockOutTime = "--:--";
                workingHours = "--h --m";
              });
            }
          }

          // Get Activity History
          final history = await ApiService.getAttendanceHistory(employeeId!);
          if (mounted) {
            setState(() {
              activityHistory = history;
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error fetching attendance: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _doLogout() async {
    debugPrint("User logging out..."); // Debug log
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    debugPrint("SharedPreferences cleared.");
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.logout,
                  color: Colors.red.shade400,
                  size: 32,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Logout?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Are you sure you want to logout\nfrom your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 26),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.5,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'No',
                        style: TextStyle(
                          color: Color(0xFF1F2937),
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Yes, Logout',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true) await _doLogout();
  }

  void _handleAttendanceClick() async {
    if (employeeId == null) {
      showSnack("Please wait while we load your profile...");
      return;
    }

    if (attendanceStatus == "Completed") {
      showSnack("Attendance already completed for today");
      return;
    }

    if (attendanceStatus == "Clock-Out") {
      // Show confirmation dialog before checking out
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              "End Work Day?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF36617E),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Are you sure you want to checkout?\n\nYou won't be able to check in again today.",
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 15),
                Text(
                  "Working Time: $workingHours",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  "Cancel",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF36617E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Check Out",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );

      if (confirm != true) {
        return;
      }
    }

    // Set loading so user can't tap it multiple times while location permissions load
    setState(() {
      isLoading = true;
    });

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      // Directly navigate
      if (!mounted) return;
      String preStatus = attendanceStatus;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LocationConfirmPage(
            isCheckIn: attendanceStatus == "Clock-In",
            employeeId: employeeId,
            attendanceId: attendanceId,
          ),
        ),
      );
      // fetch status when we return
      await _fetchAttendanceStatus();

      // Show celebration if just checked out
      if (preStatus == "Clock-Out" &&
          attendanceStatus == "Completed" &&
          mounted) {
        showSnack("🎉 Workday completed. Total Working Time: $workingHours");
      }
    } else {
      if (mounted) {
        setState(() {
          isLoading = false; // Reset loading so they can interact again
          isPopUpVisible = true;
        });
      }
    }
  }

  Widget _buildAttendanceButton() {
    String btnText = "Check In";
    IconData btnIcon = Icons.location_on;
    Color iconColor = const Color(0xFF36617E);
    String subText = "Tap to start your work day";

    if (isLoading) {
      btnText = "Loading...";
      subText = "Please wait";
    } else if (attendanceStatus == "Clock-Out") {
      btnText = "Check Out";
      btnIcon = Icons.stop_circle_outlined;
      iconColor = Colors.orange.shade800;
      subText = "End your work day";
    } else if (attendanceStatus == "Completed") {
      btnText = "Work Completed";
      btnIcon = Icons.check_circle_outline;
      iconColor = Colors.green;
      subText = "You've checked out for today";
    }

    return GestureDetector(
      onTap: isLoading || attendanceStatus == "Completed"
          ? null
          : _handleAttendanceClick,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Opacity(
          opacity: (isLoading || attendanceStatus == "Completed") ? 0.6 : 1.0,
          child: Column(
            children: [
              if (isLoading)
                const SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    color: Color(0xFF36617E),
                    strokeWidth: 3,
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(btnIcon, color: iconColor, size: 30),
                    const SizedBox(width: 10),
                    Text(
                      btnText,
                      style: TextStyle(
                        color: iconColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              if (!isLoading) const SizedBox(height: 8),
              if (!isLoading)
                Text(
                  subText,
                  style: TextStyle(
                    color: Colors.grey.shade500, 
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    double hoursWorked = 0;
    if (checkInDateTime != null) {
      final now = attendanceStatus == "Completed" && checkOutDateTime != null
          ? checkOutDateTime!
          : DateTime.now();
      final duration = now.difference(checkInDateTime!);
      hoursWorked = math.max(0, duration.inMinutes / 60.0);
    }

    double progress = (hoursWorked / 8.0).clamp(0.0, 1.0);
    int h = hoursWorked.floor();
    int m = ((hoursWorked - h) * 60).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Daily Progress",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${h}h ${m}m / 8h",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                progress >= 1.0 ? Colors.greenAccent : Colors.white,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [

                // Header Section
                Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF2A4B62),
                        Color(0xFF36617E),
                        Color(0xFF5386A4),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFF36617E).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.25,
                            ),
                            child: Text(
                              userName
                                  .split(' ')
                                  .where((w) => w.isNotEmpty)
                                  .take(2)
                                  .map((w) => w[0].toUpperCase())
                                  .join(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                userRole,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(
                              Iconsax.logout,
                              color: Colors.white,
                            ),
                            onPressed: _logout,
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),

                      // Clock Section
                      Center(
                        child: Column(
                          children: [
                            Text(
                              currentTime,
                              style: const TextStyle(
                                fontSize: 44,
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                              ),
                            ),
                            Text(
                              currentDate,
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 20),
                            _buildAttendanceButton(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Time Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TimeInfo(title: "Clock-In", time: clockInTime),
                          TimeInfo(title: "Clock-Out", time: clockOutTime),
                          TimeInfo(title: "Working Hrs", time: workingHours),
                        ],
                      ),

                      if (checkInDateTime != null) ...[
                        const SizedBox(height: 20),
                        _buildProgressBar(),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                const SizedBox(height: 25),

                // Quick Actions
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      ActionIcon(
                        icon: Iconsax.people,
                        label: "Employees",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmployeesListScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      ActionIcon(
                        icon: Iconsax.calendar_edit,
                        label: "Leave",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LeaveScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      ActionIcon(
                        icon: Iconsax.calendar_tick,
                        label: "Attendance",
                        onTap: () {
                          if (employeeId != null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AttendanceHistoryPage(
                                  employeeId: employeeId!,
                                  userName: userName,
                                ),
                              ),
                            );
                          } else {
                            showSnack("Loading profile, please wait...");
                          }
                        },
                      ),
                      const SizedBox(width: 15),
                      ActionIcon(
                        icon: Iconsax.task_square,
                        label: "Tasks",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TaskPage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      ActionIcon(
                        icon: Iconsax.document_text,
                        label: "Payslip",
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const PayslipListScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 35), // Added space below quick actions

                // Assigned Tasks Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Assigned Tasks",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF36617E),
                            ),
                          ),
                          Text(
                            "See All",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      taskItem(
                        "Update Client Presentation",
                        "Today, 5:00 PM",
                        "Pending",
                      ),
                      taskItem(
                        "Review Monthly Reports",
                        "Tomorrow, 12:00 PM",
                        "Completed",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // Attendance History Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Attendance History",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF36617E),
                            ),
                          ),
                          Text(
                            "See All",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (activityHistory.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: const Text(
                            "No attendance history found",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      else
                        ...activityHistory.take(5).map((history) {
                          final dateStr = history['date'] ?? '';
                          String formattedDate = dateStr;
                          try {
                            final rawDate = dateStr.contains('T')
                                ? dateStr.split('T')[0]
                                : dateStr;
                            formattedDate = DateFormat(
                              'dd MMM yyyy',
                            ).format(DateTime.parse(rawDate));
                          } catch (_) {}

                          // Helper: parse time from date + time strings
                          DateTime? parseTime(String? tStr) {
                            if (tStr == null || tStr.isEmpty) return null;
                            try {
                              final d = dateStr.contains('T')
                                  ? dateStr.split('T')[0]
                                  : dateStr;
                              return DateTime.parse('${d}T$tStr');
                            } catch (_) {
                              return null;
                            }
                          }

                          final checkIn = parseTime(history['checkInTime']);
                          final checkOut = parseTime(history['checkOutTime']);

                          final checkInFmt = checkIn != null
                              ? DateFormat('hh:mm a').format(checkIn)
                              : '--:--';
                          final checkOutFmt = checkOut != null
                              ? DateFormat('hh:mm a').format(checkOut)
                              : '--:--';

                          String workHrs = '--';
                          if (checkIn != null && checkOut != null) {
                            final dur = checkOut.difference(checkIn);
                            workHrs =
                                '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';
                          }

                          final status = (history['status'] ?? 'present')
                              .toString();

                          return _buildHistoryCard(
                            formattedDate,
                            checkInFmt,
                            checkOutFmt,
                            workHrs,
                            status,
                          );
                        }),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          if (isPopUpVisible)
            Positioned.fill(
              child: Container(
                color: Colors.black.withValues(
                  alpha: 0.3,
                ), // Optional background dim
                alignment: Alignment.center,
                child: LocationPopup(
                  isCheckIn: attendanceStatus == "Clock-In",
                  employeeId: employeeId,
                  attendanceId: attendanceId,
                  onClose: () {
                    if (mounted) {
                      setState(() {
                        isPopUpVisible = false;
                      });
                    }
                    // Refresh status after popup closes (assuming check-in/out might have happened)
                    _fetchAttendanceStatus();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Dynamic attendance history card showing Check-In, Check-Out, Hours & status
  Widget _buildHistoryCard(
    String date,
    String checkIn,
    String checkOut,
    String workHrs,
    String status,
  ) {
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'present':
        statusColor = Colors.green;
        break;
      case 'absent':
        statusColor = Colors.red;
        break;
      case 'late':
        statusColor = Colors.orange;
        break;
      case 'half_day':
        statusColor = Colors.purple;
        break;
      default:
        statusColor = Colors.blue;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date row + status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF36617E).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Iconsax.calendar_1,
                      color: Color(0xFF36617E),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    date,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Check-In / Check-Out / Working Hours row
          Row(
            children: [
              _buildTimePill(
                icon: Iconsax.login,
                label: 'Check In',
                time: checkIn,
                color: Colors.green,
              ),
              const SizedBox(width: 8),
              _buildTimePill(
                icon: Iconsax.logout,
                label: 'Check Out',
                time: checkOut,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              _buildTimePill(
                icon: Iconsax.clock,
                label: 'Hours',
                time: workHrs,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePill({
    required IconData icon,
    required String label,
    required String time,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 3),
                Text(
                  label,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Capitalizes each word in a string
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map(
          (w) =>
              w.isEmpty ? w : w[0].toUpperCase() + w.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  // Task item widget
  Widget taskItem(String title, String dueDate, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF36617E).withValues(alpha: 0.1),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: const Icon(Iconsax.task_square, color: Color(0xFF36617E)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  "Due: $dueDate",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: status == "Pending"
                  ? Colors.orange.shade100
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == "Pending"
                    ? Colors.orange.shade800
                    : Colors.green.shade800,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Time Info Widget
class TimeInfo extends StatelessWidget {
  final String title, time;
  const TimeInfo({super.key, required this.title, required this.time});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          time,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(title, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}

// Action Icon Widget
class ActionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const ActionIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100, // Increased width for breathing room
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18), // Increased padding
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(icon, color: const Color(0xFF36617E), size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13, // Slightly larger text
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
