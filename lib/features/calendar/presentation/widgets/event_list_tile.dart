import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';

/// One row in the selected-day event list (plan P3-CAL-1).
class EventListTile extends StatelessWidget {
  const EventListTile({required this.event, this.onTap, super.key});

  final CalendarEventModel event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color color = Color(event.colorValue);

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text(
        event.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(_timeLabel(), style: theme.textTheme.bodySmall),
    );
  }

  String _timeLabel() {
    if (event.isAllDay) {
      return 'All day';
    }
    final String start = DateFormat.jm().format(event.startDateTime);
    final DateTime? end = event.endDateTime;
    if (end == null) {
      return start;
    }
    return '$start – ${DateFormat.jm().format(end)}';
  }
}
