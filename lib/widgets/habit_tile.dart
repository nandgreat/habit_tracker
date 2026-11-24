import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit_model.dart';


/// One row in the habit list: a tap-to-toggle circle, the habit name,
/// and its current streak. Tapping the row body (not the circle) opens
/// the detail screen.
class HabitTile extends StatelessWidget {
  final HabitModel habit;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const HabitTile({
    super.key,
    required this.habit,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: onToggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (habit.completedToday ?? false)
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              border: Border.all(color: theme.colorScheme.primary, width: 2),
            ),
            child: (habit.completedToday ?? false)
                ? Icon(Icons.check, color: theme.colorScheme.onPrimary, size: 22)
                : null,
          ),
        ),
        title: Text(habit.name, style: theme.textTheme.titleMedium),
        subtitle: Text(
          habit.streak == 0
              ? 'No streak yet — mark it done today!'
              : '${habit.streak}-day streak 🔥',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
