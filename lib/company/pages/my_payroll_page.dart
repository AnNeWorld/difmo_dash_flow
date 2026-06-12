import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dashflow/company/services/api_service.dart' as company_api;
import 'package:dashflow/company/components/shared/app_drawer.dart';

class MyPayrollPage extends StatefulWidget {
  const MyPayrollPage({super.key});

  @override
  State<MyPayrollPage> createState() => _MyPayrollPageState();
}

class _MyPayrollPageState extends State<MyPayrollPage> {
  String _companyId = "";
  bool _isLoading = true;
  List<Map<String, dynamic>> _payrolls = [];
  String _searchQuery = "";
  Map<String, String> _idToName = {};
  Map<String, String> _idToRole = {};

  double _totalPayroll = 0;
  int _paidCount = 0;
  int _pendingCount = 0;
  int _employeesCount = 0;

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
        _companyId =
            user['companyId']?.toString() ??
            (user['company'] is Map
                ? (user['company']['id']?.toString() ??
                      user['company']['_id']?.toString())
                : user['company']?.toString()) ??
            '';
      }

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
          final ids = [
            u['_id']?.toString(),
            u['id']?.toString(),
          ].where((id) => id != null && id.isNotEmpty).cast<String>();
          for (final id in ids) {
            if (name.isNotEmpty) _idToName[id] = name;
            _idToRole[id] = role;
          }
        }
      } catch (_) {}

      // Also map from /employees API
      try {
        final empList = await company_api.ApiService().getAllEmployees();
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
            if (name.isNotEmpty) _idToName[id] = name;
            _idToRole[id] = role;
          }
        }
      } catch (_) {}

      try {
        final prefs = await SharedPreferences.getInstance();
        final savedEmpListStr = prefs.getString('local_mock_employees') ?? '[]';
        final List<dynamic> savedEmpList = jsonDecode(savedEmpListStr);
        for (var e in savedEmpList) {
          final fName = e['firstName']?.toString() ?? '';
          final lName = e['lastName']?.toString() ?? '';
          String name = '$fName $lName'.trim();
          if (name.isEmpty) name = e['name']?.toString() ?? '';
          String role = 'Employee';
          if (e['roles'] != null && (e['roles'] as List).isNotEmpty) {
            role = e['roles'][0]['name']?.toString() ?? 'Employee';
          } else if (e['designation'] != null) {
            role = e['designation']?.toString() ?? 'Employee';
          }
          final ids = <String>[];
          if (e['_id'] != null) ids.add(e['_id'].toString());
          if (e['id'] != null) ids.add(e['id'].toString());
          for (final id in ids) {
            if (name.isNotEmpty) _idToName[id] = name;
            _idToRole[id] = role;
          }
        }

        final userStr =
            prefs.getString('user') ?? prefs.getString('user_profile');
        if (userStr != null) {
          final cu = jsonDecode(userStr);
          final fName = cu['firstName']?.toString() ?? '';
          final lName = cu['lastName']?.toString() ?? '';
          String name = '$fName $lName'.trim();
          if (name.isEmpty) name = cu['name']?.toString() ?? '';
          if (name.isNotEmpty) {
            final cuIds = [
              cu['_id']?.toString(),
              cu['id']?.toString(),
            ].where((id) => id != null && id.isNotEmpty).cast<String>();
            for (final id in cuIds) {
              _idToName[id] = name;
            }
          }
        }
      } catch (_) {}

      await _fetchPayrolls();
    } catch (e) {
      debugPrint("Error loading user info: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPayrolls() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final data = await company_api.ApiService().getPayrolls(
        companyId: _companyId.isNotEmpty ? _companyId : null,
      );
      if (mounted) {
        setState(() {
          _payrolls = data.map((e) => e as Map<String, dynamic>).toList();
          _calculateStats();
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching payrolls: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _calculateStats() {
    _totalPayroll = 0;
    _paidCount = 0;
    _pendingCount = 0;
    final Set<String> empIds = {};

    for (var slip in _payrolls) {
      double net = _getNetSalary(slip);
      _totalPayroll += net;

      String status = (slip['status']?.toString() ?? 'PENDING').toUpperCase();
      if (status == 'PAID') {
        _paidCount++;
      } else {
        _pendingCount++;
      }

      // Track unique employees
      final empData = slip['employee'] ?? slip['userId'];
      if (empData != null) {
        String eId = empData is Map
            ? (empData['_id']?.toString() ?? empData['id']?.toString() ?? '')
            : empData.toString();
        if (eId.isNotEmpty) empIds.add(eId);
      }
    }
    _employeesCount = empIds.length;
  }

  double _getNetSalary(Map<String, dynamic> slip) {
    if (slip['netSalary'] != null) {
      return (slip['netSalary'] as num).toDouble();
    }
    double basic = ((slip['basicSalary'] ?? slip['basic'] ?? 0) as num)
        .toDouble();
    double hra = ((slip['hra'] ?? 0) as num).toDouble();
    double allowances = ((slip['allowances'] ?? 0) as num).toDouble();
    double tax = ((slip['tax'] ?? 0) as num).toDouble();
    double pf = ((slip['deductions'] ?? slip['pf'] ?? 0) as num).toDouble();
    return (basic + hra + allowances) - (tax + pf);
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return "₹${(amount / 100000).toStringAsFixed(1)}L";
    }
    return "₹${amount.toStringAsFixed(0)}";
  }

  String _resolveSlipName(Map<String, dynamic> slip) {
    final empData =
        slip['employee'] ??
        slip['employeeId'] ??
        slip['userId'] ??
        slip['user'];
    if (empData is Map) {
      final f =
          empData['firstName']?.toString() ??
          (empData['user'] is Map
              ? empData['user']['firstName']?.toString()
              : null) ??
          '';
      final l =
          empData['lastName']?.toString() ??
          (empData['user'] is Map
              ? empData['user']['lastName']?.toString()
              : null) ??
          '';
      if (f.isNotEmpty || l.isNotEmpty) return '$f $l'.trim();
      final nStr =
          empData['name']?.toString() ??
          (empData['user'] is Map
              ? empData['user']['name']?.toString()
              : null) ??
          '';
      if (nStr.isNotEmpty) return nStr;
      final eId = empData['_id']?.toString() ?? empData['id']?.toString() ?? '';
      if (eId.isNotEmpty && _idToName.containsKey(eId)) return _idToName[eId]!;
    }
    if (empData is String &&
        empData.isNotEmpty &&
        _idToName.containsKey(empData)) {
      return _idToName[empData]!;
    }
    final strId = slip['employeeId'] is String
        ? slip['employeeId'].toString()
        : '';
    if (strId.isNotEmpty && _idToName.containsKey(strId))
      return _idToName[strId]!;
    return 'Employee';
  }

  String _resolveSlipRole(Map<String, dynamic> slip) {
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
    if (empData is String &&
        empData.isNotEmpty &&
        _idToRole.containsKey(empData)) {
      return _idToRole[empData]!;
    }
    final strId = slip['employeeId'] is String
        ? slip['employeeId'].toString()
        : '';
    if (strId.isNotEmpty && _idToRole.containsKey(strId))
      return _idToRole[strId]!;
    return 'Employee';
  }

  String _resolveSlipEmpId(Map<String, dynamic> slip) {
    final empData =
        slip['employee'] ??
        slip['employeeId'] ??
        slip['userId'] ??
        slip['user'];
    if (empData is Map) {
      if (empData['customId'] != null) return empData['customId'].toString();
      if (empData['employeeId'] != null)
        return empData['employeeId'].toString();
      return empData['_id']?.toString() ?? empData['id']?.toString() ?? '';
    }
    return '';
  }

  Future<void> _paySalary(String payrollId, String empName) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    try {
      await company_api.ApiService().markPayrollPaid(payrollId);
      if (mounted) {
        Navigator.pop(context); // pop loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Salary paid to $empName"),
            backgroundColor: Colors.green,
          ),
        );
        _fetchPayrolls();
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to pay: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPayrolls = _payrolls.where((slip) {
      if (_searchQuery.isEmpty) return true;
      return _resolveSlipName(
        slip,
      ).toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),
      drawer: const AppDrawer(activeRoute: 'Pay Roll'),
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text("Payroll Management"),
        backgroundColor: const Color(0xff1D4ED8),
        foregroundColor: Colors.white,
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          "Total Payroll",
                          _formatCurrency(_totalPayroll),
                          Icons.account_balance_wallet,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statCard(
                          "Paid",
                          "$_paidCount",
                          Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statCard(
                          "Pending",
                          "$_pendingCount",
                          Icons.pending_actions,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _statCard(
                          "Employees",
                          "$_employeesCount",
                          Icons.people,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: "Search Employee",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (filteredPayrolls.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32),
                      child: Text(
                        "No payroll records found.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ...filteredPayrolls.map((slip) {
                      final payrollId =
                          slip['_id']?.toString() ??
                          slip['id']?.toString() ??
                          '';
                      final String name = _resolveSlipName(slip);
                      final String designation = _resolveSlipRole(slip);

                      final String empId = _resolveSlipEmpId(slip);

                      double basic =
                          ((slip['basicSalary'] ?? slip['basic'] ?? 0) as num)
                              .toDouble();
                      double allowances =
                          ((slip['allowances'] ?? 0) as num).toDouble() +
                          ((slip['hra'] ?? 0) as num).toDouble();
                      double deductions =
                          ((slip['deductions'] ?? slip['pf'] ?? 0) as num)
                              .toDouble() +
                          ((slip['tax'] ?? 0) as num).toDouble();
                      double net = _getNetSalary(slip);

                      String status = (slip['status']?.toString() ?? 'PENDING')
                          .toUpperCase();
                      bool paid = status == 'PAID';

                      return _employeeSalaryCard(
                        context,
                        payrollId: payrollId,
                        name: name,
                        empId: empId,
                        designation: designation,
                        basic: _formatCurrency(basic),
                        bonus: _formatCurrency(allowances),
                        deduction: _formatCurrency(deductions),
                        netSalary: _formatCurrency(net),
                        paid: paid,
                      );
                    }),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xff1D4ED8), size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _employeeSalaryCard(
    BuildContext context, {
    required String payrollId,
    required String name,
    required String empId,
    required String designation,
    required String basic,
    required String bonus,
    required String deduction,
    required String netSalary,
    required bool paid,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xff1D4ED8),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : "E",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (empId.isNotEmpty)
                      Text(
                        empId,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),

              Chip(
                backgroundColor: paid
                    ? Colors.green.shade100
                    : Colors.orange.shade100,
                padding: EdgeInsets.zero,
                labelStyle: const TextStyle(fontSize: 10),
                label: Text(
                  paid ? "PAID" : "PENDING",
                  style: TextStyle(
                    color: paid ? Colors.green[800] : Colors.orange[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 16),

          salaryRow("Basic Salary", basic),
          salaryRow("Allowances & Bonus", bonus),
          salaryRow("Deductions", deduction),

          const Divider(height: 16),

          salaryRow("Net Salary", netSalary, isBold: true),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: const BorderSide(color: Color(0xff1D4ED8)),
                      foregroundColor: const Color(0xff1D4ED8),
                    ),
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "View Payslip",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff1D4ED8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: paid
                        ? null
                        : () {
                            showDialog(
                              context: context,
                              builder: (ctx) {
                                return AlertDialog(
                                  title: const Text("Confirm Salary Payment"),
                                  content: Text("Pay $netSalary to $name?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(ctx);
                                      },
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.pop(ctx); // pop the dialog
                                        _paySalary(payrollId, name);
                                      },
                                      child: const Text("Pay Now"),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                    child: const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "Pay Salary",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget salaryRow(String title, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 15 : 13,
            ),
          ),
        ],
      ),
    );
  }
}
