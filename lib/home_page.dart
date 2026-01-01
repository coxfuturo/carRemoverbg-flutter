import 'package:carbgremover/Routes.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<bool> _requestPermissions() async {
    final camera = await Permission.camera.request();
    final gallery = await Permission.photos.request();

    if (!camera.isGranted) {
      Fluttertoast.showToast(msg: "Camera permission denied");
      return false;
    }

    if (!gallery.isGranted) {
      Fluttertoast.showToast(msg: "Gallery permission denied");
      return false;
    }

    return true;
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
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),
            Image.asset("assets/images/logo.png", height: 80),
            const SizedBox(width: 5),
            const Text(
              "Snap Your Car",
              style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white, fontSize: 18),
            ),
          ],
        ),

      ),

      /// BODY
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            /// TITLE
            const Text(
              "My Cars",
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "3 sessions • 4 photos",
              style: TextStyle(color: Colors.white60),
            ),

            const SizedBox(height: 20),

            /// SEARCH BAR
            SizedBox(
              height: 46,
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search sessions...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),

                  // 🔹 OUTLINE BORDER
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF1E3A5F),
                      width: 1,
                    ),
                  ),

                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: Color(0xFF29B6F6),
                      width: 1.5,
                    ),
                  ),

                  filled: true,
                  fillColor: const Color(0xFF0E2235),

                  contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),


            const SizedBox(height: 16),

            /// LIST
            Expanded(
              child: ListView(
                children: const [
                  CarCard(
                    image: "assets/images/car1.jpg",
                    title: "BMW 8 Series",
                    date: "2025-10-15",
                    photos: 2,
                    status: "Done",
                    statusColor: Colors.green,
                  ),
                  CarCard(
                    image: "assets/images/car1.jpg",
                    title: "Audi RS6",
                    date: "2025-10-10",
                    photos: 1,
                    status: "Done",
                    statusColor: Colors.green,
                  ),
                  CarCard(
                    image: "assets/images/car1.jpg",
                    title: "Tesla Model S",
                    date: "2025-10-05",
                    photos: 1,
                    status: "Queue",
                    statusColor: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      /// FLOATING BUTTON
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 20, bottom: 10),
        child: FloatingActionButton(
          backgroundColor: const Color(0xFF29B6F6),
          onPressed: () {
            Navigator.pushNamed(context, Routes.cameraCaptureScreen);
          },
          shape: const CircleBorder(),
          child: const Icon(Icons.add,color: Colors.white,),
        ),
      ),

    );
  }
}

class CarCard extends StatelessWidget {

  final String? image;
  final String title;
  final String date;
  final int photos;
  final String status;
  final Color statusColor;

  const CarCard({
    super.key,
    required this.image,
    required this.title,
    required this.date,
    required this.photos,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2235),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          /// IMAGE
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF122B45),
              image: image != null
                  ? DecorationImage(
                      image: AssetImage(image!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: image == null
                ? const Icon(Icons.image, color: Colors.white38)
                : null,
          ),

          const SizedBox(width: 12),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),

                        // ✅ CORRECT BORDER
                        border: Border.all(
                          color: statusColor.withOpacity(0.35),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  "$date • $photos photos",
                  style: const TextStyle(color: Colors.white54),
                ),
                const SizedBox(height: 10),

                /// BUTTONS
                Row(
                  children: [
                    _actionButton(context,Icons.remove_red_eye, "View"),
                    const SizedBox(width: 10),
                    _actionButton(context,Icons.download, "Export"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(BuildContext context,IconData icon, String text) {
    return OutlinedButton.icon(
      onPressed: () {
        Navigator.pushNamed(context, Routes.carDetailScreen);
      },
      icon: Icon(icon, size: 16, color: const Color(0xFF29B6F6)),
      label: Text(text, style: const TextStyle(color: Color(0xFF29B6F6))),
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF29B6F6)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
