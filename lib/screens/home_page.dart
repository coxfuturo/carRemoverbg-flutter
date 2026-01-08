import 'package:carbgremover/screens/CarViewDetailScreen.dart';
import 'package:carbgremover/services/car_service.dart';
import 'package:carbgremover/services/service_image_download.dart';
import 'package:carbgremover/utils/Routes.dart';
import 'package:carbgremover/utils/app_utils.dart';
import 'package:carbgremover/utils/permissions.dart';
import 'package:carbgremover/widgets/home_car_card.dart';
import 'package:carbgremover/widgets/select_car_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = "";
  String selectedCar = "Select Car";

  @override
  void initState() {
    super.initState();
    requestCameraAndGalleryPermissions();
  }

  final List<String> carList = [
    "Select Car",
    "Honda City",
    "Hyundai Creta",
    "Maruti Swift",
    "Toyota Fortuner",
    "BMW X5",
    "Audi A6",
  ];

  Future<void> _showCarNameDialog() async {
    final selected = await showSelectCarDialog(
      context: context,
      carList: carList,
    );

    if (selected == null || !mounted) return;

    try {
      // 🔥 Create new car with AUTO ID
      final carId = await CarService.createNewCar(
        carName: selected,
      );

      if (!mounted) return;

      Navigator.pushNamed(
        context,
        Routes.cameraCaptureScreen,
        arguments: {
          "carId": carId,
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: "Failed to create car session");
    }
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 18,
              ),
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
            // const Text(
            //   "3 sessions • 4 photos",
            //   style: TextStyle(color: Colors.white60),
            // ),

            const SizedBox(height: 20),

            /// SEARCH BAR
            SizedBox(
              height: 46,
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search sessions...",
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
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
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
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
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseAuth.instance.currentUser == null
                    ? const Stream.empty()
                    : FirebaseFirestore.instance
                    .collection("users")
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .collection("cars")
                    .orderBy("createdAt", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No cars uploaded yet",
                        style: TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final allCars = snapshot.data!.docs;

                  // 🔥 SEARCH FILTER
                  final filteredCars = allCars.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final carName = (data["carName"] ?? "").toString().toLowerCase();
                    final status = (data["status"] ?? "").toString().toLowerCase();

                    return carName.contains(_searchQuery) ||
                        status.contains(_searchQuery);
                  }).toList();

                  // 🔥 STATS CALCULATION
                  final totalSessions = allCars.length;
                  final totalPhotos = allCars.fold<int>(
                    0,
                        (sum, doc) =>
                    sum + ((doc["totalImages"] ?? 0) as int),
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// 🔥 DYNAMIC STATS
                      Text(
                        "$totalSessions sessions • $totalPhotos photos",
                        style: const TextStyle(color: Colors.white60),
                      ),
                      const SizedBox(height: 12),

                      /// 🔥 LIST
                      Expanded(
                        child: filteredCars.isEmpty
                            ? const Center(
                          child: Text(
                            "No matching cars found",
                            style: TextStyle(color: Colors.white70),
                          ),
                        )
                            : ListView.builder(
                          itemCount: filteredCars.length,
                          itemBuilder: (context, index) {
                            final doc = filteredCars[index];
                            final data =
                            doc.data() as Map<String, dynamic>;

                            return HomeCarCard(
                              carId: doc.id,
                              image: data["coverImage"],
                              title: data["carName"],
                              date: AppUtils.formatDate(data["updatedAt"]),
                              photos: data["totalImages"],
                              status: data["status"],
                              statusColor: data["status"] == "Done"
                                  ? Colors.green
                                  : Colors.orange,

                              onView: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => CarDetailScreen(
                                      carId: doc.id,
                                      heroTag: "car-image-${doc.id}",
                                    ),
                                  ),
                                );
                              },

                              onExport: () {
                                ImageExportService.showExportOptions(context,doc.id);
                              },
                            );

                          },
                        ),
                      ),
                    ],
                  );
                },
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
            // final user = FirebaseAuth.instance.currentUser;

            Navigator.pushNamed(context, Routes.cameraCaptureScreen,);

            // if (user != null) {
            //   _showCarNameDialog();
            //   // ✅ User logged in → go to camera
            //
            // } else {
            //   // ❌ Not logged in → go to login
            //   Navigator.pushNamed(context, Routes.login);
            // }
          },
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}
