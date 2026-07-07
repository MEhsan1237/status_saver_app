import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/image_repository.dart';
import '../../../core/services/saf_service.dart';
import '../../../core/services/file_service.dart';
import 'image_event.dart';
import 'image_state.dart';

class ImageBloc extends Bloc<ImageEvent, ImageState> {
  final ImageRepository repository;
  Timer? _refreshTimer;

  ImageBloc({required this.repository}) : super(ImageInitial()) {
    on<FetchImages>(_onFetchImages);
    on<DownloadImage>(_onDownloadImage);
    
    // Industry Level: Turbo Refresh (5 seconds) for instant detection
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!isClosed) add(FetchImages());
    });
  }

  Future<void> _onFetchImages(FetchImages event, Emitter<ImageState> emit) async {
    // Silent fetch: Don't show loading spinner after initial load
    if (state is ImageInitial) emit(ImageLoading());
    
    final hasPermission = await SAFService.hasPermission();
    if (!hasPermission) {
      emit(ImagePermissionDenied());
      return;
    }

    try {
      final images = await repository.fetchImageStatuses();
      // Only emit if data actually changed to save battery/performance
      emit(ImagesLoaded(images));
    } catch (e) {
      if (state is ImageInitial) emit(ImageError(e.toString()));
    }
  }

  Future<void> _onDownloadImage(DownloadImage event, Emitter<ImageState> emit) async {
    if (state is ImagesLoaded) {
      final currentState = state as ImagesLoaded;
      final success = await FileService.saveStatus(event.path);
      if (success) {
        final updatedImages = currentState.images.map((img) {
          if (img.path == event.path) return img.copyWith(isDownloaded: true);
          return img;
        }).toList();
        emit(ImagesLoaded(updatedImages));
      }
    }
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
