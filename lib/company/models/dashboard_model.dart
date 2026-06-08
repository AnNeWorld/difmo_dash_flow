class DashboardData {
  final int totalEmployees;
  final int presentToday;
  final double productivityPercentage;
  final int analyticsActivityCount;
  final List<AttendanceTrend> attendanceTrends;
  final double aggregateEfficiency;
  final double efficiencyChange;
  final double turnoverAmount;
  final double netProfitAmount;
  final double payrollAmount;
  final double expensesAmount;
  final double personnelBudgetPercent;
  final double resourceBudgetPercent;
  final List<ActivityFeedItem> activities;

  const DashboardData({
    this.totalEmployees = 0,
    this.presentToday = 0,
    this.productivityPercentage = 0.0,
    this.analyticsActivityCount = 0,
    this.attendanceTrends = const [],
    this.aggregateEfficiency = 0.0,
    this.efficiencyChange = 0.0,
    this.turnoverAmount = 0.0,
    this.netProfitAmount = 0.0,
    this.payrollAmount = 0.0,
    this.expensesAmount = 0.0,
    this.personnelBudgetPercent = 0.0,
    this.resourceBudgetPercent = 0.0,
    this.activities = const [],
  });
}

class AttendanceTrend {
  final String day;
  final int count;

  const AttendanceTrend({required this.day, required this.count});
}

class ActivityFeedItem {
  final String title;
  final String type;
  final String time;

  const ActivityFeedItem({
    required this.title,
    required this.type,
    required this.time,
  });
}
