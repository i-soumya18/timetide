import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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

class _HealthInsightCardState extends State<HealthInsightCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  int _currentValue = 0;
  bool _isUpdating = false;
  late HealthMetricModel _todayMetric;
  int _updateAmount = 1;
  bool _showHistoryChart = false;

  // Weekly and monthly stats for insights
  int _weeklyAverage = 0;
  int _weeklyTotal = 0;
  int _monthlyAverage = 0;
  int _bestDay = 0;

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
    _initializeMetrics();

    // Set up progress animation
    _setupProgressAnimation();

    // Start animation after a brief delay
    Future.delayed(const Duration(milliseconds: 200), () {
      _animationController.forward();
    });
  }

  void _initializeMetrics() {
    final today = DateTime.now();

    // Find today's metric
    _todayMetric = widget.metrics.firstWhere(
      (m) => _isSameDay(m.date, today),
      orElse: () => HealthMetricModel(
          id: '', userId: '', date: today, type: widget.type, value: 0),
    );

    _currentValue = _todayMetric.value;

    // Calculate weekly metrics
    final oneWeekAgo = today.subtract(const Duration(days: 7));
    final weeklyMetrics = widget.metrics
        .where((m) => m.date.isAfter(oneWeekAgo) && !_isSameDay(m.date, today))
        .toList();

    int weeklySum = weeklyMetrics.fold(0, (sum, metric) => sum + metric.value);
    _weeklyTotal = weeklySum;
    _weeklyAverage = weeklyMetrics.isNotEmpty
        ? (weeklySum / weeklyMetrics.length).round()
        : 0;

    // Calculate monthly metrics
    final oneMonthAgo = DateTime(today.year, today.month - 1, today.day);
    final monthlyMetrics =
        widget.metrics.where((m) => m.date.isAfter(oneMonthAgo)).toList();

    _monthlyAverage = monthlyMetrics.isNotEmpty
        ? (monthlyMetrics.fold(0, (sum, metric) => sum + metric.value) /
                monthlyMetrics.length)
            .round()
        : 0;

    // Find best day
    _bestDay = widget.metrics.isEmpty
        ? 0
        : widget.metrics
            .reduce((curr, next) => curr.value > next.value ? curr : next)
            .value;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.day == b.day && a.month == b.month && a.year == b.year;
  }

  void _setupProgressAnimation() {
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: _currentValue / widget.goal,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void didUpdateWidget(HealthInsightCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.metrics != widget.metrics) {
      _initializeMetrics();
      _setupProgressAnimation();
      if (!_animationController.isAnimating) {
        _animationController.reset();
        _animationController.forward();
      }
    }
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
      _currentValue = _currentValue + _updateAmount;
    });

    // Provide feedback
    HapticFeedback.mediumImpact();

    // Set up new animation
    _animationController.stop();
    _progressAnimation = Tween<double>(
      begin: (_currentValue - _updateAmount) / widget.goal,
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

  void _adjustUpdateAmount(int amount) {
    setState(() {
      _updateAmount = amount;
    });
    HapticFeedback.lightImpact();
  }

  List<FlSpot> _getChartData() {
    // Sort metrics by date
    final sortedMetrics = [...widget.metrics];
    sortedMetrics.sort((a, b) => a.date.compareTo(b.date));

    // Get data for the last 7 days
    final today = DateTime.now();
    final spots = <FlSpot>[];

    // Create a map of dates for the last 7 days
    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final dayValue = sortedMetrics
          .firstWhere(
            (m) => _isSameDay(m.date, date),
            orElse: () => HealthMetricModel(
                id: '', userId: '', date: date, type: widget.type, value: 0),
          )
          .value;

      // X-axis: day index (0-6), Y-axis: value
      spots.add(FlSpot(6 - i.toDouble(), dayValue.toDouble()));
    }

    return spots;
  }

  // New method that converts weekly total to a meaningful insight
  String _weeklyInsight() {
    if (_weeklyTotal == 0) return "Start tracking this week!";

    if (widget.type == 'water') {
      return "This week: $_weeklyTotal glasses";
    } else if (widget.type == 'steps') {
      final miles = (_weeklyTotal / 2000).toStringAsFixed(1);
      return "~$miles miles this week";
    } else {
      return "Weekly total: $_weeklyTotal";
    }
  }

  // New method that provides monthly insight
  String _monthlyInsight() {
    if (_monthlyAverage == 0) return "No monthly data yet";

    final percentOfGoal = (_monthlyAverage / widget.goal * 100).round();
    return "Monthly avg: $percentOfGoal% of goal";
  }

  @override
  Widget build(BuildContext context) {
    final progressPercentage =
        (_currentValue / widget.goal * 100).toStringAsFixed(0);
    final progressColor = _getProgressColor(_currentValue / widget.goal);
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 380;

    // Set the card width based on screen size
    final cardWidth =
        isSmallScreen ? screenSize.width * 0.82 : screenSize.width * 0.44;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: cardWidth,
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
                padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 16 : 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Goal: ${widget.goal}',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withOpacity(0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            _showHistoryChart
                                ? Icons.show_chart
                                : Icons.bar_chart_rounded,
                            color: Colors.white.withOpacity(0.7),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _showHistoryChart = !_showHistoryChart;
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Progress Visualization / Chart toggle
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: _showHistoryChart
                          ? _buildHistoryChart(isSmallScreen)
                          : _buildCircularProgress(
                              progressPercentage, progressColor, isSmallScreen),
                    ),

                    const SizedBox(height: 24),

                    // Insights section
                    Text(
                      'Quick Insights',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInsightItem(
                            icon: Icons.calendar_today,
                            value: '${_weeklyAverage}',
                            label: 'Avg/Day',
                            color: Colors.blue.shade300,
                          ),
                        ),
                        Expanded(
                          child: _buildInsightItem(
                            icon: Icons.star,
                            value: '${_bestDay}',
                            label: 'Best',
                            color: Colors.amber.shade300,
                          ),
                        ),
                        Expanded(
                          child: _buildInsightItem(
                            icon: Icons.trending_up,
                            value: '${_currentValue - _weeklyAverage}',
                            label: 'vs Avg',
                            color: _currentValue >= _weeklyAverage
                                ? Colors.green.shade300
                                : Colors.red.shade300,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

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
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Update controls
                        Row(
                          children: [
                            // Update amount selector
                            Visibility(
                              visible: widget.type != 'steps',
                              child: Container(
                                height: 38,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    _buildAmountButton(1),
                                    if (!isSmallScreen) _buildAmountButton(5),
                                    _buildAmountButton(10),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Update button
                            AnimatedScale(
                              scale: _isUpdating ? 0.9 : 1.0,
                              duration: const Duration(milliseconds: 200),
                              child: InkWell(
                                onTap: _handleUpdate,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        const Color(0xFF613DC1),
                                        const Color(0xFF613DC1)
                                            .withOpacity(0.8),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF613DC1)
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '+$_updateAmount',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountButton(int amount) {
    final isSelected = _updateAmount == amount;

    return InkWell(
      onTap: () => _adjustUpdateAmount(amount),
      child: Container(
        width: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF613DC1).withOpacity(0.5)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          '$amount',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryChart(bool isSmallScreen) {
    final spots = _getChartData();
    final chartSize = isSmallScreen ? 180.0 : 200.0;

    return Container(
      key: const ValueKey('history_chart'),
      height: chartSize,
      width: double.infinity,
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Last 7 Days',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: widget.goal / 4,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.white.withOpacity(0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final weekday = DateFormat('E').format(
                          DateTime.now()
                              .subtract(Duration(days: (6 - value.toInt()))),
                        );
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            weekday.substring(0, 1),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: widget.goal / 2,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF613DC1),
                        const Color(0xFFA23B72),
                      ],
                    ),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 6,
                          color: const Color(0xFFA23B72),
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF613DC1).withOpacity(0.3),
                          const Color(0xFFA23B72).withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => const Color(0xFF2A2A2A),
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        final date = DateTime.now()
                            .subtract(Duration(days: (6 - spot.x.toInt())));
                        final dateStr = DateFormat('MMM d').format(date);

                        return LineTooltipItem(
                          '$dateStr: ${spot.y.toInt()}',
                          GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      }).toList();
                    },
                  ),
                ),
                // Add goal line
                extraLinesData: ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: widget.goal.toDouble(),
                      color: Colors.green.withOpacity(0.7),
                      strokeWidth: 2,
                      dashArray: [5, 5],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.only(right: 5, bottom: 5),
                        style: TextStyle(
                          color: Colors.green.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                        labelResolver: (line) => 'Goal',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(
      String progressPercentage, Color progressColor, bool isSmallScreen) {
    final circleSize = isSmallScreen ? 140.0 : 160.0;

    return Center(
      key: const ValueKey('progress_circle'),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Chart background
          Container(
            width: circleSize,
            height: circleSize,
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
            width: circleSize,
            height: circleSize,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 4,
              color: Colors.white.withOpacity(0.1),
              backgroundColor: Colors.transparent,
            ),
          ),

          // Primary progress indicator
          SizedBox(
            width: circleSize,
            height: circleSize,
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return CircularProgressIndicator(
                  value: _progressAnimation.value,
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
                tween: Tween<double>(
                    begin: 0, end: double.parse(progressPercentage)),
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
              const SizedBox(height: 12),
              Text(
                _getDailyTip(),
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: Colors.white.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getDailyTip() {
    final progress = _currentValue / widget.goal;

    if (widget.type == 'water') {
      if (progress < 0.3) {
        return "Remember to stay hydrated throughout the day";
      } else if (progress < 0.6) {
        return "You're doing well! Keep drinking water";
      } else if (progress < 1.0) {
        return "Almost there! Just a few more glasses";
      } else {
        return "Great job staying hydrated today!";
      }
    } else if (widget.type == 'steps') {
      if (progress < 0.3) {
        return "Try taking the stairs or a short walk";
      } else if (progress < 0.6) {
        return "You're making good progress with your steps";
      } else if (progress < 1.0) {
        return "Almost at your goal! Keep moving";
      } else {
        return "You've crushed your step goal today!";
      }
    } else {
      return "Track your progress daily for best results";
    }
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) {
      return const Color(0xFF00C853); // Completed - Green
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
      return 'Making Progress';
    } else if (progress > 0) {
      return 'Just Started';
    } else {
      return 'Not Started';
    }
  }
}
