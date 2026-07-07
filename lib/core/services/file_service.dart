import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../constants/app_strings.dart';

class FileService {
  static const MethodChannel _channel = MethodChannel('com.senior.status_saver/saf');

  static Future<String> getDownloadPath() async {
    Directory? directory;
    if (Platform.isAndroid) {
      // Industry Standard: Save to public Pictures/Video folder for gallery visibility
      directory = Directory('/storage/emulated/0/Pictures/${AppStrings.appName}');
    } else {
      directory = await getDownloadsDirectory();
    }

    if (directory != null && !await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory!.path;
  }

  static Future<bool> saveStatus(String filePath) async {
    try {
      final downloadPath = await getDownloadPath();
      final fileName = p.basename(filePath);
      final newPath = p.join(downloadPath, fileName);

      final file = File(filePath);
      if (await file.exists()) {
        final copiedFile = await file.copy(newPath);
        
        // CRITICAL: Notify Android Gallery that a new file is added
        if (Platform.isAndroid) {
          await _channel.invokeMethod('scanFile', {'path': copiedFile.path});
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> isDownloaded(String filePath) async {
    final downloadPath = await getDownloadPath();
    final fileName = p.basename(filePath);
    final newPath = p.join(downloadPath, fileName);
    return await File(newPath).exists();
  }

  static Future<List<File>> getDownloadedMedia() async {
    final downloadPath = await getDownloadPath();
    final directory = Directory(downloadPath);
    if (await directory.exists()) {
      final files = directory.listSync().whereType<File>().toList();
      // Sort by newest first
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      return files.where((file) =>
          file.path.endsWith('.jpg') ||
          file.path.endsWith('.png') ||
          file.path.endsWith('.mp4')).toList();
    }
    return [];
  }
}
