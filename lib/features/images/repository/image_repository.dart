import 'dart:io';
import '../../home/model/status_model.dart';
import '../../../core/services/saf_service.dart';
import '../../../core/services/file_service.dart';

class ImageRepository {
  Future<List<StatusModel>> fetchImageStatuses() async {
    final messengerFiles = await SAFService.syncStatuses(isBusiness: false);
    final businessFiles = await SAFService.syncStatuses(isBusiness: true);

    List<StatusModel> images = [];

    // Filter only images from Messenger
    for (var file in messengerFiles) {
      final path = file.path.toLowerCase();
      if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png') || path.endsWith('.webp')) {
        final isDownloaded = await FileService.isDownloaded(file.path);
        images.add(StatusModel(
          path: file.path,
          type: StatusType.image,
          source: StatusSource.whatsapp,
          isDownloaded: isDownloaded,
        ));
      }
    }

    // Filter only images from Business
    for (var file in businessFiles) {
      final path = file.path.toLowerCase();
      if (path.endsWith('.jpg') || path.endsWith('.jpeg') || path.endsWith('.png') || path.endsWith('.webp')) {
        final isDownloaded = await FileService.isDownloaded(file.path);
        images.add(StatusModel(
          path: file.path,
          type: StatusType.image,
          source: StatusSource.whatsappBusiness,
          isDownloaded: isDownloaded,
        ));
      }
    }

    // Sort by Newest First
    if (images.isNotEmpty) {
      images.sort((a, b) => File(b.path).lastModifiedSync().compareTo(File(a.path).lastModifiedSync()));
    }

    return images;
  }
}
