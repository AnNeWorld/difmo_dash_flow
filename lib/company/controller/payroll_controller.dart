import 'package:get/get.dart';

class PayrollController extends GetxController {
  var payrollList = <Payroll>[].obs;
  var salarySlips = <SalarySlip>[].obs;
  var isLoading = false.obs;
  var selectedMonth = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    fetchPayroll();
  }

  void fetchPayroll() {
    isLoading(true);
    try {
      payrollList.addAll([
        Payroll(
          id: 'P001',
          employeeId: 'EMP001',
          employeeName: 'राज कुमार',
          month: DateTime.now(),
          baseSalary: 50000,
          hra: 10000,
          da: 5000,
          allowances: 3000,
          deductions: 2000,
          taxes: 4000,
          totalSalary: 61000,
          paymentDate: DateTime.now(),
          status: 'Processed',
        ),
        Payroll(
          id: 'P002',
          employeeId: 'EMP002',
          employeeName: 'प्रिया शर्मा',
          month: DateTime.now(),
          baseSalary: 45000,
          hra: 9000,
          da: 4500,
          allowances: 2500,
          deductions: 1800,
          taxes: 3600,
          totalSalary: 55200,
          paymentDate: DateTime.now(),
          status: 'Processed',
        ),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch payroll: $e');
    } finally {
      isLoading(false);
    }
  }

  void generateSalarySlip(String employeeId) {
    try {
      final payroll = payrollList.firstWhere(
        (p) => p.employeeId == employeeId,
        orElse: () => payrollList.first,
      );

      final slip = SalarySlip(
        id: 'SS${DateTime.now().millisecondsSinceEpoch}',
        payrollId: payroll.id,
        employeeId: employeeId,
        employeeName: payroll.employeeName,
        month: payroll.month,
        baseSalary: payroll.baseSalary,
        earnings: payroll.hra + payroll.da + payroll.allowances,
        deductions: payroll.deductions + payroll.taxes,
        netSalary: payroll.totalSalary,
        generatedDate: DateTime.now(),
      );

      salarySlips.add(slip);
      Get.snackbar('Success', 'Salary slip generated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate salary slip: $e');
    }
  }

  void processPayroll() {
    try {
      for (var payroll in payrollList) {
        payroll.status = 'Processed';
      }
      payrollList.refresh();
      Get.snackbar('Success', 'Payroll processed successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to process payroll: $e');
    }
  }

  void updatePayroll(String payrollId, Payroll updatedPayroll) {
    try {
      final index = payrollList.indexWhere((p) => p.id == payrollId);
      if (index != -1) {
        payrollList[index] = updatedPayroll;
        payrollList.refresh();
        Get.snackbar('Success', 'Payroll updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update payroll: $e');
    }
  }

  double calculateNetSalary(
    double baseSalary,
    double deductions,
    double taxes,
  ) {
    return baseSalary - deductions - taxes;
  }

  double calculateCtc(
    double baseSalary,
    double hra,
    double da,
    double allowances,
  ) {
    return baseSalary + hra + da + allowances;
  }

  void filterByMonth(DateTime month) {
    selectedMonth(month);
  }

  List<Payroll> getMonthlyPayroll() {
    return payrollList
        .where(
          (p) =>
              p.month.month == selectedMonth.value.month &&
              p.month.year == selectedMonth.value.year,
        )
        .toList();
  }

  double getTotalPayrollAmount() {
    return payrollList.fold(0, (sum, payroll) => sum + payroll.totalSalary);
  }

  void generatePayslips() {
    try {
      salarySlips.clear();
      for (var payroll in payrollList) {
        final slip = SalarySlip(
          id: 'SS${payroll.id}',
          payrollId: payroll.id,
          employeeId: payroll.employeeId,
          employeeName: payroll.employeeName,
          month: payroll.month,
          baseSalary: payroll.baseSalary,
          earnings: payroll.hra + payroll.da + payroll.allowances,
          deductions: payroll.deductions + payroll.taxes,
          netSalary: payroll.totalSalary,
          generatedDate: DateTime.now(),
        );
        salarySlips.add(slip);
      }
      Get.snackbar('Success', 'All salary slips generated');
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate salary slips: $e');
    }
  }
}

class Payroll {
  String id;
  String employeeId;
  String employeeName;
  DateTime month;
  double baseSalary;
  double hra;
  double da;
  double allowances;
  double deductions;
  double taxes;
  double totalSalary;
  DateTime paymentDate;
  String status;

  Payroll({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.month,
    required this.baseSalary,
    required this.hra,
    required this.da,
    required this.allowances,
    required this.deductions,
    required this.taxes,
    required this.totalSalary,
    required this.paymentDate,
    required this.status,
  });
}

class SalarySlip {
  String id;
  String payrollId;
  String employeeId;
  String employeeName;
  DateTime month;
  double baseSalary;
  double earnings;
  double deductions;
  double netSalary;
  DateTime generatedDate;

  SalarySlip({
    required this.id,
    required this.payrollId,
    required this.employeeId,
    required this.employeeName,
    required this.month,
    required this.baseSalary,
    required this.earnings,
    required this.deductions,
    required this.netSalary,
    required this.generatedDate,
  });
}
