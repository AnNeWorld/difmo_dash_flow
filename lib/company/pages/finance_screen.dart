import 'add_expense_screen.dart';
import 'Add_Income_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/finance_summary_model.dart';
import '../services/finance_summary_service.dart';
import '../utils/currency_formatter.dart';
import '../models/transaction_model.dart';
import '../components/shared/app_drawer.dart';
import 'all_transactions_page.dart';

class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key});

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  String _activeTab = 'Overview';

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(financeSummaryProvider);
    final chartAsync = ref.watch(monthlyCashFlowProvider);

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      drawer: const AppDrawer(activeRoute: 'Finance'),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Color(0xff0F172A)),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xff0F172A)),
        title: Row(
          children: [
            const Text(
              "Dashboard",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 16),
            const SizedBox(width: 8),
            const Text(
              "Finance",
              style: TextStyle(
                color: Color(0xff0F172A),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeader(),
            const SizedBox(height: 32),

            // ... (inside build method body)
            // Main Content Area
            LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth > 1000;

                final leftColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stat Cards
                    summaryAsync.when(
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, st) => Center(child: Text('Error: $err')),
                      data: (summary) {
                        return Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            SizedBox(
                              width: isDesktop
                                  ? (constraints.maxWidth * 0.65) / 2 - 8
                                  : constraints.maxWidth / 2 - 8,
                              child: _buildIncomeCard(summary.totalIncome),
                            ),
                            SizedBox(
                              width: isDesktop
                                  ? (constraints.maxWidth * 0.65) / 2 - 8
                                  : constraints.maxWidth / 2 - 8,
                              child: _buildExpensesCard(summary.totalExpenses),
                            ),
                            SizedBox(
                              width: isDesktop
                                  ? (constraints.maxWidth * 0.65) / 2 - 8
                                  : constraints.maxWidth / 2 - 8,
                              child: _buildPayrollCard(summary.totalPayroll),
                            ),
                            SizedBox(
                              width: isDesktop
                                  ? (constraints.maxWidth * 0.65) / 2 - 8
                                  : constraints.maxWidth / 2 - 8,
                              child: _buildProfitCard(summary.netProfit),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 32),

                    // Tabs
                    _buildTabs(summaryAsync),
                    const SizedBox(height: 24),

                    // Chart Section
                    if (_activeTab == 'Overview')
                      chartAsync.when(
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (err, st) => Center(child: Text('Error: $err')),
                        data: (chartData) => _buildChartSection(chartData),
                      ),
                  ],
                );

                final rightColumn = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildExpenseBreakdownPieChart(),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(),
                  ],
                );

                if (isDesktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 65, child: leftColumn),
                      const SizedBox(width: 32),
                      Expanded(flex: 35, child: rightColumn),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      leftColumn,
                      const SizedBox(height: 32),
                      rightColumn,
                    ],
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 600;
        final titleContent = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Finance",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Monitoring and managing your company's financial activities",
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ],
        );

        final actionButtons = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            OutlinedButton.icon(
              onPressed: () {
                ref.invalidate(financeSummaryProvider);
                ref.invalidate(monthlyCashFlowProvider);
              },
              icon: const Icon(
                Icons.refresh,
                size: 16,
                color: Color(0xFF0F172A),
              ),
              label: const Text(
                "Refresh",
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide(color: Colors.grey.shade300),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddIncomePage(),
                  ),
                );
                if (result == true) {
                  ref.invalidate(financeSummaryProvider);
                  ref.invalidate(monthlyCashFlowProvider);
                  ref.invalidate(recentTransactionsProvider);
                  ref.invalidate(allTransactionsProvider);
                }
              },
              icon: const Icon(Icons.add, size: 16, color: Colors.white),
              label: const Text(
                "Add Income",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981), // Green color for income
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddExpenseScreen(),
                  ),
                );
                if (result == true) {
                  ref.invalidate(recentTransactionsProvider);
                  ref.invalidate(allTransactionsProvider);
                  ref.invalidate(financeSummaryProvider);
                  ref.invalidate(monthlyCashFlowProvider);
                }
              },
              icon: const Icon(Icons.remove, size: 16, color: Colors.white),
              label: const Text(
                "Add Expense",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        );

        if (isDesktop) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [titleContent, actionButtons],
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleContent, const SizedBox(height: 16), actionButtons],
          );
        }
      },
    );
  }

  Widget _buildIncomeCard(double amount) {
    return _buildBaseStatCard(
      title: "TOTAL INCOME",
      amount: amount,
      subtitle: "↗ CREDITS RECEIVED",
      subtitleColor: const Color(0xFF10B981),
      icon: Icons.trending_up,
      iconColor: const Color(0xFF3B82F6),
      iconBg: const Color(0xFFEFF6FF),
    );
  }

  Widget _buildExpensesCard(double amount) {
    return _buildBaseStatCard(
      title: "TOTAL EXPENSES",
      amount: amount,
      subtitle: "↘ OPERATIONAL SPEND",
      subtitleColor: const Color(0xFFEF4444),
      icon: Icons.receipt_long_outlined,
      iconColor: const Color(0xFFEF4444),
      iconBg: const Color(0xFFFEF2F2),
    );
  }

  Widget _buildPayrollCard(double amount) {
    return _buildBaseStatCard(
      title: "TOTAL PAYROLL",
      amount: amount,
      subtitle: "25 DISBURSEMENTS",
      subtitleColor: const Color(0xFF64748B),
      icon: Icons.account_balance_wallet_outlined,
      iconColor: const Color(0xFFF59E0B),
      iconBg: const Color(0xFFFFFBEB),
    );
  }

  Widget _buildProfitCard(double amount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981), // Green background
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF10B981).withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "NET PROFIT",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.formatINR(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "↑ HEALTHY",
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseStatCard({
    required String title,
    required double amount,
    required String subtitle,
    required Color subtitleColor,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            CurrencyFormatter.formatINR(amount),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: subtitleColor,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(AsyncValue<FinanceSummaryModel> summaryAsync) {
    int badgeCount = 0;
    if (summaryAsync.hasValue && summaryAsync.value != null) {
      badgeCount =
          summaryAsync.value!.expenseCount + summaryAsync.value!.payrollCount;
    }

    return Row(
      children: [
        _buildTabButton("Overview", Icons.bar_chart),
        const SizedBox(width: 10),
        _buildTabButton(
          "Full Activity Log",
          Icons.show_chart,
          badgeCount: badgeCount,
        ),
      ],
    );
  }

  Widget _buildTabButton(String text, IconData icon, {int? badgeCount}) {
    final isActive = _activeTab == text;
    return InkWell(
      onTap: () => setState(() => _activeTab = text),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? const Color(0xFF2563EB) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                color: isActive ? Colors.white : const Color(0xFF475569),
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
            if (badgeCount != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildChartSection(List<MonthlyCashFlow> data) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.start,
            spacing: 16,
            runSpacing: 16,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Monthly Cash Flow",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Income vs Expenses vs Payroll — Last 6 months",
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
              Wrap(
                spacing: 16,
                runSpacing: 8,
                children: [
                  _buildLegendItem("INCOME", const Color(0xFF3B82F6)),
                  _buildLegendItem("EXPENSES", const Color(0xFFEF4444)),
                  _buildLegendItem("PAYROLL", const Color(0xFFF59E0B)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 300,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 85000,
                  getDrawingHorizontalLine: (value) =>
                      FlLine(color: Colors.grey.shade200, strokeWidth: 1),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= 0 && value.toInt() < data.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              data[value.toInt()].month,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 85000,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          "₹${(value / 1000).toStringAsFixed(0)}k",
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (data.length - 1).toDouble(),
                minY: 0,
                maxY: 340000, // Based on screenshot graph max 340k
                lineBarsData: [
                  // Income Line
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.income))
                        .toList(),
                    isCurved: true,
                    color: const Color(0xFF3B82F6),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF3B82F6).withOpacity(0.05),
                    ),
                  ),
                  // Expenses Line
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.expenses))
                        .toList(),
                    isCurved: true,
                    color: const Color(0xFFEF4444),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                  ),
                  // Payroll Line
                  LineChartBarData(
                    spots: data
                        .asMap()
                        .entries
                        .map((e) => FlSpot(e.key.toDouble(), e.value.payroll))
                        .toList(),
                    isCurved: true,
                    color: const Color(0xFFF59E0B),
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(width: 12, height: 2, color: color),
        const SizedBox(width: 6),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 10,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseBreakdownPieChart() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Expense Breakdown",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Spending by category",
            style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 50,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFF3B82F6), // Payroll
                    value: 65,
                    title: '',
                    radius: 30,
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFEF4444), // Operating
                    value: 20,
                    title: '',
                    radius: 30,
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFF59E0B), // Infrastructure
                    value: 10,
                    title: '',
                    radius: 30,
                  ),
                  PieChartSectionData(
                    color: const Color(0xFF10B981), // Water
                    value: 5,
                    title: '',
                    radius: 30,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildPieLegendRow("Payroll", 381219, const Color(0xFF3B82F6)),
          _buildPieLegendRow("Operating", 54401, const Color(0xFFEF4444)),
          _buildPieLegendRow("Infrastructure", 21681, const Color(0xFFF59E0B)),
          _buildPieLegendRow("Water", 880, const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildPieLegendRow(String title, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            CurrencyFormatter.formatINR(amount),
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final transactionsAsync = ref.watch(recentTransactionsProvider);

    return transactionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err')),
      data: (transactions) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Recent Transactions",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Latest 5 financial activities",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AllTransactionsPage()));
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF0F172A),
                    ),
                    child: Row(
                      children: const [
                        Text(
                          "View All",

                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        // SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "TRANSACTION",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "CATEGORY",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "DATE",
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...transactions.map((tx) => _buildTransactionItem(tx)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    Color iconColor;
    Color iconBg;
    IconData icon;

    switch (tx.category.toUpperCase()) {
      case 'OPERATING':
        iconColor = const Color(0xFFEF4444);
        iconBg = const Color(0xFFFEF2F2);
        icon = Icons.credit_card;
        break;
      case 'PAYROLL':
        iconColor = const Color(0xFFF59E0B);
        iconBg = const Color(0xFFFFFBEB);
        icon = Icons.payments;
        break;
      case 'INFRASTRUCTURE':
        iconColor = const Color(0xFF3B82F6);
        iconBg = const Color(0xFFEFF6FF);
        icon = Icons.domain;
        break;
      default:
        iconColor = const Color(0xFF10B981);
        iconBg = const Color(0xFFECFDF5);
        icon = Icons.attach_money;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    tx.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  tx.category.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    tx.date,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "₹${tx.amount}",
                    style: TextStyle(
                      color: tx.type == 'CREDIT'
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFullActivityLog() {
    final transactionsAsync = ref.watch(allTransactionsProvider);

    return transactionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, st) => Center(child: Text('Error: $err')),
      data: (transactions) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Full Activity Log",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${transactions.length} transactions found",
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AddExpenseScreen(),
                        ),
                      );
                      if (result == true) {
                        ref.invalidate(recentTransactionsProvider);
                        ref.invalidate(allTransactionsProvider);
                        ref.invalidate(financeSummaryProvider);
                        ref.invalidate(monthlyCashFlowProvider);
                      }
                    },
                    icon: const Icon(Icons.add, size: 14, color: Colors.white),
                    label: const Text(
                      "Add Entry",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Column Headers
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(
                        "TRANSACTION",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "CATEGORY",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "DATE",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        "AMOUNT",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        "TYPE",
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Transaction rows
              if (transactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 48,
                          color: Color(0xFFCBD5E1),
                        ),
                        SizedBox(height: 12),
                        Text(
                          "No transactions found",
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...transactions.map((tx) => _buildActivityLogRow(tx)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActivityLogRow(TransactionModel tx) {
    Color iconColor;
    Color iconBg;
    IconData icon;

    switch (tx.category.toUpperCase()) {
      case 'OPERATING':
        iconColor = const Color(0xFFEF4444);
        iconBg = const Color(0xFFFEF2F2);
        icon = Icons.credit_card;
        break;
      case 'PAYROLL':
        iconColor = const Color(0xFFF59E0B);
        iconBg = const Color(0xFFFFFBEB);
        icon = Icons.payments;
        break;
      case 'INFRASTRUCTURE':
        iconColor = const Color(0xFF3B82F6);
        iconBg = const Color(0xFFEFF6FF);
        icon = Icons.domain;
        break;
      default:
        iconColor = const Color(0xFF10B981);
        iconBg = const Color(0xFFECFDF5);
        icon = Icons.attach_money;
    }

    final isCredit = tx.type.toUpperCase() == 'CREDIT';

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          // Title + icon
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          fontSize: 13,
                        ),
                      ),
                      if (tx.description.isNotEmpty)
                        Text(
                          tx.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Category badge
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  tx.category,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
          // Date
          Expanded(
            flex: 2,
            child: Text(
              tx.date,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF475569),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Amount
          Expanded(
            flex: 2,
            child: Text(
              "₹${tx.amount}",
              textAlign: TextAlign.right,
              style: TextStyle(
                color: isCredit
                    ? const Color(0xFF10B981)
                    : const Color(0xFFEF4444),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Type chip
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: isCredit
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isCredit ? "IN" : "OUT",
                  style: TextStyle(
                    color: isCredit
                        ? const Color(0xFF10B981)
                        : const Color(0xFFEF4444),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
