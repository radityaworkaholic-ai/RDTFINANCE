import 'package:flutter/material.dart';
import '../main.dart';

class ChatPage extends StatefulWidget {
  final Function(Transaction) onTransactionAdded;

  const ChatPage({
    super.key,
    required this.onTransactionAdded,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller = TextEditingController();

  void sendTransaction() {
    final text = controller.text.trim();

    if (text.isEmpty) return;

    final parsed = parseTransaction(text);

    if (parsed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Format belum dikenali. Contoh: Makan sushi 45k BCA',
          ),
        ),
      );
      return;
    }

    widget.onTransactionAdded(parsed);

    controller.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Transaksi berhasil ditambahkan'),
      ),
    );
  }

  Transaction? parseTransaction(String text) {
    final lower = text.toLowerCase();

    final regex = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(k|rb|ribu|jt|juta)?',
    );

    final match = regex.firstMatch(lower);

    if (match == null) return null;

    double amount = double.tryParse(
          match.group(1)!.replaceAll(',', '.'),
        ) ??
        0;

    final unit = match.group(2);

    if (unit == 'k' || unit == 'rb' || unit == 'ribu') {
      amount *= 1000;
    } else if (unit == 'jt' || unit == 'juta') {
      amount *= 1000000;
    }

    final isIncome =
        lower.contains('gaji') ||
        lower.contains('income') ||
        lower.contains('bonus') ||
        lower.contains('masuk');

    String payment = 'Unknown';

    if (lower.contains('bca')) {
      payment = 'BCA';
    } else if (lower.contains('mandiri')) {
      payment = 'Mandiri';
    } else if (lower.contains('bri')) {
      payment = 'BRI';
    } else if (lower.contains('cash') ||
        lower.contains('tunai')) {
      payment = 'Cash';
    } else if (lower.contains('ovo')) {
      payment = 'OVO';
    } else if (lower.contains('gopay')) {
      payment = 'GoPay';
    }

    return Transaction(
      description: text,
      amount: amount,
      isIncome: isIncome,
      payment: payment,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('RDTFINANCE AI'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Halo 👋\n\n'
                    'Ketik transaksi seperti:\n'
                    'Makan sushi 45k BCA\n\n'
                    'Atau:\n'
                    'Gaji 5jt BCA',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) => sendTransaction(),
                    decoration: InputDecoration(
                      hintText: 'Tulis transaksi...',
                      hintStyle:
                          const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF111111),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
  onPressed: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('TOMBOL BERFUNGSI'),
      ),
    );
  },
  icon: const Icon(
    Icons.send,
    color: Colors.black,
  ),
),
                    icon: const Icon(
                      Icons.send,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}