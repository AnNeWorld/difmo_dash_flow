import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/employee_model.dart';
import 'package:dashflow/company/services/api_service.dart' as company_api;
import 'package:dashflow/core/api/api_service.dart' as core_api;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeService extends StateNotifier<AsyncValue<List<EmployeeModel>>> {
  EmployeeService() : super(const AsyncValue.loading()) {
    fetchEmployees();
  }

  Future<void> fetchEmployees() async {
    state = const AsyncValue.loading();
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      String companyId = '';
      if (userStr != null) {
        final user = jsonDecode(userStr);
        companyId = user['companyId']?.toString() ?? (user['company'] is Map ? (user['company']['id']?.toString() ?? user['company']['_id']?.toString()) : user['company']?.toString()) ?? '';
      }

      final list = await company_api.ApiService().getAllEmployees(
        department: '',
        branch: '',
        employmentType: '',
        status: '',
        companyId: companyId.isNotEmpty ? companyId : null,
      );
      
      try {
        final coreEmployees = await core_api.ApiService.getEmployees();
        for (var e in coreEmployees) {
          final id1 = e['id']?.toString() ?? e['_id']?.toString();
          bool exists = false;
          if (id1 != null && id1.isNotEmpty) {
            exists = list.any((item) {
              final id2 = item['id']?.toString() ?? item['_id']?.toString();
              return id1 == id2;
            });
          }
          if (!exists) {
            list.add(e);
          }
        }
      } catch (_) {}

      if (list.isEmpty) {
        try {
          if (userStr != null) {
            final userObj = jsonDecode(userStr);
            userObj['_id'] ??= userObj['id'] ?? 'self-user';
            list.add(userObj);
          }
        } catch (_) {}
      }

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

  Future<bool> updateEmployee(EmployeeModel updatedEmp) async {
    try {
      await company_api.ApiService().updateEmployee(
        id: updatedEmp.id,
        firstName: updatedEmp.firstName,
        lastName: updatedEmp.lastName,
        email: updatedEmp.email,
        phone: updatedEmp.phone,
        designation: updatedEmp.designation,
        department: updatedEmp.department,
      );

      // Optimistic UI update
      if (state.value != null) {
        state = AsyncValue.data(
          state.value!
              .map((e) => e.id == updatedEmp.id ? updatedEmp : e)
              .toList(),
        );
      }
      return true;
    } catch (e) {
      print('Error updating employee: $e');
      return false;
    }
  }
}

final employeeProvider =
    StateNotifierProvider<EmployeeService, AsyncValue<List<EmployeeModel>>>((
      ref,
    ) {
      return EmployeeService();
    });
