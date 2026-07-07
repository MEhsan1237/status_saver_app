import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';
import '../../settings/bloc/theme_bloc.dart';
import '../../settings/bloc/theme_event.dart';
import '../../settings/bloc/theme_state.dart';
import '../../about/about_screen.dart';
import '../../about/privacy_policy_screen.dart';
import '../../about/version_info_screen.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.darkGreen,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset(
                      'assets/images/app_icon.png',
                      width: 60,
                      height: 60,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    AppStrings.appName,
                    style: TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text(AppStrings.home),
            onTap: () => Navigator.pop(context),
          ),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, state) {
              return ListTile(
                leading: Icon(state.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode),
                title: const Text(AppStrings.theme),
                trailing: Switch(
                  value: state.themeMode == ThemeMode.dark,
                  onChanged: (_) {
                    context.read<ThemeBloc>().add(ToggleTheme());
                  },
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text(AppStrings.shareApp),
            onTap: () {
              Share.share(
                'Check out Status Saver! The best app to download WhatsApp Statuses easily.\n\nDownload now: https://play.google.com/store/apps/details?id=com.senior.status_saver',
                subject: 'Download Status Saver App',
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text(AppStrings.privacyPolicy),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            onTap: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'support@statussaver.com',
                query: 'subject=Feedback for Status Saver App',
              );
              if (!await launchUrl(emailLaunchUri)) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Could not open email app')),
                  );
                }
              }
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text(AppStrings.about),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.verified),
            title: const Text('Version'),
            trailing: const Text(AppStrings.appVersion),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VersionInfoScreen()));
            },
          ),
        ],
      ),
    );
  }
}
