import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/employee_model.dart';
import 'package:dashflow/company/services/api_service.dart' as company_api;

class EmployeeService extends StateNotifier<AsyncValue<List<EmployeeModel>>> {
  EmployeeService() : super(const AsyncValue.loading()) {
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    state = const AsyncValue.loading();
    try {
      final list = await company_api.ApiService().getAllEmployees(
        department: '',
        branch: '',
        employmentType: '',
        status: '',
        companyId: '1e96499e-c166-4234-93a4-29049f45d28e',
      );
      final employees = list.map((e) => EmployeeModel.fromJson(e)).toList();
      state = AsyncValue.data(employees);
    } catch (e, st) {
      if (e.toString().contains('401')) {
        state = AsyncValue.error(
          "Unauthorized (401): Please log in first to view the employee directory.",
          st,
        );
      } else {
        state = AsyncValue.error(e.toString(), st);
      }
    }
  }

  void addEmployee(EmployeeModel employee) {
    if (state.value != null) {
      state = AsyncValue.data([...state.value!, employee]);
    }
  }

  void deleteEmployee(String id) {
    if (state.value != null) {
      state = AsyncValue.data(state.value!.where((e) => e.id != id).toList());
    }
  }
}

final employeeProvider =
    StateNotifierProvider<EmployeeService, AsyncValue<List<EmployeeModel>>>((
      ref,
    ) {
      return EmployeeService();
    });
