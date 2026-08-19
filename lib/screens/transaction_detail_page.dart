import 'package:flutter/material.dart';

import '../main.dart';

class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailPage({
    super.key,
    required this.transaction,
  });

  // ==========================================================
  // DELETE CONFIRMATION
  // ==========================================================

  Future<void> confirmDelete(
    BuildContext context,
  ) async {
    final result = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff111111),

          title: const Text(
            'Hapus transaksi?',
          ),

          content: const Text(
            'Transaksi ini akan dihapus secara permanen.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },

              child: const Text(
                'Batal',

                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },

              child: const Text(
                'Hapus',

                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    // ========================================================
    // JANGAN HAPUS DATABASE DI SINI.
    //
    // Kirim sinyal true ke main.dart.
    // main.dart yang akan menghapus SQLite + list.
    // ========================================================

    Navigator.pop(
      context,
      true,
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final date = transaction.createdAt;

    final dateText =
        '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';

    final timeText =
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,

        title: const Text(
          'Transaction',
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // TRANSACTION INFORMATION
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: const Color(0xff111111),
                  borderRadius:
                      BorderRadius.circular(24),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      transaction.isIncome
                          ? 'Income'
                          : 'Expense',

                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      '${transaction.isIncome ? '+' : '-'}'
                      'Rp ${formatMoney(transaction.amount)}',

                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    detailRow(
                      'Description',
                      transaction.description,
                    ),

                    detailRow(
                      'Category',
                      transaction.category,
                    ),

                    detailRow(
                      'Payment',
                      transaction.payment,
                    ),

                    detailRow(
                      'Date',
                      dateText,
                    ),

                    detailRow(
                      'Time',
                      timeText,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ==================================================
              // DELETE BUTTON
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 52,

                child: ElevatedButton.icon(
                  onPressed: () {
                    confirmDelete(context);
                  },

                  icon: const Icon(
                    Icons.delete_outline,
                  ),

                  label: const Text(
                    'Delete Transaction',
                  ),

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red.shade900,

                    foregroundColor:
                        Colors.white,

                    elevation: 0,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // DETAIL ROW
  // ==========================================================

  Widget detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 16,
      ),

      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          SizedBox(
            width: 90,

            child: Text(
              title,

              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              value,

              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}