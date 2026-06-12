import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

class TransactionItem {
  final String title;
  final String time;
  final String amount;
  final bool isExpense;

  const TransactionItem({
    required this.title,
    required this.time,
    required this.amount,
    required this.isExpense,
  });
}

class FinanceData {
  final String turnoverAmount;
  final String turnoverPercent;
  final List<double> turnoverGraph;

  final String netProfitAmount;
  final String netProfitPercent;

  final String expensesAmount;
  final String expensesPercent;

  final String totalBudget;
  final double payrollPercent;
  final double marketingPercent;
  final double operationsPercent;

  final List<TransactionItem> recentTransactions;

  const FinanceData({
    required this.turnoverAmount,
    required this.turnoverPercent,
    required this.turnoverGraph,
    required this.netProfitAmount,
    required this.netProfitPercent,
    required this.expensesAmount,
    required this.expensesPercent,
    required this.totalBudget,
    required this.payrollPercent,
    required this.marketingPercent,
    required this.operationsPercent,
    required this.recentTransactions,
  });
}

class FinanceService extends StateNotifier<AsyncValue<FinanceData>> {
  FinanceService() : super(const AsyncValue.loading()) {
    fetchFinanceData();
  }

  Future<void> fetchFinanceData() async {
    state = const AsyncValue.loading();
    try {
      await Future.delayed(const Duration(milliseconds: 700));

      final data = FinanceData(
        turnoverAmount: "₹1,248,390",
        turnoverPercent: "+12.4%",
        turnoverGraph: [50, 70, 65, 90, 75, 120],
        netProfitAmount: "₹12.8k",
        netProfitPercent: "8%",
        expensesAmount: "₹835.5k",
        expensesPercent: "2%",
        totalBudget: "₹1.2M",
        payrollPercent: 0.60,
        marketingPercent: 0.25,
        operationsPercent: 0.15,
        recentTransactions: [
          const TransactionItem(
            title: "Q3 Tax Payment",
            time: "Today • 14:32",
            amount: "-₹24,100",
            isExpense: true,
          ),
          const TransactionItem(
            title: "Client Wire: NovaCorp",
            time: "Yesterday • 09:15",
            amount: "+₹156,000",
            isExpense: false,
          ),
          const TransactionItem(
            title: "SaaS Subscription",
            time: "22 Oct • 11:00",
            amount: "-₹1,250",
            isExpense: true,
          ),
        ],
      );

      state = AsyncValue.data(data);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final financeProvider =
    StateNotifierProvider<FinanceService, AsyncValue<FinanceData>>((ref) {
      return FinanceService();
    });
