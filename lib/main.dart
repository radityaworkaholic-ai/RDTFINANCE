import 'package:flutter/material.dart';

import 'database/database_helper.dart';
import 'screens/chat_page.dart';
import 'widgets/cashflow_chart.dart';

void main() {
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

  Transaction({
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
  // LOAD DATABASE
  // ==========================================================

  Future<void> loadTransactions() async {
    try {
      final data = await DatabaseHelper.instance.getTransactions();

      debugPrint(
        'RDTFINANCE DATABASE: ${data.length} transaksi ditemukan',
      );

      final loadedTransactions = data.map((item) {
        return Transaction(
          id: item['id'] as int,
          description: item['description'] as String,
          amount: (item['amount'] as num).toDouble(),
          isIncome: item['isIncome'] == 1,
          payment: item['payment'] as String? ?? 'Unknown',
          category: item['category'] as String? ?? 'Other',
          createdAt: DateTime.parse(
            item['createdAt'] as String,
          ),
        );
      }).toList();

      if (!mounted) return;

      setState(() {
        transactions
          ..clear()
          ..addAll(loadedTransactions);

        isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'RDTFINANCE DATABASE ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  // ==========================================================
  // ADD TRANSACTION
  // ==========================================================

  Future<void> addTransaction(
    Transaction transaction,
  ) async {
    try {
      final id = await DatabaseHelper.instance.insertTransaction(
        description: transaction.description,
        amount: transaction.amount,
        isIncome: transaction.isIncome,
        payment: transaction.payment,
        category: transaction.category,
      );

      debugPrint(
        'RDTFINANCE DATABASE: transaksi tersimpan ID $id',
      );

      if (!mounted) return;

      final savedTransaction = Transaction(
        id: id,
        description: transaction.description,
        amount: transaction.amount,
        isIncome: transaction.isIncome,
        payment: transaction.payment,
        category: transaction.category,
        createdAt: transaction.createdAt,
      );

      setState(() {
        transactions.add(savedTransaction);
      });
    } catch (e) {
      debugPrint(
        'RDTFINANCE DATABASE INSERT ERROR: $e',
      );

      rethrow;
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
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
        body: pages[currentIndex],
        bottomNavigationBar: BottomNavigationBar(
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
// HOME PAGE
// ============================================================

class HomePage extends StatelessWidget {
  final List<Transaction> transactions;

  const HomePage({
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =================================================
              // BALANCE
              // =================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xff111111),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Balance',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Rp ${formatMoney(balance)}',
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        _summaryItem(
                          'Income',
                          income,
                        ),
                        _summaryItem(
                          'Expense',
                          expense,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // =================================================
              // CASHFLOW
              // =================================================

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
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const CashflowChart(),
              ),

              const SizedBox(height: 24),

              // =================================================
              // RECENT TRANSACTIONS
              // =================================================

              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 12),

              if (transactions.isEmpty)
                const Text(
                  'Belum ada transaksi.',
                  style: TextStyle(
                    color: Colors.grey,
                  ),
                )
              else
                ...transactions.reversed
                    .take(5)
                    .map(
                      (transaction) {
                        return _transactionCard(
                          transaction,
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SUMMARY ITEM
  // ==========================================================

  Widget _summaryItem(
    String title,
    double amount,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Rp ${formatMoney(amount)}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // TRANSACTION CARD
  // ==========================================================

  Widget _transactionCard(
    Transaction transaction,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff111111),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              transaction.isIncome
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
              color: Colors.white,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${transaction.category} • '
                  '${transaction.payment}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Text(
            '${transaction.isIncome ? '+' : '-'}'
            'Rp ${formatMoney(transaction.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: transaction.isIncome
                  ? Colors.white
                  : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STATS PAGE
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

    final balance = income - expense;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Statistics',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _statCard(
              title: 'Total Income',
              amount: income,
              icon: Icons.trending_up,
            ),

            const SizedBox(height: 12),

            _statCard(
              title: 'Total Expense',
              amount: expense,
              icon: Icons.trending_down,
            ),

            const SizedBox(height: 12),

            _statCard(
              title: 'Net Balance',
              amount: balance,
              icon: Icons.account_balance_wallet,
            ),

            const SizedBox(height: 24),

            _categorySummary(
              income: income,
              expense: expense,
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // STAT CARD
  // ==========================================================

  Widget _statCard({
    required String title,
    required double amount,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff111111),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Rp ${formatMoney(amount)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CATEGORY SUMMARY
  // ==========================================================

  Widget _categorySummary({
    required double income,
    required double expense,
  }) {
    final Map<String, double> categories = {};

    for (final transaction in transactions) {
      if (!transaction.isIncome) {
        categories[transaction.category] =
            (categories[transaction.category] ?? 0) +
                transaction.amount;
      }
    }

    if (categories.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xff111111),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          'Belum ada data pengeluaran.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }

    final sortedCategories =
        categories.entries.toList()
          ..sort(
            (a, b) => b.value.compareTo(a.value),
          );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xff111111),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Expense by Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          ...sortedCategories.map(
            (entry) {
              final percentage =
                  expense > 0
                      ? entry.value / expense
                      : 0.0;

              return Padding(
                padding:
                    const EdgeInsets.only(
                  bottom: 14,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                          ),
                        ),
                        Text(
                          'Rp ${formatMoney(entry.value)}',
                          style:
                              const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        10,
                      ),
                      child: LinearProgressIndicator(
                        value: percentage,
                        minHeight: 5,
                        backgroundColor:
                            Colors.black,
                        valueColor:
                            const AlwaysStoppedAnimation<
                                Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE PAGE
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
        elevation: 0,
        title: const Text(
          'Profile',
        ),
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
                borderRadius:
                    BorderRadius.circular(22),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: Colors.black,
                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),

                  SizedBox(height: 14),

                  Text(
                    'Mr. Raditya',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    'RDTFINANCE',
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            _profileItem(
              icon: Icons.account_balance_wallet,
              title: 'Finance',
              subtitle:
                  'Personal finance tracking',
            ),

            const SizedBox(height: 10),

            _profileItem(
              icon: Icons.storage,
              title: 'Local Database',
              subtitle:
                  'Data tersimpan di perangkat',
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff111111),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
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