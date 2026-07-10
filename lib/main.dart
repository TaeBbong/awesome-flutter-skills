import 'package:awesome_flutter_skills/core/di/service_locator.dart';
import 'package:awesome_flutter_skills/features/home/home_view.dart';
import 'package:flutter/material.dart';

void main() {
  configureDependencies();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: HomeView());
  }
}
