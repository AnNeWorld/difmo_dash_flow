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
      totalEmployees: 412,
      presentToday: 387,
      productivityPercentage: 94.0,
      analyticsActivityCount: 142,
      attendanceTrends: [
        AttendanceTrend(day: 'Mon', count: 350),
        AttendanceTrend(day: 'Tue', count: 380),
        AttendanceTrend(day: 'Wed', count: 390),
        AttendanceTrend(day: 'Thu', count: 387),
        AttendanceTrend(day: 'Fri', count: 360),
        AttendanceTrend(day: 'Sat', count: 120),
        AttendanceTrend(day: 'Sun', count: 110),
      ],
      aggregateEfficiency: 82.5,
      efficiencyChange: 4.2,
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
        ActivityFeedItem(title: 'Annual retreat dates announced', type: 'Event', time: '04:15 PM'),
        ActivityFeedItem(title: 'Payroll processed successfully', type: 'Finance', time: '05:30 PM'),
      ],
    );
  }
}
