import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/widgets/vw_card.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';

/// One row in the selected-day event list (plan P3-CAL-1), restyled as a flat
/// card with a colour-coded accent bar (plan2.md P10-CAL-2).
///
/// The colour identifies the event but carries no meaning of its own, so it
/// lives in a bar rather than behind text: the title and time keep the theme's
/// own `onSurface` / `onSurfaceVariant` colours and stay legible whatever
/// colour an event was given, in either theme.
class EventListTile extends StatelessWidget {
  const EventListTile({required this.event, this.onTap, super.key});

  /// Width of the accent bar. Wide enough to read as deliberate, narrow enough
  /// not to compete with the title.
  static const double accentWidth = 4;

  final CalendarEventModel event;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return VWCard(
      variant: VWCardVariant.flat,
      onTap: onTap,
      // The bar has to reach the card's rounded edge, so the card's own padding
      // is replaced by padding on the text column.
      padding: EdgeInsets.zero,
      child: MergeSemantics(
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ExcludeSemantics(
                child: Container(
                  width: accentWidth,
                  color: Color(event.colorValue),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        event.title,
                        style: theme.textTheme.titleSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        _timeLabel(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
