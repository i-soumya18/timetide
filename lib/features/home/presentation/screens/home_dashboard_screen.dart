import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timetide/features/authentication/providers/auth_provider.dart';
import 'package:timetide/features/home/providers/home_provider.dart';

// Modern premium color palette
class AppColors {
  // Primary colors
  static const primary = Color(0xFF6C5CE7);       // Deep purple/indigo
  static const primaryLight = Color(0xFF8A7EED);  // Lighter purple
  static const primaryDark = Color(0xFF5549C7);   // Darker purple

  // Secondary colors
  static const secondary = Color(0xFF2D3436);     // Near black
  static const secondaryLight = Color(0xFF3D4548); // Dark grey
  static const secondaryDark = Color(0xFF1E2224); // Darker grey

  // Accent colors
  static const accent = Color(0xFFFD79A8);        // Pink
  static const accentLight = Color(0xFFFD9CB6);   // Light pink
  static const accentDark = Color(0xFFD66390);    // Dark pink

  // Background colors
  static const backgroundDark = Color(0xFF121212);// Dark background
  static const backgroundMedium = Color(0xFF1E1E1E); // Medium dark background
  static const cardBackground = Color(0xFF252525); // Card background

  // Text colors
  static const textLight = Color(0xFFF5F5F5);     // Light text
  static const textMedium = Color(0xFFBDBDBD);    // Medium text
  static const textDark = Color(0xFF757575);      // Dark text

  // Status colors
  static const success = Color(0xFF00B894);       // Success green
  static const warning = Color(0xFFFFD166);       // Warning yellow
  static const error = Color(0xFFFF6B6B);         // Error red
  static const info = Color(0xFF54A0FF);          // Info blue
}

class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showFabMenu = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleFabMenu() {
    setState(() {
      _showFabMenu = !_showFabMenu;
      if (_showFabMenu) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.backgroundDark,
              AppColors.backgroundMedium.withOpacity(0.9),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<Map<String, dynamic>>(
            stream: homeProvider.getDashboardData(authProvider.user!.id),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _buildErrorState(snapshot.error.toString());
              }
              if (!snapshot.hasData) {
                return _buildLoadingState();
              }
              final data = snapshot.data!;
              final tasks = data['tasks'] as List<dynamic>;
              final habits = data['habits'] as List<dynamic>;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // App Bar
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      title: _buildAppBarTitle(authProvider),
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryDark.withOpacity(0.6),
                              AppColors.primary.withOpacity(0.4),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined),
                        color: AppColors.textLight,
                        onPressed: () {
                          // Navigate to notifications
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout_rounded),
                        color: AppColors.textLight,
                        onPressed: () async {
                          await authProvider.signOut();
                        },
                      ),
                    ],
                  ),

                  // Dashboard Content
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildSectionHeader("Today's Summary"),
                        const SizedBox(height: 16),
                        _buildSummaryCards(tasks.length, context),
                        const SizedBox(height: 24),
                        _buildSectionHeader("Quick Access"),
                        const SizedBox(height: 16),
                        _buildDashboardCard(
                          context,
                          title: "Today's Tasks",
                          subtitle: "${tasks.length} tasks pending",
                          icon: Icons.check_circle_rounded,
                          iconColor: AppColors.success,
                          onTap: () => Navigator.pushNamed(context, '/tasks'),
                        ),
                        const SizedBox(height: 16),
                        _buildDashboardCard(
                          context,
                          title: "AI Planner",
                          subtitle: "Plan your day with AI",
                          icon: Icons.smart_toy_rounded,
                          iconColor: AppColors.info,
                          onTap: () => Navigator.pushNamed(context, '/planner'),
                        ),
                        const SizedBox(height: 16),
                        _buildDashboardCard(
                          context,
                          title: "Health & Habits",
                          subtitle: "${habits.length} habits to track",
                          icon: Icons.favorite_rounded,
                          iconColor: AppColors.accent,
                          onTap: () => Navigator.pushNamed(context, '/habits'),
                        ),
                        const SizedBox(height: 16),
                        _buildDashboardCard(
                          context,
                          title: "Reminders",
                          subtitle: "View upcoming reminders",
                          icon: Icons.notifications_active_rounded,
                          iconColor: AppColors.warning,
                          onTap: () => Navigator.pushNamed(context, '/reminders'),
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: _buildExpandableFab(context),
    );
  }

  Widget _buildAppBarTitle(AuthProvider authProvider) {
    return Row(
      children: [
        Container(
          height: 36,
          width: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLight.withOpacity(0.2),
            border: Border.all(color: AppColors.primaryLight, width: 2),
          ),
          child: Center(
            child: Text(
              (authProvider.user?.name?.isNotEmpty == true)
                  ? authProvider.user!.name![0].toUpperCase()
                  : 'U',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Welcome, ${authProvider.user?.name ?? 'User'}',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textLight,
      ),
    );
  }

  Widget _buildSummaryCards(int taskCount, BuildContext context) {
    return Container(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _buildSummaryCard(
            title: "$taskCount",
            subtitle: "Tasks",
            icon: Icons.task_alt_rounded,
            color: AppColors.primary,
            width: 130,
          ),
          _buildSummaryCard(
            title: "3",
            subtitle: "Habits",
            icon: Icons.loop_rounded,
            color: AppColors.accent,
            width: 130,
          ),
          _buildSummaryCard(
            title: "75%",
            subtitle: "Completed",
            icon: Icons.pie_chart_rounded,
            color: AppColors.success,
            width: 130,
          ),
          _buildSummaryCard(
            title: "2",
            subtitle: "Reminders",
            icon: Icons.alarm_rounded,
            color: AppColors.warning,
            width: 130,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required double width,
  }) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 8,
            right: 8,
            child: Icon(
              icon,
              color: color.withOpacity(0.2),
              size: 48,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textMedium,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color iconColor,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 300),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: Opacity(
              opacity: value,
              child: child,
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textMedium,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textMedium,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableFab(BuildContext context) {
    final Animation<double> scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Mini FABs
        ScaleTransition(
          scale: scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'AI Planner',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton.small(
                        heroTag: 'ai_planner',
                        backgroundColor: AppColors.info,
                        foregroundColor: AppColors.textLight,
                        elevation: 0,
                        onPressed: () {
                          _toggleFabMenu();
                          Navigator.pushNamed(context, '/planner');
                        },
                        child: const Icon(Icons.smart_toy_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        ScaleTransition(
          scale: scaleAnimation,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        'Add Task',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton.small(
                        heroTag: 'add_task',
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.textLight,
                        elevation: 0,
                        onPressed: () {
                          _toggleFabMenu();
                          Navigator.pushNamed(context, '/add_task');
                        },
                        child: const Icon(Icons.add_task_rounded),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Main FAB
        FloatingActionButton(
          backgroundColor: _showFabMenu ? AppColors.secondaryLight : AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 4,
          onPressed: _toggleFabMenu,
          child: AnimatedIcon(
            icon: AnimatedIcons.menu_close,
            progress: _animationController,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Loading your dashboard...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Refresh data
                setState(() {});
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}