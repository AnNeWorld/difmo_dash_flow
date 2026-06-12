import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leave_model.dart';
import '../services/leave_service.dart';
import 'package:intl/intl.dart';
import 'package:dashflow/company/components/shared/app_drawer.dart';

class LeaveManagementScreen extends ConsumerStatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  ConsumerState<LeaveManagementScreen> createState() =>
      _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends ConsumerState<LeaveManagementScreen> {
  String _activeTab = 'ALL';
  String _searchQuery = '';

  final Set<String> _expandedLeaves = {};
  final Map<String, TextEditingController> _remarkControllers = {};

  @override
  void dispose() {
    for (var ctrl in _remarkControllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _toggleExpand(String id) {
    setState(() {
      if (_expandedLeaves.contains(id)) {
        _expandedLeaves.remove(id);
      } else {
        _expandedLeaves.add(id);
        if (!_remarkControllers.containsKey(id)) {
          _remarkControllers[id] = TextEditingController();
        }
      }
    });
  }

  Future<void> _handleUpdateStatus(String id, String newStatus) async {
    final remark = _remarkControllers[id]?.text ?? '';
    final success = await ref
        .read(leaveProvider.notifier)
        .updateLeaveStatus(id, newStatus, remark: remark);
    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Leave marked as $newStatus')));
      setState(() {
        _expandedLeaves.remove(id);
      });
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to update leave')));
    }
  }

  Future<void> _handleDeleteLeave(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Leave'),
        content: const Text(
          'Are you sure you want to delete this leave request?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ref.read(leaveProvider.notifier).deleteLeave(id);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Leave deleted successfully')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to delete leave')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final leaveAsync = ref.watch(leaveProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(activeRoute: 'Leave Requests'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xff0F172A), size: 24),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text(
          "Leave Management",
          style: TextStyle(
            color: Color(0xff0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CircleAvatar(
              radius: 16,
              backgroundImage: const NetworkImage(
                "https://ui-avatars.com/api/?name=Admin",
              ),
            ),
          ),
        ],
      ),
      body: leaveAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (leaves) {
          final pendingCount = leaves
              .where((l) => l.status == 'PENDING')
              .length;
          final approvedCount = leaves
              .where((l) => l.status == 'APPROVED')
              .length;
          final outTodayCount = leaves
              .where(
                (l) =>
                    l.status == 'APPROVED' &&
                    l.startDate.isBefore(DateTime.now()) &&
                    l.endDate.isAfter(DateTime.now()),
              )
              .length;

          var filteredLeaves = leaves;
          if (_activeTab != 'ALL') {
            filteredLeaves = filteredLeaves
                .where((l) => l.status == _activeTab)
                .toList();
          }
          if (_searchQuery.isNotEmpty) {
            filteredLeaves = filteredLeaves
                .where(
                  (l) => l.employeeName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
                )
                .toList();
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            children: [
              // STAT CARDS
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: "PENDING",
                      value: pendingCount.toString(),
                      icon: Icons.hourglass_empty,
                      iconColor: const Color(0xFF2563EB),
                      iconBgColor: const Color(0xFFEFF6FF),
                      valueColor: const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: "ACTIVE",
                      value: approvedCount.toString(),
                      icon: Icons.check_circle_outline,
                      iconColor: const Color(0xFF64748B),
                      iconBgColor: const Color(0xFFF1F5F9),
                      valueColor: const Color(0xFFCBD5E1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildStatCard(
                      title: "OUT TODAY",
                      value: outTodayCount.toString().padLeft(2, '0'),
                      icon: Icons.flight_takeoff,
                      iconColor: const Color(0xFFD97706),
                      iconBgColor: const Color(0xFFFEF3C7),
                      valueColor: const Color(0xFFB45309),
                      isFullWidth: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // TABS
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTab("All", "ALL"),
                    _buildTab("Pending", "PENDING"),
                    _buildTab("Approved", "APPROVED"),
                    _buildTab("Rejected", "REJECTED"),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              const SizedBox(height: 16),

              // SEARCH BAR
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: "Search employees or IDs...",
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey),
                    prefixIcon: Icon(
                      Icons.search,
                      size: 20,
                      color: Colors.grey,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // LEAVE CARDS
              if (filteredLeaves.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      "No leave requests found.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                )
              else
                ...filteredLeaves.map((leave) => _buildLeaveCard(leave)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color valueColor,
    bool isFullWidth = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, String value) {
    final isActive = _activeTab == value;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF2563EB) : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            color: isActive ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveCard(LeaveModel leave) {
    final dateFormat = DateFormat('MMM dd');
    final dateStr =
        "${dateFormat.format(leave.startDate)} - ${dateFormat.format(leave.endDate)}";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    leave.employeeName.toLowerCase().contains('jane')
                    ? const NetworkImage('https://i.pravatar.cc/150?img=5')
                    : leave.employeeName.toLowerCase().contains('marcus')
                    ? const NetworkImage('https://i.pravatar.cc/150?img=11')
                    : leave.employeeName.toLowerCase().contains('sarah')
                    ? const NetworkImage('https://i.pravatar.cc/150?img=9')
                    : null,
                child:
                    leave.employeeName.toLowerCase().contains('jane') ||
                        leave.employeeName.toLowerCase().contains('marcus') ||
                        leave.employeeName.toLowerCase().contains('sarah')
                    ? null
                    : Text(
                        leave.employeeInitials,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      leave.employeeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "ID: ${leave.employeeId.length > 10 ? leave.employeeId.substring(0, 8).toUpperCase() : leave.employeeId.toUpperCase()}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (leave.status == 'PENDING')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "PENDING",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                )
              else if (leave.status == 'APPROVED')
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () => _handleDeleteLeave(leave.id),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Middle Details Row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Leave Type",
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      leave.type,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Dates",
                      style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Reason Section
          if (leave.reason.isNotEmpty) ...[
            const Text(
              "Reason",
              style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
            ),
            const SizedBox(height: 2),
            Text(
              leave.reason,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 10),
          ] else ...[
            const SizedBox(height: 4),
          ],

          // Action Buttons
          if (leave.status == 'PENDING')
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFEBEB), // Light red
                    foregroundColor: const Color(0xFFDC2626), // Red
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () => _handleUpdateStatus(leave.id, 'REJECTED'),
                  child: const Text(
                    'Reject',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1D4ED8),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),
                  onPressed: () => _handleUpdateStatus(leave.id, 'APPROVED'),
                  child: const Text(
                    'Approve',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            )
          else if (leave.status == 'APPROVED')
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED), // Light orange
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.check_circle,
                      size: 14,
                      color: Color(0xFFD97706),
                    ), // Orange
                    SizedBox(width: 6),
                    Text(
                      "Approved",
                      style: TextStyle(
                        color: Color(0xFFD97706),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (leave.status == 'REJECTED')
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.cancel, size: 14, color: Color(0xFFDC2626)),
                    SizedBox(width: 6),
                    Text(
                      "Rejected",
                      style: TextStyle(
                        color: Color(0xFFDC2626),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
