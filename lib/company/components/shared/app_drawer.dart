import 'package:dashflow/company/pages/my_attendance.dart';
import 'package:dashflow/features/activities/pages/attendance_history_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dashflow/company/pages/Recruitment_page.dart';
import 'package:dashflow/company/pages/company_profile_page.dart';
import 'package:dashflow/company/pages/employees_page.dart';
import 'package:dashflow/company/pages/finance_screen.dart';
import 'package:dashflow/company/pages/my_payroll_page.dart';
import 'package:dashflow/company/pages/my_attendance_page.dart';
import 'package:dashflow/company/pages/notifications_page.dart';
import 'package:dashflow/company/pages/repots_page.dart';
import 'package:dashflow/company/pages/leave_management_screen.dart';
import 'package:dashflow/company/pages/dashboard_page.dart';

class AppDrawer extends StatefulWidget {
  final String activeRoute;

  const AppDrawer({super.key, required this.activeRoute});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String _adminName = "Loading...";
  String _adminId = "";

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
  }

  Future<void> _loadAdminInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user') ?? prefs.getString('user_profile');
    if (userStr != null) {
      try {
        final user = jsonDecode(userStr);
        final firstName = user['firstName']?.toString() ?? '';
        final lastName = user['lastName']?.toString() ?? '';

        String name = "Admin";
        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          name = '$firstName $lastName'.trim();
        } else if (user['name'] != null) {
          name = user['name'].toString();
        }

        String id =
            user['customId']?.toString() ??
            user['employeeId']?.toString() ??
            user['_id']?.toString() ??
            user['id']?.toString() ??
            "";

        if (mounted) {
          setState(() {
            _adminName = name;
            _adminId = id;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _adminName = "Admin";
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _adminName = "Admin";
        });
      }
    }
  }

  void _navigateTo(BuildContext context, String routeName, Widget page) {
    Navigator.pop(context); // Close the drawer
    if (widget.activeRoute == routeName) return;

    if (routeName == 'Dashboard') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => page),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => page),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Color(0xff1D4ED8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  _adminName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_adminId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    "ID: $_adminId",
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.dashboard,
            title: "Dashboard",
            route: 'Dashboard',
            onTap: () =>
                _navigateTo(context, 'Dashboard', const DashboardPage()),
          ),
          _buildMenuItem(
            context,
            icon: Icons.people,
            title: "Employees",
            route: 'Employees',
            onTap: () =>
                _navigateTo(context, 'Employees', const EmployeePage()),
          ),
          _buildMenuItem(
            context,
            icon: Icons.time_to_leave,
            title: "Leave Requests",
            route: 'Leave Requests',
            onTap: () => _navigateTo(
              context,
              'Leave Requests',
              const LeaveManagementScreen(),
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.account_balance_wallet,
            title: "Finance",
            route: 'Finance',
            onTap: () => _navigateTo(context, 'Finance', const FinanceScreen()),
          ),
          _buildMenuItem(
            context,
            icon: Icons.notifications,
            title: "Notifications",
            route: 'Notifications',
            onTap: () => _navigateTo(
              context,
              'Notifications',
              const NotificationsPage(),
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.work,
            title: "Recruitment",
            route: 'Recruitment',
            onTap: () =>
                _navigateTo(context, 'Recruitment', const RecruitmentPage()),
          ),
          _buildMenuItem(
            context,
            icon: Icons.payments,
            title: "Pay Roll",
            route: 'Pay Roll',
            onTap: () =>
                _navigateTo(context, 'Pay Roll', const MyPayrollPage()),
          ),
          _buildMenuItem(
            context,
            icon: Icons.how_to_reg,
            title: "Attendance",
            route: 'Attendance',
            onTap: () => _navigateTo(
              context,
              'Attendance Histroy',
              AttendanceHistoryPage(employeeId: _adminId, userName: _adminName),
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.assessment,
            title: "Reports",
            route: 'Reports',
            onTap: () => _navigateTo(context, 'Reports', const ReportsPage()),
          ),
          _buildMenuItem(
            context,
            icon: Icons.business,
            title: "Company",
            route: 'Company',
            onTap: () =>
                _navigateTo(context, 'Company', const CompanyProfilePage()),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required VoidCallback onTap,
  }) {
    final isActive = widget.activeRoute == route;
    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? const Color(0xff1D4ED8) : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? const Color(0xff1D4ED8) : Colors.black87,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isActive
          ? const Color(0xff1D4ED8).withValues(alpha: 0.1)
          : null,
      onTap: onTap,
    );
  }
}
