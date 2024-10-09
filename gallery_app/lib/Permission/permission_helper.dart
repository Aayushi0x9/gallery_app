import 'package:gallery_app/headers.dart';

Future<void> requestPermissions() async {
  // For Android 13+
  if (await Permission.photos.isGranted) {
    // Permission already granted
    return;
  }

  if (await Permission.photos.request().isGranted) {
    // Permission granted after request
    return;
  }
// For Android 11+
  if (await Permission.manageExternalStorage.request().isGranted) {
    // Manage external storage permission granted
    return;
  }

  // If the user denied the permission, you can guide them to the app settings:
  if (await Permission.photos.isPermanentlyDenied ||
      await Permission.manageExternalStorage.isPermanentlyDenied) {
    openAppSettings();
  }
}
