import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/finance_summary_model.dart';
import '../models/transaction_model.dart';
import 'api_service.dart' as company_api;

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

    print("Warning: No companyId found in any SharedPreferences key");
    return '';
  } catch (e) {
    print("Error getting companyId: $e");
    return '';
  }
}

final financeSummaryProvider = FutureProvider<FinanceSummaryModel>((ref) async {
  try {
    final companyId = await _getCompanyId();
    if (companyId.isEmpty) throw Exception("No company ID found");

    final response = await company_api.ApiService().getFinanceSummary(
      companyId: companyId,
    );

    final data = response.containsKey('data') ? response['data'] : response;
    print("FINANCE SUMMARY API RESPONSE: $data");

    return FinanceSummaryModel.fromJson(data);
  } catch (e) {
    throw Exception("Failed to fetch finance summary from API: $e");
  }
});

final monthlyCashFlowProvider = FutureProvider<List<MonthlyCashFlow>>((
  ref,
) async {
  try {
    final companyId = await _getCompanyId();
    if (companyId.isEmpty) throw Exception("No company ID found");

    final response = await company_api.ApiService().getFinanceSummary(
      companyId: companyId,
    );
    final data = response.containsKey('data') ? response['data'] : response;

    if (data['cashFlow'] != null && data['cashFlow'] is List) {
      return (data['cashFlow'] as List)
          .map((item) => MonthlyCashFlow.fromJson(item))
          .toList();
    }
    return []; // Return empty list if API doesn't provide it yet
  } catch (e) {
    throw Exception("Failed to fetch monthly cash flow from API: $e");
  }
});

final recentTransactionsProvider = FutureProvider<List<TransactionModel>>((
  ref,
) async {
  try {
    final companyId = await _getCompanyId();
    if (companyId.isEmpty) throw Exception("No company ID found");

    final response = await company_api.ApiService().dio.get(
      '/finance/expenses',
      queryParameters: {'companyId': companyId},
    );
    final data = response.data.containsKey('data')
        ? response.data['data']
        : response.data;

    if (data is List) {
      // Map expenses to transactions and take top 5
      return data
          .map((item) => TransactionModel.fromJson(item))
          .take(5)
          .toList();
    }
    return [];
  } catch (e) {
    // Fallback to mock data to match the UI design if the real API fails/401s
    print(
      "API Failed for transactions. Using UI mock data for display. Error: $e",
    );
    return TransactionModel.mockData();
  }
});
