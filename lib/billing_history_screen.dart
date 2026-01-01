import 'package:flutter/material.dart';

class BillingHistoryScreen extends StatelessWidget {
  const BillingHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Billing History",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.help_outline, color: Colors.blue),
          ),
        ],
      ),

      /// ---------------- BODY ----------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryCard(),
            const SizedBox(height: 24),

            /// TRANSACTIONS HEADER
            Row(
              children: [
                const Text(
                  "Transactions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _filterChip(),
              ],
            ),
            const SizedBox(height: 16),

            /// TRANSACTIONS LIST
            _transactionTile(
              status: TransactionStatus.success,
              title: "Pro Plan Renewal",
              date: "Oct 28, 2023",
              amount: "\$14.99",
              action: "Invoice",
            ),
            _transactionTile(
              status: TransactionStatus.success,
              title: "Pro Plan Renewal",
              date: "Sep 28, 2023",
              amount: "\$14.99",
              action: "Invoice",
            ),
            _transactionTile(
              status: TransactionStatus.failed,
              title: "Payment Failed",
              date: "Aug 28, 2023",
              amount: "\$14.99",
              action: "Retry",
            ),
            _transactionTile(
              status: TransactionStatus.success,
              title: "Pro Plan Renewal",
              date: "Aug 29, 2023",
              amount: "\$14.99",
              action: "Invoice",
            ),
            _transactionTile(
              status: TransactionStatus.upgrade,
              title: "Upgrade to Pro",
              date: "Jul 28, 2023",
              amount: "\$14.99",
              action: "Invoice",
            ),

            const SizedBox(height: 32),

            /// FOOTER
            Center(
              child: Column(
                children: [
                  const Text(
                    "Questions about your bill?",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Contact Support",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),

      /// ---------------- BOTTOM NAV ----------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.photo), label: "Gallery"),
          BottomNavigationBarItem(icon: Icon(Icons.add_a_photo), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Saved"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Settings"),
        ],
      ),
    );
  }

  /// ---------------- SUMMARY CARD ----------------

  Widget _summaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Total Spent (YTD)",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          const Text(
            "\$179.88",
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Current Plan",
                        style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, color: Colors.blue, size: 16),
                        SizedBox(width: 4),
                        Text(
                          "Pro Annual",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("Next Billing",
                        style: TextStyle(color: Colors.grey)),
                    SizedBox(height: 4),
                    Text(
                      "Nov 28, 2023",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------------- TRANSACTION TILE ----------------

  Widget _transactionTile({
    required TransactionStatus status,
    required String title,
    required String date,
    required String amount,
    required String action,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _statusIcon(status),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: status == TransactionStatus.failed
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: status == TransactionStatus.failed
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              _actionChip(status, action),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusIcon(TransactionStatus status) {
    IconData icon;
    Color bg;
    Color color;

    switch (status) {
      case TransactionStatus.success:
        icon = Icons.check;
        bg = Colors.green.withOpacity(0.15);
        color = Colors.green;
        break;
      case TransactionStatus.failed:
        icon = Icons.close;
        bg = Colors.red.withOpacity(0.15);
        color = Colors.red;
        break;
      case TransactionStatus.upgrade:
        icon = Icons.arrow_upward;
        bg = Colors.blue.withOpacity(0.15);
        color = Colors.blue;
        break;
    }

    return CircleAvatar(
      radius: 18,
      backgroundColor: bg,
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _actionChip(TransactionStatus status, String label) {
    final bool isRetry = status == TransactionStatus.failed;

    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isRetry
              ? Colors.red.withOpacity(0.1)
              : Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isRetry ? Colors.red : Colors.blue,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _filterChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: const [
          Text(
            "All Time",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down, color: Colors.blue),
        ],
      ),
    );
  }
}

/// ---------------- ENUM ----------------

enum TransactionStatus { success, failed, upgrade }
