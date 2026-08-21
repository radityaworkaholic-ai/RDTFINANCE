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
  // DELETE TRANSACTION
  // ==========================================================

  Future<void> _delete(
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
        'RDTFINANCE DETAIL DELETE: '
        'ID ${transaction.id} -> rows $rows',
      );

      if (!context.mounted) {
        return;
      }

      // Hanya kembali dengan TRUE jika
      // transaksi benar-benar terhapus dari database.
      if (rows > 0) {
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Transaksi gagal dihapus.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint(
        'RDTFINANCE DETAIL DELETE ERROR: $e',
      );

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Terjadi kesalahan saat menghapus transaksi.',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // DELETE CONFIRMATION
  // ==========================================================

  Future<void> _confirmDelete(
    BuildContext context,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(0xff111111),

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
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (ok == true && context.mounted) {
      await _delete(context);
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    final d = transaction.createdAt;

    return Scaffold(
      backgroundColor:
          Colors.black,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor:
            Colors.black,

        elevation: 0,

        title: const Text(
          'Transaction',
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Padding(
        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(
          children: [
            // ====================================================
            // TRANSACTION CARD
            // ====================================================

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
                  // DESCRIPTION

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

                  // AMOUNT

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

                  // CATEGORY

                  Text(
                    'Kategori : '
                    '${transaction.category}',
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  // PAYMENT

                  Text(
                    'Payment : '
                    '${transaction.payment}',
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  // DATE

                  Text(
                    'Tanggal : '
                    '${d.day}/${d.month}/${d.year}',
                  ),
                ],
              ),
            ),

            const Spacer(),

            // ====================================================
            // DELETE BUTTON
            // ====================================================

            SizedBox(
              width:
                  double.infinity,

              child:
                  ElevatedButton(
                onPressed: () {
                  _confirmDelete(
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
          ],
        ),
      ),
    );
  }
}