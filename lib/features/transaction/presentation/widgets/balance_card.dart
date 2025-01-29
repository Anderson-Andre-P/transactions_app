import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/transaction_provider.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Saldo Atual',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                return Text(
                  'R\$ ${provider.balance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
