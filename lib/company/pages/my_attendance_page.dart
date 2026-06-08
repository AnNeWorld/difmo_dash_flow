import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../services/attendance_service.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Attendance',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A6FD4)),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const MyAttendancePage(),
    );
  }
}

class MyAttendancePage extends ConsumerStatefulWidget {
  const MyAttendancePage({super.key});

  @override
  ConsumerState<MyAttendancePage> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<MyAttendancePage> {
  late Timer _timer;
  late String _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = _formatTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 60), (_) {
      setState(() => _currentTime = _formatTime(DateTime.now()));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$min $ampm';
  }

  String _formatDate(DateTime dt) {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${days[dt.weekday - 1]}, ${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final attendanceAsync = ref.watch(attendanceProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: attendanceAsync.when(
                data: (data) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateSection(),
                        _buildEmployeeCard(),
                        _buildStatusCard(data.isCheckedIn),
                        _buildTodayTimeCard(),
                        _buildStatsRow(data.presentCount, data.absentCount, data.lateCount),
                        _buildRecentAttendance(data.recentRecords),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(Icons.menu, color: Colors.black87, size: 26),
          const Text(
            'My Attendance',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A6FD4),
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4760A),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'ADMIN MODE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE8F7),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(Icons.person, color: Color(0xFF1A6FD4), size: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TODAY',
            style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.5),
          ),
          Text(
            _formatDate(DateTime.now()),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE6F4), width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('EMPLOYEE PROFILE', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(10)),
                    child: const Text('Admin View', style: TextStyle(fontSize: 9, color: Color(0xFF1A6FD4), fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('John Doe', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
              const Text('ID: #EMP2026', style: TextStyle(fontSize: 12, color: Color(0xFF1A6FD4), fontWeight: FontWeight.w600)),
            ],
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(23)),
            child: const Icon(Icons.verified_user, color: Color(0xFF1A6FD4), size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard(bool isCheckedIn) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A6FD4), Color(0xFF1558B0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Current Status', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(20)),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, color: Colors.white, size: 12),
                    const SizedBox(width: 4),
                    Text(_currentTime, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isCheckedIn ? 'Checked In' : 'Checked Out',
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isCheckedIn ? null : () {
                    ref.read(attendanceProvider.notifier).toggleCheckIn();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Checked In Successfully!")));
                  },
                  icon: const Icon(Icons.login, size: 16),
                  label: const Text('Check In', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1A6FD4),
                    disabledBackgroundColor: Colors.white54,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isCheckedIn ? () {
                    ref.read(attendanceProvider.notifier).toggleCheckIn();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Checked Out Successfully!")));
                  } : null,
                  icon: Icon(Icons.logout, size: 16, color: isCheckedIn ? Colors.white : Colors.white38),
                  label: Text('Check Out', style: TextStyle(fontWeight: FontWeight.w700, color: isCheckedIn ? Colors.white : Colors.white38)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: isCheckedIn ? Colors.white60 : Colors.white24),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTimeCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE6F4), width: 0.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Today's Time", style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(20)),
                child: const Text('8h 15m Total', style: TextStyle(fontSize: 12, color: Color(0xFF1A6FD4), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _timeRow(color: const Color(0xFF1A6FD4), label: 'Check In', time: '09:00 AM'),
          const SizedBox(height: 8),
          _timeRow(color: const Color(0xFFE24B4A), label: 'Check Out', time: '05:15 PM'),
        ],
      ),
    );
  }

  Widget _timeRow({required Color color, required String label, required String time}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
          ],
        ),
        Text(time, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
      ],
    );
  }

  Widget _buildStatsRow(int present, int absent, int late) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Row(
        children: [
          _statCard(icon: Icons.check_circle_outline, iconColor: const Color(0xFF1A6FD4), bgColor: const Color(0xFFE8F0FE), count: present.toString(), label: 'Present'),
          const SizedBox(width: 8),
          _statCard(icon: Icons.cancel_outlined, iconColor: const Color(0xFFE24B4A), bgColor: const Color(0xFFFCEBEB), count: absent.toString(), label: 'Absent'),
          const SizedBox(width: 8),
          _statCard(icon: Icons.access_time, iconColor: const Color(0xFFD4760A), bgColor: const Color(0xFFFAEEDA), count: late.toString(), label: 'Late'),
        ],
      ),
    );
  }

  Widget _statCard({required IconData icon, required Color iconColor, required Color bgColor, required String count, required String label}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFDDE6F4), width: 0.5),
        ),
        child: Column(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(height: 8),
            Text(count, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAttendance(List<AttendanceRecord> records) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Attendance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
              GestureDetector(
                onTap: () {},
                child: const Text('View All', style: TextStyle(fontSize: 12, color: Color(0xFF1A6FD4), fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...records.map((r) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _attendanceItem(r),
            );
          }),
        ],
      ),
    );
  }

  Widget _attendanceItem(AttendanceRecord record) {
    final borderColor = record.isLate ? const Color(0xFFD4760A) : const Color(0xFF1A6FD4);
    final numColor = record.isLate ? const Color(0xFFD4760A) : const Color(0xFF1A1A2E);
    final badgeBg = record.isLate ? const Color(0xFFFAEEDA) : const Color(0xFFEAF3DE);
    final badgeText = record.isLate ? const Color(0xFF854F0B) : const Color(0xFF3B6D11);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDE6F4), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: borderColor, width: 2)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${record.day}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: numColor, height: 1)),
                Text(record.month, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.5)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(record.weekday, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(10)),
                      child: Text(record.status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: badgeText, letterSpacing: 0.3)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 11, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(record.timeRange, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: const Color(0xFFF0F4FA), borderRadius: BorderRadius.circular(10)),
                child: Text(record.duration, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
              ),
              const SizedBox(height: 6),
              const Icon(Icons.edit, size: 14, color: Color(0xFF1A6FD4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFDDE6F4), width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(icon: Icons.home_outlined, label: 'Home', isSelected: false),
              _navItem(icon: Icons.calendar_month, label: 'Attendance', isSelected: true),
              _navItem(icon: Icons.history, label: 'History', isSelected: false),
              _navItem(icon: Icons.person_outline, label: 'Profile', isSelected: false),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem({required IconData icon, required String label, required bool isSelected}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isSelected ? const Color(0xFF1A6FD4) : Colors.grey.shade400, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF1A6FD4) : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
