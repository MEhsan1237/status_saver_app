import '../../home/model/status_model.dart';
import '../../../core/services/saf_service.dart';
import '../../../core/services/file_service.dart';

class ImageRepository {
  Future<List<StatusModel>> fetchImageStatuses() async {
    final messengerFiles = await SAFService.syncStatuses(isBusiness: false);
    final businessFiles = await SAFService.syncStatuses(isBusiness: true);

    List<StatusModel> images = [];

    for (var file in messengerFiles) {
      if (file.path.endsWith('.jpg') || file.path.endsWith('.png')) {
        final isDownloaded = await FileService.isDownloaded(file.path);
        images.add(StatusModel(
          path: file.path,
          type: StatusType.image,
          source: StatusSource.whatsapp,
          isDownloaded: isDownloaded,
        ));
      }
    }

    for (var file in businessFiles) {
      if (file.path.endsWith('.jpg') || file.path.endsWith('.png')) {
        final isDownloaded = await FileService.isDownloaded(file.path);
        images.add(StatusModel(
          path: file.path,
          type: StatusType.image,
          source: StatusSource.whatsappBusiness,
          isDownloaded: isDownloaded,
        ));
      }
    }

    return images;
  }
}
