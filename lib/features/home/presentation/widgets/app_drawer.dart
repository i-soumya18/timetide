import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timetide/features/authentication/providers/auth_provider.dart';
import 'package:timetide/core/colors.dart';

class AppDrawer extends StatelessWidget {
  final AuthProvider authProvider;

  const AppDrawer({
    Key? key,
    required this.authProvider,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.backgroundDark,
      child: Column(
        children: [
          // User Profile Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.textLight,
                        backgroundImage: authProvider.user?.avatarUrl != null
                            ? CachedNetworkImageProvider(
                                authProvider.user!.avatarUrl!)
                            : null,
                        child: authProvider.user?.avatarUrl == null
                            ? Text(
                                authProvider.user!.name
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authProvider.user?.name ?? 'User',
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: AppColors.textLight,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              authProvider.user?.email ?? 'user@example.com',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textLight.withOpacity(0.8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // App Settings
                ListTile(
                  leading:
                      const Icon(Icons.settings, color: AppColors.textLight),
                  title: Text(
                    'App Settings',
                    style: GoogleFonts.poppins(
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),

                const Divider(color: AppColors.secondary),

                // App Info Section
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  child: Text(
                    'App Info',
                    style: GoogleFonts.poppins(
                      color: AppColors.textMedium,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // About App
                ListTile(
                  leading: const Icon(Icons.info_outline,
                      color: AppColors.textLight),
                  title: Text(
                    'About TimeTide',
                    style: GoogleFonts.poppins(
                      color: AppColors.textLight,
                    ),
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    _showAboutAppDialog(context);
                  },
                ),

                // FAQ
                ListTile(
                  leading: const Icon(Icons.question_answer,
                      color: AppColors.textLight),
                  title: Text(
                    'FAQs',
                    style: GoogleFonts.poppins(
                      color: AppColors.textLight,
                    ),
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/faqs');
                  },
                ),

                // Contact
                ListTile(
                  leading: const Icon(Icons.mail_outline,
                      color: AppColors.textLight),
                  title: Text(
                    'Contact Support',
                    style: GoogleFonts.poppins(
                      color: AppColors.textLight,
                    ),
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    _showContactSupportDialog(context);
                  },
                ),

                // Help & Tutorials
                ListTile(
                  leading: const Icon(Icons.help_outline,
                      color: AppColors.textLight),
                  title: Text(
                    'Help & Tutorials',
                    style: GoogleFonts.poppins(
                      color: AppColors.textLight,
                    ),
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/tutorials');
                  },
                ),

                const Divider(color: AppColors.secondary),

                // Developer Section
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
                  child: Text(
                    'Developer',
                    style: GoogleFonts.poppins(
                      color: AppColors.textMedium,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                // Developer Details
                ListTile(
                  leading: const Icon(Icons.code, color: AppColors.textLight),
                  title: Text(
                    'Developer Details',
                    style: GoogleFonts.poppins(
                      color: AppColors.textLight,
                    ),
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    _showDeveloperDetailsDialog(context);
                  },
                ),

                // Privacy Policy
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined,
                      color: AppColors.textLight),
                  title: Text(
                    'Privacy Policy',
                    style: GoogleFonts.poppins(
                      color: AppColors.textLight,
                    ),
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    _showPrivacyPolicyDialog(context);
                  },
                ),

                // Terms of Service
                ListTile(
                  leading: const Icon(Icons.description_outlined,
                      color: AppColors.textLight),
                  title: Text(
                    'Terms of Service',
                    style: GoogleFonts.poppins(
                      color: AppColors.textLight,
                    ),
                  ),
                  onTap: () {
                    HapticFeedback.lightImpact();
                    Navigator.pop(context);
                    _showTermsOfServiceDialog(context);
                  },
                ),
              ],
            ),
          ),

          // App Version at the bottom
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text(
              'TimeTide v1.0.0',
              style: GoogleFonts.poppins(
                color: AppColors.textMedium,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: Text(
          'About TimeTide',
          style: GoogleFonts.poppins(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TimeTide is an intelligent productivity application that helps you organize your tasks, track habits, and optimize your schedule with AI assistance.',
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Features:',
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _buildFeatureItem('AI-powered scheduling and task prioritization'),
            _buildFeatureItem('Habit tracking with reminders'),
            _buildFeatureItem('Productivity insights and analytics'),
            _buildFeatureItem('Personalized recommendations'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.poppins(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: Text(
          'Contact Support',
          style: GoogleFonts.poppins(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Need help with TimeTide? Reach out to us:',
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            _buildContactItem(
              Icons.email,
              'Email',
              'support@timetide.app',
            ),
            _buildContactItem(
              Icons.web,
              'Website',
              'www.timetide.app/support',
            ),
            _buildContactItem(
              Icons.chat_bubble_outline,
              'Live Chat',
              'Available 9AM-5PM EST',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                detail,
                style: GoogleFonts.poppins(
                  color: AppColors.textMedium,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeveloperDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: Text(
          'Developer Details',
          style: GoogleFonts.poppins(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  color: AppColors.cardBackground,
                ),
                child: const Icon(
                  Icons.code,
                  color: AppColors.primary,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'TimeTide Team',
                style: GoogleFonts.poppins(
                  color: AppColors.textLight,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'We are a team of developers passionate about AI and productivity. Our mission is to create tools that help people optimize their time and achieve more in their daily lives.',
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Connect with us:',
              style: GoogleFonts.poppins(
                color: AppColors.textLight,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSocialButton(Icons.language, 'Website'),
                _buildSocialButton(Icons.email, 'Email'),
                _buildSocialButton(Icons.social_distance, 'LinkedIn'),
                _buildSocialButton(Icons.code, 'GitHub'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(IconData icon, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        icon: Icon(icon, color: AppColors.primary),
        onPressed: () {
          // Implement social media links
        },
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: [
              Text(
                'Last updated: May 15, 2025',
                style: GoogleFonts.poppins(
                  color: AppColors.textMedium,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'This Privacy Policy outlines how TimeTide collects, uses, maintains, and discloses information collected from users of our mobile application.',
                style: GoogleFonts.poppins(
                  color: AppColors.textLight,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              _buildPrivacySection(
                'Information Collection',
                'We collect personal information such as name, email address, and usage data to improve your experience with our app.',
              ),
              _buildPrivacySection(
                'Data Usage',
                'Your information is used to personalize your experience, improve our app, and provide customer support.',
              ),
              _buildPrivacySection(
                'Data Protection',
                'We implement appropriate security measures to protect your personal information from unauthorized access or disclosure.',
              ),
              _buildPrivacySection(
                'Third-Party Services',
                'We may use third-party services that collect information to assist with analytics, advertising, and app functionality.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: GoogleFonts.poppins(
              color: AppColors.textLight,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _showTermsOfServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundDark,
        title: Text(
          'Terms of Service',
          style: GoogleFonts.poppins(
            color: AppColors.textLight,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: ListView(
            children: [
              Text(
                'Last updated: May 15, 2025',
                style: GoogleFonts.poppins(
                  color: AppColors.textMedium,
                  fontStyle: FontStyle.italic,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Please read these Terms of Service carefully before using the TimeTide mobile application.',
                style: GoogleFonts.poppins(
                  color: AppColors.textLight,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              _buildTermsSection(
                'License',
                'We grant you a limited, non-exclusive, non-transferable license to use the application for personal, non-commercial purposes.',
              ),
              _buildTermsSection(
                'User Content',
                'You retain all rights to your user content, but grant us a license to use, modify, and display it in connection with the app.',
              ),
              _buildTermsSection(
                'Prohibited Activities',
                'Users may not engage in any activity that interferes with the proper functioning of the app or violates applicable laws.',
              ),
              _buildTermsSection(
                'Termination',
                'We reserve the right to terminate or suspend access to the app at our sole discretion, without notice.',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: AppColors.textLight,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            content,
            style: GoogleFonts.poppins(
              color: AppColors.textLight,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
