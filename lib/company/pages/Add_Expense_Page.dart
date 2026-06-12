import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController noteController = TextEditingController();

  // ✅ FIX: Added dispose() to prevent memory leak
  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F6FA),

      appBar: AppBar(
        backgroundColor: Colors.red,
        centerTitle: true,
        elevation: 0,
        title: const Text(
          "Add Expense",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),

                boxShadow: [
                  BoxShadow(
                    // ✅ FIX: withOpacity deprecated → withValues
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Expense Details",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 25),

                  TextField(
                    controller: titleController,

                    decoration: InputDecoration(
                      labelText: "Expense Title",
                      hintText: "Enter expense title",
                      prefixIcon: const Icon(Icons.money_off),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,

                    decoration: InputDecoration(
                      labelText: "Amount",
                      hintText: "Enter amount",
                      prefixIcon: const Icon(Icons.currency_rupee),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: noteController,
                    maxLines: 4,

                    decoration: InputDecoration(
                      labelText: "Notes",
                      hintText: "Write something...",
                      prefixIcon: const Icon(Icons.note_alt),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      onPressed: () {
                        final newTx = TransactionModel(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          title: titleController.text.isNotEmpty ? titleController.text : 'New Expense',
                          description: noteController.text,
                          category: 'OPERATING',
                          date: DateFormat('MMM dd, yyyy').format(DateTime.now()),
                          amount: amountController.text.isNotEmpty ? amountController.text : '0',
                          type: 'DEBIT',
                        );
                        TransactionModel.addMockTransaction(newTx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Expense Added Successfully"),
                          ),
                        );

                        titleController.clear();
                        amountController.clear();
                        noteController.clear();

                        Navigator.pop(context, true);
                      },

                      icon: const Icon(Icons.remove, color: Colors.white),

                      label: const Text(
                        "Save Expense",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
