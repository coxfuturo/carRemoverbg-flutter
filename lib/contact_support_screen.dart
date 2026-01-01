import 'package:flutter/material.dart';

class ContactSupportScreen extends StatefulWidget {
  const ContactSupportScreen({super.key});

  @override
  State<ContactSupportScreen> createState() => _ContactSupportScreenState();
}

class _ContactSupportScreenState extends State<ContactSupportScreen> {
  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Contact Support",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      /// ---------------- BODY ----------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),

            /// HEADER
            const Text(
              "How can we help?",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "We usually respond within a few hours.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 24),

            /// EMAIL / CALL CARDS
            Row(
              children: [
                Expanded(
                  child: _contactCard(
                    icon: Icons.email_outlined,
                    iconColor: Colors.blue,
                    title: "Email Us",
                    subtitle: "support@snapyourcar.app",
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _contactCard(
                    icon: Icons.call_outlined,
                    iconColor: Colors.green,
                    title: "Call Us",
                    subtitle: "+1 (800) 123-4567",
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// SEND MESSAGE CARD
            _messageCard(),

            const SizedBox(height: 24),

            /// FOOTER LINK
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Need immediate answers? ",
                  style: TextStyle(color: Colors.grey),
                ),
                GestureDetector(
                  onTap: () {
                    // Navigate to FAQ
                  },
                  child: const Text(
                    "Check our FAQ",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
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

  /// ---------------- WIDGETS ----------------

  Widget _contactCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: _cardDecoration(),
        child: Column(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: iconColor.withOpacity(0.15),
              child: Icon(icon, color: iconColor, size: 26),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _messageCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TITLE
          Row(
            children: const [
              Icon(Icons.chat_bubble_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text(
                "Send a message",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// SUBJECT
          _label("SUBJECT"),
          _inputField(
            controller: subjectController,
            hint: "What's this about?",
          ),

          const SizedBox(height: 20),

          /// MESSAGE
          _label("MESSAGE"),
          _inputField(
            controller: messageController,
            hint: "Describe your issue or feedback...",
            maxLines: 5,
          ),

          const SizedBox(height: 24),

          /// SEND BUTTON
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: () {
                // Send message logic
              },
              icon: const Icon(Icons.send),
              label: const Text(
                "Send Message",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: Colors.grey,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          border: InputBorder.none,
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
