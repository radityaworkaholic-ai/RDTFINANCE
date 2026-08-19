import 'package:flutter/material.dart';
import '../main.dart';

class ChatPage extends StatefulWidget {
  final Future<void> Function(Transaction) onTransactionAdded;

  const ChatPage({
    super.key,
    required this.onTransactionAdded,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController controller =
      TextEditingController();

  bool isSending = false;

  // ==========================================================
  // SEND TRANSACTION
  // ==========================================================

  Future<void> sendTransaction() async {
    final text = controller.text.trim();

    if (text.isEmpty || isSending) {
      return;
    }

    final transaction = parseTransaction(text);

    if (transaction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Format belum dikenali.\n\n'
            'Contoh:\n'
            'Makan sushi 45k BCA\n'
            'Gaji 5jt BCA\n'
            'Grab 25.000 OVO',
          ),
        ),
      );
      return;
    }

    setState(() {
      isSending = true;
    });

    try {
      await widget.onTransactionAdded(
        transaction,
      );

      controller.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transaksi berhasil disimpan',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal menyimpan transaksi: $e',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSending = false;
        });
      }
    }
  }

  // ==========================================================
  // PARSE TRANSACTION
  // ==========================================================

  Transaction? parseTransaction(String text) {
    final lower = text.toLowerCase();

    final regex = RegExp(
      r'(\d+(?:[.,]\d+)?)\s*(k|rb|ribu|jt|juta)?',
    );

    final match = regex.firstMatch(lower);

    if (match == null) {
      return null;
    }

    String numberText = match.group(1)!;
    final unit = match.group(2);

    double amount;

    // Contoh: 1.5jt / 1,5jt
    if (unit != null) {
      numberText = numberText.replaceAll(',', '.');

      amount =
          double.tryParse(numberText) ?? 0;

      if (unit == 'k' ||
          unit == 'rb' ||
          unit == 'ribu') {
        amount *= 1000;
      } else if (unit == 'jt' ||
          unit == 'juta') {
        amount *= 1000000;
      }
    }

    // Contoh: 45.000
    else if (numberText.contains('.')) {
      final parts = numberText.split('.');

      if (parts.length == 2 &&
          parts[1].length == 3) {
        numberText =
            numberText.replaceAll('.', '');

        amount =
            double.tryParse(numberText) ?? 0;
      } else {
        numberText =
            numberText.replaceAll(',', '.');

        amount =
            double.tryParse(numberText) ?? 0;
      }
    }

    // Contoh: 45000 / 45,5
    else {
      numberText =
          numberText.replaceAll(',', '.');

      amount =
          double.tryParse(numberText) ?? 0;
    }

    if (amount <= 0) {
      return null;
    }

    // ========================================================
    // INCOME / EXPENSE
    // ========================================================

    final isIncome =
        lower.contains('gaji') ||
        lower.contains('income') ||
        lower.contains('bonus') ||
        lower.contains('masuk') ||
        lower.contains('terima') ||
        lower.contains('dapat');

    // ========================================================
    // PAYMENT
    // ========================================================

    String payment = 'Unknown';

    if (lower.contains('bca')) {
      payment = 'BCA';
    } else if (lower.contains('mandiri')) {
      payment = 'Mandiri';
    } else if (lower.contains('bri')) {
      payment = 'BRI';
    } else if (lower.contains('bni')) {
      payment = 'BNI';
    } else if (lower.contains('cash') ||
        lower.contains('tunai')) {
      payment = 'Cash';
    } else if (lower.contains('ovo')) {
      payment = 'OVO';
    } else if (lower.contains('gopay')) {
      payment = 'GoPay';
    } else if (lower.contains('dana')) {
      payment = 'DANA';
    } else if (lower.contains('shopeepay')) {
      payment = 'ShopeePay';
    }

    // ========================================================
    // CATEGORY
    // ========================================================

    String category = 'Other';

    if (isIncome) {
      if (lower.contains('gaji')) {
        category = 'Salary';
      } else if (lower.contains('bonus')) {
        category = 'Bonus';
      } else {
        category = 'Income';
      }
    } else if (
        lower.contains('makan') ||
        lower.contains('nasi') ||
        lower.contains('ayam') ||
        lower.contains('sushi') ||
        lower.contains('kopi') ||
        lower.contains('minum') ||
        lower.contains('restaurant') ||
        lower.contains('restoran') ||
        lower.contains('food')
    ) {
      category = 'Food';
    } else if (
        lower.contains('grab') ||
        lower.contains('gojek') ||
        lower.contains('taxi') ||
        lower.contains('ojek') ||
        lower.contains('transport') ||
        lower.contains('bensin') ||
        lower.contains('pertalite') ||
        lower.contains('pertamax')
    ) {
      category = 'Transport';
    } else if (
        lower.contains('belanja') ||
        lower.contains('shopping') ||
        lower.contains('baju') ||
        lower.contains('sepatu') ||
        lower.contains('celana') ||
        lower.contains('mall')
    ) {
      category = 'Shopping';
    } else if (
        lower.contains('kost') ||
        lower.contains('listrik') ||
        lower.contains('air') ||
        lower.contains('wifi') ||
        lower.contains('internet') ||
        lower.contains('tagihan') ||
        lower.contains('bill')
    ) {
      category = 'Bills';
    } else if (
        lower.contains('film') ||
        lower.contains('bioskop') ||
        lower.contains('game') ||
        lower.contains('hiburan') ||
        lower.contains('spotify') ||
        lower.contains('netflix')
    ) {
      category = 'Entertainment';
    } else if (
        lower.contains('obat') ||
        lower.contains('dokter') ||
        lower.contains('rumah sakit')
    ) {
      category = 'Health';
    }

    // ========================================================
    // CREATE TRANSACTION
    // ========================================================

    return Transaction(
      description: text,
      amount: amount,
      isIncome: isIncome,
      payment: payment,
      category: category,
      createdAt: DateTime.now(),
    );
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  // ==========================================================
  // UI
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text(
          'RDTFINANCE AI',
        ),
        backgroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // ==================================================
            // AI MESSAGE
            // ==================================================

            Expanded(
              child: Align(
                alignment: Alignment.topLeft,

                child: Container(
                  padding:
                      const EdgeInsets.all(14),

                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF111111),
                    borderRadius:
                        BorderRadius.circular(16),
                  ),

                  child: const Text(
                    'Halo Mr.Raditya 💸\n\n'
                    'Ketik transaksi seperti:\n'
                    'Makan sushi 45k BCA\n\n'
                    'Atau:\n'
                    'Gaji 5jt BCA\n\n'
                    'Contoh lainnya:\n'
                    'Grab 25.000 OVO',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),

            // ==================================================
            // INPUT
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,

                    onSubmitted: (_) =>
                        sendTransaction(),

                    style: const TextStyle(
                      color: Colors.white,
                    ),

                    decoration:
                        InputDecoration(
                      hintText:
                          'Tulis transaksi...',

                      hintStyle:
                          const TextStyle(
                        color: Colors.grey,
                      ),

                      filled: true,

                      fillColor:
                          const Color(
                        0xFF111111,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Container(
                  decoration:
                      const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),

                  child: IconButton(
                    onPressed: isSending
                        ? null
                        : sendTransaction,

                    icon: isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,

                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                              color:
                                  Colors.black,
                            ),
                          )
                        : const Icon(
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