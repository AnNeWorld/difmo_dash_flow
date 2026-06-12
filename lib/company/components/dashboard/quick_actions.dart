import 'package:dashflow/company/pages/add_employee_page.dart';
import 'package:dashflow/company/pages/post_job_page.dart';
import 'package:dashflow/company/pages/review_application_page.dart';
import 'package:flutter/material.dart';

class QuickActionsWidget extends StatelessWidget {
  const QuickActionsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff1E293B), // Dark Slate
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Command Terminal",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Execute primary operations",
            style: TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          _buildActionCard(
            context,
            icon: Icons.person_add_alt_1,
            title: "Add Employee",
            subtitle: "Onboard new team member",
            color: Colors.blue.shade600,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEmployeePage(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context,
            icon: Icons.post_add,
            title: "Post Job",
            subtitle: "Create new vacancy",
            color: Colors.purple.shade600,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PostJobPage()),
              );
              // Post Job Action
            },
          ),
          const SizedBox(height: 12),
          _buildActionCard(
            context,
            icon: Icons.assignment_ind,
            title: "Review Applications",
            subtitle: "Process pending candidates",
            color: Colors.orange.shade600,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReviewApplicationsPage(),
                ),
              );
              // Review Applications Action
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
      ),
    );
  }
}
