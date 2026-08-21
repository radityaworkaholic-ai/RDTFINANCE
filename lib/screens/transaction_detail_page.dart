import 'package:flutter/material.dart';

import '../database/database_helper.dart';
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

  Future<void> _deleteTransaction(
    BuildContext context,
  ) async {
    if (transaction.id == null) {
      return;
    }

    try {
      final rows =
          await DatabaseHelper.instance.deleteTransaction(
        transaction.id!,
      );

      debugPrint(
        'DELETE ID: ${transaction.id}',
      );

      debugPrint(
        'DELETE ROWS: $rows',
      );

      if (!context.mounted) {
        return;
      }

      if (rows > 0) {
        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Transaksi tidak ditemukan.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        'DELETE ERROR: $e',
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menghapus transaksi: $e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // SHOW DELETE DIALOG
  // ==========================================================

  Future<void> _showDeleteDialog(
    BuildContext context,
  ) async {
    debugPrint(
      'DELETE BUTTON PRESSED',
    );

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(0xff151515),

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
                Navigator.of(
                  dialogContext,
                ).pop(false);
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
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },

              child: const Text(
                'Hapus',

                style: TextStyle(
                  color: Colors.red,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    debugPrint(
      'DELETE DIALOG RESULT: $result',
    );

    if (result == true &&
        context.mounted) {
      await _deleteTransaction(
        context,
      );
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final d =
        transaction.createdAt;

    return Scaffold(
      backgroundColor:
          Colors.black,

      appBar: AppBar(
        backgroundColor:
            Colors.black,

        elevation: 0,

        title: const Text(
          'Transaction',
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(
          children: [
            // ==================================================
            // TRANSACTION CARD
            // ==================================================

            Container(
              width:
                  double.infinity,

              padding:
                  const EdgeInsets.all(
                24,
              ),

              decoration:
                  BoxDecoration(
                color:
                    const Color(
                  0xff111111,
                ),

                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [
                  Text(
                    transaction.description,

                    style:
                        const TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Text(
                    '${transaction.isIncome ? '+' : '-'}'
                    'Rp ${formatMoney(transaction.amount)}',

                    style:
                        const TextStyle(
                      fontSize: 30,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Text(
                    'Kategori : '
                    '${transaction.category}',
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    'Payment : '
                    '${transaction.payment}',
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(
                    'Tanggal : '
                    '${d.day}/${d.month}/${d.year}',
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ==================================================
            // DELETE BUTTON
            // ==================================================

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton(
                onPressed: () {
                  _showDeleteDialog(
                    context,
                  );
                },

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red,

                  foregroundColor:
                      Colors.white,

                  padding:
                      const EdgeInsets.symmetric(
                    vertical: 16,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                  ),
                ),

                child:
                    const Text(
                  'Delete Transaction',

                  style:
                      TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}