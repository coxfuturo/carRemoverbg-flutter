import 'package:flutter/material.dart';

class HelpFaqScreen extends StatefulWidget {
  const HelpFaqScreen({super.key});

  @override
  State<HelpFaqScreen> createState() => _HelpFaqScreenState();
}

class _HelpFaqScreenState extends State<HelpFaqScreen> {
  String selectedFilter = "All";

  final List<String> filters = ["All", "Account", "Subscription", "Editing"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Help & FAQ",
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
            /// SEARCH
            _searchBox(),

            const SizedBox(height: 16),

            /// FILTER CHIPS
            _filterChips(),

            const SizedBox(height: 24),

            /// ACCOUNT
            _sectionHeader("ACCOUNT", Colors.blue),
            _faqTile("How do I reset my password?"),
            _faqTile("Can I change my email address?"),

            const SizedBox(height: 24),

            /// SUBSCRIPTION
            _sectionHeader("SUBSCRIPTION", Colors.orange),
            _faqTile("What is included in the Pro Plan?"),
            _faqTile("How do I cancel my subscription?"),

            const SizedBox(height: 24),

            /// EDITING
            _sectionHeader("EDITING", Colors.purple),
            _faqTile("How to remove the background?"),
            _faqTile("Can I add my own watermark?"),
            _faqTile("Does the app support RAW files?"),

            const SizedBox(height: 32),

            /// SUPPORT CARD
            _supportCard(),
          ],
        ),
      ),
    );
  }

  /// ---------------- WIDGETS ----------------

  Widget _searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const TextField(
        decoration: InputDecoration(
          icon: Icon(Icons.search),
          hintText: "Search for answers...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _filterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final bool isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) {
                setState(() => selectedFilter = filter);
              },
              selectedColor: Colors.blue,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.w500,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionHeader(String title, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _faqTile(String question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: const Icon(Icons.keyboard_arrow_down),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: const [
          Text(
            "This is a sample answer. Replace this text with the actual FAQ content from your backend or static data.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _supportCard() {
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
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade50,
            child: const Icon(Icons.support_agent, size: 30, color: Colors.blue),
          ),
          const SizedBox(height: 16),
          const Text(
            "Still need help?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            "Our team is available 24/7 to assist you.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Contact Support",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
