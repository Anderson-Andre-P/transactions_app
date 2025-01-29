class Transaction {
  final double amount;
  final DateTime date;
  final bool isDeposit;

  Transaction({
    required this.amount,
    required this.date,
    required this.isDeposit,
  });
}
