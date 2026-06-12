import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter/foundation.dart';
import '../models/leave_model.dart';
import 'api_service.dart' as company_api;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> _getCompanyId() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    
    // 1. Try decoding from JWT token (core API saves under 'token')
    String? token = prefs.getString('token') ?? prefs.getString('jwt_token');
    if (token != null && token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final normalized = base64Url.normalize(parts[1]);
          final payload = jsonDecode(utf8.decode(base64Url.decode(normalized)));
          final id = payload['companyId']?.toString() ?? '';
          if (id.isNotEmpty) return id;
        }
      } catch (_) {}
    }

    // 2. Try reading from saved user profile
    final userStr = prefs.getString('user') ?? prefs.getString('user_profile');
    if (userStr != null && userStr.isNotEmpty) {
      final user = jsonDecode(userStr);
      final id = user['companyId']?.toString() ??
          user['company']?['id']?.toString() ??
          user['company']?['_id']?.toString() ?? '';
      if (id.isNotEmpty) return id;
    }

    // 3. Try reading company_profile
    final companyStr = prefs.getString('company_profile');
    if (companyStr != null && companyStr.isNotEmpty) {
      final company = jsonDecode(companyStr);
      final id = company['id']?.toString() ?? company['_id']?.toString() ?? '';
      if (id.isNotEmpty) return id;
    }

    return '';
  } catch (e) {
    return '';
  }
}

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
      final companyId = await _getCompanyId();
      if (companyId.isEmpty) {
        state = AsyncValue.error("No company ID found for current user.", StackTrace.current);
        return;
      }
      
      final list = await company_api.ApiService().getAllLeaves(
        companyId: companyId,
      );
      var leaves = list.map((e) => LeaveModel.fromJson(e)).toList();

      final Map<String, String> idToName = {};
      final Map<String, String> idToInitials = {};

      try {
        final usersList = await company_api.ApiService().getAllUsers();
        for (var u in usersList) {
          final fName = u['firstName']?.toString() ?? '';
          final lName = u['lastName']?.toString() ?? '';
          final name = '$fName $lName'.trim();
          if (name.isNotEmpty) {
            String init = '';
            if (fName.isNotEmpty) init += fName[0].toUpperCase();
            if (lName.isNotEmpty) init += lName[0].toUpperCase();
            final ids = [
              u['_id']?.toString(),
              u['id']?.toString(),
            ].where((id) => id != null && id.isNotEmpty).cast<String>();
            for (final id in ids) {
              idToName[id] = name;
              idToInitials[id] = init.isNotEmpty ? init : name[0].toUpperCase();
            }
          }
        }
      } catch (_) {}

      try {
        final employeesList = await company_api.ApiService().getAllEmployees();
        for (var e in employeesList) {
          final fName = e['firstName']?.toString() ?? '';
          final lName = e['lastName']?.toString() ?? '';
          final name = '$fName $lName'.trim();
          if (name.isNotEmpty) {
            String init = '';
            if (fName.isNotEmpty) init += fName[0].toUpperCase();
            if (lName.isNotEmpty) init += lName[0].toUpperCase();
            final ids = <String>[];
            final id1 = e['_id']?.toString();
            final id2 = e['id']?.toString();
            final id3 = e['customId']?.toString();
            final id4 = e['employeeId']?.toString();
            if (id1 != null && id1.isNotEmpty) ids.add(id1);
            if (id2 != null && id2.isNotEmpty) ids.add(id2);
            if (id3 != null && id3.isNotEmpty) ids.add(id3);
            if (id4 != null && id4.isNotEmpty) ids.add(id4);

            final uRef = e['userId'] ?? e['user'];
            if (uRef is Map) {
              final uid = uRef['_id']?.toString() ?? uRef['id']?.toString();
              if (uid != null && uid.isNotEmpty) ids.add(uid);
            } else if (uRef is String && uRef.isNotEmpty) {
              ids.add(uRef);
            }

            for (final id in ids) {
              idToName[id] = name;
              idToInitials[id] = init.isNotEmpty ? init : name[0].toUpperCase();
            }
          }
        }
      } catch (_) {}

      try {
        final prefs = await SharedPreferences.getInstance();
        final savedEmpListStr = prefs.getString('local_mock_employees') ?? '[]';
        final List<dynamic> savedEmpList = jsonDecode(savedEmpListStr);
        for (var e in savedEmpList) {
          final fName = e['firstName']?.toString() ?? '';
          final lName = e['lastName']?.toString() ?? '';
          final name = '$fName $lName'.trim();
          if (name.isNotEmpty) {
            String init = '';
            if (fName.isNotEmpty) init += fName[0].toUpperCase();
            if (lName.isNotEmpty) init += lName[0].toUpperCase();
            final ids = <String>[];
            if (e['_id'] != null) ids.add(e['_id'].toString());
            if (e['id'] != null) ids.add(e['id'].toString());
            if (e['customId'] != null) ids.add(e['customId'].toString());
            if (e['employeeId'] != null) ids.add(e['employeeId'].toString());
            for (final id in ids) {
              idToName[id] = name;
              idToInitials[id] = init.isNotEmpty ? init : name[0].toUpperCase();
            }
          }
        }

        final userStr = prefs.getString('user') ?? prefs.getString('user_profile');
        if (userStr != null) {
          final cu = jsonDecode(userStr);
          final fName = cu['firstName']?.toString() ?? '';
          final lName = cu['lastName']?.toString() ?? '';
          final name = '$fName $lName'.trim();
          if (name.isNotEmpty) {
            String init = '';
            if (fName.isNotEmpty) init += fName[0].toUpperCase();
            if (lName.isNotEmpty) init += lName[0].toUpperCase();
            final cuIds = [cu['_id']?.toString(), cu['id']?.toString()]
                .where((id) => id != null && id.isNotEmpty).cast<String>();
            for (final id in cuIds) {
              idToName[id] = name;
              idToInitials[id] = init.isNotEmpty ? init : name[0].toUpperCase();
            }
          }
        }
      } catch (_) {}

        // DEBUG: print first 2 leaves to see what IDs and names we're getting
        if (leaves.isNotEmpty) {
          for (var l in leaves.take(2)) {
            debugPrint('🔍 LEAVE DEBUG: id=${l.id} empId=${l.employeeId} name="${l.employeeName}" rawKeys=${l.rawJson?.keys.toList()}');
            final rawEmp = l.rawJson?['employee'] ?? l.rawJson?['employeeId'] ?? l.rawJson?['userId'] ?? l.rawJson?['user'];
            debugPrint('🔍 LEAVE RAW emp field: $rawEmp');
          }
          debugPrint('🔍 NAME MAP keys (first 5): ${idToName.keys.take(5).toList()}');
        }

        leaves = leaves.map((leave) {
          if (leave.employeeName == 'Unknown' || leave.employeeName.trim().isEmpty) {
            final empId = leave.employeeId.trim().toLowerCase();
            final matchedKey = idToName.keys.firstWhere(
              (k) => k.trim().toLowerCase() == empId,
              orElse: () => '',
            );
            if (matchedKey.isNotEmpty) {
              final mName = idToName[matchedKey]!;
              return leave.copyWith(
                employeeName: mName,
                employeeInitials: idToInitials[matchedKey] ?? mName[0].toUpperCase(),
              );
            } else if (leave.employeeId.isNotEmpty && leave.employeeId != 'N/A') {
              return leave.copyWith(
                employeeName: 'User ID: ${leave.employeeId}',
                employeeInitials: leave.employeeId.length > 1 ? leave.employeeId.substring(0, 2).toUpperCase() : leave.employeeId.toUpperCase(),
              );
            }
          }
          return leave;
        }).toList();

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
      return false;
    }
  }

  Future<bool> deleteLeave(String leaveId) async {
    try {
      await company_api.ApiService().deleteLeave(leaveId);
      state.whenData((leaves) {
        state = AsyncValue.data(leaves.where((l) => l.id != leaveId).toList());
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
