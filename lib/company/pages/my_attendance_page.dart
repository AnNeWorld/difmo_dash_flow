// import 'dart:convert';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:intl/intl.dart';
// import 'package:dashflow/core/api/api_service.dart';
// import 'package:geolocator/geolocator.dart';
// import '../components/shared/app_drawer.dart';
// import 'package:dashflow/features/activities/pages/location_page.dart';
// import 'package:dashflow/features/activities/pages/attendance_history_page.dart';
// class MyAttendancePage extends StatefulWidget {
//   final String? employeeId;
//   final String? employeeName;

//   const MyAttendancePage({
//     super.key,
//     this.employeeId,
//     this.employeeName,
//   });

//   @override
//   State<MyAttendancePage> createState() => _MyAttendancePageState();
// }

// class _MyAttendancePageState extends State<MyAttendancePage> {
//   late Timer _timer;
//   late String _currentTime;

//   String _employeeId = "";
//   String _employeeName = "Employee";
  
//   bool _isLoading = true;
//   bool _isActionLoading = false;
//   bool _isCheckedIn = false;
//   String? _attendanceId;
//   String? _checkInTimeStr;
//   String? _checkOutTimeStr;

//   bool _canCheckIn = true;
//   bool _canCheckOut = false;

//   int _presentCount = 0;
//   int _absentCount = 0;
//   int _lateCount = 0;
//   List<dynamic> _recentRecords = [];

//   @override
//   void initState() {
//     super.initState();
//     _currentTime = _formatTime(DateTime.now());
//     _timer = Timer.periodic(const Duration(seconds: 60), (_) {
//       setState(() => _currentTime = _formatTime(DateTime.now()));
//     });
//     _loadData();
//   }

//   @override
//   void dispose() {
//     _timer.cancel();
//     super.dispose();
//   }

//   Future<void> _loadData() async {
//     try {
//       if (widget.employeeId != null && widget.employeeId!.isNotEmpty) {
//         _employeeId = widget.employeeId!;
//         _employeeName = widget.employeeName ?? "Employee";
//       } else {
//         final prefs = await SharedPreferences.getInstance();
//         final userStr = prefs.getString('user');
//         if (userStr != null) {
//           final user = jsonDecode(userStr);
//           _employeeId = user['id']?.toString() ?? user['_id']?.toString() ?? '';
//           _employeeName = "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}".trim();
//           if (_employeeName.isEmpty) _employeeName = user['name'] ?? "Employee";
//         }
//       }
//       await _fetchAttendance();
//     } catch (e) {
//       debugPrint("Error loading user info: $e");
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _fetchAttendance() async {
//     if (_employeeId.isEmpty) {
//       if (mounted) setState(() => _isLoading = false);
//       return;
//     }
    
//     try {
//       final todayRaw = await ApiService.getTodayAttendance(_employeeId);
//       final historyRaw = await ApiService.getAttendanceHistory(_employeeId);

//       if (mounted) {
//         setState(() {
//           // Process today's attendance
//           if (todayRaw != null) {
//             String status = todayRaw['status']?.toString().toLowerCase() ?? '';
//             _isCheckedIn = (status == 'checked-in' || status == 'active');
//             bool isCompleted = (status == 'completed' || status == 'checked-out');
//             _canCheckIn = !_isCheckedIn && !isCompleted;
//             _canCheckOut = _isCheckedIn;

//             _attendanceId = todayRaw['id']?.toString() ?? todayRaw['_id']?.toString();
//             _checkInTimeStr = todayRaw['checkIn'] ?? todayRaw['createdAt'];
//             _checkOutTimeStr = todayRaw['checkOut'];
//           } else {
//             _isCheckedIn = false;
//             _canCheckIn = true;
//             _canCheckOut = false;
//             _attendanceId = null;
//             _checkInTimeStr = null;
//             _checkOutTimeStr = null;
//           }

//           // Process history
//           _recentRecords = historyRaw.take(5).toList();
          
//           _presentCount = 0;
//           _absentCount = 0;
//           _lateCount = 0;
//           for (var item in historyRaw) {
//             String s = item['status']?.toString().toLowerCase() ?? 'present';
//             bool isLate = item['isLate'] == true || s == 'late';
            
//             if (s == 'present' || s == 'checked-out' || s == 'completed') {
//               _presentCount++;
//             } else if (s == 'absent') {
//               _absentCount++;
//             }
//             if (isLate) _lateCount++;
//           }
          
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       debugPrint("Error fetching attendance: $e");
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   Future<Position> _getLocation() async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         return _fallbackPosition();
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           return _fallbackPosition();
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         return _fallbackPosition();
//       }

//       return await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
//     } catch (e) {
//       return _fallbackPosition();
//     }
//   }

//   Position _fallbackPosition() {
//     return Position(
//       longitude: 0.0,
//       latitude: 0.0,
//       timestamp: DateTime.now(),
//       accuracy: 0.0,
//       altitude: 0.0,
//       heading: 0.0,
//       speed: 0.0,
//       speedAccuracy: 0.0,
//       altitudeAccuracy: 0.0,
//       headingAccuracy: 0.0,
//     );
//   }

//   Future<void> _handleCheckIn() async {
//     if (_employeeId.isEmpty) return;
//     setState(() => _isActionLoading = true);
//     try {
//       Position position = await _getLocation();
//       await ApiService.checkIn(_employeeId, position.latitude, position.longitude, 'Office', 'Checked in from app');
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked In Successfully!'), backgroundColor: Colors.green));
//       await _fetchAttendance();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action Failed: $e'), backgroundColor: Colors.red));
//     } finally {
//       if (mounted) setState(() => _isActionLoading = false);
//     }
//   }

//   Future<void> _handleCheckOut() async {
//     if (_employeeId.isEmpty || _attendanceId == null) return;
//     setState(() => _isActionLoading = true);
//     try {
//       Position position = await _getLocation();
//       await ApiService.checkOut(_attendanceId!, position.latitude, position.longitude, 'Checked out from app');
//       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Checked Out Successfully!'), backgroundColor: Colors.orange));
//       await _fetchAttendance();
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Action Failed: $e'), backgroundColor: Colors.red));
//     } finally {
//       if (mounted) setState(() => _isActionLoading = false);
//     }
//   }

//   String _formatTime(DateTime dt) {
//     return DateFormat('hh:mm a').format(dt);
//   }

//   String _formatDate(DateTime dt) {
//     return DateFormat('EEEE, MMMM dd, yyyy').format(dt);
//   }

//   DateTime? _parseUtcTime(String? dateStr, String? timeStr) {
//     if (dateStr == null) return null;
//     try {
//       if (timeStr == null) return DateTime.parse(dateStr).toLocal();
//       final datePart = dateStr.contains('T') ? dateStr.split('T')[0] : dateStr;
//       final isoStr = "${datePart}T$timeStr";
//       return DateTime.parse(isoStr).toLocal();
//     } catch (e) {
//       return null;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final bool isOtherEmployee = widget.employeeId != null && widget.employeeId!.isNotEmpty;
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F4FA),
//       drawer: isOtherEmployee ? null : const AppDrawer(activeRoute: 'Attendance'),
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildTopBar(isOtherEmployee),
//             Expanded(
//               child: _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : Stack(
//                       children: [
//                         SingleChildScrollView(
//                           padding: const EdgeInsets.only(bottom: 16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               _buildDateSection(),
//                               _buildEmployeeCard(),
//                               _buildStatusCard(),
//                               _buildTodayTimeCard(),
//                               _buildStatsRow(),
//                               _buildRecentAttendance(),
//                             ],
//                           ),
//                         ),
//                         if (_isActionLoading)
//                           Container(
//                             color: Colors.white.withOpacity(0.6),
//                             child: const Center(child: CircularProgressIndicator()),
//                           ),
//                       ],
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTopBar(bool isOtherEmployee) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Builder(
//             builder: (context) => IconButton(
//               icon: Icon(isOtherEmployee ? Icons.arrow_back : Icons.menu, color: Colors.black87, size: 24),
//               onPressed: () {
//                 if (isOtherEmployee) {
//                   Navigator.pop(context);
//                 } else {
//                   Scaffold.of(context).openDrawer();
//                 }
//               },
//             ),
//           ),
//           Text(
//             isOtherEmployee ? 'Attendance' : 'My Attendance',
//             style: const TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: Color(0xFF1A6FD4),
//             ),
//           ),
//           const SizedBox(width: 46), // To balance the menu/back icon on the left
//         ],
//       ),
//     );
//   }

//   Widget _buildDateSection() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'TODAY',
//             style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.5),
//           ),
//           Text(
//             _formatDate(DateTime.now()),
//             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmployeeCard() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color(0xFFDDE6F4), width: 0.5),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   const Text('EMPLOYEE PROFILE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
//                   const SizedBox(width: 6),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//                     decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(10)),
//                     child: const Text('Active', style: TextStyle(fontSize: 9, color: Color(0xFF1A6FD4), fontWeight: FontWeight.w700)),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               Text(_employeeName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
//               Text('ID: $_employeeId', style: const TextStyle(fontSize: 12, color: Color(0xFF1A6FD4), fontWeight: FontWeight.w600)),
//             ],
//           ),
//           Container(
//             width: 46,
//             height: 46,
//             decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(23)),
//             child: const Icon(Icons.verified_user, color: Color(0xFF1A6FD4), size: 24),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusCard() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF1A6FD4), Color(0xFF1558B0)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Current Status', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
//                 child: Row(
//                   children: [
//                     const Icon(Icons.access_time, color: Colors.white, size: 12),
//                     const SizedBox(width: 4),
//                     Text(_currentTime, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 6),
//           Text(
//             _isCheckedIn 
//                 ? 'Checked In' 
//                 : (_checkInTimeStr != null ? 'Checked Out' : 'Not Checked In'),
//             style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
//           ),
//           const SizedBox(height: 14),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: (!_canCheckIn && !_canCheckOut) ? null : (_isCheckedIn ? _handleCheckOut : _handleCheckIn),
//               icon: Icon(_isCheckedIn ? Icons.logout : Icons.login, size: 16),
//               label: Text(
//                 (!_canCheckIn && !_canCheckOut) ? 'Completed for Today' : (_isCheckedIn ? 'Check Out' : 'Check In'), 
//                 style: const TextStyle(fontWeight: FontWeight.w700)
//               ),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.white,
//                 foregroundColor: const Color(0xFF1A6FD4),
//                 disabledBackgroundColor: Colors.white54,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                 elevation: 0,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTodayTimeCard() {
//     String checkInFormatted = "--:--";
//     String checkOutFormatted = "--:--";
//     String duration = "0h 0m Total";

//     if (_checkInTimeStr != null) {
//        DateTime dtIn = DateTime.parse(_checkInTimeStr!).toLocal();
//        checkInFormatted = DateFormat('hh:mm a').format(dtIn);
       
//        DateTime dtOut = _checkOutTimeStr != null ? DateTime.parse(_checkOutTimeStr!).toLocal() : DateTime.now();
//        if (_checkOutTimeStr != null) checkOutFormatted = DateFormat('hh:mm a').format(dtOut);
       
//        Duration diff = dtOut.difference(dtIn);
//        duration = "${diff.inHours}h ${diff.inMinutes.remainder(60)}m Total";
//     }

//     return Container(
//       margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color(0xFFDDE6F4), width: 0.5),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text("Today's Time", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//                 decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(20)),
//                 child: Text(duration, style: const TextStyle(fontSize: 12, color: Color(0xFF1A6FD4), fontWeight: FontWeight.w600)),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           _timeRow(color: const Color(0xFF1A6FD4), label: 'Check In', time: checkInFormatted),
//           const SizedBox(height: 8),
//           _timeRow(color: const Color(0xFFE24B4A), label: 'Check Out', time: checkOutFormatted),
//         ],
//       ),
//     );
//   }

//   Widget _timeRow({required Color color, required String label, required String time}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
//             const SizedBox(width: 8),
//             Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
//           ],
//         ),
//         Text(time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
//       ],
//     );
//   }

//   Widget _buildStatsRow() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
//       child: Row(
//         children: [
//           _statCard(icon: Icons.check_circle_outline, iconColor: const Color(0xFF1A6FD4), bgColor: const Color(0xFFE8F0FE), count: _presentCount.toString(), label: 'Present'),
//           const SizedBox(width: 8),
//           _statCard(icon: Icons.cancel_outlined, iconColor: const Color(0xFFE24B4A), bgColor: const Color(0xFFFCEBEB), count: _absentCount.toString(), label: 'Absent'),
//           const SizedBox(width: 8),
//           _statCard(icon: Icons.access_time, iconColor: const Color(0xFFD4760A), bgColor: const Color(0xFFFAEEDA), count: _lateCount.toString(), label: 'Late'),
//         ],
//       ),
//     );
//   }

//   Widget _statCard({required IconData icon, required Color iconColor, required Color bgColor, required String count, required String label}) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 14),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: const Color(0xFFDDE6F4), width: 0.5),
//         ),
//         child: Column(
//           children: [
//             Container(
//               width: 38,
//               height: 38,
//               decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
//               child: Icon(icon, color: iconColor, size: 20),
//             ),
//             const SizedBox(height: 8),
//             Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
//             const SizedBox(height: 2),
//             Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildRecentAttendance() {
//     return Padding(
//       padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Recent Attendance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => AttendanceHistoryPage(
//                         employeeId: _employeeId,
//                         userName: _employeeName,
//                       ),
//                     ),
//                   );
//                 },
//                 child: const Text('View All', style: TextStyle(fontSize: 12, color: Color(0xFF1A6FD4), fontWeight: FontWeight.w600)),
//               ),
//             ],
//           ),
//           const SizedBox(height: 10),
//           if (_recentRecords.isEmpty)
//              const Padding(
//                padding: EdgeInsets.symmetric(vertical: 20),
//                child: Center(child: Text('No recent attendance records.', style: TextStyle(color: Colors.grey))),
//              ),
//           ..._recentRecords.map((item) {
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 8.0),
//               child: _attendanceItem(item),
//             );
//           }),
//         ],
//       ),
//     );
//   }

//   Widget _attendanceItem(dynamic item) {
//     String dateStr = item['date'] ?? item['createdAt'] ?? DateTime.now().toIso8601String();
//     DateTime dt = DateTime.parse(dateStr).toLocal();
//     String status = (item['status'] ?? 'Present').toString().toUpperCase();
//     bool isLate = item['isLate'] == true || status == 'LATE';

//     DateTime? checkIn = _parseUtcTime(dateStr, item['checkInTime']);
//     DateTime? checkOut = _parseUtcTime(dateStr, item['checkOutTime']);

//     String timeRange = "--:--";
//     String duration = "0h 0m";
//     if (checkIn != null) {
//       String inStr = DateFormat('hh:mm a').format(checkIn);
//       String outStr = checkOut != null ? DateFormat('hh:mm a').format(checkOut) : 'Present';
//       timeRange = "$inStr - $outStr";
      
//       DateTime dOut = checkOut ?? DateTime.now();
//       Duration diff = dOut.difference(checkIn);
//       duration = "${diff.inHours}h ${diff.inMinutes.remainder(60)}m";
//     }

//     final borderColor = isLate ? const Color(0xFFD4760A) : const Color(0xFF1A6FD4);
//     final numColor = isLate ? const Color(0xFFD4760A) : const Color(0xFF1A1A2E);
//     final badgeBg = isLate ? const Color(0xFFFAEEDA) : const Color(0xFFEAF3DE);
//     final badgeText = isLate ? const Color(0xFF854F0B) : const Color(0xFF3B6D11);

//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: const Color(0xFFDDE6F4), width: 0.5),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 46,
//             height: 46,
//             decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: borderColor, width: 2)),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text('${dt.day}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: numColor, height: 1)),
//                 Text(DateFormat('MMM').format(dt).toUpperCase(), style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.5)),
//               ],
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(DateFormat('EEEE').format(dt), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
//                     const SizedBox(width: 6),
//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//                       decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10)),
//                       child: Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: badgeText, letterSpacing: 0.3)),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 3),
//                 Row(
//                   children: [
//                     const Icon(Icons.access_time, size: 11, color: Colors.grey),
//                     const SizedBox(width: 4),
//                     Text(timeRange, style: const TextStyle(fontSize: 11, color: Colors.grey)),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
//                 decoration: BoxDecoration(color: const Color(0xFFF0F4FA), borderRadius: BorderRadius.circular(10)),
//                 child: Text(duration, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
//               ),
//               const SizedBox(height: 6),
//               const Icon(Icons.edit, size: 14, color: Color(0xFF1A6FD4)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomNav() {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         border: Border(top: BorderSide(color: Color(0xFFDDE6F4), width: 0.5)),
//       ),
//       child: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _navItem(icon: Icons.home_outlined, label: 'Home', isSelected: false),
//               _navItem(icon: Icons.calendar_month, label: 'Attendance', isSelected: true),
//               _navItem(icon: Icons.history, label: 'History', isSelected: false),
//               _navItem(icon: Icons.person_outline, label: 'Profile', isSelected: false),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _navItem({required IconData icon, required String label, required bool isSelected}) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, color: isSelected ? const Color(0xFF1A6FD4) : Colors.grey.shade400, size: 24),
//         const SizedBox(height: 4),
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 10,
//             fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
//             color: isSelected ? const Color(0xFF1A6FD4) : Colors.grey.shade500,
//           ),
//         ),
//       ],
//     );
//   }
// }
