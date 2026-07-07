import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'permission_service.dart';

class SAFService {
  static Future<bool> isLegacyAndroid() async {
    if (!Platform.isAndroid) return false;
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt < 30;
  }

  static Future<bool> hasPermission({bool isBusiness = false}) async {
    return await PermissionService.checkPermission();
  }

  static Future<void> requestFolderPermission({bool isBusiness = false}) async {
    await PermissionService.requestStoragePermission();
  }

  static Future<List<File>> syncStatuses({bool isBusiness = false}) async {
    // Aggressive but Precise: Targeting only official hidden .Statuses folders
    final List<String> paths = isBusiness ? [
      // WA Business Paths
      "/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses",
      "/storage/emulated/0/WhatsApp Business/Media/.Statuses",
    ] : [
      // WA Messenger Paths
      "/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses",
      "/storage/emulated/0/WhatsApp/Media/.Statuses",
      // Common Mods
      "/storage/emulated/0/Android/media/com.gbwhatsapp/GBWhatsApp/Media/.Statuses",
      "/storage/emulated/0/GBWhatsApp/Media/.Statuses",
    ];

    List<File> files = [];
    for (var path in paths) {
      final dir = Directory(path);
      if (await dir.exists()) {
        try {
          final dirFiles = dir.listSync().whereType<File>().where((file) {
            final lower = file.path.toLowerCase();
            // Strictly filtering media extensions
            return lower.endsWith(".jpg") || lower.endsWith(".jpeg") || 
                   lower.endsWith(".png") || lower.endsWith(".mp4") ||
                   lower.endsWith(".gif") || lower.endsWith(".webp");
          }).toList();
          files.addAll(dirFiles);
        } catch (e) {}
      }
    }
    
    // Sort by Date (Newest First)
    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    
    // De-duplicate based on filename
    final Map<String, File> uniqueFiles = {};
    for (var f in files) {
      final name = f.path.split('/').last;
      if (!uniqueFiles.containsKey(name)) {
        uniqueFiles[name] = f;
      }
    }
    
    return uniqueFiles.values.toList();
  }
}
