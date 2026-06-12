import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dashflow/company/services/api_service.dart' as company_api;
import 'package:dashflow/core/api/api_service.dart' as core_api;

class PayslipListScreen extends StatefulWidget {
  const PayslipListScreen({super.key});

  @override
  State<PayslipListScreen> createState() => _PayslipListScreenState();
}

class _PayslipListScreenState extends State<PayslipListScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> salaryList = [];
  Map<String, String> _idToName = {};
  Map<String, String> _idToRole = {};
  String _companyId = '';
  String _currentUserName = '';
  String _currentRole = 'Employee';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    String currentId = '';
    try {
      final prefs = await SharedPreferences.getInstance();
      final userStr = prefs.getString('user');
      if (userStr != null) {
        final user = jsonDecode(userStr);
        final uf = user['firstName']?.toString() ?? '';
        final ul = user['lastName']?.toString() ?? '';
        print("FIRST NAME: $uf");
        print("LAST NAME: $ul");
        _currentUserName = '$uf $ul'.trim();
        if (_currentUserName.isEmpty) {
          _currentUserName = user['name']?.toString() ?? '';
        }
        _companyId =
            user['companyId']?.toString() ??
            (user['company'] is Map
                ? (user['company']['id']?.toString() ??
                      user['company']['_id']?.toString())
                : user['company']?.toString()) ??
            '';
        
        currentId = user['_id']?.toString() ?? user['id']?.toString() ?? '';
        if (currentId.isNotEmpty && _currentUserName.isNotEmpty) {
          _idToName[currentId] = _currentUserName;
          
          String role = 'Employee';
          if (user['roles'] != null && (user['roles'] as List).isNotEmpty) {
            role = user['roles'][0]['name']?.toString() ?? 'Employee';
          } else if (user['designation'] != null) {
            role = user['designation']?.toString() ?? 'Employee';
          }
          _idToRole[currentId] = role;
          _currentRole = role;
        }
      }

      bool isAdmin = _currentRole.toLowerCase().contains('admin') || 
                     _currentRole.toLowerCase().contains('hr') || 
                     _currentRole.toLowerCase().contains('owner');

      if (isAdmin) {
        // Build id → name map from /users API
        try {
          final usersList = await company_api.ApiService().getAllUsers();
          for (var u in usersList) {
            final fName = u['firstName']?.toString() ?? '';
            final lName = u['lastName']?.toString() ?? '';
            String name = '$fName $lName'.trim();
            if (name.isEmpty) name = u['name']?.toString() ?? '';
            String role = 'Employee';
            if (u['roles'] != null && (u['roles'] as List).isNotEmpty) {
              role = u['roles'][0]['name']?.toString() ?? 'Employee';
            } else if (u['designation'] != null) {
              role = u['designation']?.toString() ?? 'Employee';
            }
            for (final id in [u['_id']?.toString(), u['id']?.toString()]) {
              if (id != null && id.isNotEmpty && name.isNotEmpty) {
                _idToName[id] = name;
                _idToRole[id] = role;
              }
            }
          }
        } catch (_) {}

        // Also map from /employees API
        try {
          final empList = await company_api.ApiService().getAllEmployees(
            companyId: _companyId.isNotEmpty ? _companyId : null,
          );
          for (var e in empList) {
            final fName = e['firstName']?.toString() ?? '';
            final lName = e['lastName']?.toString() ?? '';
            String name = '$fName $lName'.trim();
            if (name.isEmpty) name = e['name']?.toString() ?? '';
            if (name.isEmpty) {
              final uRef = e['userId'] ?? e['user'];
              if (uRef is Map) {
                final uf = uRef['firstName']?.toString() ?? '';
                final ul = uRef['lastName']?.toString() ?? '';
                name = '$uf $ul'.trim();
                if (name.isEmpty) name = uRef['name']?.toString() ?? '';
              }
            }
            String role = 'Employee';
            if (e['roles'] != null && (e['roles'] as List).isNotEmpty) {
              role = e['roles'][0]['name']?.toString() ?? 'Employee';
            } else if (e['designation'] != null) {
              role = e['designation']?.toString() ?? 'Employee';
            }
            final ids = <String>[];
            if (e['_id'] != null) ids.add(e['_id'].toString());
            if (e['id'] != null) ids.add(e['id'].toString());
            final uRef = e['userId'] ?? e['user'];
            if (uRef is Map) {
              final uid = uRef['_id']?.toString() ?? uRef['id']?.toString();
              if (uid != null && uid.isNotEmpty) ids.add(uid);
            } else if (uRef is String && uRef.isNotEmpty) {
              ids.add(uRef);
            }
            for (final id in ids) {
              if (name.isNotEmpty) {
                _idToName[id] = name;
                _idToRole[id] = role;
              }
            }
          }
        } catch (_) {}

        try {
          final coreEmpList = await core_api.ApiService.getEmployees();
          for (var e in coreEmpList) {
            final fName = e['firstName']?.toString() ?? '';
            final lName = e['lastName']?.toString() ?? '';
            String name = '$fName $lName'.trim();
            if (name.isEmpty) name = e['name']?.toString() ?? '';
            if (name.isEmpty) {
              final uRef = e['userId'] ?? e['user'];
              if (uRef is Map) {
                final uf = uRef['firstName']?.toString() ?? '';
                final ul = uRef['lastName']?.toString() ?? '';
                name = '$uf $ul'.trim();
                if (name.isEmpty) name = uRef['name']?.toString() ?? '';
              }
            }
            String role = 'Employee';
            if (e['roles'] != null && (e['roles'] as List).isNotEmpty) {
              role = e['roles'][0]['name']?.toString() ?? 'Employee';
            } else if (e['designation'] != null) {
              role = e['designation']?.toString() ?? 'Employee';
            }
            final ids = <String>[];
            if (e['_id'] != null) ids.add(e['_id'].toString());
            if (e['id'] != null) ids.add(e['id'].toString());
            final uRef = e['userId'] ?? e['user'];
            if (uRef is Map) {
              final uid = uRef['_id']?.toString() ?? uRef['id']?.toString();
              if (uid != null && uid.isNotEmpty) ids.add(uid);
            } else if (uRef is String && uRef.isNotEmpty) {
              ids.add(uRef);
            }
            for (final id in ids) {
              if (name.isNotEmpty) {
                _idToName[id] = name;
                _idToRole[id] = role;
              }
            }
          }
        } catch (_) {}
      }


      // Fetch payrolls from API
      final data = await company_api.ApiService().getPayrolls(
        companyId: _companyId.isNotEmpty ? _companyId : null,
      );

      if (mounted) {
        setState(() {
          List<Map<String, dynamic>> loadedData = data.map((e) => e as Map<String, dynamic>).toList();
          
          if (!isAdmin) {
            loadedData = loadedData.where((slip) {
              final emp = slip['employee'];
              if (emp is Map) {
                final uId = emp['userId']?.toString() ?? 
                            emp['user']?['id']?.toString() ?? 
                            emp['user']?['_id']?.toString();
                if (uId == currentId) return true;
              }
              final slipEmpId = slip['employeeId']?.toString() ?? slip['userId']?.toString();
              return slipEmpId == currentId;
            }).toList();
          }
          
          salaryList = loadedData;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading payslip data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  /// Extract employee name from a payroll slip using the id map
  String _getSlipName(Map<String, dynamic> slip) {
    // 1. Try to get from nested employee/user object
    final empData =
        slip['employee'] ??
        slip['employeeId'] ??
        slip['userId'] ??
        slip['user'];
    if (empData is Map) {
      // Check if firstName/lastName are nested inside a 'user' object
      final userData = empData['user'];
      if (userData is Map) {
        final f = userData['firstName']?.toString() ?? '';
        final l = userData['lastName']?.toString() ?? '';
        if (f.isNotEmpty || l.isNotEmpty) return '$f $l'.trim();

        final nameStr = userData['name']?.toString() ?? '';
        if (nameStr.isNotEmpty) return nameStr;
      }

      // Check directly on empData
      final f = empData['firstName']?.toString() ?? '';
      final l = empData['lastName']?.toString() ?? '';
      if (f.isNotEmpty || l.isNotEmpty) return '$f $l'.trim();

      final nameStr = empData['name']?.toString() ?? '';
      if (nameStr.isNotEmpty) return nameStr;

      // fallback from id map using nested _id
      final eId = empData['_id']?.toString() ?? empData['id']?.toString() ?? '';
      if (eId.isNotEmpty && _idToName.containsKey(eId)) return _idToName[eId]!;
    }

    // 2. Try to look up by string ID
    final idRef = empData is String ? empData : null;
    if (idRef != null && idRef.isNotEmpty && _idToName.containsKey(idRef)) {
      return _idToName[idRef]!;
    }

    // 3. Try slip-level employeeId string
    final slipEmpId = slip['employeeId'] is String
        ? slip['employeeId'].toString()
        : null;
    if (slipEmpId != null &&
        slipEmpId.isNotEmpty &&
        _idToName.containsKey(slipEmpId)) {
      return _idToName[slipEmpId]!;
    }

    return _currentUserName.isNotEmpty ? _currentUserName : 'Employee';
  }

  String _getSlipRole(Map<String, dynamic> slip) {
    final empData =
        slip['employee'] ??
        slip['employeeId'] ??
        slip['userId'] ??
        slip['user'];
    if (empData is Map) {
      if (empData['roles'] != null && (empData['roles'] as List).isNotEmpty) {
        return empData['roles'][0]['name']?.toString() ?? 'Employee';
      }
      if (empData['designation'] != null)
        return empData['designation'].toString();
      final eId = empData['_id']?.toString() ?? empData['id']?.toString() ?? '';
      if (eId.isNotEmpty && _idToRole.containsKey(eId)) return _idToRole[eId]!;
    }
    final idRef = empData is String ? empData : null;
    if (idRef != null && _idToRole.containsKey(idRef)) return _idToRole[idRef]!;
    final slipEmpId = slip['employeeId'] is String
        ? slip['employeeId'].toString()
        : null;
    if (slipEmpId != null && _idToRole.containsKey(slipEmpId)) {
      return _idToRole[slipEmpId]!;
    }
    return _currentRole;
  }

  String _getSlipEmpId(Map<String, dynamic> slip) {
    final empData =
        slip['employee'] ??
        slip['employeeId'] ??
        slip['userId'] ??
        slip['user'];
    if (empData is Map) {
      return empData['_id']?.toString() ?? empData['id']?.toString() ?? '';
    }
    if (empData is String) return empData;
    if (slip['employeeId'] is String) return slip['employeeId'].toString();
    return '';
  }

  double _calculateNetSalary(Map<String, dynamic> item) {
    if (item['netSalary'] != null) return (item['netSalary'] as num).toDouble();
    double basic = ((item['basicSalary'] ?? item['basic'] ?? 0) as num)
        .toDouble();
    double hra = ((item['hra'] ?? 0) as num).toDouble();
    double allowances = ((item['allowances'] ?? 0) as num).toDouble();
    double tax = ((item['tax'] ?? 0) as num).toDouble();
    double pf = ((item['deductions'] ?? item['pf'] ?? 0) as num).toDouble();
    return (basic + hra + allowances) - (tax + pf);
  }

  String _getMonthName(dynamic monthVal) {
    if (monthVal == null) return "Unknown";
    final intMonth = int.tryParse(monthVal.toString());
    if (intMonth != null && intMonth >= 1 && intMonth <= 12) {
      const months = [
        "Jan",
        "Feb",
        "Mar",
        "Apr",
        "May",
        "Jun",
        "Jul",
        "Aug",
        "Sep",
        "Oct",
        "Nov",
        "Dec",
      ];
      return months[intMonth - 1];
    }
    return monthVal.toString();
  }

  String _getYear(dynamic yearVal) => yearVal?.toString() ?? '';

  String _getDisplayMonth(Map<String, dynamic> slip) {
    if (slip['month'] is String) return slip['month'];
    return "${_getMonthName(slip['month'])} ${_getYear(slip['year'])}".trim();
  }

  void _showPayslipDetails(BuildContext context, Map<String, dynamic> slip) {
    final slipUserName = _getSlipName(slip);
    final slipRole = _getSlipRole(slip);
    final slipEmpId = _getSlipEmpId(slip);
    final displayMonth = _getDisplayMonth(slip);

    double basic = ((slip['basicSalary'] ?? slip['basic'] ?? 0) as num)
        .toDouble();
    double hra = ((slip['hra'] ?? 0) as num).toDouble();
    double allowances = ((slip['allowances'] ?? 0) as num).toDouble();
    double tax = ((slip['tax'] ?? 0) as num).toDouble();
    double pf = ((slip['deductions'] ?? slip['pf'] ?? 0) as num).toDouble();
    double earnings = basic + hra + allowances;
    double deductions = tax + pf;
    double net =
        (slip['netSalary'] as num?)?.toDouble() ?? (earnings - deductions);

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
                          displayMonth,
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
                      child: _buildMetaBlock("EMPLOYEE", slipUserName),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 5,
                      child: _buildMetaBlock(
                        "ID",
                        slipEmpId.isNotEmpty ? slipEmpId.toUpperCase() : "N/A",
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildMetaBlock("DESIGNATION", slipRole.toUpperCase()),

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
                _buildSlipRow("Basic Salary", "₹$basic"),
                _buildSlipRow("House Rent Allowance (HRA)", "₹$hra"),
                _buildSlipRow("Special Allowances", "₹$allowances"),
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
                _buildSlipRow("Professional Tax", "₹$tax"),
                _buildSlipRow("Provident Fund (PF)", "₹$pf"),
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
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2C5282),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(
                      Icons.download_rounded,
                      color: Colors.white,
                    ),
                    label: const Text(
                      "Download Payslip",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
                const SizedBox(height: 16),
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
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1E293B),
            fontSize: 13,
            fontWeight: FontWeight.w600,
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
          : salaryList.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64,
                    color: Color(0xFFCBD5E1),
                  ),
                  SizedBox(height: 16),
                  Text(
                    "No salary slips found",
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: salaryList.length,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemBuilder: (context, index) {
                final item = salaryList[index];
                final net = _calculateNetSalary(item);
                final itemName = _getSlipName(item);
                final monthStr = _getDisplayMonth(item);

                final empIdRaw = _getSlipEmpId(item);
                String displayId = 'N/A';
                if (empIdRaw.isNotEmpty) {
                  displayId = empIdRaw.length > 8
                      ? '#${empIdRaw.substring(0, 8).toUpperCase()}'
                      : '#${empIdRaw.toUpperCase()}';
                }

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
                              backgroundColor: const Color(0xFF2C5282),
                              child: Text(
                                itemName.isNotEmpty && itemName != 'Employee'
                                    ? itemName[0].toUpperCase()
                                    : 'E',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        flex: 1,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE8F0FE),
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                          ),
                                          child: Text(
                                            displayId,
                                            style: const TextStyle(
                                              color: Color(0xFF1A73E8),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        flex: 2,
                                        child: Text(
                                          itemName,
                                          style: const TextStyle(
                                            color: Color(0xFF1E293B),
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    monthStr,
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Net Paid: ₹$net",
                                    style: const TextStyle(
                                      color: Color(0xFF2C5282),
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
