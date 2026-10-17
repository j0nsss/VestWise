/// Central named route paths and builders (plan §12).
abstract final class RoutePaths {
  static const String dashboard = '/';
  static const String finance = '/finance';
  static const String financeAdd = '/finance/add';
  static const String financeSummary = '/finance/summary';
  static const String notes = '/notes';
  static const String noteEditor = '/notes/:id/edit';
  static const String documentViewer = '/notes/document/:id';
  static const String tasks = '/tasks';
  static const String taskDetail = '/tasks/:id';
  static const String calendar = '/calendar';
  static const String eventDetail = '/calendar/event/:id';
  static const String settings = '/settings';

  /// `:id == 'new'` opens the create flow.
  static const String newId = 'new';

  static String noteEditorFor(String id) => '/notes/$id/edit';
  static String documentViewerFor(String id) => '/notes/document/$id';
  static String taskDetailFor(Object id) => '/tasks/$id';
  static String eventDetailFor(Object id) => '/calendar/event/$id';
}
