import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.privacyPolicy),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              context,
              'Introduction',
              'Welcome to Status Saver. We are committed to protecting your personal information and your right to privacy. This privacy policy explains how we handle your data when you use our application.',
              Icons.info_outline,
            ),
            _buildSection(
              context,
              'Data Collection',
              'Status Saver does NOT collect, store, or transmit any personal data to our servers. All status files (images and videos) are processed locally on your device. We do not have access to your WhatsApp messages, contacts, or media unless you explicitly choose to save a status to your gallery.',
              Icons.storage_outlined,
            ),
            _buildSection(
              context,
              'Permissions',
              'Our app requires storage permissions to read WhatsApp status files and save them to your device. These permissions are used exclusively for the core functionality of the app. We strictly adhere to Android security guidelines for data access.',
              Icons.security_outlined,
            ),
            _buildSection(
              context,
              'Third-Party Services',
              'We may use third-party services like Google AdMob to show advertisements. These services may collect information used to identify you. Please refer to their respective privacy policies for more information.',
              Icons.ads_click_outlined,
            ),
            _buildSection(
              context,
              'User Control',
              'You have full control over the statuses you choose to save. Saved statuses are stored in a public folder on your device and can be managed or deleted using any file manager or gallery app.',
              Icons.touch_app_outlined,
            ),
            _buildSection(
              context,
              'Contact Us',
              'If you have any questions or suggestions about our Privacy Policy, do not hesitate to contact us at support@statussaver.com.',
              Icons.email_outlined,
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Last Updated: May 2024',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
