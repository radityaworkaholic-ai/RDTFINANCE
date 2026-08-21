import 'package:flutter/material.dart';

import '../main.dart';

class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailPage({
    super.key,
    required this.transaction,
  });

  // ==========================================================
  // DELETE
  // ==========================================================

  Future<void> requestDelete(
    BuildContext context,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff151515),
          title: const Text(
            'Hapus transaksi?',
          ),
          content: Text(
            '"${transaction.description}" akan '
            'dihapus secara permanen.',
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    // JANGAN hapus database di sini.
    //
    // Detail hanya mengirim sinyal TRUE ke main.dart.
    // Main.dart yang menghapus database + state.
    if (!context.mounted) return;

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
        elevation: 0,
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
              // DETAIL CARD
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
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 28),

                    _detailRow(
                      'Description',
                      transaction.description,
                    ),

                    _detailRow(
                      'Category',
                      transaction.category,
                    ),

                    _detailRow(
                      'Payment',
                      transaction.payment,
                    ),

                    _detailRow(
                      'Date',
                      dateText,
                    ),

                    _detailRow(
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
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () {
                    requestDelete(context);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                  ),
                  label: const Text(
                    'Delete Transaction',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.red.shade900,
                    foregroundColor: Colors.white,
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

  Widget _detailRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 17,
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
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}