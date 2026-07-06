import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/bloc/theme_bloc.dart';
import 'features/settings/bloc/theme_event.dart';
import 'features/settings/bloc/theme_state.dart';
import 'features/splash/bloc/splash_bloc.dart';
import 'features/splash/view/splash_screen.dart';
import 'features/images/bloc/image_bloc.dart';
import 'features/images/repository/image_repository.dart';
import 'features/videos/bloc/video_bloc.dart';
import 'features/videos/repository/video_repository.dart';
import 'features/download/bloc/download_bloc.dart';
import 'features/download/repository/download_repository.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ThemeBloc()..add(LoadTheme()),
        ),
        BlocProvider(
          create: (context) => SplashBloc(),
        ),
        BlocProvider(
          create: (context) => ImageBloc(repository: ImageRepository()),
        ),
        BlocProvider(
          create: (context) => VideoBloc(repository: VideoRepository()),
        ),
        BlocProvider(
          create: (context) => DownloadBloc(repository: DownloadRepository()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Status Saver',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
