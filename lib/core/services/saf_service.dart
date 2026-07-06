import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_storage/shared_storage.dart' as saf;
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
    return await _channel.invokeMethod('checkFolderPermission', {'uri': uri});
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

    final List<File> syncedFiles = [];
    final cacheDir = await getTemporaryDirectory();
    final statusDir = Directory(p.join(cacheDir.path, isBusiness ? 'statuses_business' : 'statuses_messenger'));
    
    if (!await statusDir.exists()) {
      await statusDir.create(recursive: true);
    }

    // Use shared_storage to list files
    final files = await saf.listFiles(Uri.parse(uri), columns: [saf.DocumentFileColumn.displayName, saf.DocumentFileColumn.size]).toList();
    
    for (var file in files) {
      if (file.name != null && (file.name!.endsWith('.jpg') || file.name!.endsWith('.png') || file.name!.endsWith('.mp4'))) {
        final cacheFile = File(p.join(statusDir.path, file.name));
        
        // If file doesn't exist in cache, copy it
        // Note: For production, you might want to compare file size or last modified
        if (!await cacheFile.exists()) {
          final bytes = await saf.getDocumentContent(file.uri);
          if (bytes != null) {
            await cacheFile.writeAsBytes(bytes);
          }
        }
        syncedFiles.add(cacheFile);
      }
    }
    
    return syncedFiles;
  }
}
