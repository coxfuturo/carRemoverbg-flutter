import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

Future<bool> requestStoragePermission() async {
  if (await Permission.photos.isGranted ||
      await Permission.storage.isGranted) {
    return true;
  }

  if (await Permission.photos.request().isGranted) return true;
  if (await Permission.storage.request().isGranted) return true;

  return false;
}



Future<bool> requestCameraAndGalleryPermissions() async {
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


