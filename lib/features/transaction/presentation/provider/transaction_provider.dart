import 'package:flutter/foundation.dart';

import '../../domain/models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  final List<Transaction> _transactions = [];
  double _balance = 0.0;

  List<Transaction> get transactions => _transactions;
  double get balance => _balance;

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    _balance +=
        transaction.isDeposit ? transaction.amount : -transaction.amount;
    notifyListeners();
  }

  void sortTransactions(int Function(Transaction a, Transaction b) compare) {
    _transactions.sort(compare);
    notifyListeners();
  }
}
