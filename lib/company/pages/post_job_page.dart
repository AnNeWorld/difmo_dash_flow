import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../services/api_service.dart';

class PostJobPage extends StatefulWidget {
  const PostJobPage({super.key});
  @override
  State<PostJobPage> createState() => _PostJobPageState();
}

class _PostJobPageState extends State<PostJobPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _salaryMinController = TextEditingController();
  final TextEditingController _salaryMaxController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _requirementsController = TextEditingController();
  final TextEditingController _vacanciesController = TextEditingController();

  String _selectedJobType = 'Full-Time';
  String _selectedExperience = 'Mid Level';
  String _selectedWorkMode = 'On-site';

  bool _isPosting = false;

  final List<String> _jobTypes = [
    'Full-Time',
    'Part-Time',
    'Contract',
    'Internship',
    'Freelance',
  ];
  final List<String> _experienceLevels = [
    'Entry Level',
    'Mid Level',
    'Senior Level',
    'Lead',
    'Manager',
  ];
  final List<String> _workModes = ['On-site', 'Remote', 'Hybrid'];

  @override
  void dispose() {
    _jobTitleController.dispose();
    _departmentController.dispose();
    _locationController.dispose();
    _salaryMinController.dispose();
    _salaryMaxController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _vacanciesController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF1E40AF), size: 20),
      labelStyle: const TextStyle(
        color: Color(0xFF374151),
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        borderSide: const BorderSide(color: Color(0xFF1E40AF), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Color(0xFF111827),
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _chipSelector({
    required String label,
    required List<String> options,
    required String selected,
    required void Function(String) onSelect,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = selected == option;
            return GestureDetector(
              onTap: () => onSelect(option),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1E40AF)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1E40AF)
                        : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  option,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isSelected ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
        title: const Text(
          'Post a Job',
          style: TextStyle(
            color: Color(0xFF111827),
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E7EB)),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Basic Information'),
                    TextFormField(
                      controller: _jobTitleController,
                      decoration: _inputDecoration(
                        'Job Title',
                        'e.g. Senior Flutter Developer',
                        Icons.work_outline,
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Job title is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _departmentController,
                      decoration: _inputDecoration(
                        'Department',
                        'e.g. Engineering',
                        Icons.business_outlined,
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Department is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _locationController,
                      decoration: _inputDecoration(
                        'Location',
                        'e.g. Mumbai, India',
                        Icons.location_on_outlined,
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Location is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _vacanciesController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration(
                        'Number of Vacancies',
                        'e.g. 2',
                        Icons.people_outline,
                      ),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Vacancies is required'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Job Preferences'),
                    _chipSelector(
                      label: 'Job Type',
                      options: _jobTypes,
                      selected: _selectedJobType,
                      onSelect: (v) => setState(() => _selectedJobType = v),
                    ),
                    const SizedBox(height: 20),
                    _chipSelector(
                      label: 'Work Mode',
                      options: _workModes,
                      selected: _selectedWorkMode,
                      onSelect: (v) => setState(() => _selectedWorkMode = v),
                    ),
                    const SizedBox(height: 20),
                    _chipSelector(
                      label: 'Experience Level',
                      options: _experienceLevels,
                      selected: _selectedExperience,
                      onSelect: (v) => setState(() => _selectedExperience = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Salary Range (₹ / Month)'),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _salaryMinController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              'Minimum',
                              '30,000',
                              Icons.currency_rupee,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _salaryMaxController,
                            keyboardType: TextInputType.number,
                            decoration: _inputDecoration(
                              'Maximum',
                              '80,000',
                              Icons.currency_rupee,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _buildCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Job Description'),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 5,
                      decoration: _inputDecoration(
                        'Description',
                        'Describe the role, responsibilities...',
                        Icons.description_outlined,
                      ).copyWith(prefixIcon: null),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Description is required'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _sectionLabel('Requirements'),
                    TextFormField(
                      controller: _requirementsController,
                      maxLines: 4,
                      decoration: _inputDecoration(
                        'Requirements',
                        'List skills, qualifications...',
                        Icons.checklist_outlined,
                      ).copyWith(prefixIcon: null),
                      validator: (v) => v == null || v.isEmpty
                          ? 'Requirements is required'
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isPosting
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _isPosting = true;
                            });
                            try {
                              final prefs = await SharedPreferences.getInstance();
                              String companyId = '';
                              final token = prefs.getString('token') ?? prefs.getString('jwt_token');
                              if (token != null && token.isNotEmpty) {
                                final parts = token.split('.');
                                if (parts.length == 3) {
                                  final payload = jsonDecode(
                                      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));
                                  companyId = payload['companyId']?.toString() ?? '';
                                }
                              }
                              if (companyId.isEmpty) {
                                final userStr = prefs.getString('user') ?? prefs.getString('user_profile');
                                if (userStr != null) {
                                  final user = jsonDecode(userStr);
                                  companyId = user['companyId']?.toString() ??
                                      user['company']?['id']?.toString() ??
                                      user['company']?['_id']?.toString() ??
                                      '';
                                }
                              }

                              final reqList = _requirementsController.text
                                  .split(RegExp(r'\n|,'))
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList();

                              final data = {
                                'companyId': companyId,
                                'title': _jobTitleController.text,
                                'department': _departmentController.text,
                                'location': _locationController.text,
                                'type': _selectedJobType,
                                'experience': _selectedExperience,
                                'description': _descriptionController.text,
                                'requirements': reqList,
                                'responsibilities': [],
                                'applicationStartDate': DateTime.now().toIso8601String(),
                                'applicationEndDate': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
                                'isActive': true,
                                'vacancies': int.tryParse(_vacanciesController.text) ?? 1,
                                'workMode': _selectedWorkMode,
                                'minSalary': int.tryParse(_salaryMinController.text) ?? 0,
                                'maxSalary': int.tryParse(_salaryMaxController.text) ?? 0,
                              };

                              await ApiService().postJob(data);

                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white),
                                      SizedBox(width: 8),
                                      Text('Job Posted Successfully!'),
                                    ],
                                  ),
                                  backgroundColor: Colors.green.shade700,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              Navigator.pop(context, true); // true to indicate success
                            } catch (e) {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error posting job: $e'),
                                  backgroundColor: Colors.red.shade700,
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() {
                                  _isPosting = false;
                                });
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E40AF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isPosting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Post Job',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}
