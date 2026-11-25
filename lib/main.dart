import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:habit_tracker/screens/home_screen.dart';
import 'package:habit_tracker/theme.dart';
import 'package:habit_tracker/controllers/habit_controller.dart';


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Get.put(HabitController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: buildAppTheme(),
      home: const HomeScreen(),
    );
  }
}
