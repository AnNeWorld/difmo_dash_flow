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
                      
                      String? dateStr = item['date'] ?? item['createdAt'] ?? item['checkIn'];
                      if (dateStr == null) dateStr = DateTime.now().toIso8601String();
                      
                      DateTime? parsedCheckIn;
                      String? inRaw = item['checkIn'] ?? item['checkInTime'] ?? item['inTime'] ?? item['clockIn'];
                      if (inRaw != null) {
                        if (inRaw.contains('T')) {
                          try { parsedCheckIn = DateTime.parse(inRaw).toLocal(); } catch(_) {}
                        } else {
                          parsedCheckIn = _parseUtcTime(dateStr, inRaw);
                        }
                      }

                      DateTime? parsedCheckOut;
                      String? outRaw = item['checkOut'] ?? item['checkOutTime'] ?? item['outTime'] ?? item['clockOut'];
                      if (outRaw != null) {
                        if (outRaw.contains('T')) {
                          try { parsedCheckOut = DateTime.parse(outRaw).toLocal(); } catch(_) {}
                        } else {
                          parsedCheckOut = _parseUtcTime(dateStr, outRaw);
                        }
                      }

                      final status = item['status'] ?? 'Present';
                      final workMode = (item['workMode'] ?? 'office').toString();

                      return _buildAttendanceCard(
                        date: dateStr,
                        checkIn: parsedCheckIn,
                        checkOut: parsedCheckOut,
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
    String displayDate = date;
    try {
      displayDate = DateFormat('EEEE, dd MMM').format(DateTime.parse(date).toLocal());
    } catch (_) {}

    final checkInStr = checkIn != null ? DateFormat('hh:mm a').format(checkIn) : '--:--';
    final checkOutStr = checkOut != null ? DateFormat('hh:mm a').format(checkOut) : '--:--';
    final color = _getStatusColor(status);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.5), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  displayDate,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSimpleTimeCol("Check In", checkInStr, Iconsax.login, Colors.green),
                _buildSimpleTimeCol("Check Out", checkOutStr, Iconsax.logout, Colors.orange),
                _buildSimpleTimeCol("Total", _calculateHours(checkIn, checkOut), Iconsax.clock, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleTimeCol(String label, String time, IconData icon, Color color) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ],
        ),
        const SizedBox(height: 4),
        Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black)),
      ],
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
