import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vestwise/core/constants/app_motion.dart';
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
///
/// Every route shares one short fade-through transition (P5-T1) — 200ms, well
/// under the 250ms budget, and skipped entirely when the platform requests
/// reduced motion.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    initialLocation: RoutePaths.dashboard,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder:
            (
              BuildContext context,
              GoRouterState state,
              StatefulNavigationShell navigationShell,
            ) => AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.dashboard,
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    _transitionPage(state, const DashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.finance,
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    _transitionPage(state, const FinanceHomeScreen()),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'add',
                    pageBuilder: (BuildContext context, GoRouterState state) =>
                        _transitionPage(
                          state,
                          AddTransactionScreen(
                            transactionId: state.uri.queryParameters['id'],
                          ),
                        ),
                  ),
                  GoRoute(
                    path: 'summary',
                    pageBuilder: (BuildContext context, GoRouterState state) =>
                        _transitionPage(state, const FinanceSummaryScreen()),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.notes,
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    _transitionPage(state, const NotesListScreen()),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'document/:id',
                    pageBuilder: (BuildContext context, GoRouterState state) =>
                        _transitionPage(
                          state,
                          DocumentViewerScreen(
                            documentId: state.pathParameters['id'],
                          ),
                        ),
                  ),
                  GoRoute(
                    path: ':id/edit',
                    pageBuilder: (BuildContext context, GoRouterState state) =>
                        _transitionPage(
                          state,
                          NoteEditorScreen(noteId: state.pathParameters['id']),
                        ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.tasks,
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    _transitionPage(state, const TasksListScreen()),
                routes: <RouteBase>[
                  GoRoute(
                    path: ':id',
                    pageBuilder: (BuildContext context, GoRouterState state) =>
                        _transitionPage(
                          state,
                          TaskDetailScreen(taskId: state.pathParameters['id']),
                        ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: RoutePaths.calendar,
                pageBuilder: (BuildContext context, GoRouterState state) =>
                    _transitionPage(state, const CalendarScreen()),
                routes: <RouteBase>[
                  GoRoute(
                    path: 'event/:id',
                    pageBuilder: (BuildContext context, GoRouterState state) =>
                        _transitionPage(
                          state,
                          EventDetailScreen(
                            eventId: state.pathParameters['id'],
                          ),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RoutePaths.settings,
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _transitionPage(state, const SettingsScreen()),
      ),
    ],
  );
});

/// One shared fade + slight-rise page transition for every destination.
Page<void> _transitionPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: AppMotion.pageTransition,
    reverseTransitionDuration: AppMotion.pageTransition,
    transitionsBuilder:
        (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          if (prefersReducedMotion(context)) {
            return child;
          }
          final Animation<double> curved = CurvedAnimation(
            parent: animation,
            curve: AppMotion.standardCurve,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
  );
}
