import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/transaction_model.dart';
import 'package:intl/intl.dart';

class AllTransactionsPage extends StatefulWidget {
  const AllTransactionsPage({super.key});

  @override
  State<AllTransactionsPage> createState() => _AllTransactionsPageState();
}

class _AllTransactionsPageState extends State<AllTransactionsPage> {
  @override
  Widget build(BuildContext context) {
    // We fetch from the mutable mockData
    final transactions = TransactionModel.mockData();

    return Scaffold(
      backgroundColor: const Color(0xffF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xff0F172A)),
        title: Text(
          "All Transactions",
          style: GoogleFonts.inter(
            color: const Color(0xff0F172A),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(24),
        itemCount: transactions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final tx = transactions[index];
          return _buildTransactionItem(tx);
        },
      ),
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

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tx.category.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                    "₹ ${tx.amount}",
                    style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold,
                      color: tx.type.toUpperCase() == 'CREDIT' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tx.date,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
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
}
