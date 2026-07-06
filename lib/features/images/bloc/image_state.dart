import 'package:equatable/equatable.dart';
import '../../home/model/status_model.dart';

abstract class ImageState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ImageInitial extends ImageState {}

class ImageLoading extends ImageState {}

class ImagesLoaded extends ImageState {
  final List<StatusModel> images;
  ImagesLoaded(this.images);

  @override
  List<Object?> get props => [images];
}

class ImageError extends ImageState {
  final String message;
  ImageError(this.message);

  @override
  List<Object?> get props => [message];
}

class ImagePermissionDenied extends ImageState {}
