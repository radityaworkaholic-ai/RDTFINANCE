import 'package:flutter/material.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("AI Chat"),
        backgroundColor: Colors.black,
      ),
      body: const Center(
        child: Text(
          "Ketik: makan 45k BCA",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}