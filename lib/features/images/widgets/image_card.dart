import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../home/model/status_model.dart';
import '../bloc/image_bloc.dart';
import '../bloc/image_event.dart';
import '../../../core/constants/app_colors.dart';
import '../view/full_image_view.dart';

class ImageCard extends StatelessWidget {
  final StatusModel status;
  const ImageCard({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullImageView(status: status),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: status.path,
                child: Image.file(
                  File(status.path),
                  fit: BoxFit.cover,
                ),
              ),
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
                    status.source == StatusSource.whatsappBusiness ? 'WA Business' : 'WA Messenger',
                    style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Positioned(
                bottom: 8,
                right: 8,
                child: InkWell(
                  onTap: status.isDownloaded
                      ? null
                      : () {
                          context.read<ImageBloc>().add(DownloadImage(status.path));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Image Saved!')),
                          );
                        },
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(204),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      status.isDownloaded ? Icons.check : Icons.download,
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
