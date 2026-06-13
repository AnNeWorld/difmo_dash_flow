import 'package:flutter/material.dart';
import 'package:dashflow/core/api/api_service.dart';
import 'package:dashflow/company/services/api_service.dart' as company_api;
import 'package:dashflow/features/auth/pages/login_screen.dart' as dashflow_login;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dashflow/company/components/shared/app_drawer.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CompanyProfilePage extends StatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  State<CompanyProfilePage> createState() => _CompanyProfilePage();
}

class _CompanyProfilePage extends State<CompanyProfilePage> {
  bool _isFollowing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await company_api.ApiService().getProfile();
      final company = profile['company'] ?? profile;
      if (company != null && company is Map<String, dynamic>) {
        setState(() {
          companyData['name'] = company['name'] ?? companyData['name'];
          companyData['website'] = company['website'] ?? companyData['website'];
          companyData['industry'] = company['industry'] ?? companyData['industry'];
          companyData['headquarters'] = company['address'] ?? companyData['headquarters'];
          companyData['email'] = company['email'] ?? companyData['email'];
          companyData['phone'] = company['phone'] ?? companyData['phone'];
          companyData['about'] = company['description'] ?? companyData['about'];
          
          if (company['city'] != null || company['country'] != null) {
            companyData['locations'] = [
              {
                'city': company['city'] ?? 'Lucknow',
                'country': company['country'] ?? 'India',
                'address': company['address'] ?? '4/37 Vibhav khand, Gomti Nagar, Lucknow',
                'phone': company['phone'] ?? '+91 9519202509',
              }
            ];
          }
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  final Map<String, dynamic> companyData = {
    'name': 'Difmo Solutions Technologies Pvt. Ltd.',
    'logo': 'https://via.placeholder.com/120',
    'cover': 'https://via.placeholder.com/400x200',
    'tagline': 'Difmo  Technology',
    'industry': 'Information Technology',
    'founded': '2025',
    'headquarters': '4/37 Vibhav khand, Gomti Nagar ,Lucknow,',
    'employees': '30+',
    'website': 'www.difmo.com',
    'email': 'info@Difmo.com',
    'phone': '+91 9519202509',
    'about':
        'Difmo  Solutions is a leading provider of Difmo technology  for enterprises worldwide. We specialize in cloud computing, AI integration, and digital transformation services. Our dedicated team of experts works tirelessly to deliver cutting-edge solutions that drive business growth.',
    'stats': [
      {'label': 'Employees', 'value': '30+'},
      {'label': 'Countries', 'value': '2+'},
      {'label': 'Projects', 'value': '10+'},
      {'label': 'Clients', 'value': '15+'},
    ],
    'services': [
      'Cloud Computing',
      'AI Integration',
      'Mobile App Development',
      'Web Development',
    ],

    'locations': [
      {
        'city': 'Lucknow',
        'country': 'India',
        'address': '4/37 Vibhav khand, Gomti Nagar, Lucknow',
        'phone': '+91 9519202509',
      },
      {
        'city': 'Kanpur',
        'country': 'India',
        'address': 'Kanpur',
        'phone': '+91 9519202509',
      },
    ],
  };

  Future<void> _showEditCompanyDialog() async {
    final nameController = TextEditingController(text: companyData['name']);
    final websiteController = TextEditingController(text: companyData['website']);
    final industryController = TextEditingController(text: companyData['industry']);
    final addressController = TextEditingController(text: companyData['headquarters']);
    final emailController = TextEditingController(text: companyData['email']);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Company Profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                TextField(controller: websiteController, decoration: const InputDecoration(labelText: 'Website')),
                TextField(controller: industryController, decoration: const InputDecoration(labelText: 'Industry')),
                TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Address')),
                TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                setState(() => _isLoading = true);
                Navigator.pop(context);
                try {
                  final prefs = await SharedPreferences.getInstance();
                  final userStr = prefs.getString('user') ?? prefs.getString('user_profile');
                  String companyId = '';
                  if (userStr != null) {
                    final user = jsonDecode(userStr);
                    companyId = user['companyId'] ?? user['company']?['_id'] ?? user['company']?['id'] ?? user['company'] ?? '';
                  }
                  if (companyId.isEmpty) {
                      final profile = await company_api.ApiService().getProfile();
                      companyId = profile['company']?['_id'] ?? profile['company']?['id'] ?? profile['companyId'] ?? '';
                  }

                  if (companyId.isNotEmpty) {
                    await company_api.ApiService().updateCompany(
                      companyId: companyId,
                      name: nameController.text,
                      website: websiteController.text,
                      industry: industryController.text,
                      address: addressController.text,
                      email: emailController.text,
                      size: 30,
                      city: 'Lucknow',
                      country: 'India',
                    );
                    await _loadProfile(); // Reload
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Company ID not found.')));
                    setState(() => _isLoading = false);
                  }
                } catch (e) {
                   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update: $e')));
                   setState(() => _isLoading = false);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    final servicesRaw = companyData['services'];
    final List<String> servicesList = servicesRaw is List
        ? List<String>.from(servicesRaw.map((e) => e.toString()))
        : <String>[];
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      drawer: const AppDrawer(activeRoute: 'Company'),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'edit') {
                _showEditCompanyDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'edit', child: Text('Edit Profile')),
              const PopupMenuItem(value: 'share', child: Text('Share')),
              const PopupMenuItem(value: 'report', child: Text('Report')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  color: Colors.blue.shade300,
                  child: Image.network(
                    companyData['cover'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.blue.shade300,
                        child: Center(
                          child: Icon(
                            Icons.image,
                            size: 60,
                            color: Colors.white30,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                Positioned(
                  bottom: -40,
                  left: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.white,
                    ),
                    child: ClipOval(
                      child: Image.network(
                        companyData['logo'],
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 120,
                            height: 120,
                            color: Colors.grey.shade200,
                            child: Icon(
                              Icons.business,
                              size: 60,
                              color: Colors.grey.shade400,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 50),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              companyData['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              companyData['tagline'],
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() => _isFollowing = !_isFollowing);
                        },
                        icon: Icon(_isFollowing ? Icons.check : Icons.add),
                        label: Text(_isFollowing ? 'Following' : 'Follow'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isFollowing
                              ? Colors.blue.shade700
                              : Colors.blue.shade100,
                          foregroundColor: _isFollowing
                              ? Colors.white
                              : Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: companyData['stats'].length,
                itemBuilder: (context, index) {
                  final stat = companyData['stats'][index];
                  return _buildStatCard(stat['value'], stat['label']);
                },
              ),
            ),
            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.business,
                      'Industry',
                      companyData['industry'],
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      Icons.calendar_today,
                      'Founded',
                      companyData['founded'],
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      Icons.location_on,
                      'Headquarters',
                      companyData['headquarters'],
                    ),
                    const Divider(height: 20),
                    _buildInfoRow(
                      Icons.people,
                      'Employees',
                      companyData['employees'],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionCard(
                title: 'Contact Information',
                child: Column(
                  children: [
                    _buildContactItem(
                      icon: Icons.email,
                      label: 'Email',
                      value: companyData['email'],
                    ),
                    const Divider(height: 20),
                    _buildContactItem(
                      icon: Icons.phone,
                      label: 'Phone',
                      value: companyData['phone'],
                    ),
                    const Divider(height: 20),
                    _buildContactItem(
                      icon: Icons.language,
                      label: 'Website',
                      value: companyData['website'],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionCard(
                title: 'About Us',
                child: Text(
                  companyData['about'],
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionCard(
                title: 'Our Services',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: servicesList.map((service) => _buildServiceChip(service)).toList(),
                ),
              ),
            ),
            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSectionCard(
                title: 'Our Locations',
                child: Column(
                  children: List.generate(companyData['locations'].length, (
                    index,
                  ) {
                    final location = companyData['locations'][index];
                    return Column(
                      children: [
                        _buildLocationCard(location),
                        if (index < companyData['locations'].length - 1)
                          const Divider(height: 20),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 28),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _launchEmail(companyData['email']),
                    icon: const Icon(Icons.mail),
                    label: const Text('Send Email'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _launchPhone(companyData['phone']),
                    icon: const Icon(Icons.phone),
                    label: const Text('Call Company'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final token = await FirebaseMessaging.instance.getToken();
                      if (token != null) {
                        await ApiService.removeFcmToken(token);
                      }
                    } catch (e) {
                      debugPrint('Error removing FCM token during logout: $e');
                    }
                    
                    final prefs = await SharedPreferences.getInstance();
                    final keys = prefs.getKeys();
                    final toRemove = keys.where((key) => 
                      ['token', 'jwt_token', 'access_token', 'user', 'user_profile', 'company_profile'].contains(key)
                    ).toList();
                    for (final key in toRemove) {
                      await prefs.remove(key);
                    }
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => const dashflow_login.LoginScreen()),
                        (route) => false,
                      );
                    }
                  },
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Log Out', style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildServiceChip(String service) {
    return Chip(
      label: Text(service),
      backgroundColor: Colors.blue.shade100,
      labelStyle: TextStyle(
        color: Colors.blue.shade700,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> location) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${location['city']}, ${location['country']}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                location['address'],
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Text(
              location['phone'],
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ],
        ),
      ],
    );
  }

  void _launchEmail(String email) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Opening email client for $email')));
  }

  void _launchPhone(String phone) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Calling $phone')));
  }
}
