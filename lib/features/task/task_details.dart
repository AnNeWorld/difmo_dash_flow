import 'package:flutter/material.dart';

class TaskDetailsPage extends StatelessWidget {
  final String title;
  final String description;
  final bool completed;
  final String? priority;
  final String? dueDate;
  final String? assigneeName;
  const TaskDetailsPage({
    super.key,
    required this.title,
    required this.description,
    required this.completed,
    this.priority,
    this.dueDate,
    this.assigneeName,
  });

  @override
  Widget build(BuildContext context) {
    final String activePriority = priority ?? "Medium";
    
    String activeDueDate = "No Due Date Set";
    if (dueDate != null && dueDate!.isNotEmpty && dueDate != "null") {
      try {
        final parsed = DateTime.parse(dueDate!).toLocal();
        final months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        final hourVal = parsed.hour > 12 ? parsed.hour - 12 : (parsed.hour == 0 ? 12 : parsed.hour);
        final ampm = parsed.hour >= 12 ? "PM" : "AM";
        activeDueDate = "${months[parsed.month]} ${parsed.day}, ${parsed.year} at ${hourVal.toString().padLeft(2, '0')}:${parsed.minute.toString().padLeft(2, '0')} $ampm";
      } catch (_) {
        activeDueDate = dueDate!;
      }
    } else {
      final tomorrow = DateTime.now().add(const Duration(days: 3));
      final months = ["", "Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      activeDueDate = "${months[tomorrow.month]} ${tomorrow.day}, ${tomorrow.year} at 12:00 PM";
    }

    final String activeAssignee = assigneeName != null && assigneeName!.trim().isNotEmpty && assigneeName != "null" 
        ? assigneeName! 
        : "Unassigned";

    Color priorityColor;
    Color priorityBg;
    switch (activePriority.toUpperCase()) {
      case 'HIGH':
        priorityColor = const Color(0xFFC5221F);
        priorityBg = const Color(0xFFFCE8E6);
        break;
      case 'LOW':
        priorityColor = const Color(0xFF137333);
        priorityBg = const Color(0xFFE6F4EA);
        break;
      default:
        priorityColor = const Color(0xFFB06000);
        priorityBg = const Color(0xFFFEF7E0);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          'Task Details',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        elevation: 0,
        backgroundColor: const Color(0xFFF8F9FB),
        foregroundColor: const Color(0xFF1E293B),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: completed
                              ? const Color(0xFFE6F4EA)
                              : const Color(0xFFFEF7E0),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          completed ? "COMPLETED" : "PENDING",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: completed
                                ? const Color(0xFF137333)
                                : const Color(0xFFB06000),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: priorityBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "${activePriority.toUpperCase()} PRIORITY",
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: priorityColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Description Box
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
              ),
              child: Text(
                description,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Metadata Grid
            const Text(
              "Task Information",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoCard(
                    Icons.calendar_today_rounded,
                    "Due Date",
                    activeDueDate,
                    const Color(0xFF2C5282),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInfoCard(
                    Icons.person_outline_rounded,
                    "Assignee",
                    activeAssignee,
                    const Color(0xFF1A73E8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withValues(alpha: 0.1),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
