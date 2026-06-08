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

  static List<TransactionModel> mockData() {
    return [
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
  }
}
