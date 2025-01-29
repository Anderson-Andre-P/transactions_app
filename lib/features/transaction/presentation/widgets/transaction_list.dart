import 'package:finaciamento/features/transaction/domain/models/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../provider/transaction_provider.dart';

class TransactionList extends StatefulWidget {
  const TransactionList({super.key});

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  late TransactionDataSource _transactionDataSource;
  final DataGridController _dataGridController = DataGridController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Consumer<TransactionProvider>(
        builder: (context, provider, child) {
          _transactionDataSource = TransactionDataSource(
            transactions: provider.transactions,
            context: context,
          );

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Histórico de Transações',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${provider.transactions.length} transações',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SfDataGridTheme(
                    data: SfDataGridThemeData(
                      headerColor: Colors.grey.shade50,
                      gridLineColor: Colors.grey.shade200,
                      gridLineStrokeWidth: 1,
                    ),
                    child: SfDataGrid(
                      source: _transactionDataSource,
                      controller: _dataGridController,
                      allowSorting: true,
                      allowFiltering: true,
                      allowColumnsResizing: true,
                      columnResizeMode: ColumnResizeMode.onResize,
                      selectionMode: SelectionMode.none,
                      navigationMode: GridNavigationMode.row,
                      gridLinesVisibility: GridLinesVisibility.horizontal,
                      headerGridLinesVisibility: GridLinesVisibility.horizontal,
                      columnWidthMode: ColumnWidthMode.fill,
                      columns: [
                        GridColumn(
                          columnName: 'type',
                          label: const Center(
                            child: Text(
                              'Tipo',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          width: 150,
                        ),
                        GridColumn(
                          columnName: 'amount',
                          label: const Center(
                            child: Text(
                              'Valor',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        GridColumn(
                          columnName: 'date',
                          label: const Center(
                            child: Text(
                              'Data',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class TransactionDataSource extends DataGridSource {
  final List<Transaction> transactions;
  final BuildContext context;
  late List<DataGridRow> _dataGridRows;

  TransactionDataSource({
    required this.transactions,
    required this.context,
  }) {
    _dataGridRows = transactions.map<DataGridRow>((transaction) {
      return DataGridRow(
        cells: [
          DataGridCell<Widget>(
            columnName: 'type',
            value: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: transaction.isDeposit
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Icon(
                    transaction.isDeposit ? Icons.add : Icons.remove,
                    color: transaction.isDeposit ? Colors.green : Colors.red,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  transaction.isDeposit ? 'Depósito' : 'Retirada',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          DataGridCell<double>(
            columnName: 'amount',
            value: transaction.amount,
          ),
          DataGridCell<DateTime>(
            columnName: 'date',
            value: transaction.date,
          ),
        ],
      );
    }).toList();
  }

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((cell) {
        if (cell.columnName == 'type') {
          return Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: cell.value,
          );
        } else if (cell.columnName == 'amount') {
          final amount = cell.value as double;
          final isDeposit = amount > 0;
          return Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$')
                  .format(amount),
              style: TextStyle(
                color: isDeposit ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        } else if (cell.columnName == 'date') {
          final date = cell.value as DateTime;
          return Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              DateFormat('dd/MM/yyyy').format(date),
            ),
          );
        }
        return Container();
      }).toList(),
    );
  }
}
