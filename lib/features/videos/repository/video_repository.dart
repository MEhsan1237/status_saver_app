import '../../home/model/status_model.dart';
import '../../../core/services/saf_service.dart';
import '../../../core/services/file_service.dart';

class VideoRepository {
  Future<List<StatusModel>> fetchVideoStatuses() async {
    final messengerFiles = await SAFService.syncStatuses(isBusiness: false);
    final businessFiles = await SAFService.syncStatuses(isBusiness: true);

    List<StatusModel> videos = [];

    for (var file in messengerFiles) {
      if (file.path.endsWith('.mp4')) {
        final isDownloaded = await FileService.isDownloaded(file.path);
        videos.add(StatusModel(
          path: file.path,
          type: StatusType.video,
          source: StatusSource.whatsapp,
          isDownloaded: isDownloaded,
        ));
      }
    }

    for (var file in businessFiles) {
      if (file.path.endsWith('.mp4')) {
        final isDownloaded = await FileService.isDownloaded(file.path);
        videos.add(StatusModel(
          path: file.path,
          type: StatusType.video,
          source: StatusSource.whatsappBusiness,
          isDownloaded: isDownloaded,
        ));
      }
    }

    return videos;
  }
}
