import 'package:permission_handler/permission_handler.dart';

class PermissionService {

  static Future<bool> camera() async {
    final status = await Permission.camera.request();
    return _handle(status);
  }

  static Future<bool> gallery() async {
    final status = await Permission.photos.request();
    return _handle(status);
  }

  static Future<bool> notification() async {
    final status = await Permission.notification.request();
    return _handle(status);
  }

  static bool _handle(PermissionStatus status) {
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    return false;
  }
}