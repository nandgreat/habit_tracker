import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit_model.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controllers/habit_controller.dart';

//import '../../services/habit_repository.dart';

import '../widgets/habit_tile.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';


/// The home screen: today's progress, the habit list, and the entry
/// points into the add/detail screens. This is where Weeks 2-4 of the
/// lesson plan come together.


class HomeScreen extends GetView<HabitController> {
  const HomeScreen({super.key});

  void _addHabit() {
    if (controller.isLoading.value) return;

    Get.to(() => const AddHabitScreen());
  }

  void _toggleHabit(HabitModel habit) {
    controller.toggleHabit(habit.id);
  }

  Future<bool> _confirmDelete(
      BuildContext context, HabitModel habit
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: Text('This removes "${habit.name}" and its streak permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    return confirmed ?? false;
  }

  void _openDetail(HabitModel habit) {
    Get.to(
          () => HabitDetailScreen(habitId: habit.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Habit Tracker'),
      ),
      body: Obx(() => controller.isLoading.value
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          if (controller.habits.isNotEmpty)
            _buildProgressHeader(
              context,
              controller.completedCount,
            ),

          Expanded(
            child: controller.habits.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 88,
              ),
              itemCount: controller.habits.length,
              itemBuilder: (context, index) {
                final habit = controller.habits[index];

                return Dismissible(
                  key: ValueKey(habit.id),
                  direction: DismissDirection.endToStart,
                  confirmDismiss: (_) =>
                      _confirmDelete(context, habit),
                  onDismissed: (_) => controller.deleteHabit(habit.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Theme.of(context)
                          .colorScheme.onErrorContainer,
                    ),
                  ),
                  child: HabitTile(
                    habit: habit,
                    onToggle: () => _toggleHabit(habit),
                    onTap: () => _openDetail(habit),
                  ),
                );
              },
            ),
          ),
        ],
      )
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addHabit,
        icon: const Icon(Icons.add),
        label: const Text('Add Habit'),
      ),
    );
  }

  Widget _buildProgressHeader(BuildContext context, int completedCount) {
    final theme = Theme.of(context);
    final total = controller.habits.length;
    final progress = total == 0 ? 0.0 : completedCount / total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Today's Progress", style: theme.textTheme.titleMedium),
              Text('$completedCount/$total', style: theme.textTheme.titleMedium),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.self_improvement, size: 72, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text('No habits yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Tap "Add Habit" below to start building your first one.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
            ),
          ],
        ),
      ),
    );
  }
}
