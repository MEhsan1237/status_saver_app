import 'package:equatable/equatable.dart';

abstract class DownloadEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchDownloadedMedia extends DownloadEvent {}
