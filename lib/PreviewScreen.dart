import 'dart:io';
import 'dart:ui' as ui;

import 'package:carbgremover/CarImage.dart';
import 'package:carbgremover/RemoveBgService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PreviewScreen extends StatefulWidget {
  final List<CarImage> images;

  PreviewScreen({super.key, required this.images});

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class BackgroundItem {
  final String id;
  final String asset;

  BackgroundItem({required this.id, required this.asset});
}

class _PreviewScreenState extends State<PreviewScreen> {
  late List<CarImage> carImages;
  int selectedIndex = 0;
  bool isProcessing = false;
  bool _isLoading = false;
  bool isUploading = false;
  String selectedCar = "Select Car";
  final TextEditingController _carNameController = TextEditingController();

  final List<BackgroundItem> backgrounds = [
    BackgroundItem(id: "transparent", asset: "assets/images/frame1.jpg"),
    BackgroundItem(id: "studio_white", asset: "assets/images/frame2.jpg"),
    BackgroundItem(id: "dark_studio", asset: "assets/images/frame3.jpg"),
    BackgroundItem(id: "outdoor", asset: "assets/images/frame1.jpg"),
  ];

  final List<String> carNames = [
    "Select Car",
    "Honda City",
    "Hyundai Creta",
    "Maruti Swift",
    "Toyota Fortuner",
    "BMW X5",
    "Audi A6",
  ];

  @override
  void initState() {
    super.initState();
    carImages = widget.images;
  }

  @override
  void dispose() {
    _carNameController.dispose();
    super.dispose();
  }

  Future<Uint8List> applyBackground({
    required Uint8List carPng,
    required BackgroundItem background,
  }) async {
    if (background.id == "transparent") {
      return carPng;
    }

    try {
      // Load background
      final bgData = await rootBundle.load(background.asset);
      final bgCodec = await ui.instantiateImageCodec(
        bgData.buffer.asUint8List(),
      );
      final bgFrame = await bgCodec.getNextFrame();
      final bgImage = bgFrame.image;

      // Load car PNG
      final carCodec = await ui.instantiateImageCodec(carPng);
      final carFrame = await carCodec.getNextFrame();
      final carImage = carFrame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      final bgSize = Size(bgImage.width.toDouble(), bgImage.height.toDouble());
      final carSize = Size(
        carImage.width.toDouble(),
        carImage.height.toDouble(),
      );

      // Draw background
      canvas.drawImage(bgImage, Offset.zero, Paint());

      // Preserve aspect ratio
      final fitted = applyBoxFit(BoxFit.contain, carSize, bgSize);

      final dx = (bgSize.width - fitted.destination.width) / 2;
      final dy = (bgSize.height - fitted.destination.height) / 2;

      // Draw car centered
      canvas.drawImageRect(
        carImage,
        Rect.fromLTWH(0, 0, carSize.width, carSize.height),
        Rect.fromLTWH(
          dx,
          dy,
          fitted.destination.width,
          fitted.destination.height,
        ),
        Paint(),
      );

      final picture = recorder.endRecording();
      final finalImage = await picture.toImage(
        bgSize.width.toInt(),
        bgSize.height.toInt(),
      );

      final byteData = await finalImage.toByteData(
        format: ui.ImageByteFormat.png,
      );

      // 🔥 Dispose GPU images
      bgImage.dispose();
      carImage.dispose();
      finalImage.dispose();

      return byteData!.buffer.asUint8List();
    } catch (e) {
      debugPrint("applyBackground error: $e");
      return carPng;
    }
  }

  BackgroundItem? getBackgroundById(String id) {
    try {
      return backgrounds.firstWhere((bg) => bg.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> setBgSingle(BackgroundItem bg) async {
    final img = carImages[selectedIndex];

    if (img.bgRemoved == null) {
      Fluttertoast.showToast(msg: "Remove background first");
      return;
    }

    setState(() => isProcessing = true);

    final result = await applyBackground(
      carPng: img.bgRemoved!,
      background: bg,
    );

    setState(() {
      img.finalImage = result;
      img.background = bg.id;
      isProcessing = false;
    });
  }

  Widget animatedPreview(CarImage img) {
    final Uint8List? imageToShow = img.finalImage ?? img.bgRemoved;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.96, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: imageToShow != null
          ? Image.memory(
              imageToShow,
              key: ValueKey("${img.background}_${imageToShow.length}"),
              fit: BoxFit.contain,
            )
          : Image.file(
              File(img.original.path),
              key: const ValueKey("original"),
              fit: BoxFit.contain,
            ),
    );
  }

  late FirebaseApp storageApp;

  Future<void> initSecondFirebase() async {
    try {
      storageApp = Firebase.app('careavatar');
    } catch (e) {
      storageApp = await Firebase.initializeApp(
        name: 'careavatar',
        options: const FirebaseOptions(
          apiKey: "AIzaSyCqtXZ1yOPfhpFckf3t84w4mGGiBN93NGE",
          appId: "1:951573303887:android:b7400c6009920376d1903a",
          messagingSenderId: "951573303887",
          projectId: "careavatar-2e6bd",
          storageBucket: "careavatar-2e6bd.firebasestorage.app",
        ),
      );
    }
  }

  Future<void> uploadAllImagesToFirebase() async {
    if (selectedCar == "Select Car") {
      Fluttertoast.showToast(msg: "Please select car name 🚗");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Fluttertoast.showToast(msg: "User not logged in");
      return;
    }

    try {
      setState(() => _isLoading = true);

      // ✅ SECOND FIREBASE STORAGE
      final FirebaseStorage storage =
      FirebaseStorage.instanceFor(app: storageApp);

      // ✅ MAIN FIREBASE FIRESTORE
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      final String batchId = DateTime.now().millisecondsSinceEpoch.toString();

      for (int i = 0; i < carImages.length; i++) {
        final img = carImages[i];

        final Uint8List bytes =
            img.finalImage ??
                img.bgRemoved ??
                await img.original.readAsBytes();

        final String fileName =
            "${selectedCar.replaceAll(' ', '_')}_${i + 1}.png";

        final ref = storage
            .ref()
            .child("users")
            .child(user.uid)
            .child("cars")
            .child(selectedCar)
            .child(batchId)
            .child(fileName);

        final snapshot = await ref.putData(
          bytes,
          SettableMetadata(contentType: "image/png"),
        );

        final String url = await snapshot.ref.getDownloadURL();

        await firestore
            .collection("users")
            .doc(user.uid)
            .collection("cars")
            .doc(selectedCar)
            .collection("images")
            .add({
          "url": url,
          "carName": selectedCar,
          "background": img.background,
          "batchId": batchId,
          "index": i,
          "storageProject": "careavatar-2e6bd",
          "createdAt": FieldValue.serverTimestamp(),
        });
      }

      Fluttertoast.showToast(msg: "Images uploaded successfully ✅");
    } catch (e) {
      debugPrint("Upload error: $e");
      Fluttertoast.showToast(msg: "Upload failed ❌");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  final List<String> carList = [
    "Honda City",
    "Hyundai Creta",
    "Maruti Swift",
    "Tata Nexon",
    "Other",
  ];


  Future<void> _showCarNameDialog() async {

    String tempSelectedCar = carList.first;
    final TextEditingController customCarController =
    TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0E2235),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),

              title: const Text(
                "Select Car",
                style: TextStyle(color: Colors.white),
              ),

              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF07121E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: tempSelectedCar,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF07121E),
                        iconEnabledColor: Colors.white,
                        style: const TextStyle(color: Colors.white),
                        items: carList
                            .map(
                              (car) => DropdownMenuItem<String>(
                            value: car,
                            child: Text(car),
                          ),
                        )
                            .toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            tempSelectedCar = value!;
                          });
                        },
                      ),
                    ),
                  ),

                  if (tempSelectedCar == "Other") ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: customCarController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Enter car name",
                        hintStyle:
                        const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF07121E),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ]
                ],
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF29B6F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final finalCarName = tempSelectedCar == "Other"
                        ? customCarController.text.trim()
                        : tempSelectedCar;

                    if (finalCarName.isEmpty) {
                      Fluttertoast.showToast(
                          msg: "Please enter car name");
                      return;
                    }

                    setState(() {
                      selectedCar = finalCarName;
                    });

                    Navigator.pop(context);
                    uploadAllImagesToFirebase();
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  Future<void> _showCarNameDialog1() async {
    _carNameController.text = selectedCar == "Select Car" ? "" : selectedCar;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0E2235),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),

          title: const Text(
            "Enter Car Name",
            style: TextStyle(color: Colors.white),
          ),

          content: TextField(
            controller: _carNameController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "e.g. Honda City",
              hintStyle: const TextStyle(color: Colors.white38),
              filled: true,
              fillColor: const Color(0xFF07121E),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.white54),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF29B6F6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                final name = _carNameController.text.trim();
                if (name.isEmpty) {
                  Fluttertoast.showToast(msg: "Please enter car name");

                  return;
                }

                setState(() {
                  selectedCar = name;
                });

                Navigator.pop(context);
                uploadAllImagesToFirebase();
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }


  // Future<void> uploadAllImagesToFirebase() async {
  //   if (selectedCar == "Select Car") {
  //     Fluttertoast.showToast(msg: "Please select car name 🚗");
  //     return;
  //   }
  //
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) {
  //     Fluttertoast.showToast(msg: "User not logged in");
  //     return;
  //   }
  //
  //   try {
  //     setState(() => _isLoading = true);
  //
  //     final storage = FirebaseStorage.instance;
  //     final firestore = FirebaseFirestore.instance;
  //
  //     final String batchId = DateTime.now().millisecondsSinceEpoch.toString();
  //
  //     for (int i = 0; i < carImages.length; i++) {
  //       final img = carImages[i];
  //       final Uint8List bytes =
  //           img.finalImage ?? img.bgRemoved ?? await img.original.readAsBytes();
  //
  //       final String fileName =
  //           "${selectedCar.replaceAll(' ', '_')}_${i + 1}.png";
  //
  //       final ref = storage
  //           .ref()
  //           .child("users")
  //           .child(user.uid)
  //           .child("cars")
  //           .child(selectedCar)
  //           .child(batchId)
  //           .child(fileName);
  //
  //       final snapshot = await ref.putData(
  //         bytes,
  //         SettableMetadata(contentType: "image/png"),
  //       );
  //
  //       final url = await snapshot.ref.getDownloadURL();
  //
  //       await firestore
  //           .collection("users")
  //           .doc(user.uid)
  //           .collection("cars")
  //           .doc(selectedCar)
  //           .collection("images")
  //           .add({
  //             "url": url,
  //             "carName": selectedCar,
  //             "background": img.background,
  //             "batchId": batchId,
  //             "index": i,
  //             "createdAt": FieldValue.serverTimestamp(),
  //           });
  //     }
  //
  //     Fluttertoast.showToast(msg: "Images saved successfully ✅");
  //   } catch (e) {
  //     Fluttertoast.showToast(msg: "Upload failed ❌");
  //     debugPrint("Upload error: $e");
  //   } finally {
  //     if (mounted) {
  //       setState(() => _isLoading = false);
  //     }
  //   }
  // }

  // ---------------- PREVIEW IMAGE ----------------
  Widget _previewImage() {
    final img = carImages[selectedIndex];

    if (img.bgRemoved != null) {
      return Image.memory(img.bgRemoved!, fit: BoxFit.contain);
    }

    return Image.file(File(img.original.path), fit: BoxFit.contain);
  }

  // ---------------- REMOVE BG ----------------
  Future<void> removeBgSingle() async {
    setState(() => isProcessing = true);

    final bytes = await RemoveBgService.removeBackground(
      File(carImages[selectedIndex].original.path),
    );

    setState(() {
      carImages[selectedIndex].bgRemoved = bytes;
      isProcessing = false;
    });
  }

  Future<void> removeBgAll() async {
    setState(() => isProcessing = true);

    for (final img in carImages) {
      img.bgRemoved ??= await RemoveBgService.removeBackground(
          File(img.original.path),
        );
    }

    setState(() => isProcessing = false);
  }

  // ---------------- BACKGROUND ----------------
  // Future<void> setBgAll(String bgId) async {
  //   final bg = backgrounds.firstWhere((b) => b.id == bgId);
  //
  //   setState(() => isProcessing = true);
  //
  //   for (final img in carImages) {
  //     if (img.bgRemoved != null) {
  //       img.finalImage = await applyBackground(
  //         carPng: img.bgRemoved!,
  //         background: bg,
  //       );
  //       img.background = bg.id;
  //     }
  //   }
  //
  //   setState(() => isProcessing = false);
  // }

  Future<void> setBgAll(String bgId) async {
    final bg = backgrounds.firstWhere((b) => b.id == bgId);

    setState(() => isProcessing = true);

    try {
      await Future.wait(
        carImages.map((img) async {
          if (img.bgRemoved != null) {
            img.finalImage = await applyBackground(
              carPng: img.bgRemoved!,
              background: bg,
            );
            img.background = bg.id;
          }
        }),
      );
    } catch (e) {
      debugPrint("❌ Set BG All error: $e");
    } finally {
      setState(() => isProcessing = false);
    }
  }

  Widget carDropdown() {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.symmetric(horizontal: 16),

      decoration: BoxDecoration(
        color: const Color(0xFF0E2235),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),

      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedCar,
          isExpanded: true,
          dropdownColor: const Color(0xFF0E2235),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          style: const TextStyle(color: Colors.white),
          items: carNames.map((car) {
            return DropdownMenuItem(value: car, child: Text(car));
          }).toList(),
          onChanged: (val) {
            setState(() {
              selectedCar = val!;
            });
          },
        ),
      ),
    );
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07121E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07121E),
        title: const Text("Preview", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 🔒 PREVIEW (FIXED HEIGHT)
            Expanded(
              child: Center(
                child: isProcessing
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Container(
                  color: Colors.white,
                  child: Image.memory(
                    carImages[selectedIndex].finalImage ??
                        carImages[selectedIndex].bgRemoved ??
                        File(carImages[selectedIndex].original.path)
                            .readAsBytesSync(),
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),


            // 🔄 BOTTOM CONTROLS (SCROLLABLE – NO OVERFLOW)
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    // ---------- THUMBNAILS ----------
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: carImages.length,
                        itemBuilder: (context, index) {
                          return GestureDetector(
                            onTap: () =>
                                setState(() => selectedIndex = index),
                            child: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedIndex == index
                                      ? Colors.blue
                                      : Colors.white24,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(carImages[index].original.path),
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ---------- ACTIONS ----------
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: removeBgSingle,
                              child: const Text("Remove BG"),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: removeBgAll,
                              child: const Text("Remove BG All"),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // ---------- BACKGROUNDS ----------
                    SizedBox(
                      height: 90,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: backgrounds.length,
                        itemBuilder: (context, index) {
                          final bg = backgrounds[index];
                          return GestureDetector(
                            onTap: () => setBgSingle(bg),
                            onLongPress: () => setBgAll(bg.id),
                            child: Container(
                              width: 90,
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child:
                                Image.asset(bg.asset, fit: BoxFit.cover),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // ---------- SAVE ----------
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isUploading ? null : () {},
                          child: isUploading
                              ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                              : const Text("Save Images"),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
