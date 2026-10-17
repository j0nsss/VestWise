import 'package:flutter/material.dart';
import 'package:vestwise/core/constants/app_strings.dart';

/// Placeholder. Full composition lands in Phase 3 (P3-DASH-2).
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.dashboard)),
      body: const Center(child: Text('Dashboard')),
    );
  }
}
