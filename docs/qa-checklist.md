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
| Quick-add creates a task in one line | PASS | Enter in the row above the list writes a Medium, no-due-date task through the same `TasksRepository.createTask`; it appears under "No due date" straight from the stream, with no manual refresh — `flutter test test/features/tasks/presentation/task_quick_add_test.dart`. |
| Quick-add uses the form's own validation | PASS | Both call `validateTaskTitle`, so an empty or whitespace-only submit is a no-op in one place and cannot drift in the other. |
| Quick-add row on device | MANUAL — todo | Add three tasks in a row on the Redmi Note 8 and confirm the keyboard stays up between them. |
| Swiping right completes, swiping left deletes | PASS | `SwipeableTaskRow` wraps each row in a `Dismissible` with `direction: horizontal` and branches in `confirmDismiss`; a right-swipe calls the same `_toggleComplete` the checkbox does, a left-swipe hits the confirmation first — `flutter test test/features/tasks/presentation/task_swipe_test.dart`. |
| Swipe-delete cannot destroy a task silently | PASS | Both the swipe and the detail screen's delete button go through one `confirmTaskDeletion` dialog and one `cancelTaskReminder` + `deleteTask` pair; the tests assert nothing is deleted (and no reminder is cancelled) until "Delete" is tapped. |
| The swipe does not fight the completion morph | PASS | `confirmDismiss` returns false in both directions, so the row snaps back and leaves when the stream says so — the P9-T4 morph is not cut short, and Flutter's "a dismissed Dismissible is still part of the tree" assertion is never reachable from a stream-driven list. |
| Swipe gestures on device | MANUAL — todo | Swipe a task right (expect the tick + strike-through, then a move to Completed), then swipe another one left and cancel, then delete. Confirm the horizontal drags do not fight the vertical list scroll or the Android back gesture. |

### Calendar & Navigation (P10-CAL-1..2, P10-NAV-1)

| Check | Status | How to verify |
|-------|--------|---------------|
| The month header is flat | PASS | `HeaderStyle` now gets an empty `BoxDecoration`, an `onSurfaceVariant` chevron pair and a `titleMedium` label from the theme instead of the package's hard-coded 17px style — `flutter test test/features/calendar/presentation/calendar_screen_test.dart`. |
| Today and the selected day stay distinguishable | PASS | Today is drawn as a `primary` *ring*, the selected day as a filled `primary` circle, and each carries its own paired text colour (`primary` / `onPrimary`). Two different shapes, so the two states do not collide on the day that is both. |
| Day text is legible in both themes | PASS | Weekday, weekend, outside, disabled and marker colours all come from `ColorScheme` (`onSurface`, `onSurfaceVariant`, `outline`, `primary`) — the stock red weekend tint is gone, and the assertion runs in light *and* dark. |
| Month navigation still works | PASS | The chevrons are stock `CustomIconButton`s that were only recoloured; the test taps next and back and asserts the header label follows — a restyle, not a rebuild. |
| The header/today formats did not gain or lose a control | PASS | `formatButtonVisible` is false, but the format button only ever renders when more than one calendar format is offered and this app uses the month grid only, so no reachable control was removed. |
| "Today" and "selected" markers on device | MANUAL — todo | Check the ring/today marker and the filled selected marker in both light and dark mode on the Redmi Note 8, including the day that is both. |
| Event rows are cards, not bare list tiles | PASS | `EventListTile` is a `VWCard(variant: .flat)` with `padding: EdgeInsets.zero` so the accent bar reaches the rounded edge, and the day list became a `ListView.separated` that supplies the gutter and the gaps — `flutter test test/features/calendar/presentation/event_list_tile_test.dart`. |
| An event's colour is shown without costing legibility | PASS | `colorValue` drives a 4px accent bar only. The title and time keep `onSurface` / `onSurfaceVariant`, and the test deliberately uses a loud colour (yellow) to prove the text does not follow it, in both themes. |
| Events with different colours are visually distinct | PASS | Two rows with different `colorValue`s are asserted to paint different bars. Note: nothing in the UI *sets* `colorValue` yet — the field exists on the model (plan P3-CAL) with a default, so today every event carries the same colour. This restyle surfaces the field; a picker is not part of Phase 10. |
| The accent bar's contrast is exempt, and deliberately so | CHANGED | The bar is decorative: all the meaning lives in the text beside it, which is exactly why the colour was not put behind a label. The default brand indigo sits near 3:1 against the dark surface, so it is documented exempt like `borderSubtle` rather than being re-tinted per theme. |
| Event cards on device | MANUAL — todo | Check the day list's card spacing and accent bars in light and dark mode, and confirm tapping still opens the event. |
| The bottom bar is flat | PASS | `navigationBarTheme` sets `elevation: AppElevation.flat`, `surfaceTintColor: transparent`, the page surface as its background and a 64px height; the only separation is a `borderSubtle` hairline the shell draws — `flutter test test/widget_test.dart`. |
| The selected tab is legible in both themes | PASS | Selection rides on the icon *and* label switching to `colorScheme.primary` (clears 3:1 against the bar in either theme), with the tonal pill as reinforcement at 12% alpha rather than the signal — same test file, asserted from the theme both ways. |
| All five destinations still navigate | PASS | The walk taps each destination inside the bar and asserts `selectedIndex` plus which branch is actually hit-testable. It also builds the Finance and Notes branches for the first time in this suite (their list providers are now overridden with empty streams), so a broken branch would fail here rather than only on device. |
| Bottom bar on device | MANUAL — todo | Check the hairline, the pill and label contrast in light and dark mode, including the selected icon on the pill, and confirm each tab's scroll position is still preserved. |

## Phase 11 — Empty, loading and interactive states

### Skeletons (P11-T1)

| Check | Status | How to verify |
|-------|--------|---------------|
| The primitive is one bar and one sweep, not a widget per screen | PASS | `VWSkeleton` is a tinted block with an explicit size; `VWShimmer` is a `ShaderMask` sweep around a whole subtree, so a screen of six skeletons is six rectangles and one animation — `flutter test test/core/widgets/vw_skeleton_test.dart`. |
| The tint is the theme's, not a literal | PASS | Bars paint `surfaceContainerHighest`, asserted in light *and* dark, so a skeleton reads as the app thinking rather than as a foreign widget. |
| Reduced motion freezes the sweep instead of shortening it | CHANGED | `VWShimmer` checks `prefersReducedMotion` directly rather than routing through `motionDuration`: a zero-length `repeat()` is a busy loop, not "no animation". The one deliberate exception to the single-decision-point rule, documented in the widget. |
| The sweep duration is a token, and its exemption is explicit | CHANGED | `AppMotion.skeletonSweep` (1200ms) is a *loop period*, not a transition, so the 250ms transition ceiling is the wrong ruler for it. `app_motion_test.dart` bands it (800–2000ms) and documents the exemption instead of leaving the token quietly unlisted. |
| Each skeleton is the size of the row it replaces | PASS | Every skeleton is built from the same `ListTile`/card structure as its real counterpart, with bars at the line heights of the type roles they stand in for (`bodyLarge` ≈ 22, `bodyMedium` ≈ 20, `labelSmall` ≈ 14, `titleSmall` ≈ 18, `bodySmall` ≈ 17). Each test measures the real row and the skeleton and asserts they differ by ≤3px — `test/features/{tasks,finance,notes,calendar}/presentation/*_skeleton_test.dart`. |
| A skeleton survives the scroll contexts that already crashed once | PASS | Each skeleton is pumped inside a `SliverList`, a `SliverFillRemaining(hasScrollBody: false)` and a plain `ListView` and asserted not to throw — the §1.4 #1 failure mode, tested directly rather than hoped for (`test/helpers/scroll_contexts.dart`). |
| One documented difference: a one-line transaction row | CHANGED | The real row drops its category line when the note and the category say the same thing, so that row is one `bodyMedium` line shorter than its skeleton. Bounded to a single line and noted in the widget. |
| Skeletons on device | MANUAL — todo | Cold-start each list on the Redmi Note 8 and confirm the sweep reads as "working" rather than as flicker, and that no row shifts when data lands. |

### Loading gates (P11-T2)

| Check | Status | How to verify |
|-------|--------|---------------|
| A fast local read never flashes a skeleton | PASS | Every list waits out a ~100ms gate (`VWDelayed`) before showing a skeleton, so the ordinary Isar read (well under 100ms) shows nothing at all. Tested per screen: assert no skeleton at frame 0, a skeleton after the gate, then content and no skeleton once the stream emits — `flutter test test/features/list_loading_test.dart`. |
| The gate is wired into all four named lists | PASS | Tasks, Finance transactions, Notes notes and the Calendar day list each wrap their loading branch in `VWDelayed(key: ValueKey('<name>-loading'), child: VWSkeletonList(...))`, and the same test file fails if any of them loses it. |
| States swap instead of popping | PASS | Each list's loading/error/empty/data branches are wrapped in one `VWFadeThrough` cross-fade and keyed, so the swap is an animation rather than a hard cut. Verified per screen in the same test. |
| The spinner survives exactly one list, and says why | CHANGED | The Documents tab keeps `VWLoadingIndicator`: a document row's shape depends on its file type and metadata, so there is no honest skeleton for it. The exemption is commented in the widget rather than left as an oversight. |
| A skeleton during the gate does not hang the test suite | PASS | No test uses `pumpAndSettle` while a skeleton is on screen (a shimmer repeats forever); the gate and the swaps are driven with bounded `pump()`s in `test/features/list_loading_test.dart` and `test/core/widgets/vw_delayed_test.dart`. |
| Skeletons appear late enough to feel right on device | MANUAL — todo | Cold-start each of the four lists on the Redmi Note 8 and confirm the skeleton arrives only when the wait is noticeable, and that nothing shifts when data lands. |

## Re-running the automated part

```sh
flutter analyze
flutter test
flutter test integration_test -d <device-id>
```
