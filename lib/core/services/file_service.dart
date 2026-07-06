import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../constants/app_strings.dart';

class FileService {
  static Future<String> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download/${AppStrings.appName}');
      } else {
        directory = await getDownloadsDirectory();
      }
    } catch (err) {
      directory = await getApplicationDocumentsDirectory();
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
        await file.copy(newPath);
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

  static List<String> getWhatsAppPaths() {
    return [
      "/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses",
      "/storage/emulated/0/WhatsApp/Media/.Statuses",
      "/storage/emulated/0/Android/media/com.whatsapp.w4b/WhatsApp Business/Media/.Statuses",
      "/storage/emulated/0/WhatsApp Business/Media/.Statuses",
    ];
  }

  static Future<List<File>> getDownloadedMedia() async {
    final downloadPath = await getDownloadPath();
    final directory = Directory(downloadPath);
    if (await directory.exists()) {
      return directory
          .listSync()
          .whereType<File>()
          .where((file) =>
              file.path.endsWith('.jpg') ||
              file.path.endsWith('.png') ||
              file.path.endsWith('.mp4'))
          .toList();
    }
    return [];
  }
}
