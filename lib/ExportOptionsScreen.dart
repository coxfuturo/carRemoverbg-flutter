import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ExportOptionsScreen extends StatefulWidget {
  final File imageFile; // ✅ REQUIRED

  const ExportOptionsScreen({
    super.key,
    required this.imageFile,
  });

  @override
  State<ExportOptionsScreen> createState() => _ExportOptionsScreenState();
}

class _ExportOptionsScreenState extends State<ExportOptionsScreen> {
  bool removeBg = false;
  int selectedFrame = 0;
  String format = "PNG";

  Uint8List? processedImage;
  bool isProcessing = false;

  final List<String> frameImages = [
    'assets/images/frame1.jpg',
    'assets/images/frame1.jpg',
    'assets/images/frame2.jpg',
    'assets/images/frame3.jpg',
  ];

  // ---------------- BACKGROUND REMOVE API ----------------
  Future<Uint8List> removeBackgroundApi(File imageFile) async {
    final uri = Uri.parse('https://api.remove.bg/v1.0/removebg');

    final request = http.MultipartRequest('POST', uri)
      ..headers['X-Api-Key'] = '4JCWqBYf2v2TuxW6LTu9LUXh'
      ..files.add(
        await http.MultipartFile.fromPath('image_file', imageFile.path),
      )
      ..fields['size'] = 'auto';

    final response = await request.send();

    if (response.statusCode == 200) {
      return await response.stream.toBytes();
    } else {
      throw Exception('Background removal failed');
    }
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: const Text(
          "Export Options",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- IMAGE PREVIEW ----------------
            Stack(
              children: [
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    image: DecorationImage(
                      image: processedImage != null
                          ? MemoryImage(processedImage!)
                          : FileImage(widget.imageFile) as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                if (isProcessing)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),

            // Stack(
            //     children: [
            //       // -------- BACKGROUND IMAGE --------
            //       Container(
            //         height: 220,
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(24),
            //           image: DecorationImage(
            //             image: FileImage(widget.imageFile),
            //             fit: BoxFit.cover,
            //           ),
            //         ),
            //         child: BackdropFilter(
            //           filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            //           child: Container(
            //             color: Colors.black.withOpacity(0.2),
            //           ),
            //         ),
            //       ),
            //
            //       // -------- FOREGROUND (CUTOUT IMAGE) --------
            //       if (processedImage != null)
            //         Positioned.fill(
            //           child: Image.memory(
            //             processedImage!,
            //             fit: BoxFit.contain,
            //           ),
            //         ),
            //     ]),

            const SizedBox(height: 24),

            // ---------------- REMOVE BG ----------------
            _tile(
              icon: Icons.auto_fix_high,
              title: "Remove Background",
              subtitle: "AI powered cutout",
              trailing: Switch(
                value: removeBg,
                activeColor: Colors.deepPurple,
                onChanged: (value) async {
                  setState(() => removeBg = value);

                  if (value) {
                    setState(() => isProcessing = true);
                    try {
                      processedImage =
                      await removeBackgroundApi(widget.imageFile);
                    } catch (e) {
                      debugPrint("BG remove error: $e");
                    }
                    setState(() => isProcessing = false);
                  } else {
                    setState(() => processedImage = null);
                  }
                },
              ),
            ),

            const SizedBox(height: 24),

            // ---------------- FRAMES ----------------
            _sectionHeader("Add Frame"),
            const SizedBox(height: 12),

            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: frameImages.length,
                itemBuilder: (context, index) {
                  final selected = selectedFrame == index;

                  return GestureDetector(
                    onTap: () => setState(() => selectedFrame = index),
                    child: Container(
                      width: 70,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? Colors.deepPurple
                              : Colors.transparent,
                          width: 2,
                        ),
                        color: Colors.white,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          frameImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // ---------------- FILE FORMAT ----------------
            const Text(
              "File Format",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),

            Row(
              children: ["PNG", "JPG", "WEBP"].map((f) {
                final selected = format == f;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => format = f),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        color:
                        selected ? Colors.deepPurple : Colors.white,
                      ),
                      child: Center(
                        child: Text(
                          f,
                          style: TextStyle(
                            color:
                            selected ? Colors.white : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),

      // ---------------- ACTION BUTTONS ----------------
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            _actionButton(
              icon: Icons.share,
              label: "Share",
              filled: false,
            ),
            const SizedBox(width: 12),
            _actionButton(
              icon: Icons.download,
              label: "Download Image",
              filled: true,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- HELPERS ----------------
  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurple.shade50,
            child: Icon(icon, color: Colors.deepPurple),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style:
                    const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle,
                    style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required bool filled,
  }) {
    return Expanded(
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: filled ? Colors.deepPurple : Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: filled ? Colors.white : Colors.black),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: filled ? Colors.white : Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
