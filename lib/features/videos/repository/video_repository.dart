import 'dart:io';
import '../../home/model/status_model.dart';
import '../../../core/services/saf_service.dart';
import '../../../core/services/file_service.dart';

class VideoRepository {
  Future<List<StatusModel>> fetchVideoStatuses() async {
    final messengerFiles = await SAFService.syncStatuses(isBusiness: false);
    final businessFiles = await SAFService.syncStatuses(isBusiness: true);

    List<StatusModel> videos = [];

    // Filter only videos from Messenger
    for (var file in messengerFiles) {
      final path = file.path.toLowerCase();
      if (path.endsWith('.mp4') || path.endsWith('.mkv') || path.endsWith('.3gp')) {
        final isDownloaded = await FileService.isDownloaded(file.path);
        videos.add(StatusModel(
          path: file.path,
          type: StatusType.video,
          source: StatusSource.whatsapp,
          isDownloaded: isDownloaded,
        ));
      }
    }

    // Filter only videos from Business
    for (var file in businessFiles) {
      final path = file.path.toLowerCase();
      if (path.endsWith('.mp4') || path.endsWith('.mkv') || path.endsWith('.3gp')) {
        final isDownloaded = await FileService.isDownloaded(file.path);
        videos.add(StatusModel(
          path: file.path,
          type: StatusType.video,
          source: StatusSource.whatsappBusiness,
          isDownloaded: isDownloaded,
        ));
      }
    }

    // Sort by Newest First
    if (videos.isNotEmpty) {
      videos.sort((a, b) => File(b.path).lastModifiedSync().compareTo(File(a.path).lastModifiedSync()));
    }

    return videos;
  }
}
