import 'package:flutter/material.dart';

class MyPayrollPage extends StatelessWidget {
  const MyPayrollPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F7FC),

      appBar: AppBar(
        title: const Text("Payroll Management"),
        backgroundColor: const Color(0xff1D4ED8),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Total Payroll",
                    "₹12.5L",
                    Icons.account_balance_wallet,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    "Paid",
                    "110",
                    Icons.check_circle,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Pending",
                    "18",
                    Icons.pending_actions,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _statCard(
                    "Employees",
                    "128",
                    Icons.people,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            TextField(
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

            _employeeSalaryCard(
              context,
              name: "Pritam Sharma",
              designation: "Flutter Developer",
              basic: "₹40,000",
              bonus: "₹5,000",
              deduction: "₹2,000",
              netSalary: "₹43,000",
              paid: false,
            ),

            _employeeSalaryCard(
              context,
              name: "Rahul Kumar",
              designation: "HR Manager",
              basic: "₹35,000",
              bonus: "₹3,000",
              deduction: "₹1,000",
              netSalary: "₹37,000",
              paid: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
      String title,
      String value,
      IconData icon,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xff1D4ED8),
            size: 35,
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(title),
        ],
      ),
    );
  }

  Widget _employeeSalaryCard(
      BuildContext context, {
        required String name,
        required String designation,
        required String basic,
        required String bonus,
        required String deduction,
        required String netSalary,
        required bool paid,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [

          Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xff1D4ED8),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
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
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(designation),
                  ],
                ),
              ),

              Chip(
                backgroundColor:
                paid ? Colors.green.shade100 : Colors.orange.shade100,
                label: Text(
                  paid ? "PAID" : "PENDING",
                ),
              ),
            ],
          ),

          const Divider(height: 25),

          salaryRow("Basic Salary", basic),
          salaryRow("Bonus", bonus),
          salaryRow("Deduction", deduction),

          const Divider(),

          salaryRow(
            "Net Salary",
            netSalary,
            isBold: true,
          ),

          const SizedBox(height: 15),

          Row(
            children: [

              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  child: const Text("View Payslip"),
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff1D4ED8),
                  ),
                  onPressed: paid
                      ? null
                      : () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text("Confirm Salary Payment"),
                          content: Text(
                            "Pay $netSalary to $name ?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);

                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Salary paid to $name",
                                    ),
                                  ),
                                );
                              },
                              child: const Text("Pay Now"),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text(
                    "Pay Salary",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget salaryRow(
      String title,
      String value, {
        bool isBold = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(title),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight:
              isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: isBold ? 18 : 15,
            ),
          ),
        ],
      ),
    );
  }
}