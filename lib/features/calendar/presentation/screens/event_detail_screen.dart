import 'package:flutter/material.dart';

/// Placeholder. Full form lands in Phase 3 (P3-CAL-2).
/// `:id == 'new'` means the create flow.
class EventDetailScreen extends StatelessWidget {
  const EventDetailScreen({required this.eventId, super.key});

  final String? eventId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(eventId == 'new' ? 'New event' : 'Event')),
      body: Center(child: Text('Event detail ($eventId)')),
    );
  }
}
