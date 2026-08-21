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

  Future<void> deleteTransaction(
    BuildContext context,
  ) async {
    if (transaction.id == null) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xff151515),

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
                Navigator.of(dialogContext).pop(false);
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
                Navigator.of(dialogContext).pop(true);
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

    if (confirmed != true) {
      return;
    }

    try {
      final rows =
          await DatabaseHelper.instance.deleteTransaction(
        transaction.id!,
      );

      if (!context.mounted) {
        return;
      }

      if (rows > 0) {
        // Beri tahu Home bahwa transaksi berhasil dihapus.
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
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final d = transaction.createdAt;

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
            children: [
              // ==================================================
              // TRANSACTION CARD
              // ==================================================

              Container(
                width: double.infinity,

                padding: const EdgeInsets.all(24),

                decoration: BoxDecoration(
                  color: const Color(0xff111111),
                  borderRadius: BorderRadius.circular(24),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    Text(
                      transaction.description,

                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      '${transaction.isIncome ? '+' : '-'}'
                      'Rp ${formatMoney(transaction.amount)}',

                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Kategori : ${transaction.category}',
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Payment : ${transaction.payment}',
                    ),

                    const SizedBox(height: 6),

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
                width: double.infinity,

                height: 55,

                child: ElevatedButton(
                  onPressed: () {
                    deleteTransaction(context);
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),

                  child: const Text(
                    'Delete Transaction',

                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}