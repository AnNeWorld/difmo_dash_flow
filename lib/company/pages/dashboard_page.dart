import 'package:dashflow/company/pages/Recruitment_page.dart';
import 'package:dashflow/company/pages/company_profile_page.dart';
import 'package:dashflow/company/pages/employees_page.dart';
import 'package:dashflow/company/pages/finance_screen.dart';
import 'package:dashflow/company/pages/my_attendance_page.dart';
import 'package:dashflow/company/pages/my_leaves_page.dart';
import 'package:dashflow/company/pages/my_payroll_page.dart';
import 'package:dashflow/company/pages/notifications_page.dart';
import 'package:dashflow/company/pages/payroll_page.dart';
import 'package:dashflow/company/pages/repots_page.dart';
import 'package:dashflow/company/pages/leave_management_screen.dart';
import 'package:dashflow/features/profile/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Components
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
  String _userName = "Admin";

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
      drawer: _buildDrawer(context),
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
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xff64748B)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NotificationsPage()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                radius: 16,
                child: Text(
                  _userName.isNotEmpty ? _userName[0].toUpperCase() : "A",
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
                  style: TextStyle(
                    color: Color(0xff64748B),
                    fontSize: 15,
                  ),
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
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color(0xff1D4ED8),
            ),
            child: const Text(
              "DIFMO CRM",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.dashboard, color: Color(0xff1D4ED8)),
            title: Text("Dashboard", style: TextStyle(color: Color(0xff1D4ED8), fontWeight: FontWeight.bold)),
          ),
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Employees"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const EmployeePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.time_to_leave),
            title: const Text("Leave Requests"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaveManagementScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text("Finance"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const FinanceScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text("Recruitment"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const RecruitmentPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.payments),
            title: const Text("Pay Roll"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPayrollPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.how_to_reg),
            title: const Text("Attendance"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAttendancePage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.assessment),
            title: const Text("Reports"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.business),
            title: const Text("Company"),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CompanyProfilePage()));
            },
          ),
        ],
      ),
    );
  }
}
