import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class AttendanceRecord {
  final int day;
  final String month;
  final String weekday;
  final String status;
  final bool isLate;
  final String timeRange;
  final String duration;

  const AttendanceRecord({
    required this.day,
    required this.month,
    required this.weekday,
    required this.status,
    required this.isLate,
    required this.timeRange,
    required this.duration,
  });
}

class AttendanceData {
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final List<AttendanceRecord> recentRecords;
  final bool isCheckedIn;

  const AttendanceData({
    this.presentCount = 18,
    this.absentCount = 1,
    this.lateCount = 2,
    this.recentRecords = const [],
    this.isCheckedIn = false,
  });

  AttendanceData copyWith({
    int? presentCount,
    int? absentCount,
    int? lateCount,
    List<AttendanceRecord>? recentRecords,
    bool? isCheckedIn,
  }) {
    return AttendanceData(
      presentCount: presentCount ?? this.presentCount,
      absentCount: absentCount ?? this.absentCount,
      lateCount: lateCount ?? this.lateCount,
      recentRecords: recentRecords ?? this.recentRecords,
      isCheckedIn: isCheckedIn ?? this.isCheckedIn,
    );
  }
}

class AttendanceService extends AsyncNotifier<AttendanceData> {
  @override
  Future<AttendanceData> build() async {
    await Future.delayed(const Duration(milliseconds: 600));

    final records = [
      const AttendanceRecord(
        day: 22,
        month: 'MAY',
        weekday: 'Friday',
        status: 'PRESENT',
        isLate: false,
        timeRange: '09:02 AM - 06:10 PM',
        duration: '9h 08m',
      ),
      const AttendanceRecord(
        day: 21,
        month: 'MAY',
        weekday: 'Thursday',
        status: 'LATE',
        isLate: true,
        timeRange: '09:45 AM - 06:00 PM',
        duration: '8h 15m',
      ),
      const AttendanceRecord(
        day: 20,
        month: 'MAY',
        weekday: 'Wednesday',
        status: 'PRESENT',
        isLate: false,
        timeRange: '08:55 AM - 05:45 PM',
        duration: '8h 50m',
      ),
    ];

    return AttendanceData(recentRecords: records);
  }

  void toggleCheckIn() {
    if (state.hasValue) {
      final currentData = state.requireValue;
      final newStatus = !currentData.isCheckedIn;

      final updatedRecords = List<AttendanceRecord>.from(
        currentData.recentRecords,
      );

      if (newStatus == true) {
        // Mock a Check-In
        updatedRecords.insert(
          0,
          const AttendanceRecord(
            day: 23,
            month: 'MAY',
            weekday: 'Today',
            status: 'ACTIVE',
            isLate: false,
            timeRange: '09:00 AM - Present',
            duration: '0h 0m',
          ),
        );
      } else {
        // Mock a Check-Out
        if (updatedRecords.isNotEmpty && updatedRecords[0].weekday == 'Today') {
          updatedRecords[0] = const AttendanceRecord(
            day: 23,
            month: 'MAY',
            weekday: 'Today',
            status: 'PRESENT',
            isLate: false,
            timeRange: '09:00 AM - 05:00 PM',
            duration: '8h 0m',
          );
        }
      }

      state = AsyncData(
        currentData.copyWith(
          isCheckedIn: newStatus,
          recentRecords: updatedRecords,
          presentCount: newStatus
              ? currentData.presentCount
              : currentData.presentCount + 1, // just a mock bump
        ),
      );
    }
  }
}

final attendanceProvider = AsyncNotifierProvider<AttendanceService, AttendanceData>(() {
  return AttendanceService();
});
