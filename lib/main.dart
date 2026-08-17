import 'package:flutter/material.dart';

void main() {
  runApp(const RDTFinance());
}

class RDTFinance extends StatelessWidget {
  const RDTFinance({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "RDTFINANCE",
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RDTFINANCE"),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          "Welcome to RDTFINANCE",
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}