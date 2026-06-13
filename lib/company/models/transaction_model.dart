import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String date;
  final String amount;
  final String type; // 'CREDIT' or 'DEBIT'

  TransactionModel({
    required this.id,
    required this.title,
    this.description = '',
    required this.category,
    required this.date,
    required this.amount,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'date': date,
      'amount': amount,
      'type': type,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? json['name'] ?? 'Unknown',
      description: json['description'] ?? json['remarks'] ?? '',
      category: json['category'] ?? 'OPERATING',
      date: json['date'] ?? 'Jun 04, 2026',
      amount: json['amount']?.toString() ?? '0',
      type: json['type'] ?? 'DEBIT',
    );
  }

  static final List<TransactionModel> _mockTransactions = [
      TransactionModel(
        id: '1',
        title: 'Phynol, Sprey freshner, ...',
        description: 'Office cleaning supplies',
        category: 'OPERATING',
        date: 'Jun 04, 2026',
        amount: '120',
        type: 'DEBIT',
      ),
      TransactionModel(
        id: '2',
        title: 'Presshop',
        description: 'Monthly subscription',
        category: 'OPERATING',
        date: 'Jun 04, 2026',
        amount: '450',
        type: 'DEBIT',
      ),
      TransactionModel(
        id: '3',
        title: 'Payroll - test user',
        description: 'Monthly salary disbursement',
        category: 'PAYROLL',
        date: 'Jun 01, 2026',
        amount: '15000',
        type: 'DEBIT',
      ),
      TransactionModel(
        id: '4',
        title: 'Payroll - Simran Kumari',
        description: 'Monthly salary disbursement',
        category: 'PAYROLL',
        date: 'Jun 01, 2026',
        amount: '15000',
        type: 'DEBIT',
      ),
      TransactionModel(
        id: '5',
        title: 'AWS Hosting',
        description: 'Cloud server costs',
        category: 'INFRASTRUCTURE',
        date: 'May 28, 2026',
        amount: '250',
        type: 'DEBIT',
      ),
  ];

  static List<TransactionModel> mockData() {
    return _mockTransactions;
  }

  static Future<void> loadSavedTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStr = prefs.getString('saved_transactions');
    if (savedStr != null) {
      try {
        final List<dynamic> decoded = jsonDecode(savedStr);
        final loaded = decoded.map((e) => TransactionModel.fromJson(e)).toList();
        
        // Merge with existing avoiding duplicates
        for (var tx in loaded) {
          if (!_mockTransactions.any((e) => e.id == tx.id)) {
            _mockTransactions.insert(0, tx);
          }
        }
      } catch (e) {
        print("Error loading saved transactions: $e");
      }
    }
  }

  static void addMockTransaction(TransactionModel tx) async {
    _mockTransactions.insert(0, tx);
    final prefs = await SharedPreferences.getInstance();
    final toSave = _mockTransactions.where((tx) => !['1','2','3','4','5'].contains(tx.id)).toList();
    final encoded = jsonEncode(toSave.map((e) => e.toJson()).toList());
    await prefs.setString('saved_transactions', encoded);
  }
}
