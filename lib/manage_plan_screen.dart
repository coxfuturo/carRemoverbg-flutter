import 'package:flutter/material.dart';

class ManagePlanScreen extends StatelessWidget {
  const ManagePlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Manage Plan",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _currentPlanCard(),
            const SizedBox(height: 24),

            const Text(
              "Your Plan Benefits",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _benefitsCard(),
            const SizedBox(height: 20),

            _annualUpgradeCard(),
            const SizedBox(height: 20),

            _changePlanTile(),
            const SizedBox(height: 12),

            _cancelSubscriptionButton(),
            const SizedBox(height: 24),

            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Need help with your plan? ",
                    style: TextStyle(color: Colors.grey),
                  ),
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
          ],
        ),
      ),
    );
  }

  /// ---------------- CURRENT PLAN ----------------

  Widget _currentPlanCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F172A),
            Color(0xFF1E293B),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "CURRENT PLAN",
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const Spacer(),
              CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.15),
                child: const Icon(Icons.star, color: Colors.lightBlueAccent),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            "Pro Plan",
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "\$14.99",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 6),
              Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  "/ month",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "Renews on Nov 24, 2023",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.circle, size: 10, color: Colors.greenAccent),
              const SizedBox(width: 8),
              const Text(
                "Subscription Active",
                style: TextStyle(color: Colors.white70),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  "Billing History",
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ---------------- BENEFITS ----------------

  Widget _benefitsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _whiteCard(),
      child: Column(
        children: const [
          _BenefitItem(
            title: "Unlimited AI Enhancements",
            subtitle: "Process as many car photos as you need",
          ),
          _BenefitItem(
            title: "4K Ultra HD Export",
            subtitle: "Crystal clear quality for listings",
          ),
          _BenefitItem(
            title: "Custom Backgrounds",
            subtitle: "Access to all premium studio backgrounds",
          ),
          _BenefitItem(
            title: "No Watermark",
            subtitle: "Clean branding on all your photos",
          ),
        ],
      ),
    );
  }

  /// ---------------- ANNUAL UPGRADE ----------------

  Widget _annualUpgradeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F9FF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.lightBlueAccent.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Colors.lightBlueAccent.withOpacity(0.2),
            child: const Icon(Icons.savings, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Save 20% on Annual Plan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Switch to annual billing and pay only \$143.99/year.",
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: null,
            style: ButtonStyle(
              backgroundColor:
              MaterialStatePropertyAll(Colors.lightBlueAccent),
            ),
            child: const Text("Upgrade"),
          ),
        ],
      ),
    );
  }

  /// ---------------- ACTIONS ----------------

  Widget _changePlanTile() {
    return Container(
      decoration: _whiteCard(),
      child: ListTile(
        leading: const Icon(Icons.swap_horiz),
        title: const Text(
          "Change Plan",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }

  Widget _cancelSubscriptionButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: ListTile(
        leading: const Icon(Icons.cancel, color: Colors.red),
        title: const Text(
          "Cancel Subscription",
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: () {},
      ),
    );
  }

  BoxDecoration _whiteCard() {
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

/// ---------------- BENEFIT ITEM ----------------

class _BenefitItem extends StatelessWidget {
  final String title;
  final String subtitle;

  const _BenefitItem({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.green.withOpacity(0.15),
            child: const Icon(Icons.check, color: Colors.green, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
