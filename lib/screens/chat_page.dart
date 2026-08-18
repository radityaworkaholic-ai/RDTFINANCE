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
              "Hi Mr.Raditya 💸\nKetik transaksi seperti:\nGlenfiddich 1.7000k BCA",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
      Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tulis transaksi ya puki...",
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
              onPressed: () {},
              icon: const Icon(Icons.send, color: Colors.black),
            ),
          )
        ],
      )
    ],
  ),
),