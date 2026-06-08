import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leave_model.dart';
import '../services/leave_service.dart';
import 'package:intl/intl.dart';

class LeaveManagementScreen extends ConsumerStatefulWidget {
  const LeaveManagementScreen({super.key});

  @override
  ConsumerState<LeaveManagementScreen> createState() =>
      _LeaveManagementScreenState();
}

class _LeaveManagementScreenState extends ConsumerState<LeaveManagementScreen> {
  String _activeTab = 'ALL';
  String _searchQuery = '';

  // Track which leave cards are expanded
  final Set<String> _expandedLeaves = {};
  // Track remarks
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

  @override
  Widget build(BuildContext context) {
    final leaveAsync = ref.watch(leaveProvider);

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Leave & Attendance",
          style: TextStyle(
            color: Color(0xff0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xff0F172A)),
      ),
      body: leaveAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
        data: (leaves) {
          // Calculate Stats
          final pendingCount = leaves
              .where((l) => l.status == 'PENDING')
              .length;
          final approvedCount = leaves
              .where((l) => l.status == 'APPROVED')
              .length;
          // Just a mock for 'out today' - can be refined
          final outTodayCount = leaves
              .where(
                (l) =>
                    l.status == 'APPROVED' &&
                    l.startDate.isBefore(DateTime.now()) &&
                    l.endDate.isAfter(DateTime.now()),
              )
              .length;

          // Filter leaves
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header & Stats
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 800;
                    
                    final headerText = Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "ADMIN CONTROL PANEL",
                          style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.1),
                        ),
                        SizedBox(height: 8),
                        Text("Leave & Attendance", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        SizedBox(height: 4),
                        Text("Manage employee leave requests and approvals.", style: TextStyle(color: Color(0xFF64748B), fontSize: 14)),
                      ],
                    );

                    final statCards = Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: isDesktop ? WrapAlignment.end : WrapAlignment.start,
                      children: [
                        _buildStatCard("PENDING REVIEW", pendingCount.toString(), Icons.access_time, Colors.orange.shade100, Colors.orange.shade700),
                        _buildStatCard("ACTIVE APPROVED", approvedCount.toString(), Icons.person_add_alt_1_outlined, Colors.green.shade100, Colors.green.shade700),
                        _buildStatCard("OUT TODAY", outTodayCount.toString(), Icons.calendar_today_outlined, Colors.red.shade100, Colors.red.shade700),
                      ],
                    );

                    if (isDesktop) {
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 2, child: headerText),
                          Expanded(flex: 3, child: Align(alignment: Alignment.centerRight, child: statCards)),
                        ],
                      );
                    } else {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          headerText,
                          const SizedBox(height: 24),
                          statCards,
                        ],
                      );
                    }
                  }
                ),
                const SizedBox(height: 32),

                // Tabs and Search
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      _buildTab("ALL"),
                      _buildTab("PENDING"),
                      _buildTab("APPROVED"),
                      _buildTab("REJECTED"),
                      SizedBox(
                        width: 250,
                        height: 36,
                        child: TextField(
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: InputDecoration(
                            hintText: "Search employees...",
                            hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                            prefixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
                            filled: true,
                            fillColor: const Color(0xffF8FAFC),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Horizontally Scrollable Table Area
                LayoutBuilder(
                  builder: (context, outerConstraints) {
                    final tableWidth = outerConstraints.maxWidth > 900
                        ? outerConstraints.maxWidth
                        : 900.0;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: tableWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Table Header
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              child: Row(
                                children: [
                                  Expanded(flex: 2, child: _buildColHeader("EMPLOYEE INFO")),
                                  Expanded(flex: 1, child: _buildColHeader("CATEGORY")),
                                  Expanded(flex: 1, child: _buildColHeader("SCHEDULE")),
                                  Expanded(flex: 1, child: _buildColHeader("VERIFICATION")),
                                  SizedBox(width: 150, child: _buildColHeader("ACTIONS", alignRight: true)),
                                ],
                              ),
                            ),

                            // List of Leaves
                            if (filteredLeaves.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(
                                  child: Text(
                                    "No leave requests found.",
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                              )
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: filteredLeaves.length,
                                itemBuilder: (context, index) {
                                  final leave = filteredLeaves[index];
                                  final isExpanded = _expandedLeaves.contains(leave.id);

                                  if (isExpanded && !_remarkControllers.containsKey(leave.id)) {
                                    _remarkControllers[leave.id] = TextEditingController(text: leave.adminRemark);
                                  }

                                  return _buildLeaveCard(leave, isExpanded);
                                },
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String text) {
    final isActive = _activeTab == text;
    return InkWell(
      onTap: () => setState(() => _activeTab = text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
            color: isActive ? const Color(0xFF2563EB) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildColHeader(String text, {bool alignRight = false}) {
    return Text(
      text,
      textAlign: alignRight ? TextAlign.right : TextAlign.left,
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: Color(0xFF94A3B8),
        letterSpacing: 1.1,
      ),
    );
  }

  Widget _buildLeaveCard(LeaveModel leave, bool isExpanded) {
    final dateFormat = DateFormat('dd MMM');
    final dateStr =
        "${dateFormat.format(leave.startDate)} - ${dateFormat.format(leave.endDate)}";

    Color statusColor;
    Color statusBg;
    if (leave.status == 'APPROVED') {
      statusColor = Colors.green.shade700;
      statusBg = Colors.green.shade50;
    } else if (leave.status == 'REJECTED') {
      statusColor = Colors.red.shade700;
      statusBg = Colors.red.shade50;
    } else {
      statusColor = Colors.orange.shade700;
      statusBg = Colors.orange.shade50;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 700;
          
          final actions = [
            IconButton(
              icon: const Icon(Icons.flag_outlined, size: 18, color: Colors.grey),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.check, size: 20, color: leave.status == 'APPROVED' ? Colors.green : Colors.grey),
              onPressed: () => _handleUpdateStatus(leave.id, 'APPROVED'),
            ),
            IconButton(
              icon: Icon(Icons.close, size: 20, color: leave.status == 'REJECTED' ? Colors.red : Colors.grey),
              onPressed: () => _handleUpdateStatus(leave.id, 'REJECTED'),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
              onPressed: () {},
            ),
          ];

          final employeeInfo = Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: const Color(0xFF1E293B),
                child: Text(
                  leave.employeeInitials,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leave.employeeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A))),
                    Text(leave.employeeId.length > 8 ? leave.employeeId.substring(0, 8) : leave.employeeId, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          );

          final categoryBadge = Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(4)),
            child: Text(leave.type.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569))),
          );

          final scheduleInfo = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(dateStr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A))),
              Text("${leave.duration} Days", style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          );

          final verificationBadge = Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(16)),
            child: Text(leave.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
          );

          final reasonSection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.info_outline, size: 14, color: Color(0xFF3B82F6)),
                  SizedBox(width: 8),
                  Text("EMPLOYEE REASON", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3B82F6))),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                child: Text(leave.reason.isNotEmpty ? '"${leave.reason}"' : "No reason provided.", style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Color(0xFF475569))),
              ),
            ],
          );

          final remarkSection = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey),
                  SizedBox(width: 8),
                  Text("ADMINISTRATOR'S DECISION REMARK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _remarkControllers[leave.id],
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: "Add a remark for the employee...",
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
                ),
              ),
            ],
          );

          return Column(
            children: [
              // Main Row/Column
              InkWell(
                onTap: () => _toggleExpand(leave.id),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: isDesktop 
                    ? Row(
                        children: [
                          Expanded(flex: 2, child: employeeInfo),
                          Expanded(flex: 1, child: Align(alignment: Alignment.centerLeft, child: categoryBadge)),
                          Expanded(flex: 1, child: scheduleInfo),
                          Expanded(flex: 1, child: Align(alignment: Alignment.centerLeft, child: verificationBadge)),
                          SizedBox(
                            width: 150,
                            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
                          )
                        ],
                      )
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                employeeInfo,
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    categoryBadge,
                                    scheduleInfo,
                                    verificationBadge,
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // Actions in a column
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: actions,
                          )
                        ],
                      ),
                ),
              ),

              // Expanded Section
              if (isExpanded)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xffF8FAFC),
                    border: Border(top: BorderSide(color: Colors.grey.shade200)),
                    borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                  ),
                  child: isDesktop
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: reasonSection),
                          const SizedBox(width: 24),
                          Expanded(child: remarkSection),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          reasonSection,
                          const SizedBox(height: 24),
                          remarkSection,
                        ],
                      ),
                )
            ],
          );
        }
      ),
    );
  }
}
