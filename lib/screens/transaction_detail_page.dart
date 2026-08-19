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
          backgroundColor: const Color(0xff111111),
          title: const Text(
            'Hapus transaksi?',
          ),
          content: Text(
            'Transaksi "${transaction.description}" '
            'akan dihapus permanen.',
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

    if (shouldDelete != true) {
      return;
    }

    // ========================================================
    // PENTING:
    // Detail page TIDAK menghapus SQLite langsung.
    //
    // Detail hanya mengembalikan TRUE.
    // main.dart yang menangani delete database + UI.
    // ========================================================

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
        title: const Text(
          'Transaction',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // =================================================
            // TRANSACTION INFORMATION
            // =================================================

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

            // =================================================
            // DELETE BUTTON
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  requestDelete(context);
                },
                icon: const Icon(
                  Icons.delete_outline,
                ),
                label: const Text(
                  'Delete Transaction',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red.shade900,
                  foregroundColor: Colors.white,
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