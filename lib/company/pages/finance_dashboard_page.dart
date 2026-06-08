import 'package:dashflow/company/pages/Add_Expense_Page.dart';
import 'package:dashflow/company/pages/Add_Income_Page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/finance_service.dart';

class FinanceDashboardPage extends ConsumerWidget {
  const FinanceDashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final financeAsync = ref.watch(financeProvider);

    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: const Color(0xff1450D2),
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            label: "People",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: "Work",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet),
            label: "Finance",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            label: "Settings",
          ),
        ],
      ),
      body: SafeArea(
        child: financeAsync.when(
          data: (financeData) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.menu,
                              color: Color(0xff1450D2),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "DIFMO Finance",
                                style: TextStyle(
                                  color: Color(0xff1450D2),
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage("assets/images/ranjeet.jpg"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// TITLE
                  const Text(
                    "Fiscal Year 2024",
                    style: TextStyle(color: Colors.black54, fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  const FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Financial Suite",
                      style: TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// TURNOVER CARD
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: const Border(left: BorderSide(color: Color(0xff1450D2), width: 5)),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                "Turnover",
                                style: TextStyle(color: Colors.black87, fontSize: 20),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.trending_up, color: Colors.green.shade700),
                                const SizedBox(width: 4),
                                Text(
                                  financeData.turnoverPercent,
                                  style: TextStyle(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  financeData.turnoverAmount,
                                  style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Padding(
                              padding: EdgeInsets.only(bottom: 6),
                              child: Text(
                                "USD",
                                style: TextStyle(color: Colors.black54, fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
                        /// GRAPH
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(financeData.turnoverGraph.length, (index) {
                            return _graphBar(
                              financeData.turnoverGraph[index],
                              active: index == financeData.turnoverGraph.length - 1, // last is active
                            );
                          }),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// PROFIT + EXPENSE
                  Row(
                    children: [
                      Expanded(
                        child: _smallFinanceCard(
                          title: "Net Profit",
                          amount: financeData.netProfitAmount,
                          percent: financeData.netProfitPercent,
                          isPositive: true,
                          borderColor: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 18),
                      Expanded(
                        child: _smallFinanceCard(
                          title: "Expenses",
                          amount: financeData.expensesAmount,
                          percent: financeData.expensesPercent,
                          isPositive: false,
                          borderColor: Colors.red,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  /// BUDGET DISTRIBUTION
                  const Text(
                    "Budget Distribution",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      children: [
                        /// DONUT CHART
                        SizedBox(
                          height: 300,
                          width: 300,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                height: 250,
                                width: 250,
                                child: CircularProgressIndicator(
                                  value: financeData.payrollPercent,
                                  strokeWidth: 26,
                                  backgroundColor: Colors.greenAccent.shade100,
                                  color: const Color(0xff1450D2),
                                ),
                              ),
                              SizedBox(
                                height: 170,
                                width: 170,
                                child: CircularProgressIndicator(
                                  value: financeData.marketingPercent,
                                  strokeWidth: 26,
                                  backgroundColor: Colors.transparent,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Total", style: TextStyle(color: Colors.black54, fontSize: 24)),
                                  const SizedBox(height: 6),
                                  Text(
                                    financeData.totalBudget,
                                    style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        _legendTile(
                          color: const Color(0xff1450D2),
                          title: "Payroll",
                          value: "${(financeData.payrollPercent * 100).toInt()}%",
                        ),
                        const SizedBox(height: 18),
                        _legendTile(
                          color: Colors.greenAccent,
                          title: "Marketing",
                          value: "${(financeData.marketingPercent * 100).toInt()}%",
                        ),
                        const SizedBox(height: 18),
                        _legendTile(
                          color: const Color(0xffA86B00),
                          title: "Operations",
                          value: "${(financeData.operationsPercent * 100).toInt()}%",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// TRANSACTIONS HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          "Recent Transactions",
                          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text("View All", style: TextStyle(color: const Color(0xff1450D2), fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  /// TRANSACTIONS LIST
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      children: financeData.recentTransactions.asMap().entries.map((entry) {
                        int idx = entry.key;
                        var tx = entry.value;

                        return Column(
                          children: [
                            _transactionTile(
                              icon: tx.isExpense ? Icons.cloud_upload_outlined : Icons.account_balance,
                              title: tx.title,
                              time: tx.time,
                              amount: tx.amount,
                              isExpense: tx.isExpense,
                              iconColor: tx.isExpense ? Colors.blue : Colors.green, // simplifying logic
                            ),
                            if (idx != financeData.recentTransactions.length - 1)
                              const Divider(height: 1),
                          ],
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ADD INCOME + ADD EXPENSE BUTTONS
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddIncomePage()));
                      },
                      icon: const Icon(Icons.add, size: 22),
                      label: const Text("Add Income", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpensePage()));
                      },
                      icon: const Icon(Icons.remove, size: 22),
                      label: const Text("Add Expense", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) => Center(child: Text("Error: $err")),
        ),
      ),
    );
  }

  Widget _graphBar(double height, {bool active = false}) {
    return Container(
      width: 36,
      height: height,
      decoration: BoxDecoration(
        color: active ? const Color(0xff1450D2) : Colors.blue.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _smallFinanceCard({
    required String title,
    required String amount,
    required String percent,
    required bool isPositive,
    required Color borderColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border(left: BorderSide(color: borderColor, width: 5)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.black87, fontSize: 20)),
          const SizedBox(height: 18),
          Text(amount, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, color: borderColor, size: 20),
              const SizedBox(width: 6),
              Text(percent, style: TextStyle(color: borderColor, fontSize: 20)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendTile({required Color color, required String title, required String value}) {
    return Row(
      children: [
        CircleAvatar(radius: 8, backgroundColor: color),
        const SizedBox(width: 16),
        Expanded(child: Text(title, style: const TextStyle(fontSize: 20))),
        Text(value, style: const TextStyle(fontSize: 20)),
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
  }) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(time, style: const TextStyle(color: Colors.black54, fontSize: 18)),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isExpense ? Colors.red : Colors.green.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}
