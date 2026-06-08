import 'package:get/get.dart';

class DashboardController extends GetxController {
  var attendanceList = <Attendance>[].obs;
  var isLoading = false.obs;


  @override
  void onInit() {
    super.onInit();
    fetchAttendance();
  }

  void fetchAttendance() {
    isLoading(true);
    try {
      attendanceList.addAll([
        Attendance(
          id: '1',
          employeeId: 'EMP001',
          employeeName: 'Rajdeep Maurya',
          date: DateTime.now(),
          checkIn: '09:00 AM',
          checkOut: '06:00 PM',
          status: 'Present',
        ),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch attendance: $e');
    } finally {
      isLoading(false);
    }
  }

  void markAttendance({
    required String employeeId,
    required String status,
    required String checkInTime,
  }) {
    try {
      final attendance = Attendance(
        id: DateTime.now().toString(),
        employeeId: employeeId,
        employeeName: '',
        date: DateTime.now(),
        checkIn: checkInTime,
        checkOut: '',
        status: status,
      );
      attendanceList.add(attendance);
      Get.snackbar('Success', 'Attendance marked successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark attendance: $e');
    }
  }

  void deleteAttendance(String id) {
    attendanceList.removeWhere((element) => element.id == id);
    Get.snackbar('Success', 'Attendance record deleted');
  }
}

class Attendance {
  String id;
  String employeeId;
  String employeeName;
  DateTime date;
  String checkIn;
  String checkOut;
  String status;
  Attendance({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.status,
  });
}
