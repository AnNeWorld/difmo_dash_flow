import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/leave_model.dart';
import 'api_service.dart' as company_api;

final leaveProvider =
    StateNotifierProvider<LeaveService, AsyncValue<List<LeaveModel>>>((ref) {
      return LeaveService();
    });

class LeaveService extends StateNotifier<AsyncValue<List<LeaveModel>>> {
  LeaveService() : super(const AsyncValue.loading()) {
    fetchLeaves();
  }

  Future<void> fetchLeaves() async {
    state = const AsyncValue.loading();
    try {
      final list = await company_api.ApiService().getAllLeaves(
        companyId: '1e96499e-c166-4234-93a4-29049f45d28e',
      );
      final leaves = list.map((e) => LeaveModel.fromJson(e)).toList();
      state = AsyncValue.data(leaves);
    } catch (e, st) {
      if (e.toString().contains('401')) {
        state = AsyncValue.error("Unauthorized. Please log in.", st);
      } else {
        state = AsyncValue.error(e.toString(), st);
      }
    }
  }

  Future<bool> updateLeaveStatus(
    String leaveId,
    String newStatus, {
    String remark = '',
  }) async {
    try {
      // Call the API
      await company_api.ApiService().updateLeaveStatus(
        leaveId: leaveId,
        status: newStatus.toLowerCase(),
        rejectionReason: remark,
      );

      // Optimistically update the state
      state.whenData((leaves) {
        final updatedLeaves = leaves.map((leave) {
          if (leave.id == leaveId) {
            return leave.copyWith(
              status: newStatus.toUpperCase(),
              adminRemark: remark,
            );
          }
          return leave;
        }).toList();
        state = AsyncValue.data(updatedLeaves);
      });
      return true;
    } catch (e) {
      print('Error updating leave status: $e');
      return false;
    }
  }
}
