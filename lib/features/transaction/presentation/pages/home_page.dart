import 'package:flutter/material.dart';

import '../widgets/add_transaction_modal.dart';
import '../widgets/balance_card.dart';
import '../widgets/transaction_chart.dart';
import '../widgets/transaction_list.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Controle de Gastos'),
      ),
      body: const Column(
        children: [
          BalanceCard(),
          TransactionList(),
          TransactionChart(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const AddTransactionModal(),
    );
  }
}
