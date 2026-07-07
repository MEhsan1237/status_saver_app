import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../bloc/image_bloc.dart';
import '../bloc/image_event.dart';
import '../bloc/image_state.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../widgets/image_card.dart';

class ImageView extends StatefulWidget {
  const ImageView({super.key});

  @override
  State<ImageView> createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  void initState() {
    super.initState();
    context.read<ImageBloc>().add(FetchImages());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImageBloc, ImageState>(
      builder: (context, state) {
        if (state is ImageLoading || state is ImageInitial || state is ImagePermissionDenied) {
          return const ShimmerLoading();
        } else if (state is ImagesLoaded) {
          if (state.images.isEmpty) {
            return const Center(child: Text(AppStrings.noStatusFound));
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<ImageBloc>().add(FetchImages());
            },
            child: AnimationLimiter(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: state.images.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: ImageCard(status: state.images[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else if (state is ImageError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }
}
