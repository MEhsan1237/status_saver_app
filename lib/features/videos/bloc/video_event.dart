import 'package:equatable/equatable.dart';

abstract class VideoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchVideos extends VideoEvent {}

class DownloadVideo extends VideoEvent {
  final String path;
  DownloadVideo(this.path);

  @override
  List<Object?> get props => [path];
}
