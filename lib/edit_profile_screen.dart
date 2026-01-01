import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController nameCtrl =
  TextEditingController(text: "Marco Demo");
  final TextEditingController emailCtrl =
  TextEditingController(text: "demo@snapyourcar.app");
  final TextEditingController usernameCtrl =
  TextEditingController(text: "marcodemo_99");
  final TextEditingController bioCtrl = TextEditingController(
    text:
    "Passionate about vintage JDM cars.\nCurrently restoring a '94 Skyline.",
  );

  static const int bioMaxLength = 150;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      /// ---------------- APP BAR ----------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),

      /// ---------------- BODY ----------------
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _profilePhoto(),
            const SizedBox(height: 32),

            _label("Full Name"),
            _inputField(
              controller: nameCtrl,
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 20),

            _label("Email Address"),
            _inputField(
              controller: emailCtrl,
              icon: Icons.email_outlined,
              suffix: const Icon(Icons.verified, color: Colors.green),
              enabled: false,
            ),
            const SizedBox(height: 6),
            const Text(
              "Contact support to change your email.",
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 24),

            _label("Username"),
            _inputField(
              controller: usernameCtrl,
              icon: Icons.alternate_email,
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _label("Password"),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    "Change",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            _inputField(
              controller: TextEditingController(text: "••••••••"),
              icon: Icons.lock_outline,
              enabled: false,
            ),

            const SizedBox(height: 24),

            _label("Bio"),
            _bioField(),

            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "${bioCtrl.text.length}/$bioMaxLength",
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),

      /// ---------------- SAVE BUTTON ----------------
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              // Save profile changes
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightBlue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              "Save Changes",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ---------------- WIDGETS ----------------

  Widget _profilePhoto() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 3),
                  image: const DecorationImage(
                    image: AssetImage("assets/images/car1.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.lightBlue,
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {

            },
            child: const Text(
              "Change Profile Photo",
              style: TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
    required IconData icon,
    Widget? suffix,
    bool enabled = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        decoration: InputDecoration(
          icon: Icon(icon, color: Colors.grey),
          suffixIcon: suffix,
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _bioField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: bioCtrl,
        maxLength: bioMaxLength,
        maxLines: 4,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: "",
        ),
      ),
    );
  }
}
