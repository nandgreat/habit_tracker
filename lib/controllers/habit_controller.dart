import 'package:get/get.dart';
import 'package:habit_tracker/models/habit_model.dart';
import 'package:habit_tracker/services/habit_repository.dart';

class HabitController extends GetxController {
  final HabitRepository _repository = HabitRepository();

  final habits = <HabitModel>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadHabits();
  }

  Future<void> loadHabits() async {
    final storedHabits = await _repository.loadHabits();

    habits.assignAll(
      storedHabits.map((h) => h.refreshedForToday()).toList(),
    );

    isLoading.value = false;

    await _repository.saveHabits(habits.toList());
  }

  Future<void> addHabit(String name) async {
    final now = DateTime.now();

    final newHabit = HabitModel(
      id: now.microsecondsSinceEpoch.toString(),
      name: name.trim(),
      createdAt: now.toString(),
      streak: 0,
      completedToday: false,
    );

    habits.add(newHabit);

    await _repository.saveHabits(habits.toList());
  }

  Future<void> deleteHabit(String id) async {
    habits.removeWhere((h) => h.id == id);

    await _repository.saveHabits(habits.toList());
  }

  Future<void> toggleHabit(String id) async {
    final index = habits.indexWhere((h) => h.id == id);

    if (index == -1) return;

    final current = habits[index];

    final nowCompleting = !(current.completedToday ?? false);

    final currentStreak = current.streak ?? 0;

    habits[index] = current.copyWith(
      completedToday: nowCompleting,
      streak: nowCompleting
          ? currentStreak + 1
          : (currentStreak > 0 ? currentStreak - 1 : 0),
      lastCompletedOn: nowCompleting
          ? DateTime.now().toString()
          : current.lastCompletedOn,
    );

    await _repository.saveHabits(habits.toList());
  }

  Future<void> renameHabit(String id, String newName) async {
    final index = habits.indexWhere((h) => h.id == id);

    if (index == -1) return;

    if (newName.trim().isEmpty) return;

    habits[index] = habits[index].copyWith(
      name: newName.trim(),
    );

    await _repository.saveHabits(habits.toList());
  }

  HabitModel? findHabit(String id) {
    final index = habits.indexWhere((h) => h.id == id);

    if (index == -1) return null;

    return habits[index];
  }

  int get completedCount {
    return habits.where((h) => h.completedToday ?? false).length;
  }

}


