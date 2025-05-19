import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../widgets/auth_button.dart';
import '../../providers/auth_provider.dart';
import 'package:timetide/core/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutCubic),
      ),
    );

    // Start animation after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });

    // Configure system UI to be transparent
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Helper method to unfocus keyboard when tapping outside
  void _unfocus() {
    _emailFocusNode.unfocus();
    _passwordFocusNode.unfocus();
  }

  // Brand logo widget
  Widget _buildLogo() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value * -0.5),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.check_circle_outline_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Welcome text widget with animation
  Widget _buildWelcomeText() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Custom text field widget
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    FocusNode? focusNode,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    double animationDelay = 0.0,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final Animation<double> delayedAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.2 + animationDelay,
            0.85 + animationDelay,
            curve: Curves.easeOutCubic,
          ),
        );

        final Animation<double> fadeIn = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(delayedAnimation);

        final Animation<double> slideIn = Tween<double>(
          begin: 50.0,
          end: 0.0,
        ).animate(delayedAnimation);

        return Transform.translate(
          offset: Offset(0, slideIn.value),
          child: Opacity(
            opacity: fadeIn.value,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                obscureText: isPassword ? _obscurePassword : false,
                keyboardType: keyboardType,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  hintText: hintText,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                  prefixIcon: Icon(
                    prefixIcon,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  suffixIcon: isPassword
                      ? IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: Colors.white.withOpacity(0.8),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                ),
                onEditingComplete: isPassword
                    ? _unfocus
                    : () =>
                        FocusScope.of(context).requestFocus(_passwordFocusNode),
              ),
            ),
          ),
        );
      },
    );
  }

  // Error message widget with animation
  Widget _buildErrorMessage(String? errorMessage) {
    if (errorMessage == null) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: errorMessage.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.error.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                errorMessage,
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Login button with animation
  Widget _buildLoginButton({
    required VoidCallback onPressed,
    required String text,
    Color backgroundColor = AppColors.primary,
    Color textColor = Colors.white,
    bool isOutlined = false,
    double animationDelay = 0.0,
    Widget? icon,
  }) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final Animation<double> delayedAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.4 + animationDelay,
            1.0,
            curve: Curves.easeOutCubic,
          ),
        );

        final Animation<double> fadeIn = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(delayedAnimation);

        final Animation<double> slideIn = Tween<double>(
          begin: 50.0,
          end: 0.0,
        ).animate(delayedAnimation);

        return Transform.translate(
          offset: Offset(0, slideIn.value),
          child: Opacity(
            opacity: fadeIn.value,
            child: AuthButton(
              text: text,
              isLoading: _isLoading,
              backgroundColor: backgroundColor,
              textColor: textColor,
              onPressed: onPressed,
              icon: icon,
            ),
          ),
        );
      },
    );
  }

  // Animated divider for "or" section
  Widget _buildDivider(double animationDelay) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final Animation<double> delayedAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.4 + animationDelay,
            1.0,
            curve: Curves.easeOutCubic,
          ),
        );

        final Animation<double> fadeIn = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(delayedAnimation);

        return Opacity(
          opacity: fadeIn.value,
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OR',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: Colors.white.withOpacity(0.2),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Sign up text button with animation
  Widget _buildSignUpText(double animationDelay) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final Animation<double> delayedAnimation = CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            0.6 + animationDelay,
            1.0,
            curve: Curves.easeOutCubic,
          ),
        );

        final Animation<double> fadeIn = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(delayedAnimation);

        final Animation<double> slideIn = Tween<double>(
          begin: 30.0,
          end: 0.0,
        ).animate(delayedAnimation);

        return Transform.translate(
          offset: Offset(0, slideIn.value),
          child: Opacity(
            opacity: fadeIn.value,
            child: TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: RichText(
                text: TextSpan(
                  text: 'Don\'t have an account? ',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                  ),
                  children: const [
                    TextSpan(
                      text: 'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // Background decoration with animated gradient
  Widget _buildBackground() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryLight,
                AppColors.primary,
                AppColors.primaryDark,
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              stops: const [0.0, 0.5, 1.0],
              transform: GradientRotation(_animationController.value * 0.03),
            ),
          ),
          child: CustomPaint(
            painter: BackgroundPainter(
              animation: _animationController,
              color1: Colors.white.withOpacity(0.05),
              color2: Colors.white.withOpacity(0.1),
            ),
            child: Container(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return GestureDetector(
      onTap: _unfocus,
      child: Scaffold(
        body: Stack(
          children: [
            // Animated background
            _buildBackground(),

            // Content
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        48,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top section
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          _buildLogo(),
                          const SizedBox(height: 24),
                          _buildWelcomeText(),
                          const SizedBox(height: 30),
                        ],
                      ),

                      // Middle section with fields and buttons
                      Column(
                        children: [
                          _buildTextField(
                            controller: _emailController,
                            hintText: 'Email Address',
                            prefixIcon: Icons.email_outlined,
                            focusNode: _emailFocusNode,
                            keyboardType: TextInputType.emailAddress,
                            animationDelay: 0.1,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _passwordController,
                            hintText: 'Password',
                            prefixIcon: Icons.lock_outline_rounded,
                            focusNode: _passwordFocusNode,
                            isPassword: true,
                            animationDelay: 0.2,
                          ),
                          const SizedBox(height: 8),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: _buildLoginButton(
                              text: 'Forgot Password?',
                              onPressed: () {
                                // Handle forgot password
                              },
                              backgroundColor: Colors.transparent,
                              textColor: Colors.white.withOpacity(0.8),
                              animationDelay: 0.25,
                            ),
                          ),

                          const SizedBox(height: 16),
                          _buildErrorMessage(authProvider.errorMessage),
                          const SizedBox(height: 16),

                          // Login button
                          _buildLoginButton(
                            text: 'Login',
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              await authProvider.signInWithEmail(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                                if (authProvider.user != null) {
                                  Navigator.pushReplacementNamed(
                                      context, '/home');
                                }
                              }
                            },
                            backgroundColor: AppColors.accent,
                            textColor: Colors.white,
                            animationDelay: 0.3,
                          ),

                          const SizedBox(height: 20),
                          _buildDivider(0.35),
                          const SizedBox(height: 20),

                          // Google login button
                          _buildLoginButton(
                            text: 'Sign in with Google',
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              await authProvider.signInWithGoogle();
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                                if (authProvider.user != null) {
                                  Navigator.pushReplacementNamed(
                                      context, '/home');
                                }
                              }
                            },
                            backgroundColor: Colors.white,
                            textColor: Colors.black87,
                            animationDelay: 0.4,
                            icon: const Icon(Icons.g_mobiledata, size: 24),
                          ),

                          const SizedBox(height: 16),

                          // Guest login button
                          _buildLoginButton(
                            text: 'Continue as Guest',
                            onPressed: () async {
                              setState(() {
                                _isLoading = true;
                              });
                              await authProvider.signInAsGuest();
                              if (mounted) {
                                setState(() {
                                  _isLoading = false;
                                });
                                if (authProvider.user != null) {
                                  Navigator.pushReplacementNamed(
                                      context, '/home');
                                }
                              }
                            },
                            backgroundColor: Colors.transparent,
                            textColor: Colors.white,
                            isOutlined: true,
                            animationDelay: 0.45,
                          ),
                        ],
                      ),

                      // Bottom section
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 10),
                        child: _buildSignUpText(0.1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom background painter for animated shapes
class BackgroundPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color1;
  final Color color2;

  BackgroundPainter({
    required this.animation,
    required this.color1,
    required this.color2,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // First blob
    final paint1 = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;

    final centerX1 = size.width * 0.25;
    final centerY1 = size.height * 0.2;
    final radius1 = size.width * 0.4 * (0.8 + 0.2 * animation.value);
    final path1 = Path();
    for (int i = 0; i < 360; i += 10) {
      final rad = i * 3.14159 / 180;
      final noise = 20 * (0.6 + 0.5 * (animation.value + 0.5 * i / 360));
      final x = centerX1 +
          (radius1 + noise * sin(rad * 6 + animation.value * 2)) * cos(rad);
      final y = centerY1 +
          (radius1 + noise * cos(rad * 6 + animation.value * 2)) * sin(rad);

      if (i == 0) {
        path1.moveTo(x, y);
      } else {
        path1.lineTo(x, y);
      }
    }
    path1.close();
    canvas.drawPath(path1, paint1);

    // Second blob
    final paint2 = Paint()
      ..color = color2
      ..style = PaintingStyle.fill;

    final centerX2 = size.width * 0.8;
    final centerY2 = size.height * 0.8;
    final radius2 = size.width * 0.3 * (0.8 + 0.2 * (1 - animation.value));
    final path2 = Path();
    for (int i = 0; i < 360; i += 10) {
      final rad = i * 3.14159 / 180;
      final noise = 15 * (0.7 + 0.3 * (1 - animation.value + 0.5 * i / 360));
      final x = centerX2 +
          (radius2 + noise * sin(rad * 5 - animation.value * 2)) * cos(rad);
      final y = centerY2 +
          (radius2 + noise * cos(rad * 5 - animation.value * 2)) * sin(rad);

      if (i == 0) {
        path2.moveTo(x, y);
      } else {
        path2.lineTo(x, y);
      }
    }
    path2.close();
    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
