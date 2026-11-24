import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit_model.dart';

import '../../services/habit_repository.dart';
import '../../widgets/habit_tile.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';


/// The home screen: today's progress, the habit list, and the entry
/// points into the add/detail screens. This is where Weeks 2-4 of the
/// lesson plan come together.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HabitRepository _repository = HabitRepository();
  List<HabitModel> _habits = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHabits();
  }

  Future<void> _loadHabits() async {
    final habits = await _repository.loadHabits();
    setState(() {
      _habits = habits.map((h) => h.refreshedForToday()).toList();
      _isLoading = false;
    });
    await _repository.saveHabits(_habits);
  }

  Future<void> _addHabit() async {
    final newHabit = await Navigator.push<HabitModel>(
      context,
      MaterialPageRoute(builder: (_) => const AddHabitScreen()),
    );
    if (newHabit == null) return;
    setState(() => _habits.add(newHabit));
    await _repository.saveHabits(_habits);
  }

  void _toggleHabit(HabitModel habit) {
    setState(() {
      final index = _habits.indexWhere((h) => h.id == habit.id);
      if (index == -1) return;
      final current = _habits[index];
      final nowCompleting = !current.completedToday!;
      _habits[index] = current.copyWith(
        completedToday: nowCompleting,
        streak: nowCompleting
            ? current.streak! + 1
            : (current.streak! > 0 ? current.streak! - 1 : 0),
        lastCompletedOn: nowCompleting ? DateTime.now().toString() : current.lastCompletedOn,
      );
    });
    _repository.saveHabits(_habits);
  }

  Future<bool> _confirmDelete(HabitModel habit) async {
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

  void _deleteHabit(HabitModel habit) {
    setState(() => _habits.removeWhere((h) => h.id == habit.id));
    _repository.saveHabits(_habits);
  }

  Future<void> _openDetail(HabitModel habit) async {
    final result = await Navigator.push<HabitDetailResult>(
      context,
      MaterialPageRoute(builder: (_) => HabitDetailScreen(habit: habit)),
    );
    if (result == null) return;
    setState(() {
      if (result.deleted) {
        _habits.removeWhere((h) => h.id == habit.id);
      } else if (result.updatedHabit != null) {
        final index = _habits.indexWhere((h) => h.id == habit.id);
        if (index != -1) _habits[index] = result.updatedHabit!;
      }
    });
    await _repository.saveHabits(_habits);
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _habits.where((h) => h.completedToday ?? false).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Habit Tracker')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_habits.isNotEmpty) _buildProgressHeader(context, completedCount),

                Expanded(
                  child: _habits.isEmpty
                      ? _buildEmptyState(context)
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 88),
                          itemCount: _habits.length,
                          itemBuilder: (context, index) {
                            final habit = _habits[index];
                            return Dismissible(
                              key: ValueKey(habit.id),
                              direction: DismissDirection.endToStart,
                              confirmDismiss: (_) => _confirmDelete(habit),
                              onDismissed: (_) => _deleteHabit(habit),
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.errorContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.onErrorContainer,
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
    final total = _habits.length;
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
