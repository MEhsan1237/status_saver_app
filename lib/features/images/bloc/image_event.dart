import 'package:equatable/equatable.dart';

abstract class ImageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchImages extends ImageEvent {}

class DownloadImage extends ImageEvent {
  final String path;
  DownloadImage(this.path);

  @override
  List<Object?> get props => [path];
}
