import 'package:dashflow/company/pages/Add_Expense_Page.dart';
import 'package:dashflow/company/pages/Add_Income_Page.dart';
import 'package:flutter/material.dart';

class FinanceDashboardPage extends StatelessWidget {
  const FinanceDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
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
        child: SingleChildScrollView(
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
                    backgroundImage: AssetImage(
                      "assets/images/ranjeet.jpg",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              /// TITLE
              const Text(
                "Fiscal Year 2024",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 22,
                ),
              ),

              const SizedBox(height: 8),

              const FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Financial Suite",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// TURNOVER CARD
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: const Border(
                    left: BorderSide(
                      color: Color(0xff1450D2),
                      width: 5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 10,
                    ),
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
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 20,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.trending_up,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "+12.4%",
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

                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "\$1,248,390",
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text(
                            "USD",
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    /// GRAPH
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _graphBar(50),
                        _graphBar(70),
                        _graphBar(65),
                        _graphBar(90),
                        _graphBar(75),
                        _graphBar(
                          120,
                          active: true,
                        ),
                      ],
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
                      amount: "\$12.8k",
                      percent: "8%",
                      isPositive: true,
                      borderColor: Colors.green,
                    ),
                  ),

                  const SizedBox(width: 18),

                  Expanded(
                    child: _smallFinanceCard(
                      title: "Expenses",
                      amount: "\$835.5k",
                      percent: "2%",
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
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 10,
                    ),
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
                              value: .60,
                              strokeWidth: 26,
                              backgroundColor: Colors.greenAccent.shade100,
                              color: const Color(0xff1450D2),
                            ),
                          ),

                          const SizedBox(
                            height: 170,
                            width: 170,
                            child: CircularProgressIndicator(
                              value: .25,
                              strokeWidth: 26,
                              backgroundColor: Colors.transparent,
                              color: Colors.greenAccent,
                            ),
                          ),

                          const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 24,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                "\$1.2M",
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                ),
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
                      value: "60%",
                    ),

                    const SizedBox(height: 18),

                    _legendTile(
                      color: Colors.greenAccent,
                      title: "Marketing",
                      value: "25%",
                    ),

                    const SizedBox(height: 18),

                    _legendTile(
                      color: const Color(0xffA86B00),
                      title: "Operations",
                      value: "15%",
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
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "View All",
                    style: TextStyle(
                      color: const Color(0xff1450D2),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// TRANSACTIONS LIST
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [

                    _transactionTile(
                      icon: Icons.account_balance_wallet_outlined,
                      title: "Q3 Tax Payment",
                      time: "Today • 14:32",
                      amount: "-\$24,100",
                      isExpense: true,
                      iconColor: Colors.blue,
                    ),

                    const Divider(height: 1),

                    _transactionTile(
                      icon: Icons.account_balance,
                      title: "Client Wire: NovaCorp",
                      time: "Yesterday • 09:15",
                      amount: "+\$156,000",
                      isExpense: false,
                      iconColor: Colors.green,
                    ),

                    const Divider(height: 1),

                    _transactionTile(
                      icon: Icons.cloud_upload_outlined,
                      title: "SaaS Subscription",
                      time: "22 Oct • 11:00",
                      amount: "-\$1,250",
                      isExpense: true,
                      iconColor: Colors.orange,
                    ),
                  ],
                ),
              ),



              const SizedBox(height: 24),

              /// ✅ ADD INCOME + ADD EXPENSE BUTTONS
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context)=> const AddIncomePage(),),);
                  },
                  icon: const Icon(Icons.add, size: 22),
                  label: const Text(
                    "Add Income",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context, MaterialPageRoute(builder: (context)=> const AddExpensePage(),),);
                  },
                  icon: const Icon(Icons.remove, size: 22),
                  label: const Text(
                    "Add Expense",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                ),
              ),

              const SizedBox(height: 40),

            ],
          ),
        ),
      ),
    );
  }

  Widget _graphBar(double height, {bool active = false}) {
    return Container(
      width: 36,
      height: height,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xff1450D2)
            : Colors.blue.shade100,
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
        border: Border(
          left: BorderSide(
            color: borderColor,
            width: 5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            amount,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: borderColor,
                size: 20,
              ),

              const SizedBox(width: 6),

              Text(
                percent,
                style: TextStyle(
                  color: borderColor,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendTile({
    required Color color,
    required String title,
    required String value,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 8,
          backgroundColor: color,
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ),

        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
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
              color: iconColor.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 18),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  time,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          Text(
            amount,
            style: TextStyle(
              color: isExpense
                  ? Colors.red
                  : Colors.green.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
    );
  }
}
