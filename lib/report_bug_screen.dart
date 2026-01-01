import 'package:flutter/material.dart';

class ReportBugScreen extends StatefulWidget {
  const ReportBugScreen({super.key});

  @override
  State<ReportBugScreen> createState() => _ReportBugScreenState();
}

class _ReportBugScreenState extends State<ReportBugScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Report a Bug",
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// INFO TEXT
            const Text(
              "Found something that's not working right? Let us know the details and we'll fix it as soon as possible.",
              style: TextStyle(
                color: Colors.grey,
                height: 1.4,
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 24),

            /// BUG TITLE
            _label("Bug Title"),
            _inputField(
              controller: titleController,
              hint: "e.g. App crashes when saving photo",
            ),

            const SizedBox(height: 20),

            /// DESCRIPTION
            _label("Description of the Issue"),
            _inputField(
              controller: descriptionController,
              hint:
              "Please describe what happened, steps to reproduce, and what you expected to happen...",
              maxLines: 6,
            ),

            const SizedBox(height: 24),

            /// ATTACHMENTS
            _label("Attachments (Optional)"),
            Row(
              children: [
                Expanded(
                  child: _attachmentCard(
                    icon: Icons.image_outlined,
                    color: Colors.blue,
                    title: "Attach Screenshot",
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _attachmentCard(
                    icon: Icons.videocam_outlined,
                    color: Colors.red,
                    title: "Record Screen",
                    onTap: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            /// DEVICE INFO
            _deviceInfo(),

            const SizedBox(height: 32),

            /// SUBMIT BUTTON
            _submitButton(),
          ],
        ),
      ),
    );
  }

  /// ---------------- WIDGETS ----------------

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
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

  Widget _attachmentCard({
    required IconData icon,
    required Color color,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            style: BorderStyle.solid,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _deviceInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "DEVICE INFO",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "iPhone 13 Pro • iOS 16.4",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.blue),
                SizedBox(width: 6),
                Text(
                  "Auto-attached",
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _submitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {
          // Submit bug logic here
        },
        icon: const Icon(Icons.send),
        label: const Text(
          "Submit Report",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
