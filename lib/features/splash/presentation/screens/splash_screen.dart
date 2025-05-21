import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Premium dark color palette
  static const Color primaryColor = Color(0xFF003459);
  static const Color accentColor = Color(0xFF6564DB);
  static const Color highlightColor = Color(0xFFA23B72);
  static const Color backgroundStartColor = Color(0xFF121212);
  static const Color backgroundEndColor = Color(0xFF1E1E2A);

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _taglineSlideAnimation;
  late Animation<double> _lineWidthAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Enhanced animation controller with smoother timing
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // Improved elastic scale animation for logo
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    // Subtle 3D rotation effect
    _rotateAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.1, end: 0.05),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: 0.0),
        weight: 60,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    // Logo fade-in with smoother transition
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.5, curve: Curves.easeIn),
      ),
    );

    // Slide-in animation for tagline
    _taglineSlideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOutCubic),
      ),
    );

    // Enhanced line decoration animation
    _lineWidthAnimation = Tween<double>(begin: 0.0, end: 70.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Pulsating glow effect for logo
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.7),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start animation
    _animationController.forward();

    // Navigate to main screen after delay
    Future.delayed(const Duration(milliseconds: 3200), () {
      Navigator.pushReplacementNamed(context, '/');
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [backgroundStartColor, backgroundEndColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Enhanced particle background
            Positioned.fill(
              child: ParticleBackground(
                particleCount: 40,
                primaryColor: accentColor.withOpacity(0.15),
                secondaryColor: highlightColor.withOpacity(0.12),
              ),
            ),

            // Abstract geometric shapes in background
            Positioned(
              top: -50,
              right: -30,
              child: ShapeWidget(
                color: primaryColor.withOpacity(0.08),
                size: 200,
              ),
            ),

            Positioned(
              bottom: -40,
              left: -20,
              child: ShapeWidget(
                color: highlightColor.withOpacity(0.08),
                size: 180,
              ),
            ),

            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Premium logo with glow effect and animations
                      Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: Opacity(
                          opacity: _opacityAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: highlightColor.withOpacity(_glowAnimation.value * 0.4),
                                  blurRadius: 25 * _glowAnimation.value,
                                  spreadRadius: 4 * _glowAnimation.value,
                                ),
                                BoxShadow(
                                  color: accentColor.withOpacity(_glowAnimation.value * 0.3),
                                  blurRadius: 35 * _glowAnimation.value,
                                  spreadRadius: 2 * _glowAnimation.value,
                                ),
                              ],
                            ),
                            child: Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const RadialGradient(
                                    colors: [
                                      accentColor,
                                      primaryColor,
                                    ],
                                    stops: [0.2, 1.0],
                                    radius: 0.8,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.auto_graph_rounded,
                                    size: 80,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Decorative lines with app name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: _lineWidthAnimation.value,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  highlightColor.withOpacity(0.8),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Opacity(
                            opacity: _opacityAnimation.value,
                            child: const Text(
                              'AI TASK',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.0,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          Container(
                            width: _lineWidthAnimation.value,
                            height: 2,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  highlightColor.withOpacity(0.8),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Opacity(
                        opacity: _opacityAnimation.value,
                        child: const Text(
                          'PLANNER',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 3.0,
                            height: 0.9,
                            color: accentColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Tagline with slide-in effect
                      Transform.translate(
                        offset: Offset(0, _taglineSlideAnimation.value),
                        child: Opacity(
                          opacity: 1.0 - _taglineSlideAnimation.value / 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Intelligent planning for productive days',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.white70,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Footer branding
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) {
                  return Opacity(
                    opacity: _animationController.value > 0.7
                        ? (_animationController.value - 0.7) / 0.3
                        : 0.0,
                    child: const Center(
                      child: Text(
                        'PREMIUM EDITION',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3.0,
                          color: Colors.white38,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Enhanced particle background with dual-color particles
class ParticleBackground extends StatefulWidget {
  final Color primaryColor;
  final Color secondaryColor;
  final int particleCount;

  const ParticleBackground({
    required this.primaryColor,
    required this.secondaryColor,
    this.particleCount = 30,
    super.key,
  });

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> with TickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    particles = List.generate(widget.particleCount, (index) {
      // Alternate between primary and secondary color
      final color = index % 2 == 0 ? widget.primaryColor : widget.secondaryColor;
      return Particle(color);
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) {
        return CustomPaint(
          painter: ParticlePainter(particles, _animationController.value),
          child: Container(),
        );
      },
    );
  }
}

class Particle {
  final double x = math.Random().nextDouble();
  final double y = math.Random().nextDouble();
  final double size = math.Random().nextDouble() * 4 + 1;
  final double speed = math.Random().nextDouble() * 0.02 + 0.01;
  final Color color;

  Particle(this.color);
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter(this.particles, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < particles.length; i++) {
      final particle = particles[i];

      // Create flowing movement pattern
      final yOffset = (math.sin((animation + particle.x) * math.pi * 2) * 0.1);
      final xOffset = (math.cos((animation + particle.y) * math.pi * 2) * 0.1);

      final position = Offset(
        ((particle.x + xOffset) % 1.0) * size.width,
        ((particle.y + yOffset) % 1.0) * size.height,
      );

      // Pulse opacity based on animation progress
      final opacity = (math.sin(animation * math.pi * 2 + particle.x * math.pi * 2) + 1) / 2 * 0.7 + 0.3;

      final paint = Paint()
        ..color = particle.color.withOpacity(opacity)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

      canvas.drawCircle(
        position,
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Abstract geometric shape for visual interest
class ShapeWidget extends StatelessWidget {
  final Color color;
  final double size;

  const ShapeWidget({
    required this.color,
    required this.size,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.3,
      child: CustomPaint(
        size: Size(size, size),
        painter: ShapePainter(color),
      ),
    );
  }
}

class ShapePainter extends CustomPainter {
  final Color color;

  ShapePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();

    // Create abstract hexagon shape
    path.moveTo(size.width * 0.5, 0);
    path.lineTo(size.width * 0.9, size.height * 0.25);
    path.lineTo(size.width * 0.9, size.height * 0.75);
    path.lineTo(size.width * 0.5, size.height);
    path.lineTo(size.width * 0.1, size.height * 0.75);
    path.lineTo(size.width * 0.1, size.height * 0.25);
    path.close();

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}