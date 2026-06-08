import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/employee_model.dart';
import '../../services/employee_service.dart';

class EditEmployeeScreen extends ConsumerStatefulWidget {
  final EmployeeModel employee;

  const EditEmployeeScreen({super.key, required this.employee});

  @override
  ConsumerState<EditEmployeeScreen> createState() => _EditEmployeeScreenState();
}

class _EditEmployeeScreenState extends ConsumerState<EditEmployeeScreen> {
  int _activeTab = 0; // 0: Basic Info, 1: Roles, 2: Permissions, 3: Contact, 4: Documents

  late TextEditingController _firstNameCtrl;
  late TextEditingController _lastNameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _skillsCtrl;

  bool _isSaving = false;
  File? _profileImage;

  @override
  void initState() {
    super.initState();
    _firstNameCtrl = TextEditingController(text: widget.employee.firstName);
    _lastNameCtrl = TextEditingController(text: widget.employee.lastName);
    _emailCtrl = TextEditingController(text: widget.employee.email);
    _phoneCtrl = TextEditingController(text: widget.employee.phone);
    _skillsCtrl = TextEditingController(text: '');
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _skillsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _handleSave() async {
    setState(() => _isSaving = true);
    try {
      final updatedEmp = widget.employee.copyWith(
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );

      final success = await ref.read(employeeProvider.notifier).updateEmployee(updatedEmp);
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Employee updated successfully')));
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to update employee')));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Edit Employee", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text("ID: ${widget.employee.id}", style: const TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
        backgroundColor: const Color(0xFF1D4ED8),
        foregroundColor: Colors.white,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            )
          else
            TextButton.icon(
              onPressed: _handleSave,
              icon: const Icon(Icons.save, color: Colors.white, size: 20),
              label: const Text("Save", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Color(0xFF1D4ED8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white24,
                    radius: 28,
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null 
                      ? Text(
                          widget.employee.firstName.isNotEmpty ? widget.employee.firstName[0].toUpperCase() : 'E',
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                        )
                      : null,
                  ),
                  const SizedBox(height: 12),
                  const Text("INFORMATION SECTIONS", style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            _buildDrawerItem(0, "Basic Info", Icons.person_outline),
            _buildDrawerItem(1, "Roles & Employment", Icons.work_outline),
            _buildDrawerItem(2, "Permissions", Icons.security_outlined),
            _buildDrawerItem(3, "Contact", Icons.phone_outlined),
            _buildDrawerItem(4, "Documents", Icons.description_outlined),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          padding: const EdgeInsets.all(24),
          child: _activeTab == 0 ? _buildBasicInfoTab() : const Center(child: Text('Not implemented yet. Please use Basic Info.')),
        ),
      ),
    );
  }

  Widget _buildDrawerItem(int index, String title, IconData icon) {
    final isActive = _activeTab == index;
    return ListTile(
      leading: Icon(icon, color: isActive ? const Color(0xFF1D4ED8) : Colors.grey.shade600),
      title: Text(
        title,
        style: TextStyle(
          color: isActive ? const Color(0xFF1D4ED8) : Colors.grey.shade700,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isActive,
      selectedTileColor: Colors.blue.shade50,
      onTap: () {
        setState(() => _activeTab = index);
        Navigator.pop(context); // Close the drawer
      },
    );
  }

  Widget _buildBasicInfoTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Picture Section
        Row(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: const Color(0xFF6EE7B7),
                    backgroundImage: _profileImage != null ? FileImage(_profileImage!) : null,
                    child: _profileImage == null
                        ? Text(
                            widget.employee.firstName.isNotEmpty ? widget.employee.firstName[0].toUpperCase() : 'E',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF064E3B)),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(color: Colors.blue.shade600, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 12),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Profile Picture", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1E293B))),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: _pickImage,
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Upload Photo", style: TextStyle(color: Color(0xFF1E293B))),
                  ),
                  const SizedBox(height: 8),
                  const Text("JPG, PNG or GIF. Max size of 2MB.", style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: 32),
        // Form Fields
        LayoutBuilder(builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile layout
            return Column(
              children: [
                _buildTextField("First Name", _firstNameCtrl),
                const SizedBox(height: 16),
                _buildTextField("Last Name", _lastNameCtrl),
                const SizedBox(height: 16),
                _buildTextField("Email Address", _emailCtrl),
                const SizedBox(height: 16),
                _buildTextField("Phone Number", _phoneCtrl),
              ],
            );
          }
          // Desktop/Tablet layout
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildTextField("First Name", _firstNameCtrl)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildTextField("Last Name", _lastNameCtrl)),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: _buildTextField("Email Address", _emailCtrl)),
                  const SizedBox(width: 24),
                  Expanded(child: _buildTextField("Phone Number", _phoneCtrl)),
                ],
              ),
            ],
          );
        }),
        const SizedBox(height: 24),
        const Text("Skills & Competencies", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: _skillsCtrl,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: "Enter skills separated by commas...",
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}
