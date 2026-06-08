import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/dashboard_model.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

final dashboardDataProvider = FutureProvider<DashboardData>((ref) async {
  final service = ref.read(dashboardServiceProvider);
  return service.fetchDashboardData();
});

class DashboardService {
  Future<DashboardData> fetchDashboardData() async {
    // Simulating network delay
    await Future.delayed(const Duration(seconds: 1));

    // Returning mock data based on the website dashboard
    return const DashboardData(
      totalEmployees: 19,
      presentToday: 7,
      productivityPercentage: 0.0,
      analyticsActivityCount: 0,
      attendanceTrends: [
        AttendanceTrend(day: 'Tue', count: 8),
        AttendanceTrend(day: 'Wed', count: 8),
        AttendanceTrend(day: 'Thu', count: 7),
        AttendanceTrend(day: 'Fri', count: 8),
        AttendanceTrend(day: 'Sat', count: 8),
        AttendanceTrend(day: 'Sun', count: 1),
        AttendanceTrend(day: 'Mon', count: 6),
      ],
      aggregateEfficiency: 60.0,
      efficiencyChange: 2.4,
      turnoverAmount: 1245000.0,
      netProfitAmount: 342000.0,
      payrollAmount: 456000.0,
      expensesAmount: 218000.0,
      personnelBudgetPercent: 65.0,
      resourceBudgetPercent: 35.0,
      activities: [
        ActivityFeedItem(title: 'New policy update published', type: 'System', time: '10:45 AM'),
        ActivityFeedItem(title: 'Q3 Reviews cycle initiated', type: 'HR', time: '11:20 AM'),
        ActivityFeedItem(title: 'Server maintenance scheduled', type: 'IT', time: '02:00 PM'),
      ],
    );
  }
}
