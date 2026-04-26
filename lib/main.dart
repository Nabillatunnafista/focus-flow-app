// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/task_service.dart';
import 'screens/home/home_screen.dart';

void main() {
  runApp(const FocusFlowApp());
}

class FocusFlowApp extends StatelessWidget {
  const FocusFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<TaskService>(
          create: (_) => TaskService(),
        ),
      ],
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(),
      ),
    );
  }
}