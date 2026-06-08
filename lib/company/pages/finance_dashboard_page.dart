import 'package:dashflow/company/pages/Add_Expense_Page.dart';
import 'package:dashflow/company/pages/Add_Income_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/finance_service.dart';

class FinanceDashboardPage extends ConsumerWidget {
  const FinanceDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeAsync = ref.watch(financeProvider);

    // Premium Color Palette
    const backgroundColor = Color(0xFFF8FAFC);
    const primaryBlue = Color(0xFF2563EB);
    const textDark = Color(0xFF0F172A);
    const textLight = Color(0xFF64748B);
    const successGreen = Color(0xFF10B981);
    const dangerRed = Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: backgroundColor,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: primaryBlue,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), label: "People"),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: "Work"),
          BottomNavigationBarItem(icon: Icon(Icons.account_balance_wallet), label: "Finance"),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: "Settings"),
        ],
      ),
      body: SafeArea(
        child: financeAsync.when(
          data: (financeData) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.grid_view_rounded, color: textDark, size: 24),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const CircleAvatar(
                          radius: 22,
                          backgroundImage: AssetImage("assets/images/ranjeet.jpg"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  /// TITLE
                  Text(
                    "Fiscal Year 2024",
                    style: GoogleFonts.inter(
                      color: primaryBlue,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Financial Suite",
                    style: GoogleFonts.inter(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  /// TURNOVER CARD
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Total Turnover",
                              style: GoogleFonts.inter(
                                color: textLight,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: successGreen.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.trending_up_rounded, color: successGreen, size: 16),
                                  const SizedBox(width: 4),
                                  Text(
                                    financeData.turnoverPercent,
                                    style: GoogleFonts.inter(
                                      color: successGreen,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              financeData.turnoverAmount,
                              style: GoogleFonts.inter(
                                fontSize: 40,
                                fontWeight: FontWeight.w800,
                                color: textDark,
                                letterSpacing: -1,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "USD",
                              style: GoogleFonts.inter(
                                color: textLight,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        /// SPLINE GRAPH
                        SizedBox(
                          height: 120,
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(show: false),
                              titlesData: FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: financeData.turnoverGraph.asMap().entries.map((e) {
                                    return FlSpot(e.key.toDouble(), e.value);
                                  }).toList(),
                                  isCurved: true,
                                  color: primaryBlue,
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(show: false),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryBlue.withOpacity(0.3),
                                        primaryBlue.withOpacity(0.0),
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// PROFIT + EXPENSE
                  Row(
                    children: [
                      Expanded(
                        child: _smallFinanceCard(
                          title: "Net Profit",
                          amount: financeData.netProfitAmount,
                          percent: financeData.netProfitPercent,
                          isPositive: true,
                          accentColor: successGreen,
                          textDark: textDark,
                          textLight: textLight,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _smallFinanceCard(
                          title: "Expenses",
                          amount: financeData.expensesAmount,
                          percent: financeData.expensesPercent,
                          isPositive: false,
                          accentColor: dangerRed,
                          textDark: textDark,
                          textLight: textLight,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// BUDGET DISTRIBUTION
                  Text(
                    "Budget Distribution",
                    style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: textDark),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 220,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PieChart(
                                PieChartData(
                                  sectionsSpace: 4,
                                  centerSpaceRadius: 75,
                                  sections: [
                                    PieChartSectionData(
                                      color: primaryBlue,
                                      value: financeData.payrollPercent * 100,
                                      title: '',
                                      radius: 24,
                                    ),
                                    PieChartSectionData(
                                      color: successGreen,
                                      value: financeData.marketingPercent * 100,
                                      title: '',
                                      radius: 24,
                                    ),
                                    PieChartSectionData(
                                      color: const Color(0xFFF59E0B),
                                      value: financeData.operationsPercent * 100,
                                      title: '',
                                      radius: 24,
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("Total", style: GoogleFonts.inter(color: textLight, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text(
                                    financeData.totalBudget,
                                    style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: textDark),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        _legendTile(color: primaryBlue, title: "Payroll", value: "${(financeData.payrollPercent * 100).toInt()}%", textDark: textDark),
                        const SizedBox(height: 16),
                        _legendTile(color: successGreen, title: "Marketing", value: "${(financeData.marketingPercent * 100).toInt()}%", textDark: textDark),
                        const SizedBox(height: 16),
                        _legendTile(color: const Color(0xFFF59E0B), title: "Operations", value: "${(financeData.operationsPercent * 100).toInt()}%", textDark: textDark),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// TRANSACTIONS HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Recent Transactions",
                        style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: textDark),
                      ),
                      Text(
                        "View All",
                        style: GoogleFonts.inter(color: primaryBlue, fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  /// TRANSACTIONS LIST
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: financeData.recentTransactions.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var tx = entry.value;

                        return Column(
                          children: [
                            _transactionTile(
                              icon: tx.isExpense ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                              title: tx.title,
                              time: tx.time,
                              amount: tx.amount,
                              isExpense: tx.isExpense,
                              iconColor: tx.isExpense ? textDark : successGreen,
                              textDark: textDark,
                              textLight: textLight,
                            ),
                            if (idx != financeData.recentTransactions.length - 1)
                              Divider(height: 1, color: Colors.grey.withOpacity(0.1), indent: 24, endIndent: 24),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 32),

                  /// ACTION BUTTONS
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddIncomePage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: textDark,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text("Add Income", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpensePage()));
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: textDark,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            elevation: 0,
                            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: Text("Add Expense", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
          error: (err, stack) => Center(child: Text("Error: $err", style: GoogleFonts.inter(color: Colors.red))),
        ),
      ),
    );
  }

  Widget _smallFinanceCard({
    required String title,
    required String amount,
    required String percent,
    required bool isPositive,
    required Color accentColor,
    required Color textDark,
    required Color textLight,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPositive ? Icons.account_balance_wallet_rounded : Icons.receipt_long_rounded,
                  color: accentColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(color: textLight, fontSize: 14, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(amount, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: textDark)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded, color: accentColor, size: 14),
              const SizedBox(width: 4),
              Text(percent, style: GoogleFonts.inter(color: accentColor, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendTile({required Color color, required String title, required String value, required Color textDark}) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
        ),
        const SizedBox(width: 16),
        Expanded(child: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, color: textDark))),
        Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: textDark)),
      ],
    );
  }

  Widget _transactionTile({
    required IconData icon,
    required String title,
    required String time,
    required String amount,
    required bool isExpense,
    required Color iconColor,
    required Color textDark,
    required Color textLight,
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: textDark)),
                const SizedBox(height: 4),
                Text(time, style: GoogleFonts.inter(color: textLight, fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Text(
            amount,
            style: GoogleFonts.inter(
              color: isExpense ? textDark : const Color(0xFF10B981),
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
