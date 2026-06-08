import 'package:dashflow/company/pages/Recruitment_page.dart';
import 'package:dashflow/company/pages/company_profile_page.dart';
import 'package:dashflow/company/pages/employees_page.dart';
import 'package:dashflow/company/pages/finance_dashboard_page.dart';
import 'package:dashflow/company/pages/my_attendance_page.dart';
import 'package:dashflow/company/pages/my_leaves_page.dart';
import 'package:dashflow/company/pages/my_payroll_page.dart';
import 'package:dashflow/company/pages/notifications_page.dart';
import 'package:dashflow/company/pages/payroll_page.dart';
import 'package:dashflow/company/pages/repots_page.dart';
import 'package:dashflow/features/profile/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dashflow/company/services/api_service.dart' as company_api;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<Map<String, dynamic>>? _dashboardDataFuture;
  String _userName = "Admin";

  @override
  void initState() {
    super.initState();
    _dashboardDataFuture = _fetchDashboardData();
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

  Future<Map<String, dynamic>> _fetchDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user') ?? prefs.getString('user_profile');
      String companyId = '';
      if (userStr != null) {
        final user = jsonDecode(userStr);
        companyId = user['companyId'] ?? user['company']?['_id'] ?? user['company']?['id'] ?? user['company'] ?? '';
      }
      
      if (companyId.isEmpty) {
        final profile = await company_api.ApiService().getProfile();
        companyId = profile['company']?['_id'] ?? profile['company']?['id'] ?? profile['companyId'] ?? '';
      }
      
      if (companyId.isEmpty) {
        // Fallback or demo company if not found
        return {"totalEmployees": 0, "activePersonnel": 0, "systemIntegrity": "Unknown"};
      }
      
      final data = await company_api.ApiService().getDashboardMetrics(companyId: companyId);
      return data['data'] ?? data;
    } catch (e) {
      return {"totalEmployees": 0, "activePersonnel": 0, "error": e.toString()};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),

      drawer: Drawer(
        child: ListView(
          children:  [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xd2eef1ed),
              ),
              child: const Text(
                "DIFMO CRM",
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const ListTile(
              leading: Icon(Icons.dashboard),
              title: Text("Dashboard"),
            ),


            ListTile(
              leading: const Icon(Icons.people),
              title: const Text("Employees"),
              onTap: (){
                Navigator.pop(context);

                Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context)=> const EmployeePage(),
                ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.time_to_leave),
              title: const Text("Leave"),
              onTap: (){
                Navigator.pop(context);

                Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context)=> const MyLeavesPage(),
                ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.account_balance_wallet),
              title: const Text("Finance"),
              onTap: (){
                Navigator.pop(context);

                Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context)=> const FinanceDashboardPage(),
                ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text("Notifications"),
              onTap: (){
                Navigator.pop(context);

                Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context)=> const NotificationsPage(),
                ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.work),
              title: const Text("Recruitment"),
              onTap: (){
                Navigator.pop(context);

                Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context)=> const RecruitmentPage(),
                ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text("Pay Roll"),
              onTap: (){
                Navigator.pop(context);

                Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context)=> const MyPayrollPage(),
                ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.how_to_reg),
              title: const Text("Attendance"),
              onTap: (){
                Navigator.pop(context);
                Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context)=> const MyAttendancePage(),
                ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text("Reports"),
              onTap: (){
                Navigator.pop(context);

                Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context)=> const ReportsPage(),
                ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.business),
              title: const Text("Company"),
              onTap: (){
                Navigator.pop(context);

                Navigator.push(
                  context, MaterialPageRoute(
                  builder: (context)=> const CompanyProfilePage (),
                ),
                );
              },
            ),
          ],
        ),
      ),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xff1D4ED8)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "DIFMO CRM",
            style: TextStyle(
              color: Color(0xff1D4ED8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
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
              child: const CircleAvatar(
                backgroundColor: Color(0xff1D4ED8),
                child: Text(
                  "PS",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),

      body: FutureBuilder<Map<String, dynamic>>(
        future: _dashboardDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data ?? {};
          final totalEmployees = data['totalEmployees']?.toString() ?? "0";
          final activePersonnel = data['activePersonnel']?.toString() ?? "0";
          final systemIntegrity = data['systemIntegrity'] ?? "High";

          final healthVal = (data['workspaceHealth'] is num) ? data['workspaceHealth'] : 75;
          final double healthRatio = healthVal / 100.0;
          final String healthText = "${healthVal.round()}% Efficiency";
          
          final insight = data['automatedInsight'] ?? "All systems operating within normal parameters. No immediate automated actions taken today.";
          
          final List<dynamic> actions = data['recentActions'] ?? [
            {"title": "New Hire: Sarah Chen", "subtitle": "Engineering Department • 2h ago", "status": "Onboarding"},
            {"title": "Q3 Tax Filing Uploaded", "subtitle": "Finance Suite • 5h ago", "status": "Completed"}
          ];
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back, $_userName",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Here is your workspace overview for today.",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 24),

                _statCard(
                  icon: Icons.people,
                  title: "TOTAL EMPLOYEES",
                  value: totalEmployees,
                  tag: "+12%",
                  tagColor: Colors.green.shade100,
                ),

                const SizedBox(height: 16),

                _statCard(
                  icon: Icons.person,
                  title: "ACTIVE PERSONNEL",
                  value: activePersonnel,
                  tag: "Stable",
                  tagColor: Colors.grey.shade300,
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff1D4ED8),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "System Integrity $systemIntegrity",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "All workspace modules are operating within optimal parameters.",
                        style: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  "Recent Personnel Actions",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

                const SizedBox(height: 16),

                ...actions.map((action) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _actionTile(
                      action['title']?.toString() ?? 'Action',
                      action['subtitle']?.toString() ?? 'Recent',
                      action['status']?.toString() ?? 'Pending',
                    ),
                  );
                }),

                const SizedBox(height: 12),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Workspace Health",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      const Text(
                        "Your team's productivity and engagement scores are up by 8% this week.",
                      ),

                      const SizedBox(height: 20),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: healthRatio,
                          minHeight: 8,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          healthText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff111827),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Automated Insights",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        insight,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 80),
              ],
            ),
          );
        }
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,

        onTap: (index) {
          switch (index) {
            case 0:
              break; // Dashboard already open

            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmployeePage(),
                ),
              );
              break;

            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MyAttendancePage(),
                ),
              );
              break;

            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FinanceDashboardPage(),
                ),
              );
              break;

            case 4:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CompanyProfilePage(),
                ),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dash Board",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: "Employee",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_reg),
            label: "Attendance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Finance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: "Company Profile",
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required String tag,
    required Color tagColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade50,
                child: Icon(icon, color: Colors.blue),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: tagColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tag),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(title),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionTile(
      String title,
      String subtitle,
      String status,
      ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Chip(
          label: Text(status),
        ),
      ),
    );
  }
}
