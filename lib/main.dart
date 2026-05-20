import 'package:awesome_flutter_skills/features/infinite_scroll/view/infinite_scroll_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: InfiniteScrollView());
  }
}
