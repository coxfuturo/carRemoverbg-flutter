import 'package:camera/camera.dart';
import 'package:carbgremover/models/CarImage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class CarService {
  static final _auth = FirebaseAuth.instance;
  static final _firestore = FirebaseFirestore.instance;
  static final _storage = FirebaseStorage.instance;

  static Future<List<CarImage>> fetchCarImages(String carId) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("cars")
        .doc(carId)
        .collection("images")
        .orderBy("poseIndex")
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return CarImage(
        url: data["url"],
        imageDocId: doc.id,
        poseIndex: data["poseIndex"],
      );
    }).toList();
  }

  static Future<String> createNewCar({required String carName}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    // 🔑 AUTO GENERATED ID
    final carRef = _firestore
        .collection("users")
        .doc(user.uid)
        .collection("cars")
        .doc(); // <-- AUTO ID

    await carRef.set({
      "carName": carName,
      "status": "In Progress",
      "photos": 0,
      "createdAt": FieldValue.serverTimestamp(),
    });

    return carRef.id;
  }

  static Future<Map<int, List<XFile>>> getUploadedPoseImages(
    String carId,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return {};

    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .collection("cars")
        .doc(carId)
        .collection("images")
        .orderBy("createdAt")
        .get();

    final Map<int, List<XFile>> result = {};

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final poseIndex = data["poseIndex"];
      final url = data["url"];

      result.putIfAbsent(poseIndex, () => []);
      result[poseIndex]!.add(XFile(url));
    }

    return result;
  }

  static Future<void> uploadSingleImage({
    required String carId,
    required XFile imageFile,
    required int poseIndex,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final firestore = FirebaseFirestore.instance;
    final storage = FirebaseStorage.instance;

    // 1️⃣ Upload image
    final bytes = await imageFile.readAsBytes();

    final ref = storage
        .ref()
        .child("users")
        .child(user.uid)
        .child("cars")
        .child(carId)
        .child("pose_$poseIndex.png");

    final snap = await ref.putData(
      bytes,
      SettableMetadata(contentType: "image/png"),
    );

    final imageUrl = await snap.ref.getDownloadURL();

    final carRef = firestore
        .collection("users")
        .doc(user.uid)
        .collection("cars")
        .doc(carId);

    // 2️⃣ Save image doc
    await carRef.collection("images").doc("pose_$poseIndex").set({
      "url": imageUrl,
      "poseIndex": poseIndex,
      "createdAt": FieldValue.serverTimestamp(),
    });

    // 3️⃣ 🔥 UPDATE CAR SUMMARY
    await firestore.runTransaction((tx) async {
      final carSnap = await tx.get(carRef);
      final data = carSnap.data() as Map<String, dynamic>;

      final int currentPhotos = data["photos"] ?? 0;

      final updateData = {
        "photos": currentPhotos + 1,
        "updatedAt": FieldValue.serverTimestamp(),
      };

      // 🔥 FIRST IMAGE → COVER IMAGE
      if ((data["coverImage"] ?? "").toString().isEmpty) {
        updateData["coverImage"] = imageUrl;
      }

      tx.update(carRef, updateData);
    });
  }

  /// Delete COMPLETE car model (all images + car doc)
  static Future<void> deleteCar(String carId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw Exception("User not logged in");
    }

    final carRef = _firestore
        .collection("users")
        .doc(uid)
        .collection("cars")
        .doc(carId);

    // 1️⃣ Get all images of this car
    final imagesSnapshot = await carRef.collection("images").get();

    // 2️⃣ Delete all images (Storage + Firestore)
    for (final doc in imagesSnapshot.docs) {
      final imageUrl = doc.data()["url"];

      if (imageUrl != null && imageUrl.toString().isNotEmpty) {
        try {
          await _storage.refFromURL(imageUrl).delete();
        } catch (e) {
          // image already deleted or invalid URL → ignore
        }
      }

      await doc.reference.delete();
    }

    // 3️⃣ Delete car document itself
    await carRef.delete();
  }

  // Future<bool> uploadAllImagesToFirebase(List<CarImage> carImages,  String selectedCar) async {
  //   final user = FirebaseAuth.instance.currentUser;
  //   if (user == null) return false;
  //
  //   try {
  //     final storage = FirebaseStorage.instance;
  //     final firestore = FirebaseFirestore.instance;
  //
  //     final carDocId = selectedCar.replaceAll(' ', '_').toLowerCase();
  //
  //     final batchId =
  //     DateTime.now().millisecondsSinceEpoch.toString();
  //
  //     String? coverImageUrl;
  //
  //     for (int i = 0; i < carImages.length; i++) {
  //       final img = carImages[i];
  //
  //       final Uint8List bytes =
  //           img.finalImage ??
  //               img.bgRemoved ??
  //               await img.original.readAsBytes();
  //
  //       final ref = storage
  //           .ref()
  //           .child("users")
  //           .child(user.uid)
  //           .child("cars")
  //           .child(carDocId)
  //           .child(batchId)
  //           .child("${carDocId}_${i + 1}.png");
  //
  //       final snapshot = await ref.putData(
  //         bytes,
  //         SettableMetadata(contentType: "image/png"),
  //       );
  //
  //       final url = await snapshot.ref.getDownloadURL();
  //
  //       // 🔹 FIRST IMAGE AS COVER
  //       coverImageUrl ??= url;
  //
  //       await firestore
  //           .collection("users")
  //           .doc(user.uid)
  //           .collection("cars")
  //           .doc(carDocId)
  //           .collection("images")
  //           .doc("${batchId}_$i")
  //           .set({
  //         "url": url,
  //         "index": i + 1,
  //         "batchId": batchId,
  //         "createdAt": FieldValue.serverTimestamp(),
  //       });
  //     }
  //
  //     // 🔥 SAVE CAR SUMMARY AFTER UPLOAD
  //     await CarService.saveCarSummary(
  //       carName: selectedCar,
  //       coverImage: coverImageUrl ?? "",
  //       photosCount: carImages.length,
  //       batchId: batchId,
  //     );
  //
  //     return true;
  //   } catch (e) {
  //     debugPrint("Upload error: $e");
  //     return false;
  //   }
  // }
  //
  //
  // static Future<void> saveCarSummary({
  //   required String carName,
  //   required String coverImage,
  //   required int photosCount,
  //   required String batchId,
  // }) async
  // {
  //   final user = FirebaseAuth.instance.currentUser!;
  //   final firestore = FirebaseFirestore.instance;
  //
  //   final carDocId = carName.replaceAll(' ', '_').toLowerCase();
  //
  //   await firestore
  //       .collection("users")
  //       .doc(user.uid)
  //       .collection("cars")
  //       .doc(carDocId)
  //       .set({
  //     "carName": carName,
  //     "photos": photosCount,
  //     "status": "Done",
  //     "coverImage": coverImage,
  //     "lastBatchId": batchId,
  //     "createdAt": FieldValue.serverTimestamp(),
  //   }, SetOptions(merge: true));
  // }
}
