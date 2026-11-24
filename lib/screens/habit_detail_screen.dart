import 'package:flutter/material.dart';
import 'package:habit_tracker/models/habit_model.dart';

/// What the detail screen reports back to [HomeScreen] when it closes.
class HabitDetailResult {
  final bool deleted;
  final HabitModel? updatedHabit;

  const HabitDetailResult({this.deleted = false, this.updatedHabit});
}

/// Week 4 topic: a second screen reached via `Navigator`, receiving
/// data (the tapped [Habit]) and returning a result on the way back.
class HabitDetailScreen extends StatefulWidget {
  final HabitModel habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  State<HabitDetailScreen> createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  late HabitModel _habit;

  @override
  void initState() {
    super.initState();
    _habit = widget.habit;
  }

  void _toggleToday() {
    setState(() {
      final nowCompleting = !(_habit.completedToday ?? false);
      _habit = _habit.copyWith(
        completedToday: nowCompleting,
        streak: nowCompleting
            ? (_habit.streak ?? 0) + 1
            : ((_habit.streak ?? 0) > 0 ? (_habit.streak ?? 0) - 1 : 0),
        lastCompletedOn: nowCompleting ? DateTime.now().toString() : _habit.lastCompletedOn,
      );
    });
  }

  Future<void> _rename() async {
    final controller = TextEditingController(text: _habit.name);
    final newName = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Rename Habit'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      setState(() => _habit = _habit.copyWith(name: newName));
    }
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Habit?'),
        content: Text('This removes "${_habit.name}" and its streak permanently.'),
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
    if (confirmed == true && mounted) {
      Navigator.pop(context, const HabitDetailResult(deleted: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.pop(context, HabitDetailResult(updatedHabit: _habit));
      },
      child: Scaffold(
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
              Text(_habit.name, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Last Completed on ${_formatDate(_habit.lastCompletedOn.toString())}',
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
                        Text('${_habit.streak} days', style: theme.textTheme.headlineMedium),
                      ],
                    ),
                    const Icon(Icons.local_fire_department, size: 40),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _toggleToday,
                icon: Icon(
                  (_habit.completedToday ?? false)
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                ),
                label: Text(
                  (_habit.completedToday ?? false) ? 'Marked Done Today' : 'Mark as Done Today',
                ),
              ),
            ],
          ),
        ),
      ),
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
