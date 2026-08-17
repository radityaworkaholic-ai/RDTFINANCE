import 'screens/chat_page.dart';
import 'package:flutter/material.dart';
import 'widgets/cashflow_chart.dart';

void main() => runApp(const RDTFinance());

class RDTFinance extends StatelessWidget {
  const RDTFinance({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RDTFINANCE',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Roboto',
      ),
      home: const ChatPage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("RDTFINANCE",
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xff111111),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Balance",
                        style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 8),
                    Text("Rp 8.450.000",
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 18),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text("Income",
                                style: TextStyle(
                                    color: Colors.grey)),
                            Text("Rp12.800.000")
                          ],
                        ),
                        Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.end,
                          children: [
                            Text("Expense",
                                style: TextStyle(
                                    color: Colors.grey)),
                            Text("Rp4.350.000")
                          ],
                        ),
                      ],
                    )
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text("Cashflow",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),

              const SizedBox(height: 12),

              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xff111111),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Text(
                    "const CashflowChart()",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}