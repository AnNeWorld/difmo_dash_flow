import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_model.dart';
import 'package:dashflow/company/services/api_service.dart' as company_api;
import 'package:dashflow/core/api/api_service.dart' as core_api;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:math';
import 'package:intl/intl.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final service = ref.read(dashboardServiceProvider);
  return service.fetchDashboardData();
});

class DashboardService {
  Future<DashboardData> fetchDashboardData() async {
    int totalEmployees = 19;
    int presentToday = 0;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      String companyId = '';
      if (userStr != null) {
        final user = jsonDecode(userStr);
        companyId =
            user['companyId']?.toString() ??
            (user['company'] is Map
                ? (user['company']['id']?.toString() ??
                      user['company']['_id']?.toString())
                : user['company']?.toString()) ??
            '';
      }

      final list = await company_api.ApiService().getAllEmployees(
        companyId: companyId.isNotEmpty ? companyId : null,
      );

      final coreList = await core_api.ApiService.getEmployees();
      List<dynamic> combined = List.from(list);
      for (var e in coreList) {
        final id1 = e['id']?.toString() ?? e['_id']?.toString();
        if (id1 != null &&
            id1.isNotEmpty &&
            !combined.any(
              (item) =>
                  (item['id']?.toString() ?? item['_id']?.toString()) == id1,
            )) {
          combined.add(e);
        }
      }

      if (combined.isNotEmpty) {
        totalEmployees = combined.length;
      }
    } catch (_) {}

    try {
      final todayRaw = await core_api.ApiService.getAllCompanyAttendance();
      presentToday = todayRaw.length;
    } catch (_) {}

    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where(
        (k) => k.startsWith('local_mock_attendance_today_'),
      );
      for (var k in keys) {
        presentToday++;
      }
    } catch (_) {}

    final random = Random();
    final now = DateTime.now();
    List<AttendanceTrend> trends = [];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayName = DateFormat('E').format(date);

      int count = 0;
      if (i == 0) {
        count = presentToday;
      } else if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        count = (totalEmployees * (random.nextDouble() * 0.1)).round();
      } else {
        count = (totalEmployees * (0.75 + random.nextDouble() * 0.25)).round();
      }
      trends.add(AttendanceTrend(day: dayName, count: count));
    }

    double productivity = totalEmployees > 0
        ? (presentToday / totalEmployees) * 100
        : 0.0;
    if (productivity > 100) productivity = 100.0;

    double efficiency = 75.0 + random.nextDouble() * 20.0;

    return DashboardData(
      totalEmployees: totalEmployees,
      presentToday: presentToday,
      productivityPercentage: productivity,
      analyticsActivityCount: random.nextInt(10) + 1,
      attendanceTrends: trends,
      aggregateEfficiency: efficiency,
      efficiencyChange:
          (random.nextDouble() * 5.0) * (random.nextBool() ? 1 : -1),
      turnoverAmount: 1245000.0 + random.nextInt(50000),
      netProfitAmount: 342000.0 + random.nextInt(20000),
      payrollAmount: 456000.0,
      expensesAmount: 218000.0 + random.nextInt(10000),
      personnelBudgetPercent: 65.0,
      resourceBudgetPercent: 35.0,
      activities: [
        ActivityFeedItem(
          title: 'New policy update published',
          type: 'System',
          time: '10:45 AM',
        ),
        ActivityFeedItem(
          title: 'Q3 Reviews cycle initiated',
          type: 'HR',
          time: '11:20 AM',
        ),
        ActivityFeedItem(
          title: 'Server maintenance scheduled',
          type: 'IT',
          time: '02:00 PM',
        ),
      ],
    );
  }
}
