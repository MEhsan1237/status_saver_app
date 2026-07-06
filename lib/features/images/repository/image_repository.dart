import '../../home/model/status_model.dart';
import '../../../core/services/saf_service.dart';

class ImageRepository {
  Future<List<StatusModel>> fetchImageStatuses() async {
    final messengerFiles = await SAFService.syncStatuses(isBusiness: false);
    final businessFiles = await SAFService.syncStatuses(isBusiness: true);

    List<StatusModel> images = [];

    for (var file in messengerFiles) {
      if (file.path.endsWith('.jpg') || file.path.endsWith('.png')) {
        images.add(StatusModel(
          path: file.path,
          type: StatusType.image,
          source: StatusSource.whatsapp,
        ));
      }
    }

    for (var file in businessFiles) {
      if (file.path.endsWith('.jpg') || file.path.endsWith('.png')) {
        images.add(StatusModel(
          path: file.path,
          type: StatusType.image,
          source: StatusSource.whatsappBusiness,
        ));
      }
    }

    return images;
  }
}
