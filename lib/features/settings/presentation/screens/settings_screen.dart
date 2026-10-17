import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_strings.dart';

/// Placeholder. Full screen lands in Phase 5 (P5-T4).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.settings)),
      body: const Center(child: Text('Settings')),
    );
  }
}
