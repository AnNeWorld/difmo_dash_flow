import 'package:flutter/material.dart';

class ProjectsTab extends StatefulWidget {
  const ProjectsTab({super.key});

  @override
  State<ProjectsTab> createState() => _ProjectsTabState();
}

class _ProjectsTabState extends State<ProjectsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Workload Hub",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF36617E),
          unselectedLabelColor: Colors.grey.shade500,
          indicatorColor: const Color(0xFF36617E),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: "To-Do"),
            Tab(text: "In-Progress"),
            Tab(text: "Completed"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TO-DO TAB
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              _buildProjectCard(
                context,
                title: "CRM Dashboard Redesign",
                priority: "High",
                progress: 0.0,
                avatars: ["assets/images/ranjeet.jpg"],
              ),
              _buildProjectCard(
                context,
                title: "Client Onboarding",
                priority: "Medium",
                progress: 0.0,
                avatars: ["assets/images/ranjeet.jpg", "assets/images/ranjeet.jpg"],
              ),
            ],
          ),
          
          // IN-PROGRESS TAB
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              _buildProjectCard(
                context,
                title: "API Integration v2",
                priority: "High",
                progress: 0.45,
                avatars: ["assets/images/ranjeet.jpg"],
              ),
              _buildProjectCard(
                context,
                title: "Marketing Campaign",
                priority: "Medium",
                progress: 0.60,
                avatars: ["assets/images/ranjeet.jpg", "assets/images/ranjeet.jpg"],
              ),
            ],
          ),

          // COMPLETED TAB
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
               _buildProjectCard(
                context,
                title: "Platform Maintenance",
                priority: "Low",
                progress: 1.0,
                avatars: ["assets/images/ranjeet.jpg"],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, {
    required String title,
    required String priority,
    required double progress,
    required List<String> avatars,
  }) {
    Color priorityColor = priority == "High" ? Colors.red.shade500 : (priority == "Medium" ? Colors.orange.shade500 : Colors.green.shade500);
    
    return GestureDetector(
      onTap: () {
        _showCollabBottomSheet(context, title);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
             BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Expanded(
                   child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: Color(0xFF1F2937)),
                    overflow: TextOverflow.ellipsis,
                                   ),
                 ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: priorityColor.withValues(alpha: 0.5))
                  ),
                  child: Text(
                    priority,
                    style: TextStyle(color: priorityColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Progress", style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
                Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF36617E)),
              borderRadius: BorderRadius.circular(8),
              minHeight: 8,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: avatars.map((avatar) => Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: CircleAvatar(
                      radius: 14,
                      backgroundImage: AssetImage(avatar),
                      backgroundColor: Colors.grey.shade200,
                    ),
                  )).toList(),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: const Text("View / Collab", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF36617E))),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCollabBottomSheet(BuildContext context, String projectTitle) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(projectTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Color(0xFF36617E), child: Icon(Icons.note_alt, color: Colors.white)),
                title: const Text("View Team Notes"),
                subtitle: const Text("See what your teammates have shared."),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Opening Notes...")));
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(backgroundColor: Colors.orange, child: Icon(Icons.upload_file, color: Colors.white)),
                title: const Text("Upload Quick Report"),
                subtitle: const Text("Submit your progress directly."),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Routing to Report Upload...")));
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }
}
