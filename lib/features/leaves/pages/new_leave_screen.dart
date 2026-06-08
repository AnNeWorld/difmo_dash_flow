import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dashflow/company/services/api_service.dart' as company_api;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NewLeaveScreen extends StatefulWidget {
  const NewLeaveScreen({super.key});

  @override
  State<NewLeaveScreen> createState() => _NewLeaveScreenState();
}

class _NewLeaveScreenState extends State<NewLeaveScreen> {
  String selectedLeaveType = "Casual";
  String selectedDuration = "Full Day";
  DateTime? singleDate;
  DateTime? fromDate;
  DateTime? toDate;
  String reasonText = "";
  final TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    reasonController.addListener(() {
      setState(() {
        reasonText = reasonController.text;
      });
    });
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.chevron_left, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "New Leave",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E202B),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Apply for leave",
                style: TextStyle(fontSize: 16, color: Color(0xFF8B8B9E)),
              ),
              const SizedBox(height: 30),
              // LEAVE TYPE SECTION
              const Text(
                "LEAVE TYPE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B8B9E),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildLeaveTypeCard("Casual", "🏖️"),
                    const SizedBox(width: 16),
                    _buildLeaveTypeCard("Sick", "🏥"),
                    const SizedBox(width: 16),
                    _buildLeaveTypeCard("Earned", "📅"),
                    const SizedBox(width: 16),
                    _buildLeaveTypeCard("Maternity", "👶"),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // DURATION SECTION
              const Text(
                "DURATION",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B8B9E),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              _buildDurationOption("Full Day", "🌞"),
              const SizedBox(height: 12),
              _buildDurationOption("Half Day", "🌤️"),
              const SizedBox(height: 12),
              _buildDurationOption("Multiple Days", "📅"),
              const SizedBox(height: 30),
              // DATE SECTION
              const Text(
                "DATE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B8B9E),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              // Show single date picker for Full Day and Half Day
              if (selectedDuration != "Multiple Days") ...[
                GestureDetector(
                  onTap: _pickSingleDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF8B8B9E),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Date",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8B8B9E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                singleDate != null
                                    ? DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(singleDate!)
                                    : "Tap to select",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: singleDate != null
                                      ? Colors.black
                                      : Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey.shade300),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Show two date pickers for Multiple Days
                GestureDetector(
                  onTap: _pickFromDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF8B8B9E),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "From Date",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8B8B9E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fromDate != null
                                    ? DateFormat(
                                        'MMM dd, yyyy',
                                      ).format(fromDate!)
                                    : "Tap to select",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: fromDate != null
                                      ? Colors.black
                                      : Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey.shade300),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _pickToDate,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_today,
                            color: Color(0xFF8B8B9E),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "To Date",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF8B8B9E),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                toDate != null
                                    ? DateFormat('MMM dd, yyyy').format(toDate!)
                                    : "Tap to select",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: toDate != null
                                      ? Colors.black
                                      : Colors.grey.shade400,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey.shade300),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 30),
              // REASON FOR LEAVE SECTION
              const Text(
                "REASON FOR LEAVE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF8B8B9E),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    TextField(
                      controller: reasonController,
                      maxLength: 300,
                      maxLines: 6,
                      decoration: InputDecoration(
                        hintText: "Describe your reason here...",
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        counterText: "",
                      ),
                      style: const TextStyle(fontSize: 14),
                    ),
                    Positioned(
                      bottom: 12,
                      right: 16,
                      child: Text(
                        "${reasonText.length}/300",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              // SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5A67D8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: _submitLeaveRequest,
                  child: const Text(
                    "Submit Leave Request",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaveTypeCard(String type, String emoji) {
    bool isSelected = selectedLeaveType == type;
    return GestureDetector(
      onTap: () => setState(() => selectedLeaveType = type),
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFFC89D5C) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFC89D5C).withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 12),
            Text(
              type,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? const Color(0xFFC89D5C)
                    : const Color(0xFF8B8B9E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationOption(String duration, String emoji) {
    bool isSelected = selectedDuration == duration;
    return GestureDetector(
      onTap: () {
        setState(() => selectedDuration = duration);
        // Clear dates when changing duration
        if (duration == "Multiple Days") {
          singleDate = null;
        } else {
          fromDate = null;
          toDate = null;
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 0,
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                duration,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : const Color(0xFF8B8B9E),
                ),
              ),
            ),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : Colors.grey.shade300,
                  width: 2,
                ),
                color: isSelected ? const Color(0xFF2563EB) : Colors.white,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 12, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickSingleDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: singleDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != singleDate) {
      setState(() {
        singleDate = picked;
      });
    }
  }

  Future<void> _pickFromDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        fromDate = picked;
        // Reset toDate if it's before fromDate
        if (toDate != null && toDate!.isBefore(fromDate!)) {
          toDate = null;
        }
      });
    }
  }

  Future<void> _pickToDate() async {
    if (fromDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select From Date first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: toDate ?? fromDate!,
      firstDate: fromDate!,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        toDate = picked;
      });
    }
  }

  Future<void> _submitLeaveRequest() async {
    // Validation
    if (selectedDuration == "Multiple Days") {
      if (fromDate == null || toDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select both From Date and To Date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    } else {
      if (singleDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a date'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr =
          prefs.getString('user') ?? prefs.getString('user_profile');
      String companyId = '';
      String employeeId = '';
      if (userStr != null) {
        final user = jsonDecode(userStr);
        companyId =
            user['companyId'] ??
            user['company']?['_id'] ??
            user['company']?['id'] ??
            user['company'] ??
            '';
        employeeId = user['employeeId'] ?? user['id'] ?? user['_id'] ?? '';
      }

      final startDate = selectedDuration == "Multiple Days"
          ? fromDate!
          : singleDate!;
      final endDate = selectedDuration == "Multiple Days"
          ? toDate!
          : singleDate!;

      await company_api.ApiService().requestLeave(
        employeeId: employeeId,
        companyId: companyId,
        type: selectedLeaveType,
        startDate: startDate.toIso8601String(),
        endDate: endDate.toIso8601String(),
        reason: reasonText,
      );

      if (mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Leave request submitted!"),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context, true); // Pop screen and return true to refresh
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // close dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit leave: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
