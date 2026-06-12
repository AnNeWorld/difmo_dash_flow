import 'package:dashflow/company/pages/Recruitment_page.dart';
import 'package:dashflow/company/pages/company_profile_page.dart';
import 'package:dashflow/company/pages/employees_page.dart';
import 'package:dashflow/company/pages/finance_screen.dart';
import 'package:dashflow/company/pages/my_payroll_page.dart';
import 'package:dashflow/company/pages/my_attendance_page.dart';
import 'package:dashflow/company/pages/notifications_page.dart';
import 'package:dashflow/company/pages/repots_page.dart';

import 'package:dashflow/company/pages/leave_management_screen.dart';
import 'package:dashflow/features/profile/pages/profile.dart';
import 'package:dashflow/company/components/shared/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/dashboard/stat_card_new.dart';
import '../components/dashboard/attendance_chart.dart';
import '../components/dashboard/fiscal_summary.dart';
import '../components/dashboard/quick_actions.dart';
import '../components/dashboard/activity_feed.dart';

// Services
import '../services/dashboard_service.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  String _userName = "User";

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user') ?? prefs.getString('user_profile');
    if (userStr != null) {
      try {
        final user = jsonDecode(userStr);
        final firstName = user['firstName'] ?? '';
        final lastName = user['lastName'] ?? '';
        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          setState(() {
            _userName = '$firstName $lastName'.trim();
          });
        } else if (user['user'] != null && user['user']['firstName'] != null) {
          setState(() {
            _userName = '${user['user']['firstName']} ${user['user']['lastName'] ?? ''}'.trim();
          });
        } else if (user['name'] != null) {
          setState(() {
            _userName = user['name'];
          });
        }
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final dashboardDataAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC), // Slate 50
      drawer: const AppDrawer(activeRoute: 'Dashboard'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xff0F172A)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "ADMIN DASHBOARD",
          style: TextStyle(
            color: Color(0xff0F172A),
            fontWeight: FontWeight.w800,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final unread = ref.watch(unreadCountProvider);
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_none,
                      color: Color(0xff64748B),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotificationsPage(),
                        ),
                      );
                    },
                  ),
                  if (unread > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        constraints: const BoxConstraints(
                          minWidth: 17,
                          minHeight: 17,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFFDC2626),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          unread > 99 ? '99+' : '$unread',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                radius: 16,
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : "A",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: dashboardDataAsync.when(
        data: (data) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, $_userName 👋",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Here is what's happening in your workspace today.",
                  style: TextStyle(color: Color(0xff64748B), fontSize: 15),
                ),
                const SizedBox(height: 24),

                // Top Metrics Grid
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.1,
                  children: [
                    DashboardStatCard(
                      icon: Icons.people,
                      title: "Total Employee",
                      value: data.totalEmployees.toString(),
                      tag: "+12%",
                      tagColor: Colors.green,
                      iconColor: Colors.blue.shade600,
                    ),
                    DashboardStatCard(
                      icon: Icons.how_to_reg,
                      title: "Present Today",
                      value: data.presentToday.toString(),
                      tag: "Stable",
                      tagColor: Colors.grey.shade600,
                      iconColor: Colors.purple.shade600,
                    ),
                    DashboardStatCard(
                      icon: Icons.trending_up,
                      title: "Productivity",
                      value: "${data.productivityPercentage}%",
                      tag: "+4.2%",
                      tagColor: Colors.green,
                      iconColor: Colors.orange.shade600,
                    ),
                    DashboardStatCard(
                      icon: Icons.analytics,
                      title: "Analytics",
                      value: data.analyticsActivityCount.toString(),
                      tag: "Active",
                      tagColor: Colors.blue,
                      iconColor: Colors.red.shade600,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Attendance Chart
                AttendanceChartWidget(
                  trends: data.attendanceTrends,
                  aggregateEfficiency: data.aggregateEfficiency,
                  efficiencyChange: data.efficiencyChange,
                ),

                const SizedBox(height: 24),

                // Fiscal Summary
                FiscalSummaryWidget(
                  turnover: data.turnoverAmount,
                  netProfit: data.netProfitAmount,
                  payroll: data.payrollAmount,
                  expenses: data.expensesAmount,
                  personnelBudgetPercent: data.personnelBudgetPercent,
                  resourceBudgetPercent: data.resourceBudgetPercent,
                ),

                const SizedBox(height: 24),

                // Command Terminal
                const QuickActionsWidget(),

                const SizedBox(height: 24),

                // Activity Feed
                ActivityFeedWidget(activities: data.activities),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: ₹err')),
      ),
    );
  }

}
