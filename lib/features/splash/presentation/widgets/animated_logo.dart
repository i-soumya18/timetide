import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedLogo extends StatefulWidget {
  final double size;
  final VoidCallback? onComplete;

  const AnimatedLogo({
    super.key,
    this.size = 150,
    this.onComplete,
  });

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;

  final List<_Particle> _particles = [];
  final int _particleCount = 20;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // Main animation controller for the logo
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Particle animation controller
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    // Scale animation for the logo
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2).chain(
          CurveTween(curve: Curves.easeOutCubic),
        ),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0).chain(
          CurveTween(curve: Curves.elasticOut),
        ),
        weight: 60,
      ),
    ]).animate(_mainController);

    // Subtle rotation animation for the logo
    _rotateAnimation = Tween<double>(
      begin: -0.05,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    // Fade in animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // Generate particles
    _generateParticles();

    // Start animation and trigger callback on completion
    _mainController.forward().then((_) {
      if (widget.onComplete != null) {
        widget.onComplete!();
      }
    });
  }

  void _generateParticles() {
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(
        _Particle(
          position: Offset(
            _random.nextDouble() * widget.size - (widget.size / 2),
            _random.nextDouble() * widget.size - (widget.size / 2),
          ),
          speed: 0.3 + _random.nextDouble() * 0.7,
          size: 3 + _random.nextDouble() * 5,
          color: [
            const Color(0xFF6564DB), // Purple
            const Color(0xFFA23B72), // Pink
            const Color(0xFF004643), // Dark teal
            const Color(0xFF183A37), // Darker green
          ][_random.nextInt(4)],
          delay: _random.nextDouble() * 0.5,
        ),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size * 1.5,
      height: widget.size * 1.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Custom particle effect
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size * 1.5, widget.size * 1.5),
                painter: _ParticlesPainter(
                  particles: _particles,
                  progress: _particleController.value,
                  maxDistance: widget.size * 0.75,
                  fadeAnimation: _fadeAnimation,
                ),
              );
            },
          ),

          // Glowing effect behind the logo
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: widget.size * 0.85 * _scaleAnimation.value,
                  height: widget.size * 0.85 * _scaleAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: const [
                        Color(0xFF6564DB),
                        Color(0x006564DB),
                      ],
                      stops: const [0.1, 1.0],
                      radius: 0.7 *
                          (1.2 - (_scaleAnimation.value - 0.8).clamp(0.0, 0.4)),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6564DB).withOpacity(0.3),
                        blurRadius: 20 * _scaleAnimation.value,
                        spreadRadius: 5 * _scaleAnimation.value,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Circular background for the logo
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  width: widget.size * 0.75 * _scaleAnimation.value,
                  height: widget.size * 0.75 * _scaleAnimation.value,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF004643), // Dark teal
                        Color(0xFF003459), // Dark blue
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Logo itself
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation.value * math.pi,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: widget.size * 0.6,
                      height: widget.size * 0.6,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/logo.png',
                        width: widget.size * 0.6,
                        height: widget.size * 0.6,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Ripple effect around the logo
          AnimatedBuilder(
            animation: _mainController,
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size * 1.5, widget.size * 1.5),
                painter: _RipplePainter(
                  color: const Color(0xFF6564DB),
                  progress: _mainController.value,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Custom painter for the dynamic particles effect
class _ParticlesPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final double maxDistance;
  final Animation<double> fadeAnimation;

  _ParticlesPainter({
    required this.particles,
    required this.progress,
    required this.maxDistance,
    required this.fadeAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var particle in particles) {
      // Calculate particle position based on time and its properties
      final particleProgress =
          ((progress + particle.delay) % 1.0) * particle.speed;
      final distance = maxDistance * particleProgress;

      // Calculate movement direction
      final magnitude = particle.position.distance;
      final direction = magnitude > 0
          ? Offset(particle.position.dx / magnitude,
              particle.position.dy / magnitude)
          : Offset.zero;
      final currentPos = center + (direction * distance);

      // Calculate opacity based on distance and animation progress
      double opacity = 0.0;
      if (particleProgress < 0.1) {
        opacity = particleProgress / 0.1; // Fade in
      } else if (particleProgress > 0.7) {
        opacity = 1.0 - ((particleProgress - 0.7) / 0.3); // Fade out
      } else {
        opacity = 1.0;
      }

      // Apply global fade animation
      opacity *= fadeAnimation.value;

      // Draw the particle
      final paint = Paint()
        ..color = particle.color.withOpacity(opacity.clamp(0.0, 1.0))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
          currentPos, particle.size * (1.0 - (particleProgress * 0.5)), paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlesPainter oldDelegate) {
    return progress != oldDelegate.progress ||
        fadeAnimation.value != oldDelegate.fadeAnimation.value;
  }
}

// Custom painter for the ripple effect
class _RipplePainter extends CustomPainter {
  final Color color;
  final double progress;

  _RipplePainter({
    required this.color,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Create 3 ripple waves with different timings
    for (int i = 0; i < 3; i++) {
      final rippleProgress = (progress - (i * 0.2)).clamp(0.0, 1.0);
      if (rippleProgress <= 0) continue;

      final radius = maxRadius * 0.5 * rippleProgress;
      double opacity = 0.0;

      // Fade opacity based on progress
      if (rippleProgress < 0.3) {
        opacity = rippleProgress / 0.3;
      } else {
        opacity = 1.0 - ((rippleProgress - 0.3) / 0.7);
      }

      final paint = Paint()
        ..color = color.withOpacity(opacity * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RipplePainter oldDelegate) {
    return progress != oldDelegate.progress;
  }
}

// Particle class to store individual particle properties
class _Particle {
  final Offset position;
  final double speed;
  final double size;
  final Color color;
  final double delay;

  _Particle({
    required this.position,
    required this.speed,
    required this.size,
    required this.color,
    required this.delay,
  });
}

class Random {
  final math.Random _random = math.Random();

  double nextDouble() {
    return _random.nextDouble();
  }

  int nextInt(int max) {
    return _random.nextInt(max);
  }
}
