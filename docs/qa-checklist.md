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

## Phase 9 — Motion (P9-T1..T4)

| Check | Status | How to verify |
|-------|--------|---------------|
| Every animation token obeys the 250ms ceiling | PASS | `flutter test test/core/constants/app_motion_test.dart` — every token but `signature` is ≤ `maxDuration`. |
| The `signature` exception is bounded, not open-ended | PASS | Same test asserts `maxDuration` (250ms) < `signature` (320ms) ≤ 400ms, so the carve-out cannot be widened by accident. |
| The staggered cascade fits inside `signature` | PASS | `listItemEnter + staggerMaxItems × staggerStep` = 180 + 120 = 300ms ≤ 320ms, asserted in the motion test and in `test/core/widgets/vw_motion_widgets_test.dart`. |
| New motion primitives respect reduced motion | PASS | `motionDuration` collapses to `Duration.zero`; `VWFadeThrough`, `VWStaggeredList` and the shell settle all skip under `prefersReducedMotion` — `test/core/widgets/vw_motion_widgets_test.dart`, `test/widget_test.dart`. |
| Tab switches do not hard-cut | PASS (host) | The shell dims to 92% and restores over `stateChange` when the branch index changes; asserted in `test/widget_test.dart` ("switching tabs settles in"). |
| Tab switches and detail screens, on device | MANUAL — todo | Tap through all five tabs and into one detail screen per feature on the Redmi Note 8; confirm no pop/flash and that the Android back gesture is still smooth. |
| Task-complete morph + haptic | MANUAL — todo | Toggle a task on the Redmi Note 8: expect the check to fill and the title to strike through over ~320ms with a light haptic tick, and the row to reclassify into active/completed afterwards. |

## Phase 10 — Feature restyle

### Finance (P10-FIN-1..4)

| Check | Status | How to verify |
|-------|--------|---------------|
| Category colour comes from one palette | PASS | `VWCategoryChip` resolves its pair through `AppColors.tagFor`, so a category (or a label) always lands on the same colour everywhere. `flutter test test/core/widgets/vw_category_chip_test.dart`, `test/features/finance/presentation/category_chip_test.dart`. |
| Category colours stay legible in both themes | PASS | Every tag pair is asserted ≥ 4.5:1 for foreground-on-background and ≥ 3:1 for foreground-on-`surfaceContainerHighest` (WCAG 1.4.11) — `test/core/constants/app_colors_test.dart`. |
| The breakdown is grouped once, not per widget | PASS | `categoryTotals` is pure and returns biggest-spend-first totals; the ring and the rows both render from that one list, so they cannot disagree. `flutter test test/features/finance/presentation/category_breakdown_test.dart`. |
| The dashboard sparkline and the weekly delta describe the same week | PASS | Both come from `watchLast7DaysNetProvider`; days with no activity are zero-filled rather than skipped, so the line has seven points. `test/features/finance/data/finance_repository_test.dart`, `test/core/widgets/vw_sparkline_test.dart`. |
| A fresh install does not claim a balance of zero | PASS | With no transactions the balance card renders `VWEmptyState` instead of "0.00". Emptiness is decided by a one-row transaction query, not by the balance (income and expenses can cancel out). `flutter test test/features/dashboard/presentation/dashboard_screen_test.dart`. |

### Notes (P10-NOTES-1..4)

| Check | Status | How to verify |
|-------|--------|---------------|
| The note title reads as a document heading | PASS | `DocumentTitleField` draws no border until focused and grows to fit; asserted in `test/features/notes/presentation/note_editor_screen_test.dart`. |
| "Last edited" tells the truth after a save | PASS | The label is fed from the same `updatedAt` the autosave writes, and is absent on a note that has not been saved yet — same test file. |
| The title is announced as a header | PASS | The field is wrapped in `Semantics(header: true)`, asserted with `isSemantics(isHeader: true, isTextField: true)`. |
| A chosen icon persists and defaults safely | PASS | `iconCodePoint` is nullable and additive, so notes written before the field existed load as "no icon" (document glyph) rather than failing; round-trip asserted in `test/features/notes/data/notes_repository_test.dart`. |
| Every icon option is labelled | PASS | `NoteIconPicker` gives each option a tooltip, and the list is asserted to have no duplicate glyphs or labels — `test/features/notes/presentation/note_icon_picker_test.dart`. |
| Pinned notes are separable at a glance | PASS | The list is flattened into a row script (`buildNoteRows`) so it stays a `ListView.builder`, headings appear only when there is something to separate, and search results drop the headings entirely — `flutter test test/features/notes/presentation/notes_sections_test.dart`. |
| Collapse state is not persisted | PASS | `_collapsed` is a plain in-memory set on the tab's state; nothing is written to `shared_preferences` or the database. |
| The formatting toolbar is chrome-free | PASS | `NoteEditorToolbar` disables the dividers and sets no colour/decoration, so the page surface shows through; asserted in `test/features/notes/presentation/note_editor_toolbar_test.dart`. |
| Formatting still works after the restyle | PASS | Same file taps bold/italic/underline/strikethrough and asserts the attribute landed on the selection — a restyle, not a rebuild. |
| Toolbar buttons keep their touch targets | PASS | Button spacing is zeroed but icon size and padding are left at the stock values, so the ≥48px target survives; no `iconTheme` override. |
| Font family/size dropdowns removed | CHANGED | Deliberate: they are the only controls in the stock toolbar that render words rather than glyphs, and P10-NOTES-4 asks for icon-only. Every other action (bold, italic, underline, strikethrough, inline code, colours, clear format, headings, lists, quote, code block, indent, link, undo/redo, search) is unchanged. Restore in one line each if the trade-off is wrong. |
| Editor screen on device | MANUAL — todo | `integration_test/app_flow_test.dart` ("writes a note and sees it persisted") was updated for the new header but has not been re-run since the device was disconnected. |

### Tasks (P10-TASKS-1..4)

| Check | Status | How to verify |
|-------|--------|---------------|
| No task is hidden by the new grouping | PASS | `taskGroupOf` is total (completed → completed; no date → No due date; due today *or overdue* → Today; otherwise Upcoming), and the test asserts every input task comes back out exactly once — `flutter test test/features/tasks/presentation/task_groups_test.dart`. |
| Grouping is deterministic, not clock-dependent in tests | PASS | `today` is injected into `buildTaskRows`, so the boundary cases (due at 23:59, due yesterday) are tested rather than hoped for. |
| Group headings are collapsible and announced | PASS | `VWSectionDisclosure` (shared with the notes list) rotates its chevron over `stateChange` and reports `label`/`isExpanded` to screen readers — `test/features/tasks/presentation/task_list_tile_test.dart`, `test/features/notes/presentation/notes_sections_test.dart`. |
| Collapse state is not persisted | PASS | In-memory `Set<TaskGroup>` on the screen's state only. |

## Re-running the automated part

```sh
flutter analyze
flutter test
flutter test integration_test -d <device-id>
```
