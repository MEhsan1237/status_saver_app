import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class SAFService {
  static const MethodChannel _channel = MethodChannel('com.senior.status_saver/saf');
  static const String _uriKey = 'whatsapp_uri';
  static const String _waBusinessUriKey = 'whatsapp_business_uri';

  static Future<String?> getPersistedUri({bool isBusiness = false}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(isBusiness ? _waBusinessUriKey : _uriKey);
  }

  static Future<bool> hasPermission({bool isBusiness = false}) async {
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

  static Future<List<File>> syncStatuses({bool isBusiness = false}) async {
    final uri = await getPersistedUri(isBusiness: isBusiness);
    if (uri == null) return [];

    try {
      final List<dynamic>? filesList = await _channel.invokeMethod('listStatusFiles', {'uri': uri});
      
      if (filesList == null) return [];

      final List<File> syncedFiles = [];
      final cacheDir = await getTemporaryDirectory();
      final statusDir = Directory(p.join(cacheDir.path, isBusiness ? 'statuses_business' : 'statuses_messenger'));
      
      if (!await statusDir.exists()) {
        await statusDir.create(recursive: true);
      }

      for (var fileMap in filesList) {
        final String name = fileMap['name'];
        final String fileUri = fileMap['uri'];

        if (name.endsWith('.jpg') || name.endsWith('.png') || name.endsWith('.mp4')) {
          final cacheFile = File(p.join(statusDir.path, name));
          
          if (!await cacheFile.exists()) {
            final Uint8List? bytes = await _channel.invokeMethod('getFileContent', {'uri': fileUri});
            if (bytes != null) {
              await cacheFile.writeAsBytes(bytes);
            }
          }
          syncedFiles.add(cacheFile);
        }
      }
      
      return syncedFiles;
    } catch (e) {
      return [];
    }
  }
}
