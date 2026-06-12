import 'package:dashflow/company/pages/post_job_page.dart';
import 'package:dashflow/company/pages/review_application_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dashflow/company/components/shared/app_drawer.dart';

final jobsProvider =
    StateNotifierProvider<JobsNotifier, AsyncValue<List<dynamic>>>((ref) {
      return JobsNotifier();
    });

final applicationsProvider =
    StateNotifierProvider<ApplicationsNotifier, AsyncValue<List<dynamic>>>((
      ref,
    ) {
      return ApplicationsNotifier();
    });

class ApplicationsNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  ApplicationsNotifier() : super(const AsyncValue.loading()) {
    fetchApplications();
  }

  Future<void> fetchApplications() async {
    try {
      state = const AsyncValue.loading();
      final prefs = await SharedPreferences.getInstance();
      final userStr =
          prefs.getString('user') ?? prefs.getString('user_profile');
      String? companyId;
      if (userStr != null) {
        final u = jsonDecode(userStr);
        companyId =
            u['companyId']?.toString() ??
            (u['company'] is Map
                ? (u['company']['id']?.toString() ??
                      u['company']['_id']?.toString())
                : u['company']?.toString());
      }

      final applications = await ApiService().getJobApplications(
        companyId: companyId,
      );
      print(
        'DEBUG: fetchApplications fetched ${applications.length} items for company $companyId',
      );
      state = AsyncValue.data(applications);
    } catch (e, st) {
      print('DEBUG: fetchApplications error: $e');
      state = AsyncValue.error(e, st);
    }
  }
}

class JobsNotifier extends StateNotifier<AsyncValue<List<dynamic>>> {
  JobsNotifier() : super(const AsyncValue.loading()) {
    fetchJobs();
  }

  Future<void> fetchJobs() async {
    try {
      state = const AsyncValue.loading();
      final prefs = await SharedPreferences.getInstance();
      final userStr =
          prefs.getString('user') ?? prefs.getString('user_profile');
      String? companyId;
      if (userStr != null) {
        final u = jsonDecode(userStr);
        companyId =
            u['companyId']?.toString() ??
            (u['company'] is Map
                ? (u['company']['id']?.toString() ??
                      u['company']['_id']?.toString())
                : u['company']?.toString());
      }

      final jobs = await ApiService().getJobs(companyId: companyId);
      print(
        'DEBUG: fetchJobs fetched ${jobs.length} items for company $companyId',
      );
      state = AsyncValue.data(jobs);
    } catch (e, st) {
      print('DEBUG: fetchJobs error: $e');
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteJob(String jobId) async {
    try {
      await ApiService().deleteJob(jobId);
      state.whenData((jobs) {
        state = AsyncValue.data(
          jobs.where((j) => j['id'] != jobId && j['_id'] != jobId).toList(),
        );
      });
    } catch (e) {
      // Handle error if needed
    }
  }
}

class RecruitmentPage extends ConsumerStatefulWidget {
  const RecruitmentPage({super.key});

  @override
  ConsumerState<RecruitmentPage> createState() => _RecruitmentDashboardState();
}

class _RecruitmentDashboardState extends ConsumerState<RecruitmentPage> {
  int _selectedIndex = 2;

  @override
  Widget build(BuildContext context) {
    final jobsAsync = ref.watch(jobsProvider);
    final applicationsAsync = ref.watch(applicationsProvider);

    int totalJobs = 0;
    jobsAsync.whenData((jobs) => totalJobs = jobs.length);

    int totalApplications = 0;
    int interviews = 0;
    int offers = 0;
    int newApplications = 0;

    applicationsAsync.whenData((apps) {
      totalApplications = apps.length;
      for (var app in apps) {
        final status = app['status']?.toString().toLowerCase() ?? '';
        if (status.contains('interview'))
          interviews++;
        else if (status.contains('offer') || status.contains('hired'))
          offers++;

        if (status == 'new' || status == 'pending' || status == '')
          newApplications++;
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      drawer: const AppDrawer(activeRoute: 'Recruitment'),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Builder(
                          builder: (context) => IconButton(
                            icon: const Icon(
                              Icons.menu,
                              color: Color(0xFF2563EB),
                              size: 24,
                            ),
                            onPressed: () => Scaffold.of(context).openDrawer(),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'DIFMO CRM',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300],
                      child: Image.asset(
                        'assets/profile.png',
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.person, color: Colors.grey);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recruitment',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'v2.4.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF2563EB,
                              ).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PostJobPage(),
                                ),
                              );
                              if (result == true) {
                                ref.read(jobsProvider.notifier).fetchJobs();
                              }
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.2,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Post a Job',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF10B981,
                              ).withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ReviewApplicationsPage(),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.group,
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      ),
                                      Positioned(
                                        right: 0,
                                        top: 0,
                                        child: Container(
                                          width: 20,
                                          height: 20,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFEF4444),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              newApplications > 0
                                                  ? '$newApplications'
                                                  : '$totalApplications',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Review\nApplications',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF2563EB),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pipeline Overview',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Active across $totalJobs postings',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Pipeline options coming soon!',
                                    ),
                                  ),
                                );
                              },
                              child: Icon(
                                Icons.more_vert,
                                color: Colors.grey[400],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '$totalApplications',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2563EB),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Total',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey[300],
                            ),
                            Column(
                              children: [
                                Text(
                                  '$interviews',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF10B981),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Interviews',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: Colors.grey[300],
                            ),
                            Column(
                              children: [
                                Text(
                                  '$offers',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFD97706),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Offers',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Active Job Postings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        final url = Uri.parse(
                          'https://dashflow-frontend.vercel.app/difmo-jobs',
                        );
                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        )) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not launch careers page'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ref
                  .watch(jobsProvider)
                  .when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    error: (err, _) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'Failed to load jobs: $err',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                    data: (jobs) {
                      if (jobs.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Center(
                            child: Text(
                              'No active job postings.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }
                      return Column(children: _buildJobCards(jobs));
                    },
                  ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Review Applications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: applicationsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ),
                  error: (err, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Failed to load applications: $err',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  data: (apps) {
                    if (apps.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Center(
                          child: Text(
                            'No applications yet.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    return Row(
                      children: apps.take(5).map((app) {
                        final name =
                            app['applicantName']?.toString() ??
                            app['name']?.toString() ??
                            'Applicant';
                        final position =
                            app['jobTitle']?.toString() ??
                            app['position']?.toString() ??
                            'Position';
                        final status = app['status']?.toString() ?? 'Pending';
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: _buildCandidateCard(
                            context: context,
                            name: name,
                            position: position,
                            badge1: status,
                            badge2: 'New',
                            color1: const Color(0xFF10B981),
                            color2: const Color(0xFFEBF5FF),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildJobCards(List<dynamic> jobs) {
    final colors = [
      const Color(0xFF5B7AFF),
      const Color(0xFFFFB366),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF0891B2),
      const Color(0xFFD97706),
    ];
    final icons = [
      Icons.phone_android_rounded,
      Icons.bar_chart_rounded,
      Icons.palette_rounded,
      Icons.code_rounded,
      Icons.architecture_rounded,
      Icons.group_rounded,
      Icons.trending_up_rounded,
    ];

    return List.generate(jobs.length, (index) {
      final job = jobs[index];
      final title = job['title']?.toString() ?? 'Unknown Position';
      final type =
          job['type']?.toString() ?? job['jobType']?.toString() ?? 'Full-time';
      final location = job['location']?.toString() ?? 'Remote';
      final experience = job['experience']?.toString() ?? '';
      final department = job['department']?.toString() ?? '';
      final isActive = job['isActive'] == true;
      final jobId = job['id']?.toString() ?? job['_id']?.toString() ?? '';
      final appEndDate = job['applicationEndDate']?.toString();
      final applicationsCount = job['applicationsCount']?.toString() ?? '0';

      // Parse deadline
      String deadline = '';
      if (appEndDate != null) {
        final dt = DateTime.tryParse(appEndDate);
        if (dt != null) {
          final diff = dt.difference(DateTime.now()).inDays;
          if (diff < 0) {
            deadline = 'Closed';
          } else if (diff == 0) {
            deadline = 'Last day!';
          } else {
            deadline = '$diff days left';
          }
        }
      }

      final color = colors[index % colors.length];
      final icon = icons[index % icons.length];

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Dismissible(
          key: Key(jobId.isNotEmpty ? jobId : index.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFDC2626),
            ),
          ),
          onDismissed: (_) {
            if (jobId.isNotEmpty) {
              ref.read(jobsProvider.notifier).deleteJob(jobId);
            }
          },
          child: GestureDetector(
            onTap: () => _showJobDetails(context, job, color, icon),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: color.withValues(alpha: 0.15),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(icon, color: color, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                department,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Status badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            isActive ? 'Active' : 'Closed',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? const Color(0xFF10B981)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Tags row
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _buildTag(Icons.location_on_outlined, location, color),
                        _buildTag(Icons.work_outline_rounded, type, color),
                        if (experience.isNotEmpty)
                          _buildTag(Icons.timeline_rounded, experience, color),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.people_outline_rounded,
                              size: 14,
                              color: Colors.grey[500],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$applicationsCount Applied',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        if (deadline.isNotEmpty)
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 13,
                                color: deadline == 'Closed'
                                    ? Colors.red
                                    : deadline == 'Last day!'
                                    ? Colors.orange
                                    : Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                deadline,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: deadline == 'Closed'
                                      ? Colors.red
                                      : deadline == 'Last day!'
                                      ? Colors.orange
                                      : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTag(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _showJobDetails(
    BuildContext context,
    dynamic job,
    Color color,
    IconData icon,
  ) {
    final title = job['title']?.toString() ?? 'Unknown Position';
    final type =
        job['type']?.toString() ?? job['jobType']?.toString() ?? 'Full-time';
    final location = job['location']?.toString() ?? 'Remote';
    final experience = job['experience']?.toString() ?? '';
    final department = job['department']?.toString() ?? '';
    final description = job['description']?.toString() ?? '';
    final isActive = job['isActive'] == true;
    final responsibilities =
        (job['responsibilities'] as List?)?.cast<String>() ?? [];
    final requirements = (job['requirements'] as List?)?.cast<String>() ?? [];
    final appEndDate = job['applicationEndDate']?.toString();
    final appStartDate = job['applicationStartDate']?.toString();

    String _formatDate(String? iso) {
      if (iso == null) return '';
      final dt = DateTime.tryParse(iso);
      if (dt == null) return iso;
      final months = [
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
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Header
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(icon, color: color, size: 26),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                department,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xFF10B981).withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isActive ? '● Active' : '● Closed',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isActive
                                  ? const Color(0xFF10B981)
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Info chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildTag(Icons.location_on_outlined, location, color),
                        _buildTag(Icons.work_outline_rounded, type, color),
                        if (experience.isNotEmpty)
                          _buildTag(Icons.timeline_rounded, experience, color),
                      ],
                    ),
                    // Application dates
                    if (appStartDate != null || appEndDate != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: color.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          children: [
                            if (appStartDate != null)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Apply From',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _formatDate(appStartDate),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (appStartDate != null && appEndDate != null)
                              Container(
                                width: 1,
                                height: 30,
                                color: color.withValues(alpha: 0.2),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                              ),
                            if (appEndDate != null)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Apply By',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      _formatDate(appEndDate),
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    // Description
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _sectionHeader(
                        'About this Role',
                        Icons.info_outline_rounded,
                        color,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Colors.grey[700],
                          height: 1.6,
                        ),
                      ),
                    ],
                    // Responsibilities
                    if (responsibilities.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _sectionHeader(
                        'Responsibilities',
                        Icons.checklist_rounded,
                        color,
                      ),
                      const SizedBox(height: 10),
                      ...responsibilities.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                margin: const EdgeInsets.only(top: 5),
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  r,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    // Requirements
                    if (requirements.isNotEmpty) ...[
                      const SizedBox(height: 20),
                      _sectionHeader(
                        'Requirements',
                        Icons.task_alt_rounded,
                        color,
                      ),
                      const SizedBox(height: 10),
                      ...requirements.map(
                        (r) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: color,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  r,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    color: Colors.grey[700],
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildCandidateCard({
    required BuildContext context,
    required String name,
    required String position,
    required String badge1,
    required String badge2,
    required Color color1,
    required Color color2,
  }) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 3,
              width: 60,
              decoration: BoxDecoration(
                color: color1,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.grey, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      Text(
                        position,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color1,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge1,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color2,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge2,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReviewApplicationsPage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Shortlist',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
