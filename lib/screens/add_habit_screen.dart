import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/controllers/habit_controller.dart';

//import 'package:habit_tracker/models/habit_model.dart';

/// Week 3 topic in the lesson plan: a form with a text field, a save
/// button, and basic validation. Returns the new [Habit] to the
/// caller via `Navigator.pop` — no shared state needed.
class AddHabitScreen extends StatefulWidget {
  const AddHabitScreen({super.key});

  @override
  State<AddHabitScreen> createState() => _AddHabitScreenState();
}

class _AddHabitScreenState extends State<AddHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _habitController = TextEditingController();

  @override
  void dispose() {
    _habitController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await Get.find<HabitController>().addHabit(
      _habitController.text,
    );

    if (!mounted) return;

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Habit')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'What habit do you want to build?',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _habitController,
                autofocus: true,
                decoration: InputDecoration(hintText: "e.g Pray daily"),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Give your habit a name first.';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Save Habit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField CustomTextField(
    TextEditingController controller,
    String hintText, {
    Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      autofocus: true,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(hintText: hintText),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Give your habit a name first.';
        }
        return null;
      },
      onFieldSubmitted: onFieldSubmitted,
    );
  }
}
