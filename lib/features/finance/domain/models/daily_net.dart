/// Net (income − expense) for one calendar day (plan2.md P10-FIN-2).
///
/// The sparkline on the dashboard balance card plots these, so it needs the day
/// as well as the figure: a day with no transactions is a real zero, not a gap.
class DailyNet {
  const DailyNet({required this.day, required this.net});

  /// Local midnight of the day this figure covers.
  final DateTime day;

  /// Income minus expenses for that day. Negative means a net spend.
  final double net;

  @override
  String toString() => 'DailyNet($day, $net)';
}
