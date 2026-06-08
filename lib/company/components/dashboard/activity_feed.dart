import 'package:flutter/material.dart';
import '../../models/dashboard_model.dart';

class ActivityFeedWidget extends StatelessWidget {
  final List<ActivityFeedItem> activities;

  const ActivityFeedWidget({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "System Activity Log",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0F172A),
                ),
              ),
              Text(
                "View All",
                style: TextStyle(
                  color: Colors.blue.shade700,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...activities.map((activity) {
            Color typeColor;
            IconData typeIcon;

            switch (activity.type.toLowerCase()) {
              case 'hr':
                typeColor = Colors.purple;
                typeIcon = Icons.people;
                break;
              case 'it':
              case 'system':
                typeColor = Colors.blue;
                typeIcon = Icons.computer;
                break;
              case 'event':
                typeColor = Colors.orange;
                typeIcon = Icons.event;
                break;
              case 'finance':
                typeColor = Colors.green;
                typeIcon = Icons.attach_money;
                break;
              default:
                typeColor = Colors.grey;
                typeIcon = Icons.notifications;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(typeIcon, color: typeColor, size: 16),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Color(0xff0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity.type,
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    activity.time,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
