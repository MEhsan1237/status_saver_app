import 'package:equatable/equatable.dart';
import '../../home/model/status_model.dart';

abstract class VideoState extends Equatable {
  @override
  List<Object?> get props => [];
}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {}

class VideosLoaded extends VideoState {
  final List<StatusModel> videos;
  VideosLoaded(this.videos);

  @override
  List<Object?> get props => [videos];
}

class VideoError extends VideoState {
  final String message;
  VideoError(this.message);

  @override
  List<Object?> get props => [message];
}

class VideoPermissionDenied extends VideoState {}
