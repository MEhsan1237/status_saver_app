import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'permission_service.dart';

class SAFService {
  static const MethodChannel _channel = MethodChannel('com.senior.status_saver/saf');
  static const String _uriKey = 'whatsapp_uri';
  static const String _waBusinessUriKey = 'whatsapp_business_uri';

  static Future<bool> isLegacyAndroid() async {
    if (!Platform.isAndroid) return false;
    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    return androidInfo.version.sdkInt < 30; // Android 10 or below
  }

  static Future<String?> getPersistedUri({bool isBusiness = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(isBusiness ? _waBusinessUriKey : _uriKey);
  }

  static Future<bool> hasPermission({bool isBusiness = false}) async {
    if (await isLegacyAndroid()) {
      return await PermissionService.checkPermission();
    }
    final uri = await getPersistedUri(isBusiness: isBusiness);
    if (uri == null) return false;
    try {
      final bool? hasPerm = await _channel.invokeMethod('checkFolderPermission', {'uri': uri});
      return hasPerm ?? false;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> requestFolderPermission({bool isBusiness = false}) async {
    if (await isLegacyAndroid()) {
      await PermissionService.requestStoragePermission();
      return "legacy";
    }
    try {
      final String? uri = await _channel.invokeMethod('openFolderPicker', {
        'initialPath': isBusiness 
            ? 'content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fmedia%2Fcom.whatsapp.w4b%2FWhatsApp%20Business%2FMedia%2F.Statuses'
            : 'content://com.android.externalstorage.documents/tree/primary%3AAndroid%2Fmedia%2Fcom.whatsapp%2FWhatsApp%2FMedia%2F.Statuses'
      });
      
      if (uri != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(isBusiness ? _waBusinessUriKey : _uriKey, uri);
      }
      return uri;
    } catch (e) {
      return null;
    }
  }

  static Future<List<File>> getLegacyFiles({bool isBusiness = false}) async {
    // Aggressive scanning of all possible WhatsApp paths for legacy devices
    final List<String> paths = isBusiness ? [
      "/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses",
      "/storage/emulated/0/WhatsApp Business/Media/.Statuses",
      "/storage/emulated/0/Android/media/com.gbwhatsapp/GBWhatsApp/Media/.Statuses",
    ] : [
      "/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses",
      "/storage/emulated/0/WhatsApp/Media/.Statuses",
      "/storage/emulated/0/Android/media/com.fmwhatsapp/FMWhatsApp/Media/.Statuses",
      "/storage/emulated/0/Android/media/com.yowhatsapp/YoWhatsApp/Media/.Statuses",
    ];

    List<File> files = [];
    for (var path in paths) {
      final dir = Directory(path);
      if (await dir.exists()) {
        try {
          files.addAll(dir.listSync().whereType<File>().where((file) {
            final lower = file.path.toLowerCase();
            return lower.endsWith(".jpg") || lower.endsWith(".jpeg") || 
                   lower.endsWith(".png") || lower.endsWith(".mp4") ||
                   lower.endsWith(".gif") || lower.endsWith(".webp");
          }).toList());
        } catch (e) {}
      }
    }
    return files;
  }

  static Future<List<File>> syncStatuses({bool isBusiness = false}) async {
    if (await isLegacyAndroid()) {
      return await getLegacyFiles(isBusiness: isBusiness);
    }

    final uri = await getPersistedUri(isBusiness: isBusiness);
    if (uri == null) return [];

    try {
      final List<dynamic>? filesList = await _channel.invokeMethod('listStatusFiles', {'uri': uri});
      if (filesList == null) return [];

      final List<File> syncedFiles = [];
      final cacheDir = await getTemporaryDirectory();
      final statusDir = Directory("${cacheDir.path}/${isBusiness ? 'biz' : 'msg'}");
      
      if (!await statusDir.exists()) await statusDir.create(recursive: true);

      // Clean up local cache if files are no longer in WhatsApp (Real-time removal)
      final currentNames = filesList.map((f) => f['name'] as String).toSet();
      if (await statusDir.exists()) {
        final cachedFiles = statusDir.listSync();
        for (var f in cachedFiles) {
          final name = f.path.split('/').last;
          if (!currentNames.contains(name)) {
            await f.delete();
          }
        }
      }

      for (var fileMap in filesList) {
        final String name = fileMap['name'];
        final String fileUri = fileMap['uri'];
        final cacheFile = File("${statusDir.path}/$name");
        
        if (!await cacheFile.exists()) {
          final Uint8List? bytes = await _channel.invokeMethod('getFileContent', {'uri': fileUri});
          if (bytes != null) await cacheFile.writeAsBytes(bytes);
        }
        syncedFiles.add(cacheFile);
      }
      return syncedFiles;
    } catch (e) {
      return [];
    }
  }
}
