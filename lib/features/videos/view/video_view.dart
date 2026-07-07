import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../bloc/video_bloc.dart';
import '../bloc/video_event.dart';
import '../bloc/video_state.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../widgets/video_card.dart';

class VideoView extends StatefulWidget {
  const VideoView({super.key});

  @override
  State<VideoView> createState() => _VideoViewState();
}

class _VideoViewState extends State<VideoView> {
  @override
  void initState() {
    super.initState();
    context.read<VideoBloc>().add(FetchVideos());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VideoBloc, VideoState>(
      builder: (context, state) {
        if (state is VideoLoading || state is VideoInitial || state is VideoPermissionDenied) {
          return const ShimmerLoading();
        } else if (state is VideosLoaded) {
          if (state.videos.isEmpty) {
            return const Center(child: Text(AppStrings.noStatusFound));
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<VideoBloc>().add(FetchVideos());
            },
            child: AnimationLimiter(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: state.videos.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: VideoCard(status: state.videos[index]),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else if (state is VideoError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }
}
