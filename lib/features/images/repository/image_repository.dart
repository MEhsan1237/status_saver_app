import 'dart:io';
import '../../home/model/status_model.dart';
import '../../../core/services/saf_service.dart';
import '../../../core/services/file_service.dart';

class ImageRepository {
  Future<List<StatusModel>> fetchImageStatuses() async {
    final messengerFiles = await SAFService.syncStatuses(isBusiness: false);
    final businessFiles = await SAFService.syncStatuses(isBusiness: true);

    List<StatusModel> images = [];

    for (var file in messengerFiles) {
      final isDownloaded = await FileService.isDownloaded(file.path);
      images.add(StatusModel(
        path: file.path,
        type: StatusType.image,
        source: StatusSource.whatsapp,
        isDownloaded: isDownloaded,
      ));
    }

    for (var file in businessFiles) {
      final isDownloaded = await FileService.isDownloaded(file.path);
      images.add(StatusModel(
        path: file.path,
        type: StatusType.image,
        source: StatusSource.whatsappBusiness,
        isDownloaded: isDownloaded,
      ));
    }

    // Sort combined images by modification time (Newest First)
    images.sort((a, b) => File(b.path).lastModifiedSync().compareTo(File(a.path).lastModifiedSync()));

    return images;
  }
}
