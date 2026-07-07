import 'dart:io';
import '../../home/model/status_model.dart';
import '../../../core/services/saf_service.dart';
import '../../../core/services/file_service.dart';

class VideoRepository {
  Future<List<StatusModel>> fetchVideoStatuses() async {
    final messengerFiles = await SAFService.syncStatuses(isBusiness: false);
    final businessFiles = await SAFService.syncStatuses(isBusiness: true);

    List<StatusModel> videos = [];

    for (var file in messengerFiles) {
      final isDownloaded = await FileService.isDownloaded(file.path);
      videos.add(StatusModel(
        path: file.path,
        type: StatusType.video,
        source: StatusSource.whatsapp,
        isDownloaded: isDownloaded,
      ));
    }

    for (var file in businessFiles) {
      final isDownloaded = await FileService.isDownloaded(file.path);
      videos.add(StatusModel(
        path: file.path,
        type: StatusType.video,
        source: StatusSource.whatsappBusiness,
        isDownloaded: isDownloaded,
      ));
    }

    // Sort combined videos by modification time (Newest First)
    videos.sort((a, b) => File(b.path).lastModifiedSync().compareTo(File(a.path).lastModifiedSync()));

    return videos;
  }
}
