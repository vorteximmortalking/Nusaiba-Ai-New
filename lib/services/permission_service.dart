import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestAllPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.camera,
      Permission.phone,
      Permission.contacts,
    ].request();

    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
      }
    });
    return allGranted;
  }

  static Future<void> openSettings() async {
    await openAppSettings();
  }
}
