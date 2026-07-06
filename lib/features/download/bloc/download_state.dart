import 'package:equatable/equatable.dart';
import '../../home/model/status_model.dart';

abstract class DownloadState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DownloadInitial extends DownloadState {}

class DownloadLoading extends DownloadState {}

class DownloadLoaded extends DownloadState {
  final List<StatusModel> media;
  DownloadLoaded(this.media);

  @override
  List<Object?> get props => [media];
}

class DownloadError extends DownloadState {
  final String message;
  DownloadError(this.message);

  @override
  List<Object?> get props => [message];
}
