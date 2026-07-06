import 'package:equatable/equatable.dart';

enum StatusType { image, video }

enum StatusSource { whatsapp, whatsappBusiness }

class StatusModel extends Equatable {
  final String path;
  final StatusType type;
  final bool isDownloaded;
  final StatusSource source;

  const StatusModel({
    required this.path,
    required this.type,
    this.isDownloaded = false,
    this.source = StatusSource.whatsapp,
  });

  StatusModel copyWith({
    String? path,
    StatusType? type,
    bool? isDownloaded,
    StatusSource? source,
  }) {
    return StatusModel(
      path: path ?? this.path,
      type: type ?? this.type,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      source: source ?? this.source,
    );
  }

  @override
  List<Object?> get props => [path, type, isDownloaded, source];
}
