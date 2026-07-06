import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../bloc/download_bloc.dart';
import '../bloc/download_event.dart';
import '../bloc/download_state.dart';
import '../../../core/widgets/shimmer_loading.dart';
import '../../images/widgets/image_card.dart';
import '../../videos/widgets/video_card.dart';
import '../../home/model/status_model.dart';

class DownloadView extends StatefulWidget {
  const DownloadView({super.key});

  @override
  State<DownloadView> createState() => _DownloadViewState();
}

class _DownloadViewState extends State<DownloadView> {
  @override
  void initState() {
    super.initState();
    context.read<DownloadBloc>().add(FetchDownloadedMedia());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadBloc, DownloadState>(
      builder: (context, state) {
        if (state is DownloadLoading) {
          return const ShimmerLoading();
        } else if (state is DownloadLoaded) {
          if (state.media.isEmpty) {
            return const Center(child: Text('No Downloaded Media Found'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DownloadBloc>().add(FetchDownloadedMedia());
            },
            child: AnimationLimiter(
              child: GridView.builder(
                padding: const EdgeInsets.all(10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: state.media.length,
                itemBuilder: (context, index) {
                  final status = state.media[index];
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 375),
                    columnCount: 2,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: status.type == StatusType.image
                            ? ImageCard(status: status)
                            : VideoCard(status: status),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        } else if (state is DownloadError) {
          return Center(child: Text(state.message));
        }
        return const SizedBox();
      },
    );
  }
}
