# QA checklist — states, accessibility and performance

Living checklist produced by Phase 5 (plan §7). Re-run the "how to verify"
column whenever a screen changes. Status values: **PASS**, **N/A**, **FIXED**
(was a gap, addressed in this phase).

## P5-T2 — Empty / loading / error states

Every screen must have an explicit design for first-run empty, loading and
error. All states are rendered through the shared `VWEmptyState`,
`VWLoadingIndicator` / `VWInlineSpinner` widgets — no screen constructs a bare
`CircularProgressIndicator`. (Enforced by inspection; `VWInlineSpinner` is the
only place in `lib/` that builds one, apart from `VWLoadingIndicator`, which
delegates to it.)

| # | Screen | Empty | Loading | Error | Notes |
|---|--------|-------|---------|-------|-------|
| 1 | Dashboard (`/`) | PASS — per-card empty copy | FIXED — one spinner while all four streams load | FIXED — error banner naming the failed sections + Retry | Was silently rendering empty cards on failure; loading state added so empty never reads as "no data". |
| 2 | Finance home | PASS — "No transactions yet" + CTA | PASS — `VWLoadingIndicator` | FIXED — message + Retry | Failed stream previously had no way back without a restart. |
| 3 | Add/edit transaction | N/A — form | PASS — `VWLoadingIndicator` while loading an edit; category list has its own inline loading | PASS — inline "Could not load categories" text under the picker | |
| 4 | Finance summary | PASS — "No expenses in this period." | PASS — `VWLoadingIndicator` | FIXED — message + Retry | |
| 5 | Notes list — Notes tab | PASS — "No notes yet" / "No matches" for a search | PASS — `VWLoadingIndicator` | FIXED — message + Retry | Empty copy distinguishes first-run from a search with no hits. |
| 6 | Notes list — Documents tab | PASS — "No documents" | PASS — `VWLoadingIndicator` | FIXED — message + Retry | Storage readout shows `…` until the size resolves. |
| 7 | Document import action | N/A | PASS — `VWInlineSpinner` replaces the app-bar icon (FIXED: was a bare spinner) | PASS — SnackBar `Import failed: …` | |
| 8 | Document viewer | N/A | PASS — `VWLoadingIndicator` | PASS — `VWEmptyState` for missing file / render failure | |
| 9 | Note editor | PASS — new note starts blank | PASS — `VWLoadingIndicator` | PASS — SnackBar on delete failure | |
| 10 | Tasks list | PASS — "No tasks yet" + CTA | PASS — `VWLoadingIndicator` | FIXED — message + Retry | |
| 11 | Task create/edit | N/A — form | PASS — `VWLoadingIndicator` | PASS — SnackBar via `Failure.message` | |
| 12 | Calendar | PASS — "No events on this day." | FIXED — day list had no loading state | FIXED — message + Retry | The month grid always renders; only the day list is stateful, and its markers degrade to none while loading. |
| 13 | Event create/edit | N/A — form | PASS — `VWLoadingIndicator` | PASS — SnackBar / inline "End time must be after the start time." | |
| 14 | Settings | PASS — `—` placeholders for unresolved values | PASS — inline placeholders | PASS — status rows read "Unavailable" instead of throwing | |

## P5-T3 — Accessibility

| Check | Status | How to verify |
|-------|--------|---------------|
| Tap targets ≥ 48×48 | PASS | Material `IconButton`/`Checkbox`/`FloatingActionButton` defaults plus `VWButton.minimumSize` (48). `flutter test test/core/widgets/vw_button_test.dart`. |
| Icon-only controls have a semantics label | PASS | `tooltip` on every FAB and icon-only `IconButton`; the priority dot is decorative and carries no semantics. TalkBack reads "Add task", "Delete task", "Import document", … |
| Text contrast ≥ 4.5:1 | PASS | Finance income/expense figures use brightness-aware tones (`AppColors.incomeFor` / `expenseFor`), asserted by a WCAG ratio test — `flutter test test/core/constants/app_colors_test.dart`. |
| Priority colours | PASS | `priorityHigh`/`priorityMedium`/`priorityLow` are only ever used as small dots next to an equivalent text label ("High"/"Medium"/"Low"), never as sole information, so the 3:1 non-text threshold applies. |
| Reduced motion honoured | PASS | `prefersReducedMotion` skips page transitions and row enter animations (Android "Remove animations"); `AppMotion` tokens all ≤ 250ms. |
| Primary actions operable with TalkBack | MANUAL — todo | On-device pass: add task, add transaction, save note. Not yet run; needs a physical TalkBack session. |

## P5-T4 — Settings

| Check | Status | How to verify |
|-------|--------|---------------|
| Theme choice persists across restart | PASS | The app reads the stored mode before the first frame (`ThemeStore.load()` in `main.dart`) so there is no flash of the wrong theme; round-trip and persistence asserted by `flutter test test/core/theme/theme_store_test.dart`. Device scenario: `integration_test/app_flow_test.dart` ("changes the theme and clears all data from Settings") checks the value lands in `shared_preferences`. |
| Clear-all data is complete and non-destructive to settings | PASS | `resetAllData` clears the database, deletes every imported file and re-seeds default categories, while leaving the theme preference alone — `flutter test test/core/database/app_data_reset_test.dart`. |
| Destructive action is confirmed first | PASS | "Clear all data" is a danger-tinted `ListTile` that opens an `AlertDialog`; the confirming action repeats the wording and `Cancel` is listed first. |

## P5-T5 — Performance

| Check | Status | How to verify |
|-------|--------|---------------|
| Long lists are lazy | PASS | `SliverList.builder` / `ListView.builder` everywhere; no `Column(child: items.map(...))` for an unbounded collection. Dashboard cards iterate a bounded slice (`take(3)` / `take(2)`). |
| Finance history is windowed | PASS | The finance home watches `watchRecentTransactionsProvider`, which reads at most `financeHistoryPageSize` (50) rows and grows the window on demand via a "Load older" button, instead of holding the entire history in memory. `flutter test test/features/finance/data/finance_repository_test.dart`. |
| Summary queries are range-bounded | PASS | The summary screen watches `watchTransactionsInRangeProvider(start, end)` for the selected week/month rather than loading all history and filtering in Dart. |
| Dashboard aggregates instead of scanning | PASS | The finance card takes its balance from `balanceProvider` (an Isar `sum()` that loads no rows) and its weekly net from the current week's range query — the dashboard no longer pulls the whole history to add two numbers up. |
| 200-item list scroll | MANUAL — todo | Seed 200 transactions on the Redmi Note 8 and scroll the finance list with the performance overlay on. |
| Cold start < ~2s | MANUAL — todo | `flutter run --profile --trace-startup` on the Redmi Note 8 (mid-range, Android 11). |

## Re-running the automated part

```sh
flutter analyze
flutter test
flutter test integration_test -d <device-id>
```
