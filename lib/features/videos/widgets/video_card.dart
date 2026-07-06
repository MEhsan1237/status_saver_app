import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import '../../home/model/status_model.dart';
import '../bloc/video_bloc.dart';
import '../bloc/video_event.dart';
import '../../../core/constants/app_colors.dart';
import '../view/video_player_screen.dart';

class VideoCard extends StatefulWidget {
  final StatusModel status;
  const VideoCard({super.key, required this.status});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  String? _thumbnail;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    final thumb = await VideoThumbnail.thumbnailFile(
      video: widget.status.path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 25,
    );
    if (mounted) {
      setState(() {
        _thumbnail = thumb;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(status: widget.status),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.black12,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              _thumbnail != null
                  ? Image.file(File(_thumbnail!), fit: BoxFit.cover)
                  : const Center(child: CircularProgressIndicator()),
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    widget.status.source == StatusSource.whatsappBusiness ? 'WA Business' : 'WA Messenger',
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const Center(
                child: Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: InkWell(
                  onTap: widget.status.isDownloaded
                      ? null
                      : () {
                          context.read<VideoBloc>().add(DownloadVideo(widget.status.path));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Video Saved!')),
                          );
                        },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(204),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.status.isDownloaded ? Icons.check : Icons.download,
                      color: AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
