import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dashflow/company/pages/dashboard_page.dart';
import 'package:dashflow/company/pages/employees_page.dart';
import 'package:dashflow/company/pages/attendance_management_screen.dart';
import 'package:dashflow/company/pages/finance_screen.dart';
import 'package:dashflow/company/pages/company_profile_page.dart';

class AdminShell extends StatefulWidget {
  final int initialIndex;
  const AdminShell({super.key, this.initialIndex = 0});

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  late int _currentIndex;

  final List<_TabItem> _tabs = [
    _TabItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: "Dashboard"),
    _TabItem(icon: Icons.people_outline, activeIcon: Icons.people, label: "Employees"),
    _TabItem(icon: Icons.how_to_reg_outlined, activeIcon: Icons.how_to_reg, label: "Attendance"),
    _TabItem(icon: Icons.account_balance_wallet_outlined, activeIcon: Icons.account_balance_wallet, label: "Finance"),
    _TabItem(icon: Icons.business_outlined, activeIcon: Icons.business, label: "Company"),
  ];

  final List<Widget> _pages = const [
    _KeepAlivePage(child: DashboardPage()),
    _KeepAlivePage(child: EmployeePage()),
    _KeepAlivePage(child: AttendanceManagementScreen()),
    _KeepAlivePage(child: FinanceScreen()),
    _KeepAlivePage(child: CompanyProfilePage()),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(top: BorderSide(color: Colors.grey.shade100, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _tabs.length,
              (index) => _buildTabItem(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(int index) {
    final tab = _tabs[index];
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _currentIndex = index);
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? const Color(0xFF2563EB).withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? tab.activeIcon : tab.icon,
                key: ValueKey(isActive),
                color: isActive ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                color: isActive ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
              ),
              child: Text(tab.label),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 2,
              width: isActive ? 20 : 0,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _TabItem({required this.icon, required this.activeIcon, required this.label});
}

/// Keeps page state alive when switching tabs via IndexedStack
class _KeepAlivePage extends StatefulWidget {
  final Widget child;
  const _KeepAlivePage({required this.child});

  @override
  State<_KeepAlivePage> createState() => _KeepAlivePageState();
}

class _KeepAlivePageState extends State<_KeepAlivePage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
