import 'package:flutter/material.dart';
import 'package:dashflow/core/api/api_service.dart';
import 'package:intl/intl.dart';
import 'package:iconsax/iconsax.dart';

class AttendanceHistoryPage extends StatefulWidget {
  final String employeeId;
  final String userName;

  const AttendanceHistoryPage({
    super.key,
    required this.employeeId,
    required this.userName,
  });

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  bool isLoading = true;
  List<dynamic> attendanceList = [];

  DateTime selectedMonth = DateTime.now();
  String selectedStatus = 'all';

  final List<Map<String, String>> statusOptions = [
    {'value': 'all', 'label': 'All Status'},
    {'value': 'present', 'label': 'Present'},
    {'value': 'absent', 'label': 'Absent'},
    {'value': 'late', 'label': 'Late'},
    {'value': 'half_day', 'label': 'Half Day'},
    {'value': 'wfh', 'label': 'Work From Home'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    setState(() {
      isLoading = true;
    });

    try {
      final startDate = DateTime(selectedMonth.year, selectedMonth.month, 1);
      final endDate = DateTime(selectedMonth.year, selectedMonth.month + 1, 0);

      final startStr = DateFormat('yyyy-MM-dd').format(startDate);
      final endStr = DateFormat('yyyy-MM-dd').format(endDate);

      final data = await ApiService.getAttendanceHistory(
        widget.employeeId,
        startDate: startStr,
        endDate: endStr,
        status: selectedStatus,
      );

      setState(() {
        attendanceList = data;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching history: $e')));
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedMonth,
      firstDate: DateTime(2026),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
      helpText: 'Select Month',
    );

    if (picked != null &&
        (picked.month != selectedMonth.month ||
            picked.year != selectedMonth.year)) {
      setState(() {
        selectedMonth = picked;
      });
      _fetchAttendance();
    }
  }

  DateTime? _parseUtcTime(String? dateStr, String? timeStr) {
    if (dateStr == null || timeStr == null) return null;
    try {
      final datePart = dateStr.contains('T') ? dateStr.split('T')[0] : dateStr;
      final isoStr = "${datePart}T$timeStr";
      return DateTime.parse(isoStr);
    } catch (e) {
      return null;
    }
  }

  Map<String, int> _getMonthSummary() {
    int present = 0, absent = 0, wfh = 0, late = 0;
    for (final item in attendanceList) {
      final status = (item['status'] ?? '').toString().toLowerCase();
      final workMode = (item['workMode'] ?? '').toString().toLowerCase();
      if (workMode == 'wfh') {
        wfh++;
      } else if (status == 'present') {
        present++;
      } else if (status == 'absent') {
        absent++;
      } else if (status == 'late') {
        late++;
      }
    }
    return {'present': present, 'absent': absent, 'wfh': wfh, 'late': late};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Attendance History"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _selectMonth(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MMMM yyyy').format(selectedMonth),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const Icon(
                                Iconsax.calendar_1,
                                size: 18,
                                color: Colors.grey,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.white,
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedStatus,
                            isExpanded: true,
                            icon: const Icon(
                              Iconsax.arrow_down_1,
                              size: 18,
                              color: Colors.grey,
                            ),
                            items: statusOptions.map((status) {
                              return DropdownMenuItem(
                                value: status['value'],
                                child: Text(
                                  status['label']!,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  selectedStatus = val;
                                });
                                _fetchAttendance();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (!isLoading && attendanceList.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildMonthlySummaryStrip(),
                ],
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : attendanceList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.calendar_remove,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "No attendance records found",
                          style: TextStyle(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: attendanceList.length,
                    itemBuilder: (context, index) {
                      final item = attendanceList[index];
                      final date = item['date'];
                      final checkIn = _parseUtcTime(date, item['checkInTime']);
                      final checkOut = _parseUtcTime(
                        date,
                        item['checkOutTime'],
                      );
                      final status = item['status'] ?? 'Present';
                      final workMode = (item['workMode'] ?? 'office')
                          .toString();

                      return _buildAttendanceCard(
                        date: date,
                        checkIn: checkIn,
                        checkOut: checkOut,
                        status: status,
                        workMode: workMode,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryStrip() {
    final summary = _getMonthSummary();

    return Row(
      children: [
        _buildSummaryChip(
          label: "Present",
          count: summary['present']!,
          color: Colors.green,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(width: 8),
        _buildSummaryChip(
          label: "WFH",
          count: summary['wfh']!,
          color: Colors.teal,
          icon: Icons.home_work_rounded,
        ),
        const SizedBox(width: 8),
        _buildSummaryChip(
          label: "Absent",
          count: summary['absent']!,
          color: Colors.red,
          icon: Icons.cancel_outlined,
        ),
        const SizedBox(width: 8),
        _buildSummaryChip(
          label: "Late",
          count: summary['late']!,
          color: Colors.orange,
          icon: Icons.access_time,
        ),
      ],
    );
  }

  Widget _buildSummaryChip({
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 2),
            Text(
              "$count",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 14,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 10, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard({
    required String date,
    required DateTime? checkIn,
    required DateTime? checkOut,
    required String status,
    required String workMode,
  }) {
    final bool isWFH = workMode.toLowerCase() == 'wfh';
    final Color wfhColor = isWFH ? Colors.teal : Colors.blue;
    final IconData wfhIcon = isWFH
        ? Icons.home_work_rounded
        : Icons.business_rounded;
    final String wfhLabel = isWFH ? "Work From Home" : "Office";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: wfhColor, width: 4),
          top: BorderSide(color: Colors.grey.shade200),
          right: BorderSide(color: Colors.grey.shade200),
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('EEEE, dd MMM').format(DateTime.parse(date)),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: wfhColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(wfhIcon, size: 11, color: wfhColor),
                        const SizedBox(width: 3),
                        Text(
                          wfhLabel,
                          style: TextStyle(
                            color: wfhColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      status.toString().toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(status),
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildTimeColumn(
                  "Check In",
                  checkIn != null
                      ? DateFormat('hh:mm a').format(checkIn)
                      : "--:--",
                  Iconsax.login,
                  Colors.green,
                ),
              ),
              Container(width: 1, height: 30, color: Colors.grey.shade200),
              Expanded(
                child: _buildTimeColumn(
                  "Check Out",
                  checkOut != null
                      ? DateFormat('hh:mm a').format(checkOut)
                      : "--:--",
                  Iconsax.logout,
                  Colors.orange,
                ),
              ),
              Container(width: 1, height: 30, color: Colors.grey.shade200),
              Expanded(
                child: _buildTimeColumn(
                  "Hrs",
                  _calculateHours(checkIn, checkOut),
                  Iconsax.clock,
                  Colors.blue,
                ),
              ),
            ],
          ),
          if (isWFH) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFF3F4F6)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: Colors.teal.shade400,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Remote Location",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.teal.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeColumn(
    String label,
    String time,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          time,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  String _calculateHours(DateTime? checkIn, DateTime? checkOut) {
    if (checkIn == null || checkOut == null) return "--";
    final duration = checkOut.difference(checkIn);
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return "${hours}h ${minutes}m";
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'half_day':
        return Colors.purple;
      case 'wfh':
        return Colors.teal;
      default:
        return Colors.blue;
    }
  }
}
