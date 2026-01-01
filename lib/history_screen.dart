import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),

      /// ---------------- APP BAR ----------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF7F8FC),
        
        title: const Text(
          "History",
          style: TextStyle(
            color: Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Clear all history
            },
            child: const Text(
              "Clear All",
              style: TextStyle(
                color: Color(0xFF7C3AED),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),

      /// ---------------- BODY ----------------
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [

          /// TODAY
          const _SectionTitle("TODAY"),

          _HistoryItem(
            image: 'assets/images/car1.jpg',
            title: "Chevrolet Corvette",
            time: "2:30 PM",
            action: "Background Removed",
          ),

          _HistoryItem(
            image: 'assets/images/car1.jpg',
            title: "Ford Mustang 1969",
            time: "10:15 AM",
            action: "Color Corrected",
          ),

          const SizedBox(height: 24),

          /// YESTERDAY
          const _SectionTitle("YESTERDAY"),

          _HistoryItem(
            image: 'assets/images/car1.jpg',
            title: "Ferrari 488 Spider",
            time: "4:45 PM",
            action: "Cropped",
          ),

          _HistoryItem(
            image: 'assets/images/car1.jpg',
            title: "Mercedes-Benz C-Class",
            time: "11:20 AM",
            action: "AI Enhanced",
            showAi: true,
          ),

          const SizedBox(height: 40),

          /// FOOTER
          Column(
            children: const [
              Icon(Icons.history, color: Colors.grey),
              SizedBox(height: 10),
              Text(
                "No more history to show",
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// ---------------- SECTION TITLE ----------------
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

/// ---------------- HISTORY ITEM ----------------
class _HistoryItem extends StatelessWidget {
  final String image;
  final String title;
  final String time;
  final String action;
  final bool showAi;

  const _HistoryItem({
    required this.image,
    required this.title,
    required this.time,
    required this.action,
    this.showAi = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        children: [

          /// IMAGE
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.asset(
                  image,
                  height: 70,
                  width: 70,
                  fit: BoxFit.cover,
                ),
              ),
              if (showAi)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "AI",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          /// DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "$time • $action",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: const [
                    Text(
                      "Re-edit",
                      style: TextStyle(
                        color: Color(0xFF3DB3F7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      "Delete",
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// MENU
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }
}
