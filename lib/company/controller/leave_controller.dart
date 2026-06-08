import 'package:get/get.dart';
import '../services/api_service.dart';

class LeaveController extends GetxController {
  final ApiService apiService = ApiService();

  var leaves = <dynamic>[].obs;
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var selectedLeave = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    fetchAllLeaves();
  }

  Future<void> fetchAllLeaves() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.getAllLeaves();
      leaves.value = response;

      if (leaves.isEmpty) {
        errorMessage.value = 'No leave requests found';
      }
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('❌ Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLeaveById(String leaveId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await apiService.getLeaveById(leaveId);
      selectedLeave.value = response;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('❌ Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> requestLeave({
    required String employeeId,
    required String startDate,
    required String endDate,
    required String type,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await apiService.requestLeave(
        employeeId: employeeId,
        startDate: startDate,
        endDate: endDate,
        type: type,
      );
      await fetchAllLeaves();
      Get.snackbar('✅ Success', 'Leave request submitted successfully!');
      Get.back();
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('❌ Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveLeave({
    required String leaveId,
    String? rejectionReason,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await apiService.updateLeaveStatus(
        leaveId: leaveId,
        status: 'approved',
        rejectionReason: rejectionReason,
      );
      await fetchAllLeaves();

      Get.snackbar('✅ Success', 'Leave approved!');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('❌ Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> rejectLeave({
    required String leaveId,
    required String rejectionReason,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await apiService.updateLeaveStatus(
        leaveId: leaveId,
        status: 'rejected',
        rejectionReason: rejectionReason,
      );
      await fetchAllLeaves();

      Get.snackbar('✅ Success', 'Leave rejected!');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('❌ Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteLeave(String leaveId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await apiService.deleteLeave(leaveId);
      await fetchAllLeaves();
      Get.snackbar('✅ Success', 'Leave deleted!');
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar('❌ Error', errorMessage.value);
    } finally {
      isLoading.value = false;
    }
  }

  String getStatusBadge(String status) {
    const statusMap = {
      'pending': '⏳ Pending',
      'approved': '✅ Approved',
      'rejected': '❌ Rejected',
    };
    return statusMap[status] ?? status;
  }

  String getLeaveTypeLabel(String type) {
    const typeMap = {
      'vacation': '🏖️ Vacation',
      'sick': '🏥 Sick Leave',
      'personal': '🏠 Personal',
      'other': '📋 Other',
    };
    return typeMap[type] ?? type;
  }
}
