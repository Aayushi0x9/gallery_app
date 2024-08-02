import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  final status = await Permission.photos.request();
  if (!status.isGranted) {
    print('Permission denied');
  }
}
