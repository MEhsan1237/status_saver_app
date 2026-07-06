import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';

class VersionInfoScreen extends StatelessWidget {
  const VersionInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Version Info'),
            centerTitle: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.darkGreen, AppColors.primary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.verified_outlined,
                    size: 80,
                    color: Colors.white.withAlpha(50),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildInfoCard(
                  context,
                  'App Version',
                  AppStrings.appVersion,
                  Icons.phone_android,
                ),
                _buildInfoCard(
                  context,
                  'Build Number',
                  '102',
                  Icons.build_circle_outlined,
                ),
                _buildInfoCard(
                  context,
                  'Release Type',
                  'Stable Production',
                  Icons.rocket_launch_outlined,
                ),
                const SizedBox(height: 24),
                const Text(
                  'What\'s New',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildChangelogItem(
                  '1.0.0',
                  'Initial Production Release\n- High-Speed Status Fetching\n- Multi-Path Support for WA Business\n- Material 3 Design Integration\n- Advanced BLoC State Management',
                ),
                _buildChangelogItem(
                  '0.9.8',
                  'Beta Testing\n- Optimized Video Player\n- Fixed Storage Permission Logic\n- Added Dark Mode Persistence',
                ),
                const SizedBox(height: 40),
                const Center(
                  child: Text(
                    'Checked for updates: Just now',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh),
                    label: const Text('Check for Update'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, String value, IconData icon) {
    return Card(
      elevation: 0,
      color: AppColors.primary.withAlpha(15),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildChangelogItem(String version, String changes) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withAlpha(50)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'v$version',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            changes,
            style: const TextStyle(height: 1.4, fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
