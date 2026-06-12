import 'package:flutter/material.dart';
import '../../models/dashboard_model.dart';
import 'package:intl/intl.dart';

class FiscalSummaryWidget extends StatelessWidget {
  final double turnover;
  final double netProfit;
  final double payroll;
  final double expenses;
  final double personnelBudgetPercent;
  final double resourceBudgetPercent;

  const FiscalSummaryWidget({
    super.key,
    required this.turnover,
    required this.netProfit,
    required this.payroll,
    required this.expenses,
    required this.personnelBudgetPercent,
    required this.resourceBudgetPercent,
  });

  String _formatCurrency(double amount) {
    String compacted = NumberFormat.compact(locale: 'en_US').format(amount);
    return '₹$compacted';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Fiscal Summary",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff0F172A),
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey.shade400),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildFiscalItem("Turnover", _formatCurrency(turnover), Colors.blue.shade600),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade200),
              Expanded(
                child: _buildFiscalItem("Net Profit", _formatCurrency(netProfit), Colors.green.shade600),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildFiscalItem("Payroll", _formatCurrency(payroll), Colors.orange.shade600),
              ),
              Container(width: 1, height: 40, color: Colors.grey.shade200),
              Expanded(
                child: _buildFiscalItem("Expenses", _formatCurrency(expenses), Colors.red.shade600),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            "Budget Distribution",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xff0F172A),
            ),
          ),
          const SizedBox(height: 16),
          _buildBudgetProgress("Personnel", personnelBudgetPercent, Colors.blue.shade600),
          const SizedBox(height: 12),
          _buildBudgetProgress("Resources", resourceBudgetPercent, Colors.purple.shade600),
        ],
      ),
    );
  }

  Widget _buildFiscalItem(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetProgress(String title, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
            Text(
              "${percent.toInt()}%",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: percent / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
