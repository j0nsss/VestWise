import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vestwise/core/router/app_shell.dart';
import 'package:vestwise/core/router/route_paths.dart';
import 'package:vestwise/features/calendar/presentation/screens/calendar_screen.dart';
import 'package:vestwise/features/calendar/presentation/screens/event_detail_screen.dart';
import 'package:vestwise/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:vestwise/features/finance/presentation/screens/add_transaction_screen.dart';
import 'package:vestwise/features/finance/presentation/screens/finance_home_screen.dart';
import 'package:vestwise/features/finance/presentation/screens/finance_summary_screen.dart';
import 'package:vestwise/features/notes/presentation/screens/document_viewer_screen.dart';
import 'package:vestwise/features/notes/presentation/screens/note_editor_screen.dart';
import 'package:vestwise/features/notes/presentation/screens/notes_list_screen.dart';
import 'package:vestwise/features/settings/presentation/screens/settings_screen.dart';
import 'package:vestwise/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:vestwise/features/tasks/presentation/screens/tasks_list_screen.dart';

/// The app's single [GoRouter] (plan P1-T5, §12).
///
/// Five top-level destinations live inside a persistent bottom-navigation
/// [StatefulShellRoute]; detail/edit screens are nested per feature.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    initialLocation: RoutePaths.dashboard,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (
          BuildContext context,
          GoRouterState state,
          StatefulNavigationShell navigationShell,
        ) => AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.dashboard,
                builder: (BuildContext context, GoRouterState state) =>
                    const DashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.finance,
                builder: (BuildContext context, GoRouterState state) =>
                    const FinanceHomeScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'add',
                    builder: (BuildContext context, GoRouterState state) =>
                        const AddTransactionScreen(),
                  ),
                  GoRoute(
                    path: 'summary',
                    builder: (BuildContext context, GoRouterState state) =>
                        const FinanceSummaryScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.notes,
                builder: (BuildContext context, GoRouterState state) =>
                    const NotesListScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'document/:id',
                    builder: (BuildContext context, GoRouterState state) =>
                        DocumentViewerScreen(
                      documentId: state.pathParameters['id'],
                    ),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    builder: (BuildContext context, GoRouterState state) =>
                        NoteEditorScreen(noteId: state.pathParameters['id']),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.tasks,
                builder: (BuildContext context, GoRouterState state) =>
                    const TasksListScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: ':id',
                    builder: (BuildContext context, GoRouterState state) =>
                        TaskDetailScreen(taskId: state.pathParameters['id']),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.calendar,
                builder: (BuildContext context, GoRouterState state) =>
                    const CalendarScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'event/:id',
                    builder: (BuildContext context, GoRouterState state) =>
                        EventDetailScreen(eventId: state.pathParameters['id']),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.settings,
        builder: (BuildContext context, GoRouterState state) =>
            const SettingsScreen(),
      ),
    ],
  );
});
