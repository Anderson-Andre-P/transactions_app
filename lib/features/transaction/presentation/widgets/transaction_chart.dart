// lib/features/transactions/presentation/widgets/transaction_chart.dart
import 'package:finaciamento/features/transaction/presentation/provider/transaction_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import '../../domain/models/transaction.dart';

class ChartData {
  final DateTime date;
  final double balance;
  final bool isDeposit;
  final double amount;

  ChartData(this.date, this.balance, this.isDeposit, this.amount);
}

class TransactionChart extends StatelessWidget {
  const TransactionChart({super.key});

  List<ChartData> _prepareChartData(List<Transaction> transactions) {
    double runningBalance = 0;
    final sortedTransactions = List<Transaction>.from(transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    return sortedTransactions.map((transaction) {
      runningBalance +=
          transaction.isDeposit ? transaction.amount : -transaction.amount;
      return ChartData(transaction.date, runningBalance, transaction.isDeposit,
          transaction.amount);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Evolução do Saldo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, child) {
                final chartData = _prepareChartData(provider.transactions);

                if (chartData.isEmpty) {
                  return const Center(
                    child: Text(
                      'Adicione transações para ver o gráfico',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                // Calcula o intervalo de datas para o eixo X
                final minDate = chartData.first.date;
                final maxDate = chartData.last.date;
                final daysDifference = maxDate.difference(minDate).inDays;

                return SfCartesianChart(
                  plotAreaBorderWidth: 0,
                  margin: const EdgeInsets.all(0),
                  primaryXAxis: DateTimeAxis(
                    dateFormat: DateFormat('dd/MM'),
                    intervalType: DateTimeIntervalType.days,
                    minimum: minDate.subtract(const Duration(days: 1)),
                    maximum: maxDate.add(const Duration(days: 1)),
                    interval: daysDifference > 30 ? 7 : 1,
                    majorGridLines: const MajorGridLines(width: 0),
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    autoScrollingDelta:
                        daysDifference < 7 ? daysDifference + 2 : 7,
                    autoScrollingMode: AutoScrollingMode.end,
                  ),
                  primaryYAxis: NumericAxis(
                    numberFormat: currencyFormat,
                    majorGridLines: const MajorGridLines(
                      width: 1,
                      color: Colors.grey,
                      dashArray: <double>[5, 5],
                    ),
                    labelStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  tooltipBehavior: TooltipBehavior(
                    enable: true,
                    format: 'point.x : point.y',
                    header: '',
                    builder: (data, point, series, pointIndex, seriesIndex) {
                      final ChartData chartData = data as ChartData;
                      return Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('dd/MM/yyyy').format(chartData.date),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Saldo: ${currencyFormat.format(chartData.balance)}',
                              style: const TextStyle(
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              '${chartData.isDeposit ? "Depósito" : "Retirada"}: ${currencyFormat.format(chartData.amount)}',
                              style: TextStyle(
                                color: chartData.isDeposit
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  series: <CartesianSeries>[
                    // Linha principal de saldo
                    LineSeries<ChartData, DateTime>(
                      dataSource: chartData,
                      xValueMapper: (ChartData data, _) => data.date,
                      yValueMapper: (ChartData data, _) => data.balance,
                      color: Colors.blue,
                      width: 2,
                      markerSettings: const MarkerSettings(
                        isVisible: true,
                        height: 8,
                        width: 8,
                        shape: DataMarkerType.circle,
                        borderWidth: 2,
                        borderColor: Colors.blue,
                      ),
                    ),
                    // Pontos de depósito
                    ScatterSeries<ChartData, DateTime>(
                      dataSource:
                          chartData.where((data) => data.isDeposit).toList(),
                      xValueMapper: (ChartData data, _) => data.date,
                      yValueMapper: (ChartData data, _) => data.balance,
                      color: Colors.green,
                      markerSettings: const MarkerSettings(
                        height: 10,
                        width: 10,
                        shape: DataMarkerType.diamond,
                      ),
                    ),
                    // Pontos de retirada
                    ScatterSeries<ChartData, DateTime>(
                      dataSource:
                          chartData.where((data) => !data.isDeposit).toList(),
                      xValueMapper: (ChartData data, _) => data.date,
                      yValueMapper: (ChartData data, _) => data.balance,
                      color: Colors.red,
                      markerSettings: const MarkerSettings(
                        height: 10,
                        width: 10,
                        shape: DataMarkerType.triangle,
                      ),
                    ),
                  ],
                  zoomPanBehavior: ZoomPanBehavior(
                    enablePanning: true,
                    zoomMode: ZoomMode.x,
                    enablePinching: true,
                    enableDoubleTapZooming: true,
                    enableMouseWheelZooming: true,
                    enableSelectionZooming: true,
                  ),
                  trackballBehavior: TrackballBehavior(
                    enable: true,
                    activationMode: ActivationMode.singleTap,
                    tooltipSettings: const InteractiveTooltip(
                      enable: true,
                      format: 'point.x : point.y',
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendItem(
                color: Colors.green,
                label: 'Depósito',
                shape: BoxShape.circle,
              ),
              const SizedBox(width: 16),
              _LegendItem(
                color: Colors.red,
                label: 'Retirada',
                shape: BoxShape.circle,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final BoxShape shape;

  const _LegendItem({
    required this.color,
    required this.label,
    this.shape = BoxShape.circle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: shape,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
