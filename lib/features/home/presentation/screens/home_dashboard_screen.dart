import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../authentication/providers/auth_provider.dart';
import '../../core/colors.dart';
import '../providers/home_provider.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final homeProvider = Provider.of<HomeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Welcome, ${authProvider.user?.name ?? 'User'}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.secondary, AppColors.primary],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: StreamBuilder<Map<String, dynamic>>(
          stream: homeProvider.getDashboardData(authProvider.user!.id),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final data = snapshot.data!;
            final tasks = data['tasks'] as List<dynamic>;
            final habits = data['habits'] as List<dynamic>;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Summary',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardCard(
                    context,
                    title: 'Today\'s Tasks',
                    subtitle: '${tasks.length} tasks pending',
                    icon: Icons.check_circle,
                    onTap: () => Navigator.pushNamed(context, '/tasks'),
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardCard(
                    context,
                    title: 'AI Planner',
                    subtitle: 'Plan your day with AI',
                    icon: Icons.smart_toy,
                    onTap: () => Navigator.pushNamed(context, '/planner'),
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardCard(
                    context,
                    title: 'Health & Habits',
                    subtitle: '${habits.length} habits to track',
                    icon: Icons.favorite,
                    onTap: () => Navigator.pushNamed(context, '/habits'),
                  ),
                  const SizedBox(height: 16),
                  _buildDashboardCard(
                    context,
                    title: 'Reminders',
                    subtitle: 'View upcoming reminders',
                    icon: Icons.notifications,
                    onTap: () => Navigator.pushNamed(context, '/reminders'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.add_task),
                  title: const Text('Add Task'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/add_task');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.smart_toy),
                  title: const Text('Open AI Planner'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/planner');
                  },
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDashboardCard(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary,
          child: Icon(icon, color: AppColors.textDark),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.primary),
        onTap: onTap,
      ),
    );
  }
}