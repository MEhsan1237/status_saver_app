import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/image_repository.dart';
import '../../../core/services/saf_service.dart';
import '../../../core/services/file_service.dart';
import 'image_event.dart';
import 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final ImageRepository repository;

  ImageBloc({required this.repository}) : super(ImageInitial()) {
    on<FetchImages>(_onFetchImages);
    on<DownloadImage>(_onDownloadImage);
  }

  Future<void> _onFetchImages(FetchImages event, Emitter<ImageState> emit) async {
    emit(ImageLoading());
    
    final hasMessenger = await SAFService.hasPermission(isBusiness: false);
    final hasBusiness = await SAFService.hasPermission(isBusiness: true);

    if (!hasMessenger && !hasBusiness) {
      emit(ImagePermissionDenied());
      return;
    }

    try {
      final images = await repository.fetchImageStatuses();
      emit(ImagesLoaded(images));
    } catch (e) {
      emit(ImageError(e.toString()));
    }
  }

  Future<void> _onDownloadImage(DownloadImage event, Emitter<ImageState> emit) async {
    if (state is ImagesLoaded) {
      final currentState = state as ImagesLoaded;
      final success = await FileService.saveStatus(event.path);
      if (success) {
        final updatedImages = currentState.images.map((img) {
          if (img.path == event.path) {
            return img.copyWith(isDownloaded: true);
          }
          return img;
        }).toList();
        emit(ImagesLoaded(updatedImages));
      }
    }
  }
}
