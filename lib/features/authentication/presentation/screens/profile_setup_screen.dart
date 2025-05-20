import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timetide/features/authentication/providers/auth_provider.dart';
import '../widgets/avatar_picker.dart';
import 'package:timetide/core/colors.dart';
import 'dart:ui';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final List<String> _selectedGoals = [];
  File? _selectedAvatarFile;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _availableGoals = [
    'Productivity',
    'Health',
    'Learning',
    'Relaxation',
  ];

  // Premium dark theme colors
  static const Color primaryColor = Color(0xFF6564DB);
  static const Color secondaryColor = Color(0xFF004643);
  static const Color accentColor = Color(0xFFA23B72);
  static const Color backgroundStartColor = Color(0xFF1A1A2E);
  static const Color backgroundEndColor = Color(0xFF16213E);
  static const Color cardColor = Color(0xFF252A37);
  static const Color textPrimaryColor = Color(0xFFF8F8F8);
  static const Color textSecondaryColor = Color(0xFFB0B0B0);

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Start animation
    _animationController.forward();

    // Load user data if available
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    if (user != null) {
      _nameController.text = user.name;
      if (user.preferences.isNotEmpty) {
        _selectedGoals.addAll(user.preferences);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Create Your Profile',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: textPrimaryColor,
            fontSize: 22,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: textPrimaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundStartColor, backgroundEndColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative background elements
              Positioned(
                top: screenSize.height * 0.1,
                left: -screenSize.width * 0.2,
                child: Container(
                  width: screenSize.width * 0.6,
                  height: screenSize.width * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryColor.withOpacity(0.1),
                  ),
                ),
              ),
              Positioned(
                bottom: -screenSize.width * 0.4,
                right: -screenSize.width * 0.2,
                child: Container(
                  width: screenSize.width * 0.8,
                  height: screenSize.width * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor.withOpacity(0.08),
                  ),
                ),
              ),

              // Main content
              SlideTransition(
                position: _slideAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
                    physics: const BouncingScrollPhysics(),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header text
                          Center(
                            child: Text(
                              'Let\'s set up your profile',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: textSecondaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Avatar picker with animation
                          Center(
                            child: Hero(
                              tag: 'avatar',
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: AvatarPicker(
                                  imageUrl: authProvider.user?.avatarUrl,
                                  onImageSelected: (imagePath) {
                                    setState(() {
                                      _selectedAvatarFile = File(imagePath);
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Name input field
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 600),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 20 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Your Name',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _nameController,
                                  style: GoogleFonts.poppins(
                                    color: textPrimaryColor,
                                    fontSize: 16,
                                  ),
                                  cursorColor: primaryColor,
                                  decoration: InputDecoration(
                                    hintText: 'Enter your full name',
                                    hintStyle: GoogleFonts.poppins(
                                      color:
                                          textSecondaryColor.withOpacity(0.7),
                                    ),
                                    filled: true,
                                    fillColor: cardColor,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: primaryColor,
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Colors.redAccent,
                                        width: 2,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: const BorderSide(
                                        color: Colors.redAccent,
                                        width: 2,
                                      ),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.person_rounded,
                                      color: primaryColor,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  validator: (value) => value!.isEmpty
                                      ? 'Please enter your name'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 40),

                          // Goals selection
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 30 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Select Your Goals',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textPrimaryColor,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Choose what matters most to you',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: textSecondaryColor,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: _availableGoals.map((goal) {
                                    final isSelected =
                                        _selectedGoals.contains(goal);

                                    return InkWell(
                                      onTap: () {
                                        setState(() {
                                          if (isSelected) {
                                            _selectedGoals.remove(goal);
                                          } else {
                                            _selectedGoals.add(goal);
                                          }
                                        });
                                      },
                                      borderRadius: BorderRadius.circular(12),
                                      splashColor:
                                          primaryColor.withOpacity(0.1),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 300),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? primaryColor.withOpacity(0.2)
                                              : cardColor,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? primaryColor
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: primaryColor
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    spreadRadius: 0,
                                                    offset: const Offset(0, 2),
                                                  )
                                                ]
                                              : null,
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              _getIconForGoal(goal),
                                              color: isSelected
                                                  ? primaryColor
                                                  : textSecondaryColor,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              goal,
                                              style: GoogleFonts.poppins(
                                                fontSize: 14,
                                                fontWeight: isSelected
                                                    ? FontWeight.w600
                                                    : FontWeight.w500,
                                                color: isSelected
                                                    ? primaryColor
                                                    : textSecondaryColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 50),

                          // Save button
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: const Duration(milliseconds: 800),
                            curve: Curves.easeOut,
                            builder: (context, value, child) {
                              return Opacity(
                                opacity: value,
                                child: Transform.translate(
                                  offset: Offset(0, 40 * (1 - value)),
                                  child: child,
                                ),
                              );
                            },
                            child: Center(
                              child: SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    if (_formKey.currentState!.validate()) {
                                      // Add button press animation
                                      await authProvider.updateUserProfile(
                                        name: _nameController.text.trim(),
                                        preferences: _selectedGoals,
                                        avatar: _selectedAvatarFile,
                                      );

                                      if (authProvider.user != null &&
                                          mounted) {
                                        // Add transition animation
                                        Navigator.pushReplacementNamed(
                                            context, '/home');
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 4,
                                    shadowColor: primaryColor.withOpacity(0.4),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                  ),
                                  child: Text(
                                    'Continue',
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconForGoal(String goal) {
    switch (goal) {
      case 'Productivity':
        return Icons.work_rounded;
      case 'Health':
        return Icons.favorite_rounded;
      case 'Learning':
        return Icons.school_rounded;
      case 'Relaxation':
        return Icons.self_improvement_rounded;
      default:
        return Icons.star_rounded;
    }
  }
}
