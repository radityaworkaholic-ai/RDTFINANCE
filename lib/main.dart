import 'package:flutter/material.dart';

import 'database/database_helper.dart';
import 'screens/chat_page.dart';
import 'screens/transaction_detail_page.dart';
import 'widgets/cashflow_chart.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RDTFinance());
}

// ============================================================
// TRANSACTION MODEL
// ============================================================

class Transaction {
  final int? id;
  final String description;
  final double amount;
  final bool isIncome;
  final String payment;
  final String category;
  final DateTime createdAt;

  const Transaction({
    this.id,
    required this.description,
    required this.amount,
    required this.isIncome,
    required this.payment,
    required this.category,
    required this.createdAt,
  });
}

// ============================================================
// APP
// ============================================================

class RDTFinance extends StatefulWidget {
  const RDTFinance({super.key});

  @override
  State<RDTFinance> createState() => _RDTFinanceState();
}

class _RDTFinanceState extends State<RDTFinance> {
  int currentIndex = 0;
  bool isLoading = true;

  final List<Transaction> transactions = [];

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  // ==========================================================
  // LOAD
  // ==========================================================

  Future<void> loadTransactions() async {
    try {
      final data =
          await DatabaseHelper.instance.getTransactions();

      final result = data.map<Transaction>((item) {
        return Transaction(
          id: item['id'] as int,
          description:
              item['description'] as String? ?? '',
          amount:
              (item['amount'] as num).toDouble(),
          isIncome:
              item['isIncome'] == 1,
          payment:
              item['payment'] as String? ?? 'Unknown',
          category:
              item['category'] as String? ?? 'Other',
          createdAt:
              DateTime.parse(
            item['createdAt'] as String,
          ),
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        transactions
          ..clear()
          ..addAll(result);

        isLoading = false;
      });

      debugPrint(
        'RDTFINANCE: ${transactions.length} transaksi loaded',
      );
    } catch (e) {
      debugPrint(
        'RDTFINANCE LOAD ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ==========================================================
  // ADD
  // ==========================================================

  Future<void> addTransaction(
    Transaction transaction,
  ) async {
    try {
      final id =
          await DatabaseHelper.instance.insertTransaction(
        description: transaction.description,
        amount: transaction.amount,
        isIncome: transaction.isIncome,
        payment: transaction.payment,
        category: transaction.category,
      );

      final saved = Transaction(
        id: id,
        description: transaction.description,
        amount: transaction.amount,
        isIncome: transaction.isIncome,
        payment: transaction.payment,
        category: transaction.category,
        createdAt: transaction.createdAt,
      );

      if (!mounted) return;

      setState(() {
        transactions.add(saved);
      });

      debugPrint(
        'RDTFINANCE: INSERT ID $id',
      );
    } catch (e) {
      debugPrint(
        'RDTFINANCE INSERT ERROR: $e',
      );

      rethrow;
    }
  }

  // ==========================================================
  // DELETE DATABASE
  // ==========================================================

  Future<bool> deleteTransaction(
    Transaction transaction,
  ) async {
    if (transaction.id == null) {
      debugPrint(
        'RDTFINANCE DELETE: ID NULL',
      );
      return false;
    }

    try {
      final id = transaction.id!;

      final rows =
          await DatabaseHelper.instance.deleteTransaction(id);

      debugPrint(
        'RDTFINANCE DELETE: ID $id -> rows $rows',
      );

      if (rows <= 0) {
        return false;
      }

      if (!mounted) return true;

      setState(() {
        transactions.removeWhere(
          (item) => item.id == id,
        );
      });

      return true;
    } catch (e) {
      debugPrint(
        'RDTFINANCE DELETE ERROR: $e',
      );

      return false;
    }
  }

  // ==========================================================
  // DELETE CONFIRMATION
  // ==========================================================

  Future<bool> confirmDelete(
    Transaction transaction,
  ) async {
    final result = await showDialog<bool>(
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
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (result != true) {
      return false;
    }

    return deleteTransaction(transaction);
  }

  // ==========================================================
  // OPEN DETAIL
  // ==========================================================

  Future<void> openDetail(
    Transaction transaction,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return TransactionDetailPage(
            transaction: transaction,
          );
        },
      ),
    );

    // Selalu sync ulang dari database
    // setelah kembali dari detail.
    await loadTransactions();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    final pages = [
      HomePage(
        transactions: transactions,
        onTransactionTap: openDetail,
        onDeleteTransaction: confirmDelete,
      ),

      ChatPage(
        onTransactionAdded: addTransaction,
      ),

      StatsPage(
        transactions: transactions,
      ),

      const ProfilePage(),
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RDTFINANCE',

      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
        colorScheme: const ColorScheme.dark(
          surface: Colors.black,
        ),
      ),

      home: Scaffold(
        backgroundColor: Colors.black,

        body: pages[currentIndex],

        bottomNavigationBar:
            BottomNavigationBar(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,

          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },

          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Stats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// HOME
// ============================================================

class HomePage extends StatelessWidget {
  final List<Transaction> transactions;

  final Future<void> Function(
    Transaction,
  ) onTransactionTap;

  final Future<bool> Function(
    Transaction,
  ) onDeleteTransaction;

  const HomePage({
    super.key,
    required this.transactions,
    required this.onTransactionTap,
    required this.onDeleteTransaction,
  });

  @override
  Widget build(BuildContext context) {
    double income = 0;
    double expense = 0;

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    final balance = income - expense;

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,

        title: const Text(
          'RDTFINANCE',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              // ==================================================
              // BALANCE
              // ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: const Color(0xff111111),
                  borderRadius:
                      BorderRadius.circular(24),
                ),

                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,

                  children: [
                    const Text(
                      'Balance',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Rp ${formatMoney(balance)}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [
                        summaryItem(
                          'Income',
                          income,
                        ),

                        summaryItem(
                          'Expense',
                          expense,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // CASHFLOW
              // ==================================================

              const Text(
                'Cashflow',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                height: 180,
                width: double.infinity,
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: const Color(0xff111111),
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: const CashflowChart(),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // RECENT TRANSACTIONS
              // ==================================================

              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: transactions.isEmpty
                    ? const Align(
                        alignment:
                            Alignment.topLeft,
                        child: Text(
                          'Belum ada transaksi.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics:
                            const BouncingScrollPhysics(),

                        padding:
                            const EdgeInsets.only(
                          bottom: 20,
                        ),

                        itemCount:
                            transactions.length > 5
                                ? 5
                                : transactions.length,

                        itemBuilder:
                            (context, index) {
                          final transaction =
                              transactions[
                                transactions.length -
                                    1 -
                                    index
                              ];

                          return _TransactionItem(
                            transaction:
                                transaction,

                            onTap: () {
                              onTransactionTap(
                                transaction,
                              );
                            },

                            onDelete: () {
                              return onDeleteTransaction(
                                transaction,
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget summaryItem(
    String title,
    double amount,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Rp ${formatMoney(amount)}',
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// TRANSACTION ITEM
// ============================================================

class _TransactionItem extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;
  final Future<bool> Function() onDelete;

  const _TransactionItem({
    required this.transaction,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 10,
      ),

      child: Dismissible(
        key: ValueKey(
          transaction.id ??
              transaction.createdAt
                  .microsecondsSinceEpoch,
        ),

        direction:
            DismissDirection.endToStart,

        confirmDismiss: (_) async {
          return onDelete();
        },

        background: Container(
          alignment: Alignment.centerRight,

          padding: const EdgeInsets.only(
            right: 20,
          ),

          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius:
                BorderRadius.circular(16),
          ),

          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 26,
          ),
        ),

        child: Material(
          color: Colors.transparent,

          child: InkWell(
            onTap: onTap,

            borderRadius:
                BorderRadius.circular(16),

            child: Ink(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: const Color(0xff111111),
                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: Row(
                children: [
                  // ICON
                  Container(
                    width: 42,
                    height: 42,

                    decoration:
                        const BoxDecoration(
                      color: Color(0xff1c1c1c),
                      shape: BoxShape.circle,
                    ),

                    child: Icon(
                      transaction.isIncome
                          ? Icons
                              .arrow_downward
                          : Icons.arrow_upward,

                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // DESCRIPTION
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,

                      children: [
                        Text(
                          transaction
                              .description,

                          maxLines: 1,
                          overflow:
                              TextOverflow.ellipsis,

                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),

                        const SizedBox(
                          height: 5,
                        ),

                        Text(
                          '${transaction.category} • '
                          '${transaction.payment}',

                          style:
                              const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // AMOUNT
                  Text(
                    '${transaction.isIncome ? '+' : '-'}'
                    'Rp ${formatMoney(transaction.amount)}',

                    style: const TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STATS
// ============================================================

class StatsPage extends StatelessWidget {
  final List<Transaction> transactions;

  const StatsPage({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    double income = 0;
    double expense = 0;

    for (final transaction in transactions) {
      if (transaction.isIncome) {
        income += transaction.amount;
      } else {
        expense += transaction.amount;
      }
    }

    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Statistics',
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            statCard(
              'Total Income',
              income,
            ),

            const SizedBox(height: 12),

            statCard(
              'Total Expense',
              expense,
            ),

            const SizedBox(height: 12),

            statCard(
              'Net Balance',
              income - expense,
            ),
          ],
        ),
      ),
    );
  }

  Widget statCard(
    String title,
    double amount,
  ) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: const Color(0xff111111),
        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Rp ${formatMoney(amount)}',

            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE
// ============================================================

class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Profile',
        ),
      ),

      body: const Center(
        child: Text(
          'RDTFINANCE',

          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MONEY FORMATTER
// ============================================================

String formatMoney(double amount) {
  return amount
      .round()
      .toString()
      .replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => '.',
      );
}