import 'dart:convert';

import 'package:habit_tracker/models/habit_model.dart';
import 'package:habit_tracker/services/shared_preferences_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HabitRepository {
  static const _storageKey = 'habits_v1';

  SharedPreferencesHelper spHelper = SharedPreferencesHelper();

  Future<List<HabitModel>> loadHabits() async {
    return await spHelper.getStringList(_storageKey);
  }

  Future<void> saveHabits(List<HabitModel> habits) async {
    await spHelper.setStringList(_storageKey, habits);
  }
}
