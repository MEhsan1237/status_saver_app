import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/download_repository.dart';
import 'download_event.dart';
import 'download_state.dart';

class DownloadBloc extends Bloc<DownloadEvent, DownloadState> {
  final DownloadRepository repository;

  DownloadBloc({required this.repository}) : super(DownloadInitial()) {
    on<FetchDownloadedMedia>(_onFetchDownloadedMedia);
  }

  Future<void> _onFetchDownloadedMedia(
      FetchDownloadedMedia event, Emitter<DownloadState> emit) async {
    emit(DownloadLoading());
    try {
      final media = await repository.fetchDownloadedStatuses();
      emit(DownloadLoaded(media));
    } catch (e) {
      emit(DownloadError(e.toString()));
    }
  }
}
