class FinanceSummaryModel {
  final double totalIncome;
  final double totalExpenses;
  final double totalPayroll;
  final double netProfit;
  final int expenseCount;
  final int payrollCount;

  FinanceSummaryModel({
    required this.totalIncome,
    required this.totalExpenses,
    required this.totalPayroll,
    required this.netProfit,
    this.expenseCount = 0,
    this.payrollCount = 0,
  });

  factory FinanceSummaryModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return FinanceSummaryModel(
      totalIncome: parseDouble(
        json['turnover'] ?? json['totalCredit'] ?? json['totalIncome'],
      ),
      totalExpenses: parseDouble(
        json['totalExpenses'] ?? json['totalDebit'] ?? json['expenses'],
      ),
      totalPayroll: parseDouble(
        json['totalPayroll'] ?? json['payroll'],
      ),
      netProfit: parseDouble(
        json['netBalance'] ?? json['netProfit'] ?? json['profit'],
      ),
      expenseCount: json['expenseCount'] ?? 0,
      payrollCount: json['payrollCount'] ?? 0,
    );
  }

  // Mock Data for development
  factory FinanceSummaryModel.mock() {
    return FinanceSummaryModel(
      totalIncome: 275000,
      totalExpenses: 76962,
      totalPayroll: 30385,
      netProfit: 167653,
      expenseCount: 23,
      payrollCount: 25,
    );
  }
}

class MonthlyCashFlow {
  final String month;
  final double income;
  final double expenses;
  final double payroll;

  MonthlyCashFlow({
    required this.month,
    required this.income,
    required this.expenses,
    required this.payroll,
  });

  factory MonthlyCashFlow.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return MonthlyCashFlow(
      month: json['month']?.toString() ?? '',
      income: parseDouble(json['income']),
      expenses: parseDouble(json['expenses']),
      payroll: parseDouble(json['payroll']),
    );
  }
}
