import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dashflow/company/services/api_service.dart' as company_api;
import 'new_leave_screen.dart';

enum LeaveType { casual, sick }

enum LeaveStatus { awaiting, approved, declined }

class LeaveModel {
  final String id;
  final String applicationType;
  final String dateRange;
  final LeaveType leaveType;
  final LeaveStatus status;
  final DateTime sortDate;
  final String reason;

  LeaveModel({
    required this.id,
    required this.applicationType,
    required this.dateRange,
    required this.leaveType,
    required this.status,
    required this.sortDate,
    required this.reason,
  });

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    final leaveTypeString =
        (json['type'] ?? '').toString().toLowerCase();

    LeaveType type = leaveTypeString.contains('sick')
        ? LeaveType.sick
        : LeaveType.casual;

    LeaveStatus stat = LeaveStatus.awaiting;
    final statusString = (json['status'] ?? '').toString().toLowerCase();
    if (statusString == 'approved') {
      stat = LeaveStatus.approved;
    } else if (statusString == 'declined' || statusString == 'rejected') {
      stat = LeaveStatus.declined;
    }

    final startStr = json['startDate'] ?? '';
    final endStr = json['endDate'] ?? '';
    DateTime start = DateTime.tryParse(startStr) ?? DateTime.now();
    DateTime end = DateTime.tryParse(endStr) ?? start;

    String range = '';
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final startDayStr =
        '${days[start.weekday]}, ${start.day} ${months[start.month]}';
    if (json['duration'] == 'Multiple Days' ||
        start.day != end.day ||
        start.month != end.month) {
      final endDayStr = '${days[end.weekday]}, ${end.day} ${months[end.month]}';
      range = '$startDayStr – $endDayStr';
    } else {
      range = startDayStr;
    }

    String appType = 'Full Day Application';
    if (json['duration'] == 'Half Day') {
      appType = 'Half Day Application';
    } else if (json['duration'] == 'Multiple Days') {
      appType = 'Multiple Days Application';
    }

    return LeaveModel(
      id: json['_id'] ?? json['id']?.toString() ?? '',
      applicationType: appType,
      dateRange: range,
      leaveType: type,
      status: stat,
      sortDate: start,
      reason: json['reason'] ?? '',
    );
  }
}

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<LeaveModel> _allLeaves = [];
  bool _isLoading = true;
  String? _employeeId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _loadUserAndLeaves();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserAndLeaves() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        _employeeId = user['employeeId'] ?? user['id']?.toString();
      }

      if (_employeeId != null) {
        await _fetchLeaves();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchLeaves() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await company_api.ApiService().getAllLeaves(employeeId: _employeeId);
      setState(() {
        _allLeaves.clear();
        _allLeaves.addAll(
          data.map((item) => LeaveModel.fromJson(item)).toList(),
        );
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching leaves: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<LeaveModel> _getFilteredLeaves(int tabIndex) {
    if (tabIndex == 1) {
      return _allLeaves.where((l) => l.leaveType == LeaveType.casual).toList();
    } else if (tabIndex == 2) {
      return _allLeaves.where((l) => l.leaveType == LeaveType.sick).toList();
    }
    return _allLeaves;
  }

  Map<String, List<LeaveModel>> _groupByMonth(List<LeaveModel> leaves) {
    final Map<String, List<LeaveModel>> map = {};
    for (final leave in leaves) {
      final key = _monthYear(leave.sortDate);
      map.putIfAbsent(key, () => []).add(leave);
    }
    return map;
  }

  String _monthYear(DateTime d) {
    const m = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${m[d.month]} ${d.year}';
  }

  int get _totalLeaves => _allLeaves.length;
  int get _approvedCount =>
      _allLeaves.where((l) => l.status == LeaveStatus.approved).length;
  int get _pendingCount =>
      _allLeaves.where((l) => l.status == LeaveStatus.awaiting).length;

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredLeaves(_tabController.index);
    final grouped = _groupByMonth(filtered);
    final keys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSummaryCards(),
            _buildTabBar(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2C5282),
                      ),
                    )
                  : filtered.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: keys.length,
                      itemBuilder: (_, i) {
                        final key = keys[i];
                        return _buildMonthGroup(key, grouped[key]!);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Leaves',
                style: TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                '$_totalLeaves total applications',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF64748B),
                      size: 22,
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFFC5221F),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // + Button (Now navigates to NewLeaveScreen dynamically!)
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewLeaveScreen(),
                    ),
                  );
                  if (result == true) {
                     _fetchLeaves();
                  }
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: Color(0xFF1E293B),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Row(
        children: [
          _summaryCard(
            label: 'Approved',
            count: _approvedCount,
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF137333),
            bgColor: const Color(0xFFE6F4EA),
          ),
          const SizedBox(width: 10),
          _summaryCard(
            label: 'Pending',
            count: _pendingCount,
            icon: Icons.access_time_rounded,
            iconColor: const Color(0xFFB06000),
            bgColor: const Color(0xFFFEF7E0),
          ),
          const SizedBox(width: 10),
          _summaryCard(
            label: 'Declined',
            count: _allLeaves
                .where((l) => l.status == LeaveStatus.declined)
                .length,
            icon: Icons.cancel_outlined,
            iconColor: const Color(0xFFC5221F),
            bgColor: const Color(0xFFFCE8E6),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard({
    required String label,
    required int count,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 18),
            ),
            const SizedBox(height: 12),
            Text(
              '$count',
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF64748B),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(
            0xFF2C5282,
          ), // Custom Slate-Blue matching Calendar select style
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(3),
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFF64748B),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w400,
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Casual'),
          Tab(text: 'Sick'),
        ],
      ),
    );
  }

  Widget _buildMonthGroup(String month, List<LeaveModel> leaves) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Row(
            children: [
              Text(
                month.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(height: 1, color: const Color(0xFFE2E8F0)),
              ),
            ],
          ),
        ),
        ...leaves.map((leave) => _buildLeaveCard(leave)),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildLeaveCard(LeaveModel leave) {
    final isCasual = leave.leaveType == LeaveType.casual;
    final typeName = isCasual ? 'Casual' : 'Sick';
    final typeIcon = isCasual
        ? Icons.beach_access_rounded
        : Icons.medical_services_outlined;

    final typeBg = isCasual ? const Color(0xFFFEF7E0) : const Color(0xFFFCE8E6);
    final typeColor = isCasual
        ? const Color(0xFFB06000)
        : const Color(0xFFC5221F);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: const Color(0xFFE2E8F0),
          onTap: () => _showLeaveDetails(context, leave),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Left icon circle matching tinted icon style
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: typeBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(typeIcon, color: typeColor, size: 20),
                ),
                const SizedBox(width: 14),

                // Middle: info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        leave.applicationType,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        leave.dateRange,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        typeName,
                        style: TextStyle(
                          color: typeColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right: badge
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStatusBadge(leave.status),
                    const SizedBox(height: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF64748B),
                      size: 13,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(LeaveStatus status) {
    late String label;
    late Color txtColor;
    late Color bg;

    switch (status) {
      case LeaveStatus.awaiting:
        label = 'Awaiting';
        txtColor = const Color(0xFF64748B);
        bg = const Color(0xFFF1F5F9);
        break;
      case LeaveStatus.approved:
        label = 'Approved';
        txtColor = const Color(0xFF137333);
        bg = const Color(0xFFE6F4EA);
        break;
      case LeaveStatus.declined:
        label = 'Declined';
        txtColor = const Color(0xFFC5221F);
        bg = const Color(0xFFFCE8E6);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: txtColor,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              color: Color(0xFF64748B),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No leaves found',
            style: TextStyle(
              color: Color(0xFF64748B),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeLeaveStatus(String leaveId, String status) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await company_api.ApiService().updateLeaveStatus(leaveId: leaveId, status: status);
      if (mounted) {
        Navigator.pop(context); // Pop loading
        Navigator.pop(context); // Pop bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Leave status updated to $status successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchLeaves(); // Refresh leaves list
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Pop loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update leave status: $e"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showLeaveDetails(BuildContext context, LeaveModel leave) {
    final isCasual = leave.leaveType == LeaveType.casual;
    final typeName = isCasual ? 'Casual Leave' : 'Sick Leave';
    final typeIcon = isCasual
        ? Icons.beach_access_rounded
        : Icons.medical_services_outlined;

    final typeBg = isCasual ? const Color(0xFFFEF7E0) : const Color(0xFFFCE8E6);
    final typeColor = isCasual
        ? const Color(0xFFB06000)
        : const Color(0xFFC5221F);

    late String statusLabel;
    late Color statusTxtColor;
    late Color statusBg;
    late IconData statusIcon;

    switch (leave.status) {
      case LeaveStatus.awaiting:
        statusLabel = 'Awaiting';
        statusTxtColor = const Color(0xFF64748B);
        statusBg = const Color(0xFFF1F5F9);
        statusIcon = Icons.access_time_filled_rounded;
        break;
      case LeaveStatus.approved:
        statusLabel = 'Approved';
        statusTxtColor = const Color(0xFF137333);
        statusBg = const Color(0xFFE6F4EA);
        statusIcon = Icons.check_circle_rounded;
        break;
      case LeaveStatus.declined:
        statusLabel = 'Declined';
        statusTxtColor = const Color(0xFFC5221F);
        statusBg = const Color(0xFFFCE8E6);
        statusIcon = Icons.cancel_rounded;
        break;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: typeBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(typeIcon, color: typeColor, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            leave.applicationType,
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            typeName,
                            style: TextStyle(
                              color: typeColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, color: statusTxtColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusTxtColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Divider(color: Color(0xFFF1F5F9), height: 1),
                const SizedBox(height: 20),
                _buildDetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Date Range',
                  value: leave.dateRange,
                  valColor: const Color(0xFF1E293B),
                ),
                const SizedBox(height: 18),
                _buildDetailRow(
                  icon: Icons.fingerprint_rounded,
                  label: 'Application ID',
                  value: leave.id.isEmpty ? 'N/A' : leave.id,
                  valColor: const Color(0xFF64748B),
                  isMono: true,
                ),
                const SizedBox(height: 24),
                const Text(
                  'REASON FOR LEAVE',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Text(
                    leave.reason.isEmpty ? 'No reason provided.' : leave.reason,
                    style: const TextStyle(
                      color: Color(0xFF1E293B),
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C5282),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        'Close Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valColor,
    bool isMono = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF64748B), size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: TextStyle(
                  color: valColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: isMono ? 'monospace' : null,
                  letterSpacing: isMono ? -0.5 : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: LeaveScreen()),
  );
}
