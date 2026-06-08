import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PayslipListScreen extends StatefulWidget {
  const PayslipListScreen({super.key});

  @override
  State<PayslipListScreen> createState() => _PayslipListScreenState();
}

class _PayslipListScreenState extends State<PayslipListScreen> {
  String userName = "Employee";
  String userRole = "Software Engineer";
  String employeeId = "EMP001";
  bool isLoading = true;

  final List<Map<String, dynamic>> salaryList = [
    {
      "month": "April 2026",
      "basic": 25000,
      "hra": 5000,
      "allowances": 2000,
      "tax": 1200,
      "pf": 1800,
    },
    {
      "month": "March 2026",
      "basic": 25000,
      "hra": 5000,
      "allowances": 1800,
      "tax": 1200,
      "pf": 1800,
    },
    {
      "month": "February 2026",
      "basic": 25000,
      "hra": 5000,
      "allowances": 2200,
      "tax": 1200,
      "pf": 1800,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        setState(() {
          userName = "${user['firstName'] ?? ''} ${user['lastName'] ?? ''}"
              .trim();
          if (userName.isEmpty) userName = "Employee";
          employeeId = user['id']?.toString() ?? "EMP001";
          if (user['roles'] != null && user['roles'].isNotEmpty) {
            userRole = user['roles'][0]['name'] ?? "Employee";
          }
        });
      }
    } catch (e) {
      debugPrint("Error loading user info: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  double _calculateNetSalary(Map<String, dynamic> item) {
    double earnings =
        ((item['basic'] as num) +
                (item['hra'] as num) +
                (item['allowances'] as num))
            .toDouble();
    double deductions = ((item['tax'] as num) + (item['pf'] as num)).toDouble();
    return earnings - deductions;
  }

  void _showPayslipDetails(BuildContext context, Map<String, dynamic> slip) {
    double earnings =
        ((slip['basic'] as num) +
                (slip['hra'] as num) +
                (slip['allowances'] as num))
            .toDouble();
    double deductions = ((slip['tax'] as num) + (slip['pf'] as num)).toDouble();
    double net = earnings - deductions;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Invoice Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "SALARY SLIP",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2C5282),
                          ),
                        ),
                        Text(
                          slip['month'],
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const Icon(
                      Icons.receipt_long_rounded,
                      color: Color(0xFF2C5282),
                      size: 36,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),

                // Employee Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: _buildMetaBlock("EMPLOYEE", userName),
                    ),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: _buildMetaBlock("ID", employeeId)),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMetaBlock("DESIGNATION", userRole.toUpperCase()),

                const SizedBox(height: 24),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),

                // Earnings Section
                const Text(
                  "EARNINGS",
                  style: TextStyle(
                    color: Color(0xFF2C5282),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSlipRow("Basic Salary", "₹${slip['basic']}"),
                _buildSlipRow("House Rent Allowance (HRA)", "₹${slip['hra']}"),
                _buildSlipRow("Special Allowances", "₹${slip['allowances']}"),
                const SizedBox(height: 8),
                _buildSlipRow("Total Earnings", "₹$earnings", isBold: true),

                const SizedBox(height: 24),
                const Divider(color: Color(0xFFE2E8F0)),
                const SizedBox(height: 16),

                // Deductions Section
                const Text(
                  "DEDUCTIONS",
                  style: TextStyle(
                    color: Color(0xFFC5221F),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSlipRow("Professional Tax", "₹${slip['tax']}"),
                _buildSlipRow("Provident Fund (PF)", "₹${slip['pf']}"),
                const SizedBox(height: 8),
                _buildSlipRow(
                  "Total Deductions",
                  "₹$deductions",
                  isBold: true,
                  isRed: true,
                ),

                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFD0E1F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "NET SALARY PAID",
                        style: TextStyle(
                          color: Color(0xFF1E293B),
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        "₹$net",
                        style: const TextStyle(
                          color: Color(0xFF2C5282),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C5282),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Done",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetaBlock(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildSlipRow(
    String title,
    String val, {
    bool isBold = false,
    bool isRed = false,
  }) {
    final style = TextStyle(
      color: isRed ? const Color(0xFFC5221F) : const Color(0xFF1E293B),
      fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
      fontSize: isBold ? 14 : 13,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: style),
          Text(val, style: style),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      appBar: AppBar(
        title: const Text(
          "Salary Slips",
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2C5282)),
            )
          : ListView.builder(
              itemCount: salaryList.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final item = salaryList[index];
                final net = _calculateNetSalary(item);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(18),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => _showPayslipDetails(context, item),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: const Color(0xFFE6F4EA),
                              child: const Icon(
                                Icons.currency_rupee,
                                color: Color(0xFF137333),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['month'],
                                    style: const TextStyle(
                                      color: Color(0xFF1E293B),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Net Paid: ₹$net",
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: Color(0xFFCBD5E1),
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
