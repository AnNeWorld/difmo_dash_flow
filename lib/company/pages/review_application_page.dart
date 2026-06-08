import 'package:flutter/material.dart';

class Applicant {
  final String name;
  final String role;
  final String location;
  final String experience;
  final String appliedDate;
  final String avatarInitials;
  final Color avatarColor;
  String status;

  Applicant({
    required this.name,
    required this.role,
    required this.location,
    required this.experience,
    required this.appliedDate,
    required this.avatarInitials,
    required this.avatarColor,
    required this.status,
  });
}

class ReviewApplicationsPage extends StatefulWidget {
  const ReviewApplicationsPage({super.key});

  @override
  State<ReviewApplicationsPage> createState() => _ReviewApplicationsPageState();
}

class _ReviewApplicationsPageState extends State<ReviewApplicationsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<Applicant> _applicants = [
    Applicant(
      name: 'Aryan Sharma',
      role: 'Senior Flutter Developer',
      location: 'Mumbai, India',
      experience: '5 yrs exp',
      appliedDate: 'Today',
      avatarInitials: 'AS',
      avatarColor: const Color(0xFF1E40AF),
      status: 'New',
    ),
    Applicant(
      name: 'Priya Verma',
      role: 'UI/UX Designer',
      location: 'Bangalore, India',
      experience: '3 yrs exp',
      appliedDate: 'Yesterday',
      avatarInitials: 'PV',
      avatarColor: const Color(0xFF065F46),
      status: 'Shortlisted',
    ),
    Applicant(
      name: 'Rahul Mehta',
      role: 'Backend Engineer',
      location: 'Delhi, India',
      experience: '7 yrs exp',
      appliedDate: 'Dec 18',
      avatarInitials: 'RM',
      avatarColor: const Color(0xFF92400E),
      status: 'Interview',
    ),
    Applicant(
      name: 'Sneha Patel',
      role: 'Product Manager',
      location: 'Pune, India',
      experience: '4 yrs exp',
      appliedDate: 'Dec 17',
      avatarInitials: 'SP',
      avatarColor: const Color(0xFF6B21A8),
      status: 'Offered',
    ),
    Applicant(
      name: 'Karan Joshi',
      role: 'Senior Flutter Developer',
      location: 'Hyderabad, India',
      experience: '6 yrs exp',
      appliedDate: 'Dec 16',
      avatarInitials: 'KJ',
      avatarColor: const Color(0xFF9F1239),
      status: 'Rejected',
    ),
    Applicant(
      name: 'Divya Nair',
      role: 'Data Analyst',
      location: 'Chennai, India',
      experience: '2 yrs exp',
      appliedDate: 'Dec 15',
      avatarInitials: 'DN',
      avatarColor: const Color(0xFF164E63),
      status: 'New',
    ),
    Applicant(
      name: 'Rohan Gupta',
      role: 'DevOps Engineer',
      location: 'Kolkata, India',
      experience: '4 yrs exp',
      appliedDate: 'Dec 14',
      avatarInitials: 'RG',
      avatarColor: const Color(0xFF14532D),
      status: 'Shortlisted',
    ),
    Applicant(
      name: 'Anjali Singh',
      role: 'HR Coordinator',
      location: 'Jaipur, India',
      experience: '3 yrs exp',
      appliedDate: 'Dec 13',
      avatarInitials: 'AS',
      avatarColor: const Color(0xFF1E3A5F),
      status: 'Interview',
    ),
  ];

  final List<String> _tabs = [
    'All',
    'New',
    'Shortlisted',
    'Interview',
    'Offered',
    'Rejected',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Applicant> get _filtered {
    final tabIndex = _tabController.index;
    final tabFilter = _tabs[tabIndex];

    return _applicants.where((a) {
      final matchesTab = tabFilter == 'All' || a.status == tabFilter;
      final matchesSearch =
          _searchQuery.isEmpty ||
          a.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          a.role.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesTab && matchesSearch;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'New':
        return const Color(0xFF1E40AF);
      case 'Shortlisted':
        return const Color(0xFF065F46);
      case 'Interview':
        return const Color(0xFF92400E);
      case 'Offered':
        return const Color(0xFF6B21A8);
      case 'Rejected':
        return const Color(0xFF9F1239);
      default:
        return Colors.grey;
    }
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'New':
        return const Color(0xFFEFF6FF);
      case 'Shortlisted':
        return const Color(0xFFECFDF5);
      case 'Interview':
        return const Color(0xFFFFFBEB);
      case 'Offered':
        return const Color(0xFFF5F3FF);
      case 'Rejected':
        return const Color(0xFFFFF1F2);
      default:
        return Colors.grey.shade100;
    }
  }

  void _changeStatus(Applicant applicant, String newStatus) {
    setState(() {
      applicant.status = newStatus;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${applicant.name} moved to $newStatus'),
        backgroundColor: _statusColor(newStatus),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showApplicantDetail(Applicant applicant) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ApplicantDetailSheet(
        applicant: applicant,
        statusColor: _statusColor(applicant.status),
        statusBg: _statusBg(applicant.status),
        onStatusChange: (newStatus) {
          Navigator.pop(context);
          _changeStatus(applicant, newStatus);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF111827),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Review Applications',
              style: TextStyle(
                color: Color(0xFF111827),
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            Text(
              '${_applicants.length} total applicants',
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.people_alt_outlined,
                  color: Color(0xFF1E40AF),
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_applicants.length}',
                  style: const TextStyle(
                    color: Color(0xFF1E40AF),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search by name or role...',
                hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(0xFF6B7280),
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF9FAFB),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF1E40AF),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              onTap: (_) => setState(() {}),
              labelColor: const Color(0xFF1E40AF),
              unselectedLabelColor: const Color(0xFF6B7280),
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
              indicator: const UnderlineTabIndicator(
                borderSide: BorderSide(color: Color(0xFF1E40AF), width: 2.5),
              ),
              tabs: _tabs.map((tab) {
                final count = tab == 'All'
                    ? _applicants.length
                    : _applicants.where((a) => a.status == tab).length;
                return Tab(
                  child: Row(
                    children: [
                      Text(tab),
                      if (count > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E40AF),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: _filtered.isEmpty
                ? _buildEmpty()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filtered.length,
                    itemBuilder: (ctx, i) => _buildApplicantCard(_filtered[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 12),
          Text(
            'No applicants found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Try changing filters or search',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(Applicant applicant) {
    return GestureDetector(
      onTap: () => _showApplicantDetail(applicant),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: applicant.avatarColor.withOpacity(0.12), // ✅ FIXED
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                applicant.avatarInitials,
                style: TextStyle(
                  color: applicant.avatarColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          applicant.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBg(applicant.status),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          applicant.status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _statusColor(applicant.status),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    applicant.role,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF374151),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 13,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        applicant.location,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.work_outline,
                        size: 13,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        applicant.experience,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        applicant.appliedDate,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplicantDetailSheet extends StatelessWidget {
  final Applicant applicant;
  final Color statusColor;
  final Color statusBg;
  final void Function(String) onStatusChange;

  const _ApplicantDetailSheet({
    required this.applicant,
    required this.statusColor,
    required this.statusBg,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      'New',
      'Shortlisted',
      'Interview',
      'Offered',
      'Rejected',
    ].where((s) => s != applicant.status).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: applicant.avatarColor.withOpacity(0.12), // ✅ FIXED
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    applicant.avatarInitials,
                    style: TextStyle(
                      color: applicant.avatarColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        applicant.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        applicant.role,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    applicant.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade100, height: 1),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailRow(
                    Icons.location_on_outlined,
                    'Location',
                    applicant.location,
                  ),
                  _detailRow(
                    Icons.work_outline,
                    'Experience',
                    applicant.experience,
                  ),
                  _detailRow(
                    Icons.calendar_today_outlined,
                    'Applied',
                    applicant.appliedDate,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Move to Stage',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: actions.map((action) {
                      Color bg;
                      Color fg;
                      switch (action) {
                        case 'New':
                          bg = const Color(0xFFEFF6FF);
                          fg = const Color(0xFF1E40AF);
                          break;
                        case 'Shortlisted':
                          bg = const Color(0xFFECFDF5);
                          fg = const Color(0xFF065F46);
                          break;
                        case 'Interview':
                          bg = const Color(0xFFFFFBEB);
                          fg = const Color(0xFF92400E);
                          break;
                        case 'Offered':
                          bg = const Color(0xFFF5F3FF);
                          fg = const Color(0xFF6B21A8);
                          break;
                        case 'Rejected':
                          bg = const Color(0xFFFFF1F2);
                          fg = const Color(0xFF9F1239);
                          break;
                        default:
                          bg = Colors.grey.shade100;
                          fg = Colors.grey;
                      }
                      return GestureDetector(
                        onTap: () => onStatusChange(action),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: bg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: fg.withOpacity(0.3)),
                          ),
                          child: Text(
                            action,
                            style: TextStyle(
                              color: fg,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _actionButton(
                          icon: Icons.call_outlined,
                          label: 'Call',
                          color: const Color(0xFF065F46),
                          bg: const Color(0xFFECFDF5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _actionButton(
                          icon: Icons.mail_outline,
                          label: 'Email',
                          color: const Color(0xFF1E40AF),
                          bg: const Color(0xFFEFF6FF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _actionButton(
                          icon: Icons.download_outlined,
                          label: 'Resume',
                          color: const Color(0xFF6B21A8),
                          bg: const Color(0xFFF5F3FF),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF374151)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
