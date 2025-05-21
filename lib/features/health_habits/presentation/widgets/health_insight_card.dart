import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timetide/features/health_habits/data/models/health_metric_model.dart';

// Default callback for the onUpdate parameter
void _defaultOnUpdate(int value) {}

class HealthInsightCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final List<HealthMetricModel> metrics;
  final String type;
  final int goal;
  final Function(int) onUpdate;

  const HealthInsightCard({
    super.key,
    required this.title,
    required this.icon,
    required this.metrics,
    required this.type,
    required this.goal,
    this.onUpdate = _defaultOnUpdate,
  });

  @override
  State<HealthInsightCard> createState() => _HealthInsightCardState();
}

class _HealthInsightCardState extends State<HealthInsightCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  int _currentValue = 0;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();

    // Animation controller setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutCubic),
      ),
    );

    // Initialize with the current day's metric
    final today = DateTime.now();
    final todayMetric = widget.metrics.firstWhere(
          (m) =>
      m.date.day == today.day &&
          m.date.month == today.month &&
          m.date.year == today.year,
      orElse: () => HealthMetricModel(
          id: '', userId: '', date: today, type: widget.type, value: 0),
    );

    _currentValue = todayMetric.value;

    // Set up progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _currentValue / widget.goal,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Start animation after a brief delay
    Future.delayed(const Duration(milliseconds: 200), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleUpdate() {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
      _currentValue = _currentValue + 1;
    });

    // Provide feedback
    HapticFeedback.mediumImpact();

    // Set up new animation
    _animationController.stop();
    _progressAnimation = Tween<double>(
      begin: (_currentValue - 1) / widget.goal,
      end: _currentValue / widget.goal,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.reset();
    _animationController.duration = const Duration(milliseconds: 500);
    _animationController.forward().then((_) {
      setState(() {
        _isUpdating = false;
      });
      widget.onUpdate(_currentValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    final progressPercentage = (_currentValue / widget.goal * 100).toStringAsFixed(0);
    final progressColor = _getProgressColor(_currentValue / widget.goal);
    final remainingColor = Color(0xFF2A2A2A);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF252525),
                    const Color(0xFF1A1A1A),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with icon and title
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF613DC1).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            widget.icon,
                            color: const Color(0xFF613DC1),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003459).withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Goal: ${widget.goal}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Progress Visualization
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Chart background
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: const Color(0xFF252525),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                          ),

                          // Dashed circle indicator
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: CircularProgressIndicator(
                              value: 1,
                              strokeWidth: 4,
                              color: Colors.white.withOpacity(0.1),
                              backgroundColor: Colors.transparent,
                            ),
                          ),

                          // Primary progress indicator
                          SizedBox(
                            width: 160,
                            height: 160,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0, end: _currentValue / widget.goal),
                              duration: const Duration(milliseconds: 1000),
                              curve: Curves.easeOutCubic,
                              builder: (context, value, child) {
                                return CircularProgressIndicator(
                                  value: value,
                                  strokeWidth: 8,
                                  strokeCap: StrokeCap.round,
                                  color: progressColor,
                                  backgroundColor: Colors.transparent,
                                );
                              },
                            ),
                          ),

                          // Center text info
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TweenAnimationBuilder<double>(
                                tween: Tween<double>(begin: 0, end: double.parse(progressPercentage)),
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Text(
                                    '${value.toInt()}%',
                                    style: GoogleFonts.poppins(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$_currentValue/${widget.goal}',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Bottom action area
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Current status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progress',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.6),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getProgressText(_currentValue / widget.goal),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: progressColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Update button
                        AnimatedScale(
                          scale: _isUpdating ? 0.9 : 1.0,
                          duration: const Duration(milliseconds: 200),
                          child: InkWell(
                            onTap: _handleUpdate,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF613DC1),
                                    const Color(0xFF613DC1).withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF613DC1).withOpacity(0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Update',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.add_circle_outline_rounded,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) {
      return const Color(0xFF00C853); // Completed
    } else if (progress >= 0.7) {
      return const Color(0xFFA23B72); // Berry - almost there
    } else if (progress >= 0.4) {
      return const Color(0xFF613DC1); // Purple - getting there
    } else {
      return const Color(0xFF003459); // Navy - just started
    }
  }

  String _getProgressText(double progress) {
    if (progress >= 1.0) {
      return 'Goal Reached!';
    } else if (progress >= 0.7) {
      return 'Almost There!';
    } else if (progress >= 0.4) {
      return 'Getting There';
    } else if (progress > 0) {
      return 'Just Started';
    } else {
      return 'Not Started';
    }
  }
}