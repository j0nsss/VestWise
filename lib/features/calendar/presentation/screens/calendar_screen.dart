import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_strings.dart';

/// Placeholder. Full screen lands in Phase 3 (P3-CAL-1).
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.calendar)),
      body: const Center(child: Text('Calendar')),
    );
  }
}
