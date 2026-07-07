import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import '../../home/model/status_model.dart';
import '../../../core/constants/app_colors.dart';

class FullImageView extends StatelessWidget {
  final StatusModel status;
  const FullImageView({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Hero(
        tag: status.path,
        child: PhotoView(
          imageProvider: FileImage(File(status.path)),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 2,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text(
                'Could not load image',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}
