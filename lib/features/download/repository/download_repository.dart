import '../../../core/services/file_service.dart';
import '../../home/model/status_model.dart';

class DownloadRepository {
  Future<List<StatusModel>> fetchDownloadedStatuses() async {
    final files = await FileService.getDownloadedMedia();
    return files.map((file) {
      final isVideo = file.path.endsWith('.mp4');
      return StatusModel(
        path: file.path,
        type: isVideo ? StatusType.video : StatusType.image,
        isDownloaded: true,
      );
    }).toList();
  }
}
