import 'package:flutter/material.dart';
import 'package:timetide/core/constants/colors.dart';

class GoalSelector extends StatelessWidget {
  final List<String> goals;
  final List<String> selectedGoals;
  final Function(String) onToggleGoal;

  const GoalSelector({
    super.key,
    required this.goals,
    required this.selectedGoals,
    required this.onToggleGoal,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: goals.length,
      itemBuilder: (context, index) {
        final goal = goals[index];
        final isSelected = selectedGoals.contains(goal);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: InkWell(
            onTap: () => onToggleGoal(goal),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: isSelected
                    ? AppColors.accent
                    : Colors.white.withOpacity(0.2),
              ),
              child: Row(
                children: [
                  Icon(
                    _getIconForGoal(goal),
                    color: Colors.white,
                    size: 24,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    goal,
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIconForGoal(String goal) {
    switch (goal.toLowerCase()) {
      case 'productivity':
        return Icons.rocket_launch;
      case 'health':
        return Icons.favorite;
      case 'study':
        return Icons.school;
      case 'work':
        return Icons.work;
      case 'family':
        return Icons.family_restroom;
      case 'finance':
        return Icons.attach_money;
      case 'fitness':
        return Icons.fitness_center;
      case 'travel':
        return Icons.flight;
      case 'mindfulness':
        return Icons.spa;
      default:
        return Icons.check_circle;
    }
  }
}
