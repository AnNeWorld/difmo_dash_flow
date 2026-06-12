import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

class ApiService {
  static const String BASE_URL = 'https://dashflow-backend.vercel.app/api';

  late Dio _dio;
  late SharedPreferences _prefs;

  static final ApiService _instance = ApiService._internal();

  factory ApiService() {
    return _instance;
  }

  Dio get dio => _dio;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: BASE_URL,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        contentType: 'application/json',
      ),
    );

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: false,
        requestHeader: true,
        error: true,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          String? token =
              prefs.getString('jwt_token') ?? prefs.getString('token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Origin'] = 'https://dashflow-frontend.vercel.app';
          options.headers['Referer'] = 'https://dashflow-frontend.vercel.app/';
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic>) {
      if (responseData.containsKey('data')) {
        var inner = responseData['data'];
        if (inner is Map<String, dynamic> && inner.containsKey('data')) {
          return inner['data'];
        }
        return inner;
      }
      if (responseData.containsKey('jobs') && responseData['jobs'] is List) {
        return responseData['jobs'];
      }
      if (responseData.containsKey('applications') &&
          responseData['applications'] is List) {
        return responseData['applications'];
      }
      if (responseData.containsKey('items') && responseData['items'] is List) {
        return responseData['items'];
      }
    }
    return responseData;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final token =
            data['data']?['access_token'] ??
            data['access_token'] ??
            data['token'];
        if (token != null) {
          await saveToken(token);
        }
        return response.data;
      }
      throw Exception('Login failed');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login error');
    }
  }

  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await _dio.get('/auth/profile');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to fetch profile');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching profile');
    }
  }

  Future<Map<String, dynamic>> switchCompany(String companyId) async {
    try {
      final response = await _dio.post(
        '/auth/switch-company',
        data: {'companyId': companyId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = response.data['access_token'] ?? response.data['token'];
        if (token != null) {
          await saveToken(token);
        }
        return response.data;
      }
      throw Exception('Failed to switch company');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error switching company');
    }
  }

  Future<List<dynamic>> getMyWorkspaces() async {
    try {
      final response = await _dio.get('/auth/my-workspaces');
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch workspaces');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching workspaces',
      );
    }
  }

  Future<Map<String, dynamic>> changePassword(String newPassword) async {
    try {
      final response = await _dio.patch(
        '/auth/change-password',
        data: {'newPassword': newPassword},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to change password');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error changing password');
    }
  }

  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password/send-otp',
        data: {'email': email},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to send OTP');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error sending OTP');
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/forgot-password/reset',
        data: {'email': email, 'otp': otp, 'newPassword': newPassword},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to reset password');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error resetting password',
      );
    }
  }

  Future<List<dynamic>> getAllUsers() async {
    try {
      final response = await _dio.get('/users');
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch users');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching users');
    }
  }

  Future<List<dynamic>> getDashboard() async {
    try {
      final response = await _dio.get('/dashboard/metrics');
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch users');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching users');
    }
  }

  Future<Map<String, dynamic>> getUserById(String userId) async {
    try {
      final response = await _dio.get('/users/$userId');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch user');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching user');
    }
  }

  Future<Map<String, dynamic>> createUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
    String? companyId,
  }) async {
    try {
      final response = await _dio.post(
        '/users',
        data: {
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'role': role,
          if (companyId != null) 'companyId': companyId,
        },
      );
      if (response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create user');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating user');
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required String userId,
    required String firstName,
    required String lastName,
    required String phone,
    required String role,
  }) async {
    try {
      final response = await _dio.put(
        '/users/$userId',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'phone': phone,
          'role': role,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update user');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating user');
    }
  }

  Future<void> deleteUser(String userId) async {
    try {
      final response = await _dio.delete('/users/$userId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete user');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error deleting user');
    }
  }

  Future<Map<String, dynamic>> createEmployee({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String designation,
    required String department,
    String? password,
  }) async {
    try {
      final response = await _dio.post(
        '/employees',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'designation': designation,
          'department': department,
          if (password != null && password.isNotEmpty) 'password': password,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create employee');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating employee');
    }
  }

  Future<List<dynamic>> getAllEmployees({
    String? department,
    String? branch,
    String? employmentType,
    String? status,
    String? companyId,
  }) async {
    try {
      final response = await _dio.get(
        '/employees',
        queryParameters: {
          if (department != null) 'department': department,
          if (branch != null) 'branch': branch,
          if (employmentType != null) 'employmentType': employmentType,
          if (status != null) 'status': status,
          if (companyId != null) 'companyId': companyId,
        },
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch employees');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching employees',
      );
    }
  }

  Future<Map<String, dynamic>> getEmployeeById(String id) async {
    try {
      final response = await _dio.get('/employees/$id');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch employee');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching employee');
    }
  }

  Future<Map<String, dynamic>> updateEmployee({
    required String id,
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String designation,
    required String department,
    String? password,
  }) async {
    try {
      final response = await _dio.put(
        '/employees/$id',
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'phone': phone,
          'designation': designation,
          'department': department,
          if (password != null && password.isNotEmpty) 'password': password,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update employee');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating employee');
    }
  }

  Future<Map<String, dynamic>> updateEmployeeStatus(
    String id,
    String status,
  ) async {
    try {
      final response = await _dio.patch(
        '/employees/$id/status',
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update employee status');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error updating employee status',
      );
    }
  }

  Future<void> deleteEmployee(String id) async {
    try {
      final response = await _dio.delete('/employees/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete employee');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error deleting employee');
    }
  }

  Future<Map<String, dynamic>> syncEmployeeRoles(String companyId) async {
    try {
      final response = await _dio.post(
        '/employees/sync-roles',
        data: {'companyId': companyId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to sync employee roles');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error syncing employee roles',
      );
    }
  }

  Future<Map<String, dynamic>> assignBulkManagers(
    List<String> employeeIds,
  ) async {
    try {
      final response = await _dio.post(
        '/employees/bulk-managers',
        data: {'employeeIds': employeeIds},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to assign managers in bulk');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error assigning bulk managers',
      );
    }
  }

  Future<void> revokeManagerRole(String id) async {
    try {
      final response = await _dio.delete('/employees/$id/manager-role');
      if (response.statusCode != 200) {
        throw Exception('Failed to revoke manager role');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error revoking manager role',
      );
    }
  }

  Future<Map<String, dynamic>> getEmployeeCount(String companyId) async {
    try {
      final response = await _dio.get(
        '/employees/stats/count',
        queryParameters: {'companyId': companyId},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch employee count');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching employee count',
      );
    }
  }

  Future<List<dynamic>> getAllCompanies() async {
    try {
      final response = await _dio.get('/companies');
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch companies');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching companies',
      );
    }
  }

  Future<Map<String, dynamic>> getCompanyById(String companyId) async {
    try {
      final response = await _dio.get('/companies/$companyId');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch company');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching company');
    }
  }

  Future<Map<String, dynamic>> createCompany({
    required String name,
    required String email,
    required String website,
    required String industry,
    required int size,
    required String address,
    required String city,
    required String country,
  }) async {
    try {
      final response = await _dio.post(
        '/companies',
        data: {
          'name': name,
          'email': email,
          'website': website,
          'industry': industry,
          'size': size,
          'address': address,
          'city': city,
          'country': country,
        },
      );
      if (response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create company');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating company');
    }
  }

  Future<Map<String, dynamic>> updateCompany({
    required String companyId,
    required String name,
    required String email,
    required String website,
    required String industry,
    required int size,
    required String address,
    required String city,
    required String country,
  }) async {
    try {
      final response = await _dio.put(
        '/companies/$companyId',
        data: {
          'name': name,
          'email': email,
          'website': website,
          'industry': industry,
          'size': size,
          'address': address,
          'city': city,
          'country': country,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update company');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating company');
    }
  }

  Future<void> deleteCompany(String companyId) async {
    try {
      final response = await _dio.delete('/companies/$companyId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete company');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error deleting company');
    }
  }

  Future<Map<String, dynamic>> getCompanyGst(String id) async {
    try {
      final response = await _dio.get('/companies/$id');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch GST info');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching GST info');
    }
  }

  Future<Map<String, dynamic>> updateCompanyGst(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch('/companies/$id', data: data);
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update GST info');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating GST info');
    }
  }

  Future<List<dynamic>> getAllLeaves({
    String? companyId,
    String? employeeId,
    String? status,
    String? type,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (companyId != null) queryParams['companyId'] = companyId;
      if (employeeId != null) queryParams['employeeId'] = employeeId;
      if (status != null) queryParams['status'] = status;
      if (type != null) queryParams['type'] = type;

      final response = await _dio.get('/leaves', queryParameters: queryParams);
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch leaves');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching leaves');
    }
  }

  Future<Map<String, dynamic>> getLeaveById(String leaveId) async {
    try {
      final response = await _dio.get('/leaves/$leaveId');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch leave');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching leave');
    }
  }

  Future<Map<String, dynamic>> requestLeave({
    required String employeeId,
    required String startDate,
    required String endDate,
    required String type,
    String? reason,
    String? companyId,
  }) async {
    try {
      final Map<String, dynamic> data = {
        'employeeId': employeeId,
        'startDate': startDate,
        'endDate': endDate,
        'type': type,
      };
      if (reason != null && reason.isNotEmpty) data['reason'] = reason;
      if (companyId != null && companyId.isNotEmpty)
        data['companyId'] = companyId;

      final response = await _dio.post('/leaves', data: data);
      if (response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to request leave');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error requesting leave');
    }
  }

  Future<Map<String, dynamic>> updateLeaveStatus({
    required String leaveId,
    required String status,
    String? rejectionReason,
  }) async {
    try {
      final response = await _dio.patch(
        '/leaves/$leaveId/status',
        data: {
          'status': status,
          if (rejectionReason != null) 'rejectionReason': rejectionReason,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update leave status');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating leave');
    }
  }

  Future<Map<String, dynamic>> updateLeaveDetails({
    required String leaveId,
    String? startDate,
    String? endDate,
    String? type,
  }) async {
    try {
      final response = await _dio.patch(
        '/leaves/$leaveId',
        data: {
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
          if (type != null) 'type': type,
        },
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update leave details');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error updating leave details',
      );
    }
  }

  Future<void> deleteLeave(String leaveId) async {
    try {
      final response = await _dio.delete('/leaves/$leaveId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete leave');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error deleting leave');
    }
  }

  Future<List<dynamic>> getWfhRequests({
    String? companyId,
    String? employeeId,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (companyId != null) queryParams['companyId'] = companyId;
      if (employeeId != null) queryParams['employeeId'] = employeeId;
      if (status != null) queryParams['status'] = status;
      final response = await _dio.get(
        '/wfh-requests',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch WFH requests');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching WFH requests',
      );
    }
  }

  Future<Map<String, dynamic>> getWfhRequestById(String id) async {
    try {
      final response = await _dio.get('/wfh-requests/$id');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch WFH request');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching WFH request',
      );
    }
  }

  Future<Map<String, dynamic>> submitWfhRequest({
    required String employeeId,
    required String companyId,
    required String date,
    required String reason,
  }) async {
    try {
      final response = await _dio.post(
        '/wfh-requests',
        data: {
          'employeeId': employeeId,
          'companyId': companyId,
          'date': date,
          'reason': reason,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to submit WFH request');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error submitting WFH request',
      );
    }
  }

  Future<Map<String, dynamic>> updateWfhRequestStatus({
    required String id,
    required String status,
    String? comment,
  }) async {
    try {
      final response = await _dio.patch(
        '/wfh-requests/$id/status',
        data: {'status': status, if (comment != null) 'comment': comment},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update WFH request status');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error updating WFH request',
      );
    }
  }

  Future<void> deleteWfhRequest(String id) async {
    try {
      final response = await _dio.delete('/wfh-requests/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete WFH request');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error deleting WFH request',
      );
    }
  }

  Future<Map<String, dynamic>> getAttendanceAnalytics({
    required String companyId,
    required int month,
    required int year,
  }) async {
    try {
      final response = await _dio.get(
        '/attendance/analytics',
        queryParameters: {'companyId': companyId, 'month': month, 'year': year},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch attendance analytics');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching attendance analytics',
      );
    }
  }

  Future<List<dynamic>> getDepartments(String companyId) async {
    try {
      final response = await _dio.get(
        '/departments',
        queryParameters: {'companyId': companyId},
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch departments');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching departments',
      );
    }
  }

  Future<Map<String, dynamic>> createDepartment({
    required String name,
    required String companyId,
  }) async {
    try {
      final response = await _dio.post(
        '/departments',
        data: {'name': name, 'companyId': companyId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create department');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error creating department',
      );
    }
  }

  Future<void> deleteDepartment(String id) async {
    try {
      final response = await _dio.delete('/departments/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete department');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error deleting department',
      );
    }
  }

  Future<List<dynamic>> getDesignations(String companyId) async {
    try {
      final response = await _dio.get(
        '/designations',
        queryParameters: {'companyId': companyId},
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch designations');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching designations',
      );
    }
  }

  Future<Map<String, dynamic>> createDesignation({
    required String name,
    required String companyId,
  }) async {
    try {
      final response = await _dio.post(
        '/designations',
        data: {'name': name, 'companyId': companyId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create designation');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error creating designation',
      );
    }
  }

  Future<void> deleteDesignation(String id) async {
    try {
      final response = await _dio.delete('/designations/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete designation');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error deleting designation',
      );
    }
  }

  Future<Map<String, dynamic>> createPayroll({
    required String employeeId,
    required int month,
    required int year,
    required double basicSalary,
    required double allowances,
    required double deductions,
    required double netSalary,
  }) async {
    try {
      final response = await _dio.post(
        '/finance/payroll',
        data: {
          'employeeId': employeeId,
          'month': month,
          'year': year,
          'basicSalary': basicSalary,
          'allowances': allowances,
          'deductions': deductions,
          'netSalary': netSalary,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create payroll');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating payroll');
    }
  }

  Future<List<dynamic>> getPayrolls({
    String? employeeId,
    String? companyId,
    int? month,
    int? year,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (employeeId != null) queryParams['employeeId'] = employeeId;
      if (companyId != null) queryParams['companyId'] = companyId;
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;

      final response = await _dio.get(
        '/finance/payroll',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch payrolls');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching payrolls');
    }
  }

  Future<Map<String, dynamic>> updatePayroll(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.patch('/finance/payroll/$id', data: data);
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to update payroll');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error updating payroll');
    }
  }

  Future<void> deletePayroll(String id) async {
    try {
      final response = await _dio.delete('/finance/payroll/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete payroll');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error deleting payroll');
    }
  }

  Future<Map<String, dynamic>> markPayrollPaid(String payrollId) async {
    try {
      final response = await _dio.post(
        '/finance/payroll/pay',
        data: {'payrollId': payrollId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to mark payroll as paid');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error marking payroll as paid',
      );
    }
  }

  Future<dynamic> downloadPayrollSlip(String id) async {
    try {
      final response = await _dio.get('/finance/payroll/$id/slip');
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to download slip');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error downloading slip');
    }
  }

  Future<void> sendPayrollEmail({
    required String id,
    String? customHtml,
    String? notes,
  }) async {
    try {
      final response = await _dio.post(
        '/finance/payroll/$id/send-email',
        data: {
          if (customHtml != null) 'customHtml': customHtml,
          if (notes != null) 'notes': notes,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to send email');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error sending email');
    }
  }

  Future<Map<String, dynamic>> generatePayroll({
    required String attendanceId,
    required int month,
    required int year,
  }) async {
    try {
      final response = await _dio.post(
        '/finance/generate',
        data: {'attendanceId': attendanceId, 'month': month, 'year': year},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to generate payroll');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error generating payroll',
      );
    }
  }

  Future<Map<String, dynamic>> generateSinglePayroll(
    String attendanceId,
  ) async {
    try {
      final response = await _dio.post(
        '/finance/generate-single',
        data: {'attendanceId': attendanceId},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to generate single payroll');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error generating single payroll',
      );
    }
  }

  Future<Map<String, dynamic>> createExpense({
    required String companyId,
    required String title,
    required double amount,
    required String currency,
    required String category,
    required String date,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        '/finance/expenses',
        data: {
          'companyId': companyId,
          'title': title,
          'amount': amount,
          'currency': currency,
          'category': category,
          'date': date,
          'description': description,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create expense');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating expense');
    }
  }

  Future<List<dynamic>> getExpenses({
    String? companyId,
    String? currency,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (companyId != null) queryParams['companyId'] = companyId;
      if (currency != null) queryParams['currency'] = currency;

      final response = await _dio.get(
        '/finance/expenses',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch expenses');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching expenses');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      final response = await _dio.delete('/finance/expenses/$id');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete expense');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error deleting expense');
    }
  }

  Future<Map<String, dynamic>> getFinanceSummary({
    String? companyId,
    int? month,
    int? year,
    String? currency,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (companyId != null) queryParams['companyId'] = companyId;
      if (month != null) queryParams['month'] = month;
      if (year != null) queryParams['year'] = year;
      if (currency != null) queryParams['currency'] = currency;

      final response = await _dio.get(
        '/finance/summary',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch finance summary');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching finance summary',
      );
    }
  }

  Future<List<dynamic>> getProjects(String companyId) async {
    try {
      final response = await _dio.get(
        '/projects',
        queryParameters: {'companyId': companyId},
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch projects');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching projects');
    }
  }

  Future<Map<String, dynamic>> createProject({
    required String name,
    required String description,
    required String companyId,
    required String startDate,
    required String endDate,
    String? clientId,
    int? budget,
    List<String>? memberIds,
  }) async {
    try {
      final response = await _dio.post(
        '/projects',
        data: {
          'name': name,
          'description': description,
          'companyId': companyId,
          'startDate': startDate,
          'endDate': endDate,
          if (clientId != null) 'clientId': clientId,
          if (budget != null) 'budget': budget,
          if (memberIds != null) 'memberIds': memberIds,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create project');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating project');
    }
  }

  Future<List<dynamic>> getClients() async {
    try {
      final response = await _dio.get('/clients');
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch clients');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error fetching clients');
    }
  }

  Future<Map<String, dynamic>> createClient({
    required String name,
    required String email,
    required String phone,
    required String address,
    required String companyId,
  }) async {
    try {
      final response = await _dio.post(
        '/clients',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'companyId': companyId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to create client');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error creating client');
    }
  }

  Future<Map<String, dynamic>> startTimeTracking({
    required String employeeId,
    required String taskId,
    required String projectId,
    required String description,
  }) async {
    try {
      final response = await _dio.post(
        '/time-tracking/start',
        data: {
          'employeeId': employeeId,
          'taskId': taskId,
          'projectId': projectId,
          'description': description,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data;
      }
      throw Exception('Failed to start timer');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error starting timer');
    }
  }

  Future<Map<String, dynamic>> stopTimeTracking(
    String id,
    String description,
  ) async {
    try {
      final response = await _dio.put(
        '/time-tracking/stop/$id',
        data: {'description': description},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to stop timer');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error stopping timer');
    }
  }

  Future<List<dynamic>> getTimeTrackingEntries(String employeeId) async {
    try {
      final response = await _dio.get(
        '/time-tracking',
        queryParameters: {'employeeId': employeeId},
      );
      if (response.statusCode == 200) {
        final data = _extractData(response.data);
        return data is List ? data : [];
      }
      throw Exception('Failed to fetch time entries');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching time entries',
      );
    }
  }

  Future<void> registerFcmToken({
    required String token,
    required String platform,
    required String deviceId,
  }) async {
    try {
      print("Calling /notifications/fcm-token API...");
      print(
        "Request Data: token=$token, platform=$platform, deviceId=$deviceId",
      );
      final response = await _dio.post(
        '/notifications/fcm-token',
        data: {'token': token, 'platform': platform, 'deviceId': deviceId},
      );
      print("API Response: ${response.statusCode} - ${response.data}");
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to register FCM token');
      }
    } on DioException catch (e) {
      print("API Error: ${e.response?.statusCode} - ${e.response?.data}");
      throw Exception(
        e.response?.data['message'] ?? 'Error registering FCM token',
      );
    }
  }

  Future<List<dynamic>> getNotifications({String? companyId}) async {
    try {
      final Map<String, dynamic> params = {};
      if (companyId != null && companyId.isNotEmpty) {
        params['companyId'] = companyId;
      }
      final response = await _dio.get(
        '/notifications/mine',
        queryParameters: params.isNotEmpty ? params : null,
      );
      if (response.statusCode == 200) {
        dynamic r = response.data;
        if (r is List) return r;
        if (r is Map) {
          if (r['notifications'] is List) return r['notifications'];
          if (r['data'] is List) return r['data'];
          if (r['items'] is List) return r['items'];
          if (r['data'] is Map) {
            if (r['data']['notifications'] is List)
              return r['data']['notifications'];
            if (r['data']['data'] is List) return r['data']['data'];
            if (r['data']['items'] is List) return r['data']['items'];
          }
        }
        return [];
      }
      throw Exception('Failed to fetch notifications');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching notifications',
      );
    }
  }

  Future<Map<String, dynamic>> markNotificationAsRead(String id) async {
    try {
      final response = await _dio.patch('/notifications/$id/read');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data ?? {};
      }
      throw Exception('Failed to mark notification as read');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error marking notification as read',
      );
    }
  }

  Future<Map<String, dynamic>> markAllNotificationsRead() async {
    try {
      final response = await _dio.patch('/notifications/read-all');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data ?? {};
      }
      throw Exception('Failed to mark all notifications as read');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ??
            'Error marking all notifications as read',
      );
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final notifications = await getNotifications();
      return notifications
          .where((n) => n['isRead'] == false || n['read'] == false)
          .length;
    } catch (_) {
      return 0;
    }
  }

  Future<Map<String, dynamic>> sendNotification({
    required String title,
    required String message,
    String? type,
    String? targetUserId,
  }) async {
    try {
      final response = await _dio.post(
        '/notifications',
        data: {
          'title': title,
          'message': message,
          if (type != null) 'type': type,
          if (targetUserId != null) 'targetUserId': targetUserId,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data ?? {};
      }
      throw Exception('Failed to send notification');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error sending notification',
      );
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final response = await _dio.delete('/notifications/$id');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete notification');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error deleting notification',
      );
    }
  }

  // ─────────────────────────── RECRUITMENT / JOBS ───────────────────────────

  Future<List<dynamic>> getJobs({String? companyId}) async {
    List<dynamic> apiJobs = [];
    try {
      final Map<String, dynamic> params = {};
      if (companyId != null && companyId.isNotEmpty) {
        params['companyId'] = companyId;
      }

      final response = await _dio.get(
        '/jobs',
        queryParameters: params.isNotEmpty ? params : null,
      );

      if (response.statusCode == 200) {
        dynamic r = response.data;
        if (r is String) {
          try {
            r = jsonDecode(r);
          } catch (_) {}
        }
        if (r is List) {
          apiJobs = r;
        } else if (r is Map) {
          if (r['jobs'] is List)
            apiJobs = r['jobs'] as List;
          else if (r['data'] is List)
            apiJobs = r['data'] as List;
          else if (r['items'] is List)
            apiJobs = r['items'] as List;
          else if (r['data'] is Map) {
            final inner = r['data'] as Map;
            if (inner['jobs'] is List)
              apiJobs = inner['jobs'] as List;
            else if (inner['data'] is List)
              apiJobs = inner['data'] as List;
            else if (inner['items'] is List)
              apiJobs = inner['items'] as List;
          }
        }
      }
    } catch (e) {
      print('DEBUG getJobs API failed: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      var localJobsStr = prefs.getString('local_mock_jobs') ?? '[]';
      var localJobs = jsonDecode(localJobsStr) as List<dynamic>;

      // If no jobs exist at all, seed with some dummy data!
      if (localJobs.isEmpty && apiJobs.isEmpty) {
        final mockJob1 = {
          'id': 'mock-seed-job-1',
          '_id': 'mock-seed-job-1',
          'title': 'Senior Flutter Developer',
          'department': 'Engineering',
          'location': 'Remote',
          'type': 'Full-time',
          'status': 'Active',
          'createdAt': DateTime.now()
              .subtract(const Duration(days: 2))
              .toIso8601String(),
        };
        final mockJob2 = {
          'id': 'mock-seed-job-2',
          '_id': 'mock-seed-job-2',
          'title': 'Product Manager',
          'department': 'Product',
          'location': 'New York, USA',
          'type': 'Full-time',
          'status': 'Active',
          'createdAt': DateTime.now()
              .subtract(const Duration(days: 5))
              .toIso8601String(),
        };
        localJobs = [mockJob1, mockJob2];
        await prefs.setString('local_mock_jobs', jsonEncode(localJobs));
      }

      return [...localJobs, ...apiJobs];
    } catch (e) {
      return apiJobs;
    }
  }

  Future<Map<String, dynamic>> postJob(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/jobs', data: data);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return response.data ?? {};
      }
      throw Exception('Failed to post job');
    } catch (e) {
      print('DEBUG postJob API failed: $e, saving locally...');
      final prefs = await SharedPreferences.getInstance();

      final mockJob = {
        ...data,
        'id': 'mock-job-${DateTime.now().millisecondsSinceEpoch}',
        '_id': 'mock-job-${DateTime.now().millisecondsSinceEpoch}',
        'createdAt': DateTime.now().toIso8601String(),
      };

      final localJobsStr = prefs.getString('local_mock_jobs') ?? '[]';
      final List<dynamic> localJobs = jsonDecode(localJobsStr);
      localJobs.insert(0, mockJob);
      await prefs.setString('local_mock_jobs', jsonEncode(localJobs));

      // Also generate some mock applications for this job!
      final localAppsStr = prefs.getString('local_mock_applications') ?? '[]';
      final List<dynamic> localApps = jsonDecode(localAppsStr);

      final mockApp1 = {
        'id': 'app-1-${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Pritam Singh',
        'role': data['title'] ?? 'Developer',
        'location': 'Mumbai, India',
        'experience': '3 Years',
        'appliedDate': 'Just now',
        'status': 'New',
        'jobId': mockJob['id'],
      };
      final mockApp2 = {
        'id': 'app-2-${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Rahul Verma',
        'role': data['title'] ?? 'Developer',
        'location': 'Delhi, India',
        'experience': '5 Years',
        'appliedDate': 'Just now',
        'status': 'Shortlisted',
        'jobId': mockJob['id'],
      };

      localApps.insert(0, mockApp2);
      localApps.insert(0, mockApp1);
      await prefs.setString('local_mock_applications', jsonEncode(localApps));

      return mockJob;
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      await _dio.delete('/jobs/$jobId');
    } catch (e) {
      print('DEBUG deleteJob API failed: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final localJobsStr = prefs.getString('local_mock_jobs') ?? '[]';
      final List<dynamic> localJobs = jsonDecode(localJobsStr);
      final initialLength = localJobs.length;
      localJobs.removeWhere((job) => job['id'] == jobId || job['_id'] == jobId);

      if (localJobs.length != initialLength) {
        await prefs.setString('local_mock_jobs', jsonEncode(localJobs));
      }
    } catch (e) {
      print('DEBUG deleteJob local failed: $e');
    }
  }

  Future<List<dynamic>> getJobApplications({String? companyId}) async {
    List<dynamic> apiApps = [];
    try {
      final Map<String, dynamic> params = {};
      if (companyId != null && companyId.isNotEmpty) {
        params['companyId'] = companyId;
      }
      final response = await _dio.get(
        '/applications',
        queryParameters: params.isNotEmpty ? params : null,
      );
      if (response.statusCode == 200) {
        dynamic r = response.data;
        if (r is List)
          apiApps = r;
        else if (r is Map) {
          if (r['applications'] is List)
            apiApps = r['applications'];
          else if (r['data'] is List)
            apiApps = r['data'];
          else if (r['items'] is List)
            apiApps = r['items'];
          else if (r['data'] is Map) {
            if (r['data']['applications'] is List)
              apiApps = r['data']['applications'];
            else if (r['data']['data'] is List)
              apiApps = r['data']['data'];
            else if (r['data']['items'] is List)
              apiApps = r['data']['items'];
          }
        }
      }
    } catch (e) {
      print('DEBUG getJobApplications API failed: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      var localAppsStr = prefs.getString('local_mock_applications') ?? '[]';
      var localApps = jsonDecode(localAppsStr) as List<dynamic>;

      // If no applications exist at all, seed with dummy data
      if (localApps.isEmpty && apiApps.isEmpty) {
        final mockApp1 = {
          'id': 'seed-app-1',
          'name': 'Pritam Singh',
          'role': 'Senior Flutter Developer',
          'location': 'Mumbai, India',
          'experience': '3 Years',
          'appliedDate': '2 days ago',
          'status': 'New',
          'jobId': 'mock-seed-job-1',
        };
        final mockApp2 = {
          'id': 'seed-app-2',
          'name': 'Rahul Verma',
          'role': 'Senior Flutter Developer',
          'location': 'Delhi, India',
          'experience': '5 Years',
          'appliedDate': '3 days ago',
          'status': 'Shortlisted',
          'jobId': 'mock-seed-job-1',
        };
        final mockApp3 = {
          'id': 'seed-app-3',
          'name': 'Sneha Gupta',
          'role': 'Product Manager',
          'location': 'Bangalore, India',
          'experience': '4 Years',
          'appliedDate': '5 days ago',
          'status': 'Interview',
          'jobId': 'mock-seed-job-2',
        };
        localApps = [mockApp1, mockApp2, mockApp3];
        await prefs.setString('local_mock_applications', jsonEncode(localApps));
      }

      return [...localApps, ...apiApps];
    } catch (e) {
      return apiApps;
    }
  }

  // ─────────────────────────── DASHBOARD ───────────────────────────

  Future<Map<String, dynamic>> getDashboardMetrics({
    required String companyId,
    String? userId,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {'companyId': companyId};
      if (userId != null) queryParams['userId'] = userId;
      final response = await _dio.get(
        '/dashboard/metrics',
        queryParameters: queryParams,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch dashboard metrics');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching dashboard metrics',
      );
    }
  }

  Future<Map<String, dynamic>> getDashboardCharts(String companyId) async {
    try {
      final response = await _dio.get(
        '/dashboard/charts',
        queryParameters: {'companyId': companyId},
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw Exception('Failed to fetch dashboard charts');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error fetching dashboard charts',
      );
    }
  }

  Future<void> saveToken(String token) async {
    await _prefs.setString('jwt_token', token);
  }

  Future<String?> getToken() async {
    return _prefs.getString('jwt_token');
  }

  Future<void> clearToken() async {
    await _prefs.remove('jwt_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> updateFCMToken({
    required String token,
    required String platform,
    required String deviceId,
  }) async {
    try {
      final response = await _dio.post(
        '/notifications/fcm-token',
        data: {'token': token, 'platform': platform, 'deviceId': deviceId},
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to update FCM token');
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data['message'] ?? 'Error updating FCM token: $e',
      );
    }
  }
}
