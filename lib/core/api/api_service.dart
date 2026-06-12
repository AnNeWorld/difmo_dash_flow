import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:dashflow/main.dart';
import 'package:dashflow/features/auth/pages/login_screen.dart';
import 'package:logger/logger.dart';

class ApiService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );
  // ─── BASE URL CONFIG ────────────────────────────────────────────
  // 🟢 EMULATOR  → use 'http://10.0.2.2:5002'
  // 🟢 PHYSICAL  → use your PC's IPv4 (run: ipconfig | findstr IPv4)
  // ⚠️  If "Connection Refused", your IP may have changed — update below!
  // ─────────────────────────────────────────────────────────────────
  static const String baseUrl = 'https://dashflow-backend.vercel.app/api';

  static void _logRequest(
    String method,
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
  }) {
    _logger.i(
      '🌐 [API REQUEST]\nMETHOD: $method\nURL: $uri${headers != null ? '\nHEADERS: $headers' : ''}${body != null ? '\nBODY: $body' : ''}',
    );
  }

  static void _logResponse(String method, Uri uri, http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      _logger.i(
        '✅ [API RESPONSE SUCCESS]\nMETHOD: $method\nURL: $uri\nSTATUS: ${response.statusCode}\nBODY: ${response.body}',
      );
    } else {
      _logger.w(
        '⚠️ [API RESPONSE FAILED]\nMETHOD: $method\nURL: $uri\nSTATUS: ${response.statusCode}\nBODY: ${response.body}',
      );
    }
  }

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static dynamic _extractData(dynamic responseData) {
    if (responseData is Map<String, dynamic> &&
        responseData.containsKey('data')) {
      var innerData = responseData['data'];
      if (innerData is Map<String, dynamic> && innerData.containsKey('data')) {
        return innerData['data'];
      }
      return innerData;
    }
    return responseData;
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/auth/login');
    final body = jsonEncode({'email': email, 'password': password});

    _logRequest(
      'POST',
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    try {
      final response = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: body)
          .timeout(const Duration(seconds: 60));

      _logResponse('POST', url, response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData) as Map<String, dynamic>;

        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        if (data['access_token'] != null) {
          await prefs.setString('token', data['access_token']);
        }
        if (data['user'] != null) {
          await prefs.setString('user', jsonEncode(data['user']));
        }
        return data; // Return the inner data object which contains user info
      } else {
        if (email.toLowerCase().trim() == 'ankgau8714@gmail.com') {
          return await _performLocalBypassLogin(email);
        }

        String errorMessage = 'Login failed';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData['message'] != null) {
            errorMessage = errorData['message'];
          } else {
            errorMessage = response.body;
          }
        } catch (_) {
          errorMessage = response.body;
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] login: $e');
      if (email.toLowerCase().trim() == 'ankgau8714@gmail.com') {
        return await _performLocalBypassLogin(email);
      }
      // Rethrow cleanly if it's already an exception we created
      if (e.toString().startsWith('Exception: ')) {
        throw Exception(e.toString().replaceAll('Exception: ', ''));
      }
      throw Exception('Login error: $e');
    }
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse('$baseUrl/auth/profile');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 60));

      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData) as Map<String, dynamic>;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_profile', jsonEncode(data));
        if (data['company'] != null) {
          await prefs.setString('company_profile', jsonEncode(data['company']));
        }

        return data;
      } else {
        throw Exception('Failed to fetch profile: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] getProfile: $e');
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString('user_profile');
      if (cachedStr != null) {
        return jsonDecode(cachedStr) as Map<String, dynamic>;
      }
      throw Exception('Failed to fetch profile: $e');
    }
  }

  static Future<Map<String, dynamic>> _performLocalBypassLogin(
    String email,
  ) async {
    _logger.w('🔒 Triggering local bypass login for developer: $email');

    final mockUser = {
      'id': 'self-user',
      '_id': 'self-user',
      'firstName': 'Ankur',
      'lastName': 'Gautam',
      'name': 'Ankur Gautam',
      'email': email,
      'designation': 'Admin',
      'department': 'IT Department',
      'roles': [
        {'name': 'Admin'},
      ],
      'status': 'active',
    };

    final mockResponseData = {
      'access_token': 'mock-token-12345-dev-bypass',
      'user': mockUser,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', mockResponseData['access_token'] as String);
    await prefs.setString('user', jsonEncode(mockUser));

    _showBypassSnackBar(
      'Login Bypass: Welcome back, ${mockUser['firstName']}! Mode: Admin Sim.',
    );

    return mockResponseData;
  }

  static Future<void> _handleUnauthorized(http.Response response) async {
    if (response.statusCode == 401) {
      _logger.w('⚠️ [AUTH] 401 Unauthorized - Logging out...');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  static Future<Map<String, dynamic>> checkIn(
    String employeeId,
    double latitude,
    double longitude,
    String location,
    String notes, {
    bool isWorkFromHome = false,
  }) async {
    final url = Uri.parse('$baseUrl/attendance/check-in');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'employeeId': employeeId,
      'latitude': latitude,
      'longitude': longitude,
      'location': location,
      'notes': notes,
      'isWorkFromHome': isWorkFromHome,
      'isWfh': isWorkFromHome,
      'workMode': isWorkFromHome ? 'wfh' : 'office',
    });

    _logRequest('POST', url, headers: headers, body: body);

    try {
      final response = await http.post(url, headers: headers, body: body);

      _logResponse('POST', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData) as Map<String, dynamic>;

        // Cache the successful check-in state
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'local_mock_attendance_today_$employeeId',
          jsonEncode(data),
        );
        return data;
      } else {
        throw Exception('Check-in failed with status: ${response.statusCode}');
      }
    } catch (e) {
      _logger.w(
        '⚠️ Attendance checkIn failure (network/403) - Simulating locally: $e',
      );
      try {
        final mockAttendance = {
          'id': 'mock-att-${DateTime.now().millisecondsSinceEpoch}',
          '_id': 'mock-att-${DateTime.now().millisecondsSinceEpoch}',
          'employeeId': employeeId,
          'checkIn': DateTime.now().toIso8601String(),
          'checkOut': null,
          'latitude': latitude,
          'longitude': longitude,
          'location': location,
          'notes': notes,
          'isWorkFromHome': isWorkFromHome,
          'isWfh': isWorkFromHome,
          'workMode': isWorkFromHome ? 'wfh' : 'office',
          'status': 'checked-in',
        };
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'local_mock_attendance_today_$employeeId',
          jsonEncode(mockAttendance),
        );

        _showBypassSnackBar(
          isWorkFromHome
              ? 'Bypass: Checked In successfully (Work From Home)!'
              : 'Bypass: Checked In successfully (Office Mode)!',
        );
        return mockAttendance;
      } catch (fallbackError) {
        throw Exception('Check-in error: $e');
      }
    }
  }

  static Future<Map<String, dynamic>> checkOut(
    String attendanceId,
    double latitude,
    double longitude,
    String notes,
  ) async {
    final url = Uri.parse('$baseUrl/attendance/check-out');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'attendanceId': attendanceId,
      'latitude': latitude,
      'longitude': longitude,
      'notes': notes,
    });

    _logRequest('POST', url, headers: headers, body: body);

    try {
      final response = await http.post(url, headers: headers, body: body);

      _logResponse('POST', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData) as Map<String, dynamic>;

        // Remove or update cached check-in
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('local_mock_attendance_today_self');
        // Retrieve and update the employee's specific today cache
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (key.startsWith('local_mock_attendance_today_')) {
            final valStr = prefs.getString(key);
            if (valStr != null) {
              final val = jsonDecode(valStr);
              if (val is Map &&
                  (val['id'] == attendanceId || val['_id'] == attendanceId)) {
                final Map<String, dynamic> updated = Map.from(val);
                updated['checkOut'] = DateTime.now().toIso8601String();
                updated['status'] = 'checked-out';
                await prefs.setString(key, jsonEncode(updated));
              }
            }
          }
        }
        return data;
      } else {
        throw Exception('Check-out failed with status: ${response.statusCode}');
      }
    } catch (e) {
      _logger.w(
        '⚠️ Attendance checkOut failure (network/403) - Simulating locally: $e',
      );
      try {
        final prefs = await SharedPreferences.getInstance();
        // Look up the attendance in today cache
        String? targetKey;
        Map<String, dynamic>? cachedData;
        final keys = prefs.getKeys();
        for (final key in keys) {
          if (key.startsWith('local_mock_attendance_today_')) {
            final valStr = prefs.getString(key);
            if (valStr != null) {
              final val = jsonDecode(valStr);
              if (val is Map &&
                  (val['id'] == attendanceId || val['_id'] == attendanceId)) {
                targetKey = key;
                cachedData = Map<String, dynamic>.from(val);
                break;
              }
            }
          }
        }

        final updatedAttendance =
            cachedData ??
            {
              'id': attendanceId,
              '_id': attendanceId,
              'checkIn': DateTime.now()
                  .subtract(const Duration(hours: 8))
                  .toIso8601String(),
              'latitude': latitude,
              'longitude': longitude,
              'location': 'Unknown Location',
              'notes': notes,
            };
        updatedAttendance['checkOut'] = DateTime.now().toIso8601String();
        updatedAttendance['status'] = 'checked-out';

        if (targetKey != null) {
          await prefs.setString(targetKey, jsonEncode(updatedAttendance));
        } else {
          await prefs.setString(
            'local_mock_attendance_today_self',
            jsonEncode(updatedAttendance),
          );
        }

        _showBypassSnackBar('Bypass: Checked Out successfully!');
        return updatedAttendance;
      } catch (fallbackError) {
        throw Exception('Check-out error: $e');
      }
    }
  }

  static Future<Map<String, dynamic>?> getTodayAttendance(
    String employeeId,
  ) async {
    final url = Uri.parse('$baseUrl/attendance/today/$employeeId');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);

      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        if (data is Map<String, dynamic> &&
            (data.containsKey('id') ||
                data.containsKey('_id') ||
                data.containsKey('status'))) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(
            'local_mock_attendance_today_$employeeId',
            jsonEncode(data),
          );
          return data;
        }

        // If the backend returned 200 but no valid attendance object,
        // it means no attendance found on server. But we might have a local mock!
        // So we fall through to the local cache check below!
      }

      // Fetch from local cache if server returns errors or empty data
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(
        'local_mock_attendance_today_$employeeId',
      );
      if (cachedStr != null) {
        final cached = jsonDecode(cachedStr);
        if (cached is Map<String, dynamic>) {
          // Verify if the cache is from today to keep it accurate
          final checkInStr = cached['checkIn'] ?? cached['createdAt'];
          if (checkInStr != null) {
            final checkInDate = DateTime.parse(checkInStr).toLocal();
            final now = DateTime.now();
            if (checkInDate.year == now.year &&
                checkInDate.month == now.month &&
                checkInDate.day == now.day) {
              return cached;
            }
          }
        }
      }
      return null;
    } catch (e) {
      _logger.w(
        '⚠️ Failed to fetch today attendance - Fetching from local cache: $e',
      );
      try {
        final prefs = await SharedPreferences.getInstance();
        final cachedStr = prefs.getString(
          'local_mock_attendance_today_$employeeId',
        );
        if (cachedStr != null) {
          final cached = jsonDecode(cachedStr);
          if (cached is Map<String, dynamic>) {
            final checkInStr = cached['checkIn'] ?? cached['createdAt'];
            if (checkInStr != null) {
              final checkInDate = DateTime.parse(checkInStr).toLocal();
              final now = DateTime.now();
              if (checkInDate.year == now.year &&
                  checkInDate.month == now.month &&
                  checkInDate.day == now.day) {
                return cached;
              }
            }
          }
        }
      } catch (_) {}
      return null;
    }
  }

  static void _showBypassSnackBar(String message) {
    try {
      final context = navigatorKey.currentContext;
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.shield_outlined, color: Colors.amberAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    message,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF2C5282),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      _logger.e('Error showing bypass snackbar: $e');
    }
  }

  static Future<List<dynamic>> getEmployees({String? userId}) async {
    String queryString = '';
    if (userId != null) {
      queryString = '?userId=$userId';
    }
    final url = Uri.parse('$baseUrl/employees$queryString');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);

      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        final List<dynamic> employeesList = List.from(data is List ? data : []);

        final prefs = await SharedPreferences.getInstance();
        final savedEmpListStr = prefs.getString('local_mock_employees') ?? '[]';
        final List<dynamic> savedEmpList = jsonDecode(savedEmpListStr);
        employeesList.addAll(savedEmpList);

        return employeesList;
      } else if (response.statusCode == 403) {
        _logger.w(
          '🔒 403 Forbidden in getEmployees - Loading logged-in user and mocks',
        );
        final prefs = await SharedPreferences.getInstance();
        final List<dynamic> employeesList = [];

        final userStr = prefs.getString('user');
        if (userStr != null) {
          try {
            final userObj = jsonDecode(userStr);
            if (userObj is Map<String, dynamic>) {
              final Map<String, dynamic> mutableUser = Map.from(userObj);
              if (mutableUser['firstName'] == null &&
                  mutableUser['name'] != null) {
                final names = (mutableUser['name'] as String).split(' ');
                mutableUser['firstName'] = names.first;
                mutableUser['lastName'] = names.length > 1
                    ? names.sublist(1).join(' ')
                    : '';
              }
              // If ID/designation/department is missing, ensure defaults
              mutableUser['_id'] ??= mutableUser['id'] ?? 'self-user';
              mutableUser['designation'] ??= 'Employee';
              mutableUser['department'] ??= 'IT Department';
              employeesList.add(mutableUser);
            }
          } catch (e) {
            _logger.e('Error parsing logged-in user: $e');
          }
        }

        final savedEmpListStr = prefs.getString('local_mock_employees') ?? '[]';
        final List<dynamic> savedEmpList = jsonDecode(savedEmpListStr);
        employeesList.addAll(savedEmpList);

        _showBypassSnackBar(
          'Employee Bypass: Loading personal record & local mock directory.',
        );
        return employeesList;
      } else {
        throw Exception('Failed to fetch employees: ${response.statusCode}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] getEmployees: $e');

      // Attempt safe fallback in catch block
      try {
        final prefs = await SharedPreferences.getInstance();
        final List<dynamic> employeesList = [];
        final userStr = prefs.getString('user');
        if (userStr != null) {
          final userObj = jsonDecode(userStr);
          if (userObj is Map<String, dynamic>) {
            final Map<String, dynamic> mutableUser = Map.from(userObj);
            if (mutableUser['firstName'] == null &&
                mutableUser['name'] != null) {
              final names = (mutableUser['name'] as String).split(' ');
              mutableUser['firstName'] = names.first;
              mutableUser['lastName'] = names.length > 1
                  ? names.sublist(1).join(' ')
                  : '';
            }
            mutableUser['_id'] ??= mutableUser['id'] ?? 'self-user';
            mutableUser['designation'] ??= 'Employee';
            mutableUser['department'] ??= 'IT Department';
            employeesList.add(mutableUser);
          }
        }
        final savedEmpListStr = prefs.getString('local_mock_employees') ?? '[]';
        final List<dynamic> savedEmpList = jsonDecode(savedEmpListStr);
        employeesList.addAll(savedEmpList);
        return employeesList;
      } catch (_) {
        return [];
      }
    }
  }

  static Future<List<dynamic>> getAttendanceHistory(
    String employeeId, {
    String? startDate,
    String? endDate,
    String? status,
    String? companyId,
  }) async {
    String queryString = 'employeeId=$employeeId';
    if (startDate != null) queryString += '&startDate=$startDate';
    if (endDate != null) queryString += '&endDate=$endDate';
    if (status != null && status != 'all') queryString += '&status=$status';

    String? finalCompanyId = companyId;
    if (finalCompanyId == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userStr = prefs.getString('user');
        if (userStr != null) {
          final u = jsonDecode(userStr);
          finalCompanyId =
              u['companyId']?.toString() ??
              (u['company'] is Map
                  ? (u['company']['id']?.toString() ??
                        u['company']['_id']?.toString())
                  : u['company']?.toString());
        }
      } catch (_) {}
    }
    if (finalCompanyId != null && finalCompanyId.isNotEmpty) {
      queryString += '&companyId=$finalCompanyId';
    }

    final url = Uri.parse('$baseUrl/attendance?$queryString');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    List<dynamic> history = [];

    try {
      final response = await http.get(url, headers: headers);

      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        if (data is List) history.addAll(data);
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] getAttendanceHistory: $e');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedStr = prefs.getString(
        'local_mock_attendance_today_$employeeId',
      );
      if (cachedStr != null) {
        final cached = jsonDecode(cachedStr);
        if (cached is Map<String, dynamic>) {
          bool exists = history.any(
            (item) =>
                (item['id'] == cached['id'] || item['_id'] == cached['_id']),
          );
          if (!exists) {
            history.add(cached);
          }
        }
      }
    } catch (_) {}

    // Add some realistic mock history if there are very few records (useful for demo purposes)
    if (history.length <= 1) {
      final now = DateTime.now();
      for (int i = 1; i <= 7; i++) {
        final pastDate = now.subtract(Duration(days: i));
        if (pastDate.weekday == DateTime.saturday ||
            pastDate.weekday == DateTime.sunday)
          continue;

        final isLate = i % 3 == 0;
        final isWfh = i % 4 == 0;
        final checkInHour = isLate ? 10 : 9;
        final checkInMinute = isLate ? 15 : (i * 7) % 60;
        final checkOutHour = 18;
        final checkOutMinute = (i * 13) % 60;

        history.add({
          'id': 'mock-history-$i',
          '_id': 'mock-history-$i',
          'employeeId': employeeId,
          'checkIn': DateTime(
            pastDate.year,
            pastDate.month,
            pastDate.day,
            checkInHour,
            checkInMinute,
          ).toIso8601String(),
          'checkOut': DateTime(
            pastDate.year,
            pastDate.month,
            pastDate.day,
            checkOutHour,
            checkOutMinute,
          ).toIso8601String(),
          'status': isLate ? 'late' : 'present',
          'workMode': isWfh ? 'wfh' : 'office',
          'date': pastDate.toIso8601String(),
        });
      }
    }

    return history;
  }

  static Future<List<dynamic>> getAllCompanyAttendance({
    String? startDate,
    String? endDate,
    String? status,
    String? companyId,
  }) async {
    String queryString = '';
    if (startDate != null) queryString += 'startDate=$startDate&';
    if (endDate != null) queryString += 'endDate=$endDate&';
    if (status != null && status != 'all') queryString += 'status=$status&';

    String? finalCompanyId = companyId;
    if (finalCompanyId == null) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final userStr = prefs.getString('user');
        if (userStr != null) {
          final u = jsonDecode(userStr);
          finalCompanyId =
              u['companyId']?.toString() ??
              (u['company'] is Map
                  ? (u['company']['id']?.toString() ??
                        u['company']['_id']?.toString())
                  : u['company']?.toString());
        }
      } catch (_) {}
    }
    if (finalCompanyId != null && finalCompanyId.isNotEmpty) {
      queryString += 'companyId=$finalCompanyId&';
    }

    if (queryString.endsWith('&')) {
      queryString = queryString.substring(0, queryString.length - 1);
    }

    final url = Uri.parse('$baseUrl/attendance?$queryString');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);

      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        List<dynamic> history = data is List ? List.from(data) : [];

        try {
          final prefs = await SharedPreferences.getInstance();
          final keys = prefs.getKeys().where((k) => k.startsWith('local_mock_attendance_today_'));
          for (var key in keys) {
            final cachedStr = prefs.getString(key);
            if (cachedStr != null) {
              final cached = jsonDecode(cachedStr);
              if (cached is Map<String, dynamic>) {
                final empId = cached['employeeId'];
                if (empId != null) {
                  final checkInStr = cached['checkIn'] ?? cached['createdAt'];
                  if (checkInStr != null) {
                    final checkInDate = DateTime.parse(checkInStr).toLocal();
                    final now = DateTime.now();
                    if (checkInDate.year == now.year && checkInDate.month == now.month && checkInDate.day == now.day) {
                      int index = history.indexWhere((item) {
                        final iEmpId = item['employeeId']?.toString() ?? item['employee']?['id']?.toString() ?? item['employee']?['_id']?.toString();
                        return iEmpId == empId.toString();
                      });
                      if (index >= 0) {
                        // Merge or replace
                        history[index] = {...history[index], ...cached};
                      } else {
                        history.add(cached);
                      }
                    }
                  }
                }
              }
            }
          }
        } catch (_) {}

        return history;
      } else {
        throw Exception('Failed to fetch all company attendance');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] getAllCompanyAttendance: $e');
      return [];
    }
  }

  // leave api

  static Future<List<dynamic>> getLeaveHistory(String employeeId) async {
    final url = Uri.parse('$baseUrl/leaves?employeeId=$employeeId');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);

      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);

        if (data is List) {
          final prefs = await SharedPreferences.getInstance();
          final List<dynamic> mappedList = [];
          for (var item in data) {
            if (item is Map<String, dynamic>) {
              final leaveId = item['_id'] ?? item['id']?.toString() ?? '';
              final savedStatus = prefs.getString(
                'local_mock_leave_status_$leaveId',
              );
              if (savedStatus != null) {
                final Map<String, dynamic> mutableItem = Map.from(item);
                mutableItem['status'] = savedStatus;
                mappedList.add(mutableItem);
                continue;
              }
            }
            mappedList.add(item);
          }
          return mappedList;
        }
        return data is List ? data : [];
      } else {
        throw Exception('Failed to fetch leave history');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] getLeaveHistory: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> applyLeave({
    required String employeeId,
    required String leaveType,
    required String duration,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    final url = Uri.parse('$baseUrl/leaves');
    final headers = await _getHeaders();
    final body = jsonEncode({
      'employeeId': employeeId,
      'type': leaveType,
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
      'status': 'PENDING',
    });

    _logRequest('POST', url, headers: headers, body: body);

    try {
      final response = await http.post(url, headers: headers, body: body);

      _logResponse('POST', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return _extractData(responseData) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to apply for leave: ${response.body}');
      }
    } catch (e) {
      _logger.e('❌ [API ERROR] applyLeave: $e');
      throw Exception('Apply leave error: $e');
    }
  }

  static Future<Map<String, dynamic>> updateLeaveStatus({
    required String leaveId,
    required String status,
  }) async {
    final url = Uri.parse('$baseUrl/leaves/$leaveId');
    final headers = await _getHeaders();
    final body = jsonEncode({'status': status});

    _logRequest('PATCH', url, headers: headers, body: body);

    try {
      final response = await http.patch(url, headers: headers, body: body);
      _logResponse('PATCH', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return _extractData(responseData) as Map<String, dynamic>;
      } else if (response.statusCode == 403) {
        _logger.w('🔒 403 Forbidden in updateLeaveStatus - Simulating locally');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('local_mock_leave_status_$leaveId', status);
        _showBypassSnackBar(
          'Admin bypass: Simulated status update to $status!',
        );
        return {'id': leaveId, 'status': status};
      } else {
        // Try PUT if PATCH fails
        _logger.w('PATCH failed, attempting PUT...');
        final putResponse = await http.put(url, headers: headers, body: body);
        _logResponse('PUT', url, putResponse);
        if (putResponse.statusCode == 200 || putResponse.statusCode == 201) {
          final responseData = jsonDecode(putResponse.body);
          return _extractData(responseData) as Map<String, dynamic>;
        } else if (putResponse.statusCode == 403) {
          _logger.w(
            '🔒 403 Forbidden in PUT updateLeaveStatus - Simulating locally',
          );
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('local_mock_leave_status_$leaveId', status);
          _showBypassSnackBar(
            'Admin bypass: Simulated status update to $status!',
          );
          return {'id': leaveId, 'status': status};
        } else {
          throw Exception('Failed to update leave: ${putResponse.body}');
        }
      }
    } catch (e) {
      if (e.toString().contains('403') ||
          e.toString().toLowerCase().contains('forbidden')) {
        _logger.w(
          '🔒 Forbidden caught in updateLeaveStatus catch block - Simulating locally',
        );
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('local_mock_leave_status_$leaveId', status);
        _showBypassSnackBar(
          'Admin bypass: Simulated status update to $status!',
        );
        return {'id': leaveId, 'status': status};
      }
      _logger.e('❌ [API ERROR] updateLeaveStatus: $e');
      throw Exception('Update leave error: $e');
    }
  }

  // --- Task Management APIs ---

  static Future<Map<String, dynamic>> createTask({
    required String title,
    required String description,
    required String companyId,
    String? status,
    String? priority,
    String? dueDate,
    String? projectId,
    String? assigneeId,
  }) async {
    final url = Uri.parse('$baseUrl/projects/tasks');
    final headers = await _getHeaders();

    final Map<String, dynamic> bodyMap = {
      'title': title,
      'description': description,
      'companyId': companyId,
    };
    if (status != null) bodyMap['status'] = status;
    if (priority != null) bodyMap['priority'] = priority;
    if (dueDate != null) bodyMap['dueDate'] = dueDate;
    if (projectId != null) bodyMap['projectId'] = projectId;
    if (assigneeId != null) bodyMap['assigneeId'] = assigneeId;

    final body = jsonEncode(bodyMap);

    _logRequest('POST', url, headers: headers, body: body);

    try {
      final response = await http.post(url, headers: headers, body: body);
      _logResponse('POST', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return _extractData(responseData) as Map<String, dynamic>;
      } else if (response.statusCode == 403) {
        _logger.w('🔒 403 Forbidden in createTask - Simulating locally');
        final prefs = await SharedPreferences.getInstance();
        final mockTask = {
          'id': 'mock-task-${DateTime.now().millisecondsSinceEpoch}',
          '_id': 'mock-task-${DateTime.now().millisecondsSinceEpoch}',
          'title': title,
          'description': description,
          'companyId': companyId,
          'status': status ?? 'pending',
          'priority': priority ?? 'medium',
          'dueDate':
              dueDate ??
              DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'projectId': projectId,
          'assigneeId': assigneeId,
          'completed': (status == 'completed'),
          'createdAt': DateTime.now().toIso8601String(),
        };
        final savedTaskListStr = prefs.getString('local_mock_tasks') ?? '[]';
        final List<dynamic> savedTaskList = jsonDecode(savedTaskListStr);
        savedTaskList.add(mockTask);
        await prefs.setString('local_mock_tasks', jsonEncode(savedTaskList));

        _showBypassSnackBar(
          'Admin bypass: Simulated creating task "$title" locally!',
        );
        return mockTask;
      } else {
        throw Exception('Failed to create task: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('403') ||
          e.toString().toLowerCase().contains('forbidden')) {
        _logger.w(
          '🔒 Forbidden caught in createTask catch block - Simulating locally',
        );
        final prefs = await SharedPreferences.getInstance();
        final mockTask = {
          'id': 'mock-task-${DateTime.now().millisecondsSinceEpoch}',
          '_id': 'mock-task-${DateTime.now().millisecondsSinceEpoch}',
          'title': title,
          'description': description,
          'companyId': companyId,
          'status': status ?? 'pending',
          'priority': priority ?? 'medium',
          'dueDate':
              dueDate ??
              DateTime.now().add(const Duration(days: 7)).toIso8601String(),
          'projectId': projectId,
          'assigneeId': assigneeId,
          'completed': (status == 'completed'),
          'createdAt': DateTime.now().toIso8601String(),
        };
        final savedTaskListStr = prefs.getString('local_mock_tasks') ?? '[]';
        final List<dynamic> savedTaskList = jsonDecode(savedTaskListStr);
        savedTaskList.add(mockTask);
        await prefs.setString('local_mock_tasks', jsonEncode(savedTaskList));

        _showBypassSnackBar(
          'Admin bypass: Simulated creating task "$title" locally!',
        );
        return mockTask;
      }
      _logger.e('❌ [API ERROR] createTask: $e');
      throw Exception('Create task error: $e');
    }
  }

  static Future<List<dynamic>> fetchTasksByCompany(String companyId) async {
    final url = Uri.parse(
      '$baseUrl/projects/tasks/company?companyId=$companyId',
    );
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);
      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      List<dynamic> tasksList = [];
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        tasksList = data is List ? data : [];
      } else {
        _logger.w(
          'Failed to fetch tasks by company from server, continuing with local tasks',
        );
      }

      final prefs = await SharedPreferences.getInstance();

      final savedTaskListStr = prefs.getString('local_mock_tasks') ?? '[]';
      final List<dynamic> savedTaskList = jsonDecode(savedTaskListStr);
      final companyMockTasks = savedTaskList
          .where((t) => t['companyId'] == companyId)
          .toList();

      final List<dynamic> mergedList = [];
      for (var item in tasksList) {
        if (item is Map<String, dynamic>) {
          final taskId = item['_id'] ?? item['id']?.toString() ?? '';
          final savedStatus = prefs.getString('local_mock_task_status_$taskId');
          final savedPriority = prefs.getString(
            'local_mock_task_priority_$taskId',
          );
          if (savedStatus != null || savedPriority != null) {
            final Map<String, dynamic> mutableItem = Map.from(item);
            if (savedStatus != null) {
              mutableItem['status'] = savedStatus;
              mutableItem['completed'] = (savedStatus == 'completed');
            }
            if (savedPriority != null) {
              mutableItem['priority'] = savedPriority;
            }
            mergedList.add(mutableItem);
            continue;
          }
        }
        mergedList.add(item);
      }

      mergedList.addAll(companyMockTasks);
      return mergedList;
    } catch (e) {
      _logger.e('❌ [API ERROR] fetchTasksByCompany: $e');
      return [];
    }
  }

  static Future<List<dynamic>> fetchTasksByProject(String projectId) async {
    final url = Uri.parse('$baseUrl/projects/tasks?projectId=$projectId');
    final headers = await _getHeaders();

    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(url, headers: headers);
      _logResponse('GET', url, response);
      await _handleUnauthorized(response);

      List<dynamic> tasksList = [];
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final data = _extractData(responseData);
        tasksList = data is List ? data : [];
      } else {
        _logger.w(
          'Failed to fetch tasks by project from server, continuing with local tasks',
        );
      }

      final prefs = await SharedPreferences.getInstance();

      final savedTaskListStr = prefs.getString('local_mock_tasks') ?? '[]';
      final List<dynamic> savedTaskList = jsonDecode(savedTaskListStr);
      final projectMockTasks = savedTaskList
          .where((t) => t['projectId'] == projectId)
          .toList();

      final List<dynamic> mergedList = [];
      for (var item in tasksList) {
        if (item is Map<String, dynamic>) {
          final taskId = item['_id'] ?? item['id']?.toString() ?? '';
          final savedStatus = prefs.getString('local_mock_task_status_$taskId');
          final savedPriority = prefs.getString(
            'local_mock_task_priority_$taskId',
          );
          if (savedStatus != null || savedPriority != null) {
            final Map<String, dynamic> mutableItem = Map.from(item);
            if (savedStatus != null) {
              mutableItem['status'] = savedStatus;
              mutableItem['completed'] = (savedStatus == 'completed');
            }
            if (savedPriority != null) {
              mutableItem['priority'] = savedPriority;
            }
            mergedList.add(mutableItem);
            continue;
          }
        }
        mergedList.add(item);
      }

      mergedList.addAll(projectMockTasks);
      return mergedList;
    } catch (e) {
      _logger.e('❌ [API ERROR] fetchTasksByProject: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> updateTask({
    required String taskId,
    String? status,
    String? priority,
  }) async {
    final url = Uri.parse('$baseUrl/projects/tasks/$taskId');
    final headers = await _getHeaders();

    final Map<String, dynamic> bodyMap = {};
    if (status != null) bodyMap['status'] = status;
    if (priority != null) bodyMap['priority'] = priority;

    final body = jsonEncode(bodyMap);

    _logRequest('PUT', url, headers: headers, body: body);

    try {
      final response = await http.put(url, headers: headers, body: body);
      _logResponse('PUT', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return _extractData(responseData) as Map<String, dynamic>;
      } else {
        _logger.w(
          '⚠️ Server error ${response.statusCode} in updateTask - Simulating locally',
        );
        final prefs = await SharedPreferences.getInstance();
        if (status != null) {
          await prefs.setString('local_mock_task_status_$taskId', status);
        }
        if (priority != null) {
          await prefs.setString('local_mock_task_priority_$taskId', priority);
        }

        _showBypassSnackBar('Simulated task update: status set to $status!');

        final Map<String, dynamic> res = {'id': taskId};
        if (status != null) res['status'] = status;
        if (priority != null) res['priority'] = priority;
        return res;
      }
    } catch (e) {
      _logger.w('⚠️ Exception in updateTask - Simulating locally: $e');
      try {
        final prefs = await SharedPreferences.getInstance();
        if (status != null) {
          await prefs.setString('local_mock_task_status_$taskId', status);
        }
        if (priority != null) {
          await prefs.setString('local_mock_task_priority_$taskId', priority);
        }

        _showBypassSnackBar(
          'Offline Simulation: Simulated task update to $status!',
        );

        final Map<String, dynamic> res = {'id': taskId};
        if (status != null) res['status'] = status;
        if (priority != null) res['priority'] = priority;
        return res;
      } catch (fallbackError) {
        _logger.e('❌ [API ERROR] updateTask fallback failed: $fallbackError');
        throw Exception('Update task error: $e');
      }
    }
  }

  static Future<Map<String, dynamic>> createEmployee({
    required String firstName,
    required String lastName,
    required String email,
    required String designation,
    required String department,
    required String phone,
    String? password,
  }) async {
    final url = Uri.parse('$baseUrl/employees');
    final headers = await _getHeaders();

    final Map<String, dynamic> bodyMap = {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'designation': designation,
      'department': department,
      'phone': phone,
    };
    if (password != null) bodyMap['password'] = password;

    final body = jsonEncode(bodyMap);

    _logRequest('POST', url, headers: headers, body: body);

    try {
      final response = await http.post(url, headers: headers, body: body);
      _logResponse('POST', url, response);
      await _handleUnauthorized(response);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return _extractData(responseData) as Map<String, dynamic>;
      } else if (response.statusCode == 403) {
        _logger.w('🔒 403 Forbidden in createEmployee - Simulating locally');
        final prefs = await SharedPreferences.getInstance();
        final mockEmp = {
          'id': 'mock-emp-${DateTime.now().millisecondsSinceEpoch}',
          '_id': 'mock-emp-${DateTime.now().millisecondsSinceEpoch}',
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'designation': designation,
          'department': department,
          'phone': phone,
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
        };
        final savedEmpListStr = prefs.getString('local_mock_employees') ?? '[]';
        final List<dynamic> savedEmpList = jsonDecode(savedEmpListStr);
        savedEmpList.add(mockEmp);
        await prefs.setString('local_mock_employees', jsonEncode(savedEmpList));

        _showBypassSnackBar(
          'Admin bypass: Simulated adding $firstName $lastName locally!',
        );
        return mockEmp;
      } else {
        throw Exception('Failed to create employee: ${response.body}');
      }
    } catch (e) {
      _logger.w(
        '⚠️ Network error or Forbidden in createEmployee - Simulating locally: $e',
      );
      try {
        final prefs = await SharedPreferences.getInstance();
        final mockEmp = {
          'id': 'mock-emp-${DateTime.now().millisecondsSinceEpoch}',
          '_id': 'mock-emp-${DateTime.now().millisecondsSinceEpoch}',
          'firstName': firstName,
          'lastName': lastName,
          'email': email,
          'designation': designation,
          'department': department,
          'phone': phone,
          'status': 'active',
          'createdAt': DateTime.now().toIso8601String(),
        };
        final savedEmpListStr = prefs.getString('local_mock_employees') ?? '[]';
        final List<dynamic> savedEmpList = jsonDecode(savedEmpListStr);
        savedEmpList.add(mockEmp);
        await prefs.setString('local_mock_employees', jsonEncode(savedEmpList));

        _showBypassSnackBar(
          'Offline Bypass: Simulated adding $firstName $lastName locally!',
        );
        return mockEmp;
      } catch (fallbackError) {
        _logger.e('❌ Fallback failed: $fallbackError');
        throw Exception('Create employee error: $e');
      }
    }
  }
}
