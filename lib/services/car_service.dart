import 'package:camera/camera.dart';
import 'package:carbgremover/models/CarImage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';

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
  static Future<void> createCarAndUploadAllImages({
    required List<CarImage> images,
    required Function(double progress) onProgress,
  }) async {
    final uid = _auth.currentUser!.uid;

    if (images.isEmpty) {
      throw Exception("No images to upload");
    }

    final userRef = _firestore.collection("users").doc(uid);

    /// 1️⃣ CREATE CAR DOC
    final carRef = userRef.collection("cars").doc();
    final String carId = carRef.id;

    final int totalImages = images.length;

    await carRef.set({
      "carName": "Toyota Fortuner", // later dynamic
      "status": "Queue",
      "totalImages": totalImages,
      "coverImage": "",
      "createdAt": FieldValue.serverTimestamp(),
      "updatedAt": FieldValue.serverTimestamp(),
    });

    /// 🔢 CALCULATE TOTAL BYTES (FOR REAL PROGRESS)
    int totalBytes = 0;
    for (final img in images) {
      final bytes = img.finalImage ?? img.bgRemoved;
      if (bytes != null) totalBytes += bytes.length;
    }

    int uploadedBytes = 0;
    int uploadedCount = 0;
    bool coverImageSet = false;

    /// 2️⃣ UPLOAD EACH IMAGE
    for (final CarImage img in images) {
      final Uint8List? uploadBytes =
          img.finalImage ?? img.bgRemoved;

      if (uploadBytes == null) continue;

      final bool isTransparent = img.finalImage == null;

      final storageRef = _storage.ref(
        "users/$uid/cars/$carId/pose_${img.poseIndex}.png",
      );

      final uploadTask = storageRef.putData(uploadBytes);

      /// 🔥 REAL BYTE PROGRESS
      uploadTask.snapshotEvents.listen((event) {
        uploadedBytes += event.bytesTransferred;

        final progress =
        (uploadedBytes / totalBytes).clamp(0.0, 1.0);

        onProgress(progress);
      });

      await uploadTask;

      final String downloadUrl = await storageRef.getDownloadURL();

      /// IMAGE DOC
      final imageRef = carRef.collection("images").doc();

      await imageRef.set({
        "imageDocId": imageRef.id,
        "url": downloadUrl,
        "poseIndex": img.poseIndex,
        "background": img.background,
        "isTransparent": isTransparent,
        "createdAt": FieldValue.serverTimestamp(),
        "updatedAt": FieldValue.serverTimestamp(),
      });

      /// ✅ SET COVER IMAGE (ONLY ONCE)
      if (!coverImageSet) {
        await carRef.update({
          "coverImage": downloadUrl,
        });
        coverImageSet = true;
      }

      uploadedCount++; // ✅ FIX
    }

    /// 3️⃣ MARK CAR DONE
    if (uploadedCount == totalImages) {
      await carRef.update({
        "status": "Done",
        "updatedAt": FieldValue.serverTimestamp(),
      });
    }

    /// 🔥 ENSURE 100%
    onProgress(1.0);
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

}
