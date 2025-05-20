import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _taglineOpacityAnimation;
  late Animation<double> _lineWidthAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller with longer duration for richer animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Enhanced scale animation with bouncy curve
    _scaleAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.elasticOut,
      ),
    );

    // Subtle rotation animation
    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutBack),
      ),
    );

    // Logo opacity animation
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.6, curve: Curves.easeIn),
      ),
    );

    // Delayed tagline animation
    _taglineOpacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );

    // Line decoration animation
    _lineWidthAnimation = Tween<double>(begin: 0.0, end: 60.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
      ),
    );

    // Start animation
    _animationController.forward();

    // Navigate to main screen after delay
    Future.delayed(const Duration(seconds: 3), () {
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
            colors: [Color(0xFF613DC1), Color(0xFF6564DB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Subtle animated particles
            Positioned.fill(
              child: ParticleBackground(
                color: const Color(0xFFA23B72).withOpacity(0.15),
              ),
            ),

            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with glow and animations
                      Transform.rotate(
                        angle: _rotateAnimation.value,
                        child: Opacity(
                          opacity: _opacityAnimation.value,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFA23B72).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Image.asset(
                                'assets/images/logo.png',
                                width: 140,
                                height: 140,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Decorative lines
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: _lineWidthAnimation.value,
                            height: 2,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Color(0xFFA23B72),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Opacity(
                            opacity: _opacityAnimation.value,
                            child: const Text(
                              'AI Task Planner',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            width: _lineWidthAnimation.value,
                            height: 2,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Color(0xFFA23B72),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Tagline with delayed fade-in
                      Opacity(
                        opacity: _taglineOpacityAnimation.value,
                        child: const Text(
                          'Effortlessly plan your day with AI',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white70,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
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

// Subtle particle animation in background
class ParticleBackground extends StatefulWidget {
  final Color color;

  const ParticleBackground({required this.color, super.key});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground> with TickerProviderStateMixin {
  late List<Particle> particles;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    particles = List.generate(30, (_) => Particle(widget.color));

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
  final double size = math.Random().nextDouble() * 3 + 1;
  final Color color;

  Particle(this.color);
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter(this.particles, this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(
            (math.sin(animation * math.pi * 2 + particle.x * math.pi * 2) + 1) / 2 * 0.8 + 0.2
        );

      canvas.drawCircle(
        Offset(
          particle.x * size.width,
          particle.y * size.height,
        ),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}