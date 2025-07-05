// lib/screens/daily_log_screen.dart
import 'package:flutter/material.dart';

class DailyLogScreen extends StatelessWidget {
  const DailyLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Actividades Diarias'),
      ),
      body: const Center(
        child: Text('Aquí se registrarán las actividades diarias.'),
      ),
    );
  }
}