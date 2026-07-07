import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 30) {
        // This is the "Allow All" permission for Android 11+
        var status = await Permission.manageExternalStorage.request();
        if (status.isGranted) return true;
        
        // Fallback to media permissions
        await Permission.photos.request();
        await Permission.videos.request();
      } else {
        await Permission.storage.request();
      }
      return await checkPermission();
    }
    return false;
  }

  static Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;

      if (androidInfo.version.sdkInt >= 30) {
        return await Permission.manageExternalStorage.isGranted;
      } else {
        return await Permission.storage.isGranted;
      }
    }
    return false;
  }
}
