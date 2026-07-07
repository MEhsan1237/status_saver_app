import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/video_repository.dart';
import '../../../core/services/saf_service.dart';
import '../../../core/services/file_service.dart';
import 'video_event.dart';
import 'video_state.dart';

class VideoBloc extends Bloc<VideoEvent, VideoState> {
  final VideoRepository repository;
  Timer? _refreshTimer;

  VideoBloc({required this.repository}) : super(VideoInitial()) {
    on<FetchVideos>(_onFetchVideos);
    on<DownloadVideo>(_onDownloadVideo);

    // Industry Level: Turbo Refresh (5 seconds)
    _refreshTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!isClosed) add(FetchVideos());
    });
  }

  Future<void> _onFetchVideos(FetchVideos event, Emitter<VideoState> emit) async {
    if (state is VideoInitial) emit(VideoLoading());
    
    final hasPermission = await SAFService.hasPermission();
    if (!hasPermission) {
      emit(VideoPermissionDenied());
      return;
    }

    try {
      final videos = await repository.fetchVideoStatuses();
      emit(VideosLoaded(videos));
    } catch (e) {
      if (state is VideoInitial) emit(VideoError(e.toString()));
    }
  }

  Future<void> _onDownloadVideo(DownloadVideo event, Emitter<VideoState> emit) async {
    if (state is VideosLoaded) {
      final currentState = state as VideosLoaded;
      final success = await FileService.saveStatus(event.path);
      if (success) {
        final updatedVideos = currentState.videos.map((vid) {
          if (vid.path == event.path) return vid.copyWith(isDownloaded: true);
          return vid;
        }).toList();
        emit(VideosLoaded(updatedVideos));
      }
    }
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
