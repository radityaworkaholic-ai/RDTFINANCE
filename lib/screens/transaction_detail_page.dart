import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../main.dart';

class TransactionDetailPage extends StatelessWidget {
  final Transaction transaction;

  const TransactionDetailPage({
    super.key,
    required this.transaction,
  });

  Future<void> _delete(BuildContext context) async {
    if (transaction.id == null) return;

    await DatabaseHelper.instance.deleteTransaction(transaction.id!);

    if (!context.mounted) return;

    Navigator.pop(context, true); // kirim TRUE ke Home
  }

  @override
  Widget build(BuildContext context) {
    final d = transaction.createdAt;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('Transaction'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xff111111),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Rp ${formatMoney(transaction.amount)}",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Kategori : ${transaction.category}"),
                  Text("Payment : ${transaction.payment}"),
                  Text("Tanggal : ${d.day}/${d.month}/${d.year}"),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: const Color(0xff111111),
                      title: const Text("Hapus transaksi?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Batal"),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Hapus"),
                        ),
                      ],
                    ),
                  );

                  if (ok == true) {
                    await _delete(context);
                  }
                },
                child: const Text("Delete Transaction"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}