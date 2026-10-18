import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vestwise/core/constants/app_spacing.dart';
import 'package:vestwise/core/errors/failure.dart';
import 'package:vestwise/core/notifications/inexact_alarm_notice.dart';
import 'package:vestwise/core/notifications/notification_provider.dart';
import 'package:vestwise/core/notifications/notification_service.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/core/widgets/vw_app_bar.dart';
import 'package:vestwise/core/widgets/vw_button.dart';
import 'package:vestwise/core/widgets/vw_loading_indicator.dart';
import 'package:vestwise/core/widgets/vw_text_field.dart';
import 'package:vestwise/features/calendar/data/models/calendar_event_model.dart';
import 'package:vestwise/features/calendar/presentation/providers/calendar_providers.dart';

/// Event create/edit form with optional reminder scheduling (plan P3-CAL-2).
/// `':id' == 'new'` opens the create flow.
class EventDetailScreen extends ConsumerStatefulWidget {
  const EventDetailScreen({required this.eventId, super.key});

  final String? eventId;

  @override
  ConsumerState<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends ConsumerState<EventDetailScreen> {
  static const List<int> _reminderOptions = <int>[5, 10, 15, 30, 60, 1440];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  DateTime _start = DateTime.now().add(const Duration(hours: 1));
  DateTime? _end;
  bool _isAllDay = false;
  EventRepeat _repeat = EventRepeat.none;
  int? _reminderMinutesBefore;

  int? _eventId;
  int? _notificationId;
  bool _loading = true;
  bool _saving = false;

  bool get _isEditing => _eventId != null;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final String? raw = widget.eventId;
    final int? id = raw == null ? null : int.tryParse(raw);
    if (id == null || raw == RoutePaths.newId) {
      setState(() => _loading = false);
      return;
    }

    final CalendarEventModel? event =
        (await ref.read(calendarRepositoryProvider).getEventById(id))
            .dataOrNull;
    if (event != null) {
      _eventId = event.id;
      _titleController.text = event.title;
      _descriptionController.text = event.description ?? '';
      _start = event.startDateTime;
      _end = event.endDateTime;
      _isAllDay = event.isAllDay;
      _repeat = event.repeat;
      _reminderMinutesBefore = event.hasReminder
          ? event.reminderMinutesBefore
          : null;
      _notificationId = event.notificationId;
    }
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: VWAppBar(
        title: _isEditing ? 'Edit event' : 'New event',
        actions: <Widget>[
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete event',
              onPressed: _loading ? null : _confirmDelete,
            ),
        ],
      ),
      body: _loading
          ? const VWLoadingIndicator()
          : Form(key: _formKey, child: _buildForm(context)),
    );
  }

  Widget _buildForm(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: <Widget>[
        VWTextField(
          controller: _titleController,
          label: 'Title',
          textInputAction: TextInputAction.next,
          validator: (String? value) => (value == null || value.trim().isEmpty)
              ? 'Title is required'
              : null,
        ),
        const SizedBox(height: AppSpacing.lg),
        VWTextField(
          controller: _descriptionController,
          label: 'Description',
          maxLines: 3,
        ),
        const SizedBox(height: AppSpacing.lg),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('All day'),
          value: _isAllDay,
          onChanged: (bool value) => setState(() => _isAllDay = value),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text('Starts', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        OutlinedButton.icon(
          icon: const Icon(Icons.event),
          label: Text(_formatDateTime(_start)),
          onPressed: () => _pickStart(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Ends (optional)', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.event_available),
                label: Text(
                  _end == null ? 'No end time' : _formatDateTime(_end!),
                  overflow: TextOverflow.ellipsis,
                ),
                onPressed: () => _pickEnd(),
              ),
            ),
            if (_end != null)
              IconButton(
                icon: const Icon(Icons.clear),
                tooltip: 'Clear end time',
                onPressed: () => setState(() => _end = null),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Repeat', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<EventRepeat>(
          initialValue: _repeat,
          items: EventRepeat.values
              .map(
                (EventRepeat r) => DropdownMenuItem<EventRepeat>(
                  value: r,
                  child: Text(_repeatLabel(r)),
                ),
              )
              .toList(),
          onChanged: (EventRepeat? value) =>
              setState(() => _repeat = value ?? EventRepeat.none),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Reminder', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        DropdownButtonFormField<int?>(
          initialValue: _reminderMinutesBefore,
          items: <DropdownMenuItem<int?>>[
            const DropdownMenuItem<int?>(child: Text('No reminder')),
            for (final int minutes in _reminderOptions)
              DropdownMenuItem<int?>(
                value: minutes,
                child: Text(_reminderLabel(minutes)),
              ),
          ],
          onChanged: (int? value) =>
              setState(() => _reminderMinutesBefore = value),
        ),
        const SizedBox(height: AppSpacing.xxl),
        VWButton(
          label: _isEditing ? 'Save changes' : 'Create event',
          expand: true,
          isLoading: _saving,
          onPressed: _save,
        ),
      ],
    );
  }

  Future<void> _pickStart() async {
    final DateTime? picked = await _pickDateTime(_start);
    if (picked != null && mounted) {
      setState(() => _start = picked);
    }
  }

  Future<void> _pickEnd() async {
    final DateTime? picked = await _pickDateTime(_end ?? _start);
    if (picked != null && mounted) {
      setState(() => _end = picked);
    }
  }

  Future<DateTime?> _pickDateTime(DateTime initial) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(initial.year - 1),
      lastDate: DateTime(initial.year + 5),
    );
    if (date == null || !mounted) {
      return null;
    }
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (time == null || !mounted) {
      return null;
    }
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    final DateTime? end = _end;
    if (end != null && end.isBefore(_start)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after the start time.')),
      );
      return;
    }

    setState(() => _saving = true);

    final NotificationService notifications = ref.read(
      notificationServiceProvider,
    );
    final int? minutesBefore = _reminderMinutesBefore;

    if (_notificationId != null) {
      await _safeCancel(notifications, _notificationId!);
    }

    int? notificationId;
    if (minutesBefore != null) {
      final DateTime fireAt = _start.subtract(Duration(minutes: minutesBefore));
      if (fireAt.isAfter(DateTime.now())) {
        final ScheduledReminder? reminder = await _safeSchedule(
          notifications,
          title: _titleController.text.trim(),
          fireAt: fireAt,
        );
        notificationId = reminder?.id;
        if (reminder != null && !reminder.isExact && mounted) {
          await maybeShowInexactAlarmNotice(context, notifications);
        }
      }
    }

    final String description = _descriptionController.text.trim();
    final CalendarEventModel event = CalendarEventModel()
      ..title = _titleController.text.trim()
      ..description = description.isEmpty ? null : description
      ..startDateTime = _start
      ..endDateTime = end
      ..isAllDay = _isAllDay
      ..repeat = _repeat
      ..hasReminder = minutesBefore != null
      ..reminderMinutesBefore = minutesBefore
      ..notificationId = notificationId;

    if (_isEditing) {
      event.id = _eventId!;
      final result = await ref
          .read(calendarRepositoryProvider)
          .updateEvent(event);
      if (!mounted) {
        return;
      }
      result.fold(
        onSuccess: (_) => context.pop(),
        onError: (Failure f) => _onSaveFailed(f),
      );
    } else {
      final result = await ref
          .read(calendarRepositoryProvider)
          .createEvent(event);
      if (!mounted) {
        return;
      }
      result.fold(
        onSuccess: (_) => context.pop(),
        onError: (Failure f) => _onSaveFailed(f),
      );
    }
  }

  void _onSaveFailed(Failure failure) {
    setState(() => _saving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(failure.message)));
  }

  Future<void> _confirmDelete() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Delete event?'),
        content: const Text('This event and its reminder will be removed.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    if (_notificationId != null) {
      await _safeCancel(
        ref.read(notificationServiceProvider),
        _notificationId!,
      );
    }
    await ref.read(calendarRepositoryProvider).deleteEvent(_eventId!);
    if (mounted) {
      context.pop();
    }
  }

  Future<ScheduledReminder?> _safeSchedule(
    NotificationService service, {
    required String title,
    required DateTime fireAt,
  }) async {
    try {
      await service.requestPermissions();
      return await service.scheduleReminder(
        title: title.isEmpty ? 'Event reminder' : title,
        body: 'Starting soon.',
        scheduledDate: fireAt,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _safeCancel(NotificationService service, int id) async {
    try {
      await service.cancelNotification(id);
    } catch (_) {}
  }

  String _formatDateTime(DateTime value) =>
      DateFormat.yMMMd().add_Hm().format(value);

  String _repeatLabel(EventRepeat repeat) => switch (repeat) {
    EventRepeat.none => 'Does not repeat',
    EventRepeat.daily => 'Daily',
    EventRepeat.weekly => 'Weekly',
    EventRepeat.monthly => 'Monthly',
    EventRepeat.yearly => 'Yearly',
  };

  String _reminderLabel(int minutes) {
    if (minutes >= 1440) {
      final int days = minutes ~/ 1440;
      return days == 1 ? '1 day before' : '$days days before';
    }
    if (minutes >= 60) {
      final int hours = minutes ~/ 60;
      return hours == 1 ? '1 hour before' : '$hours hours before';
    }
    return '$minutes minutes before';
  }
}
