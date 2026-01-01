import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'Routes.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool watermark = true;
  bool darkMode = true;
  String background = "Studio White";

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = true;

  Future<void> _loadUserProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) return;

      // 🔹 Email from Auth
      _emailController.text = user.email ?? "";

      // 🔹 Fetch from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? "";
      }
    } catch (e) {
      debugPrint("Profile load error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _logoutUser() async {
    try {
      await FirebaseAuth.instance.signOut();

      Fluttertoast.showToast(msg: "Logged out successfully");

      if (!mounted) return;

      /// Clear navigation stack & go to login
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.login,
        (route) => false,
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Logout failed");
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0E2235),
        title: const Text("Log out?", style: TextStyle(color: Colors.white)),
        content: const Text(
          "Are you sure you want to log out?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _logoutUser();
            },
            child: const Text("Log Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07121E),

      /// APP BAR
      appBar: AppBar(
        backgroundColor: const Color(0xFF07121E),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text("Settings",style: TextStyle(color: Colors.white)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// PROFILE CARD
            _card(
              child: Column(
                children: [
                  /// LOGO + APP NAME (CENTERED)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset("assets/images/logo.png", height: 70),
                      const SizedBox(width: 8),
                      const Text(
                        "Snap Your Car",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  /// USER NAME + EMAIL (CENTERED IN CARD)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children:  [
                      Text(
                        _nameController.text.isEmpty
                            ? "Marco Demo"
                            : _nameController.text,
                        style: const TextStyle(color: Colors.white),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _emailController.text.isEmpty
                            ? "demo@snapyourcar.app"
                            : _emailController.text,
                        style: const TextStyle(color: Colors.white38),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  /// EDIT PROFILE BUTTON
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text("Edit Profile"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF29B6F6),
                      side: const BorderSide(color: Color(0xFF29B6F6)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// PREFERENCES
            const Text("Preferences", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),

            _card(
              child: Column(
                children: [
                  settingsDropdown(
                    label: "Default Background",
                    value: background,
                    items: const ["Studio White", "Dark Studio", "Outdoor"],
                    onChanged: (val) {
                      setState(() {
                        background = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  _switchTile(
                    title: "Watermark by Default",
                    value: watermark,
                    onChanged: (val) {
                      setState(() => watermark = val);
                    },
                  ),
                  _switchTile(
                    title: "Dark Mode",
                    value: darkMode,
                    onChanged: (val) {
                      setState(() => darkMode = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// SUPPORT
            const Text("Support", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),

            _card(
              child: Column(
                children:  [
                  ListTile(
                    leading: Icon(Icons.help_outline, color: Colors.white70),
                    onTap: (){
                      Navigator.pushNamed(context, Routes.helpFaqScreen);
                    },
                    title: Text("FAQ", style: TextStyle(color: Colors.white)),
                  ),
                  Divider(color: Colors.white24),
                  ListTile(
                    leading: Icon(Icons.mail_outline, color: Colors.white70),
                    onTap: (){
                      Navigator.pushNamed(context, Routes.contactSupportScreen);
                    },
                    title: Text(
                      "Contact Support",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// LOG OUT
            _card(
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Log Out",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  _showLogoutConfirmation();
                },
              ),
            ),

            const SizedBox(height: 32),

            /// FOOTER
            const Center(
              child: Column(
                children: [
                  Text(
                    "Snap Your Car v1.0.0",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "© 2025 • Made with ❤️ in India",
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// COMMON CARD
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2235),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  /// SWITCH TILE
  Widget _switchTile({
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(color: Colors.white)),
      value: value,
      inactiveTrackColor: const Color(0xFF1E3A5F),
      inactiveThumbColor: const Color(0xFF29B6F6),
      activeTrackColor: const Color(0xFF29B6F6),
      activeColor: const Color(0xFF1E3A5F),
      onChanged: onChanged,
    );
  }

  Widget settingsDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),

        /// DROPDOWN CONTAINER
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF0E2235),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF1E3A5F), width: 1),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF0E2235),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white54,
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
