import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:timetide/core/colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Define our premium color scheme
  static const Color primaryColor = Color(0xFF003459); // Deep blue
  static const Color secondaryColor = Color(0xFF6564DB); // Purple
  static const Color accentColor = Color(0xFFA23B72); // Magenta
  static const Color bgDarkest = Color(0xFF121212); // Background darkest
  static const Color bgDark = Color(0xFF1E1E24); // Background dark
  static const Color errorColor = Color(0xFFE57373); // Error color
  static const Color surfaceColor = Color(0xFF252535); // Surface color

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: bgDarkest,
      ),
      child: Scaffold(
        backgroundColor: bgDarkest,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Hero(
            tag: 'back_button',
            child: Material(
              color: Colors.transparent,
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white),
                onPressed: () => Navigator.pop(context),
                splashRadius: 24,
              ),
            ),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  bgDarkest,
                  bgDarkest.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                bgDarkest,
                Color.lerp(secondaryColor, bgDarkest, 0.85)!,
                Color.lerp(primaryColor, bgDarkest, 0.8)!,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.1, 0.6, 1.0],
            ),
          ),
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            // App logo or branding
                            Center(
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.elasticOut,
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: value,
                                    child: child,
                                  );
                                },
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        secondaryColor,
                                        accentColor,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(24),
                                    boxShadow: [
                                      BoxShadow(
                                        color: secondaryColor.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.access_time_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),
                            Text(
                              'Create account',
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Join TimeTide and start planning your day efficiently',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Colors.white70,
                                letterSpacing: 0.2,
                              ),
                            ),
                            const SizedBox(height: 32),
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildInputField(
                                    controller: _nameController,
                                    label: 'Name',
                                    prefixIcon: Icons.person_outline_rounded,
                                    validator: (value) => value!.isEmpty
                                        ? 'Please enter your name'
                                        : null,
                                  ),
                                  const SizedBox(height: 18),
                                  _buildInputField(
                                    controller: _emailController,
                                    label: 'Email',
                                    keyboardType: TextInputType.emailAddress,
                                    prefixIcon: Icons.email_outlined,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter your email';
                                      }
                                      final emailRegex =
                                          RegExp(r'^[^@]+@[^@]+\.[^@]+');
                                      if (!emailRegex.hasMatch(value)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 18),
                                  _buildInputField(
                                    controller: _passwordController,
                                    label: 'Password',
                                    obscureText: _obscurePassword,
                                    prefixIcon: Icons.lock_outline_rounded,
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        color: Colors.white60,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Please enter a password';
                                      }
                                      if (value.length < 6) {
                                        return 'Password must be at least 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  if (authProvider.errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16.0, left: 8.0),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline_rounded,
                                            color: errorColor,
                                            size: 16,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              authProvider.errorMessage!,
                                              style: GoogleFonts.outfit(
                                                color: errorColor,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 32),
                                  _buildSignupButton(authProvider, size),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Divider(
                                          color: Colors.white30,
                                          thickness: 1,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Text(
                                          'OR',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white54,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Divider(
                                          color: Colors.white30,
                                          thickness: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  _buildGoogleSignupButton(authProvider, size),
                                  const SizedBox(height: 24),
                                  Center(
                                    child: TextButton(
                                      onPressed: () => Navigator.pushNamed(
                                          context, '/login'),
                                      style: TextButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                      ),
                                      child: RichText(
                                        text: TextSpan(
                                          text: 'Already have an account? ',
                                          style: GoogleFonts.outfit(
                                            color: Colors.white70,
                                            fontSize: 15,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Log in',
                                              style: GoogleFonts.outfit(
                                                color: secondaryColor,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white10,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(
            color: Colors.white60,
            fontSize: 15,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: Colors.white60,
            size: 20,
          ),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: secondaryColor.withOpacity(0.7),
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: errorColor,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: errorColor,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          errorStyle: GoogleFonts.outfit(
            color: errorColor,
            fontSize: 12,
          ),
        ),
        validator: validator,
        cursorColor: secondaryColor,
        cursorWidth: 1.5,
        cursorRadius: const Radius.circular(1),
        onTap: () {
          HapticFeedback.lightImpact();
        },
      ),
    );
  }

  Widget _buildSignupButton(AuthProvider authProvider, Size size) {
    return SizedBox(
      width: size.width,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading
            ? null
            : () async {
                HapticFeedback.mediumImpact();
                FocusScope.of(context).unfocus();

                if (_formKey.currentState!.validate()) {
                  setState(() {
                    _isLoading = true;
                  });

                  await authProvider.signUpWithEmail(
                    _emailController.text.trim(),
                    _passwordController.text.trim(),
                    _nameController.text.trim(),
                  );

                  setState(() {
                    _isLoading = false;
                  });

                  if (authProvider.user != null) {
                    Navigator.pushReplacementNamed(context, '/profile_setup');
                  }
                }
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: secondaryColor.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: _isLoading
            ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Create account',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGoogleSignupButton(AuthProvider authProvider, Size size) {
    return SizedBox(
      width: size.width,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _isLoading
            ? null
            : () async {
                HapticFeedback.mediumImpact();
                setState(() {
                  _isLoading = true;
                });

                await authProvider.signInWithGoogle();

                setState(() {
                  _isLoading = false;
                });

                if (authProvider.user != null) {
                  Navigator.pushReplacementNamed(context, '/profile_setup');
                }
              },
        icon: Image.asset(
          'assets/images/google(1).png',
          width: 20,
          height: 20,
        ),
        label: Text(
          'Continue with Google',
          style: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          shadowColor: Colors.black.withOpacity(0.1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.white10, width: 1),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
