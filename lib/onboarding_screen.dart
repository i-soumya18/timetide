import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> _goals = ['Productivity', 'Health', 'Study'];
  final List<String> _selectedGoals = [];
  TimeOfDay _wakeUpTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _bedTime = const TimeOfDay(hour: 23, minute: 0);
  bool _timeBasedReminders = true;
  bool _locationBasedReminders = false;
  bool _repeatingReminders = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8ECAE6), Color(0xFF219EBC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildGoalSelectionPage(),
                  _buildTimeSettingsPage(context),
                  _buildReminderSettingsPage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      // Navigate to authentication screen
                      Navigator.pushReplacementNamed(context, '/auth');
                    },
                    child: const Text(
                      'Skip',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Row(
                    children: List.generate(3, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFFFFB703)
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_currentPage < 2) {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        // Save preferences and navigate to auth screen
                        Navigator.pushReplacementNamed(context, '/auth');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFB703),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(_currentPage == 2 ? 'Finish' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Select Your Goals',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ..._goals.map((goal) {
            return CheckboxListTile(
              title: Text(goal, style: const TextStyle(color: Colors.white)),
              value: _selectedGoals.contains(goal),
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedGoals.add(goal);
                  } else {
                    _selectedGoals.remove(goal);
                  }
                });
              },
              checkColor: const Color(0xFF219EBC),
              activeColor: const Color(0xFFFFB703),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTimeSettingsPage(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Set Your Schedule',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Wake-Up Time', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              _wakeUpTime.format(context),
              style: const TextStyle(color: Colors.white70),
            ),
            onTap: () async {
              final selectedTime = await showTimePicker(
                context: context,
                initialTime: _wakeUpTime,
              );
              if (selectedTime != null) {
                setState(() {
                  _wakeUpTime = selectedTime;
                });
              }
            },
          ),
          ListTile(
            title: const Text('Bedtime', style: TextStyle(color: Colors.white)),
            subtitle: Text(
              _bedTime.format(context),
              style: const TextStyle(color: Colors.white70),
            ),
            onTap: () async {
              final selectedTime = await showTimePicker(
                context: context,
                initialTime: _bedTime,
              );
              if (selectedTime != null) {
                setState(() {
                  _bedTime = selectedTime;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReminderSettingsPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Reminder Preferences',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Time-Based Reminders', style: TextStyle(color: Colors.white)),
            value: _timeBasedReminders,
            onChanged: (value) {
              setState(() {
                _timeBasedReminders = value;
              });
            },
            activeColor: const Color(0xFFFFB703),
          ),
          SwitchListTile(
            title: const Text('Location-Based Reminders', style: TextStyle(color: Colors.white)),
            value: _locationBasedReminders,
            onChanged: (value) {
              setState(() {
                _locationBasedReminders = value;
              });
            },
            activeColor: const Color(0xFFFFB703),
          ),
          SwitchListTile(
            title: const Text('Repeating Reminders', style: TextStyle(color: Colors.white)),
            value: _repeatingReminders,
            onChanged: (value) {
              setState(() {
                _repeatingReminders = value;
              });
            },
            activeColor: const Color(0xFFFFB703),
          ),
        ],
      ),
    );
  }
}