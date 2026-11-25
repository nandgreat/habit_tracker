import 'dart:convert';

import 'package:habit_tracker/models/habit_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {


  Future<List<HabitModel>> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(key) ?? <String>[];
    return raw
        .map((habit) => HabitModel.fromJson(jsonDecode(habit) as Map<String, dynamic>))
        .toList();
  }


  Future<void> setStringList(String key, List<HabitModel> habits) async {
    final prefs = await SharedPreferences.getInstance();

    final raw = habits.map((habit) =>
        jsonEncode(habit.toJson())).toList();

    await prefs.setStringList(key, raw);
  }
}