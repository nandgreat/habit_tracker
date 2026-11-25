import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controllers/habit_controller.dart';
//import 'package:habit_tracker/models/habit_model.dart';

/// What the detail screen reports back to [HomeScreen] when it closes.


/// Week 4 topic: a second screen reached via `Navigator`, receiving
/// data (the tapped [Habit]) and returning a result on the way back.
class HabitDetailScreen extends GetView<HabitController> {
  final String habitId;

  const HabitDetailScreen({
    super.key,
    required this.habitId,
  });



  Future<void> _rename() async {
    final habit = controller.findHabit(habitId);

    if (habit == null) return;

    var editedName = habit.name;

    final newName = await Get.dialog<String>(
      AlertDialog(
        title: const Text('Rename Habit'),
        content: TextFormField(
          initialValue: habit.name,
          autofocus: true,
          onChanged: (value) => editedName = value,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(
              result: editedName.trim(),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (newName != null && newName.isNotEmpty) {
      await controller.renameHabit(habitId, newName);
    }
  }

  Future<void> _confirmDelete() async {
    final habit = controller.findHabit(habitId);

    if (habit == null) return;

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Habit?'),
        content: Text(
          'This removes "${habit.name}" and its streak permanently.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Get.theme.colorScheme.error,
            ),
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      Get.back();
      await controller.deleteHabit(habitId);
    }
  }

@override
Widget build(BuildContext context) {
  final theme = Theme.of(context);

  return Obx(() {
    final habit = controller.findHabit(habitId);

    if (habit == null) {
      return const Scaffold(
        body: SizedBox.shrink(),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Habit Details'),
          actions: [
            IconButton(onPressed: _rename, icon: const Icon(Icons.edit_outlined)),
            IconButton(onPressed: _confirmDelete, icon: const Icon(Icons.delete_outline)),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
              '${habit.streak ?? 0} days',
              style: theme.textTheme.headlineMedium,
              ),
              Text(
                'Last Completed on ${_formatDate(habit.lastCompletedOn.toString())}',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.outline),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Current Streak', style: theme.textTheme.bodyMedium),
                        Text('${habit.streak} days', style: theme.textTheme.headlineMedium),
                      ],
                    ),
                    const Icon(Icons.local_fire_department, size: 40),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => controller.toggleHabit(habitId),
                icon: Icon(
                  (habit.completedToday ?? false)
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                ),

                label: Text(
                  (habit.completedToday ?? false)
                      ? 'Marked Done Today'
                      : 'Mark as Done Today',
                ),
              ),
            ],
          ),
        ),
        );
        }
    );
  }

  String _formatDate(String inputDate) {
    try {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ];

      var date = DateTime.parse(inputDate);
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }catch(e){
      return "invalid date";
    }
  }
}
