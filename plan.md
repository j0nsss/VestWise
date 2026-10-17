# VestWise — Engineering Implementation Plan

**Project:** VestWise — Offline-First Productivity Platform
**Platforms:** Android & iOS (Flutter)
**Application ID:** `com.vestwise.app`
**Document type:** Execution roadmap for an AI coding agent (Cursor / Windsurf / Cline / Roo Code)

---

## 0. How to Use This Document

This file is the single source of truth for building VestWise. Work through it **phase by phase, in order** — later phases depend on earlier ones (data layer before UI, core infra before features).

Rules for the agent:
1. Do not skip the **Validation Steps** at the end of each task. A task is not "done" until its validation passes.
2. After every task: run `flutter analyze` and `flutter pub get` (or `dart run build_runner build --delete-conflicting-outputs` when models changed) before moving on.
3. Never introduce a cloud/network dependency for core functionality. If a package silently requires network access, replace it.
4. Keep each feature self-contained under `lib/features/<feature>/` — a file inside `finance/` should never import directly from `notes/` internals; share only through `core/`.
5. Commit after each completed task with a message matching the task ID (e.g. `feat(P2-T3): add TaskModel Isar schema`).
6. When a package name/version below looks uncertain, verify it on pub.dev before adding it — the Dart package ecosystem moves fast and this plan was authored at a point in time.

---

## 1. System Overview

### 1.1 Product Vision
VestWise is a single, calm home for a student's or professional's daily operating system: money, notes, tasks, and schedule — entirely on-device. No account, no sign-in, no sync server. Fast cold start, instant interactions, and a minimal visual language are non-negotiable quality bars, not nice-to-haves.

### 1.2 Architectural Principles
- **Offline-first, always.** Every feature must be fully functional in airplane mode. No feature may block on a network call.
- **Feature-first modularity.** Code is organized by feature, not by technical layer at the top level. Each feature owns its `data/`, `domain/`, `presentation/`.
- **Single local database.** Isar is the only persistence engine for structured data. Files (PDF/DOCX imports) live on-disk via `path_provider`; only their metadata is indexed in Isar.
- **Unidirectional state flow.** UI reads state via Riverpod providers → user actions call notifier methods → notifiers call repositories → repositories touch Isar/filesystem → state updates flow back to UI. UI widgets never touch Isar directly.
- **Repository pattern as the only data-access boundary.** Features depend on repository interfaces (abstract classes) in `domain/`, implemented in `data/`. This keeps the data source swappable and testable.
- **Result-based error handling.** Repository and service methods return a `Result<T>` (success/failure) type rather than throwing across layers, so the UI can always render a graceful state.
- **Composable, reusable UI kit.** Shared primitives (`VWCard`, `VWButton`, `VWEmptyState`, etc.) live in `core/widgets/` and are the only building blocks features should use for structure — this is what keeps the UI consistent and "minimal."

### 1.3 Tech Stack

| Concern | Package | Notes |
|---|---|---|
| Framework | `flutter` (stable channel) | Material 3 (`useMaterial3: true`) |
| State management | `flutter_riverpod`, `riverpod_annotation`, `riverpod_generator` | Code-gen providers (`@riverpod`) preferred over manual `StateNotifierProvider` boilerplate |
| Navigation | `go_router` | Declarative routes, deep-linkable, shell routes for bottom nav |
| Local database | `isar_community` (+ `isar_community_flutter_libs`, `isar_community_generator`) | **Important:** the original `isar` / `isar_flutter_libs` / `isar_generator` packages on pub.dev are discontinued/unmaintained as of this plan. Use the actively-maintained community fork, hosted at `https://pub.isar-community.dev/`. Verify current status on pub.dev before installing; if the fork is also stale by build time, fall back to `drift` (SQLite) per §1.6. |
| File storage | `path_provider` | Resolves app documents directory for imported files |
| File import | `file_picker` | Document/file picker (PDF, DOCX, images, etc.) |
| PDF rendering | `flutter_pdfview` (or `syncfusion_flutter_pdfviewer` as fallback if rendering quality is insufficient) | In-app PDF viewing |
| DOCX preview | No reliable pure-Dart renderer exists offline; see §5.3 for the pragmatic approach (metadata + "Open with" external viewer, or text extraction preview) |
| Rich text editor | `flutter_quill` | Delta-JSON based; stores structured rich text locally |
| Local notifications | `flutter_local_notifications` | Scheduled/exact alarms for tasks & events |
| Timezone support | `timezone` | Required by `flutter_local_notifications` for scheduled times |
| Charts | `fl_chart` | Lightweight, no network, good for weekly/monthly summaries |
| Fonts | `google_fonts` (Inter) *or* bundled `.ttf` in `assets/fonts/` for guaranteed offline-safe first paint | Prefer bundled fonts to avoid any first-run network fetch by `google_fonts` |
| Icons | `lucide_icons` or Material Symbols (bundled) | Minimal, consistent icon set |
| Unique IDs | `uuid` | For embedded sub-entities (sub-tasks) |
| Permissions | `permission_handler` | Runtime permission prompts where required |
| App icon/splash | `flutter_launcher_icons`, `flutter_native_splash` | Dev-only, for release prep |
| Testing | `flutter_test`, `mocktail`, `integration_test` | Unit, widget, and e2e coverage |

### 1.4 Directory Structure

```
vestwise/
├── android/
├── ios/
├── assets/
│   ├── fonts/                     # Inter-*.ttf (bundled, offline-safe)
│   └── icons/                     # app icon source, splash source
├── lib/
│   ├── main.dart                  # entrypoint: init Isar, notifications, run app
│   ├── app.dart                   # MaterialApp.router, theme, router wiring
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   ├── app_spacing.dart
│   │   │   └── app_strings.dart
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── theme_provider.dart
│   │   ├── router/
│   │   │   ├── app_router.dart
│   │   │   └── route_paths.dart
│   │   ├── database/
│   │   │   ├── isar_service.dart
│   │   │   └── isar_provider.dart
│   │   ├── notifications/
│   │   │   ├── notification_service.dart
│   │   │   └── notification_provider.dart
│   │   ├── storage/
│   │   │   └── file_storage_service.dart
│   │   ├── errors/
│   │   │   ├── result.dart
│   │   │   └── failure.dart
│   │   ├── utils/
│   │   │   ├── date_utils.dart
│   │   │   ├── currency_formatter.dart
│   │   │   └── validators.dart
│   │   └── widgets/
│   │       ├── vw_card.dart
│   │       ├── vw_button.dart
│   │       ├── vw_text_field.dart
│   │       ├── vw_empty_state.dart
│   │       ├── vw_section_header.dart
│   │       ├── vw_app_bar.dart
│   │       └── vw_loading_indicator.dart
│   └── features/
│       ├── dashboard/
│       │   └── presentation/
│       │       ├── screens/dashboard_screen.dart
│       │       ├── widgets/
│       │       │   ├── today_tasks_card.dart
│       │       │   ├── balance_summary_card.dart
│       │       │   ├── upcoming_deadlines_card.dart
│       │       │   └── quick_notes_card.dart
│       │       └── providers/dashboard_provider.dart
│       ├── finance/
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   ├── transaction_model.dart
│       │   │   │   └── category_model.dart
│       │   │   └── repositories/finance_repository_impl.dart
│       │   ├── domain/
│       │   │   └── repositories/finance_repository.dart
│       │   └── presentation/
│       │       ├── screens/
│       │       │   ├── finance_home_screen.dart
│       │       │   ├── add_transaction_screen.dart
│       │       │   └── finance_summary_screen.dart
│       │       ├── widgets/
│       │       └── providers/
│       │           ├── finance_providers.dart
│       │           └── transaction_form_controller.dart
│       ├── notes/
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   ├── note_model.dart
│       │   │   │   └── imported_document_model.dart
│       │   │   └── repositories/notes_repository_impl.dart
│       │   ├── domain/
│       │   │   └── repositories/notes_repository.dart
│       │   └── presentation/
│       │       ├── screens/
│       │       │   ├── notes_list_screen.dart
│       │       │   ├── note_editor_screen.dart
│       │       │   └── document_viewer_screen.dart
│       │       ├── widgets/
│       │       └── providers/notes_providers.dart
│       ├── tasks/
│       │   ├── data/
│       │   │   ├── models/task_model.dart
│       │   │   └── repositories/tasks_repository_impl.dart
│       │   ├── domain/
│       │   │   └── repositories/tasks_repository.dart
│       │   └── presentation/
│       │       ├── screens/
│       │       │   ├── tasks_list_screen.dart
│       │       │   └── task_detail_screen.dart
│       │       ├── widgets/
│       │       └── providers/tasks_providers.dart
│       └── calendar/
│           ├── data/
│           │   ├── models/calendar_event_model.dart
│           │   └── repositories/calendar_repository_impl.dart
│           ├── domain/
│           │   └── repositories/calendar_repository.dart
│           └── presentation/
│               ├── screens/
│               │   ├── calendar_screen.dart
│               │   └── event_detail_screen.dart
│               ├── widgets/
│               └── providers/calendar_providers.dart
├── test/
│   ├── core/
│   └── features/
├── pubspec.yaml
└── plan.md
```

### 1.5 Design Tokens / Brand Identity
Define these once in `core/constants/` and never hardcode colors/spacing in feature widgets.

- **Typography:** Inter (bundled). Scale: `displaySmall` (dashboard headers), `titleLarge` (screen titles), `titleMedium` (card headers), `bodyMedium` (default), `labelSmall` (meta text/timestamps).
- **Color system:** Build via `ColorScheme.fromSeed(seedColor: ..., brightness: ...)` for both light and dark, with one brand seed color.
  - Suggested seed: a deep indigo (`#4F46E5`–`#5B52E0` range) for primary actions.
  - Semantic accents (not part of the seeded scheme, defined separately in `app_colors.dart`): `incomeGreen`, `expenseRed`, `priorityHigh` (amber/red), `priorityMedium` (amber), `priorityLow` (blue/gray).
- **Spacing scale:** 4/8/12/16/24/32 (`AppSpacing.xs/sm/md/lg/xl/xxl`) — use exclusively, no magic numbers in widget code.
- **Shape:** rounded corners, `BorderRadius.circular(16)` for cards, `12` for inputs/buttons. Define once as `AppRadii`.
- **Elevation:** prefer flat cards with a subtle `surfaceContainerHighest` background + thin border over heavy shadows, consistent with a minimal aesthetic.

### 1.6 Fallback Policy for Isar
Because the Isar ecosystem has had maintenance churn, the agent must do the following **before Phase 2**:
1. Search pub.dev for `isar_community` and the original `isar` package. Confirm which is current/healthy (non-trivial maintenance + popularity + security score).
2. If neither is viable at build time, substitute **`drift`** (SQLite, well-maintained, offline-first) using the same repository interfaces defined in this plan — only the `data/` layer implementation changes, `domain/` and `presentation/` are unaffected. Record this decision in `/docs/adr/001-database-choice.md`.

---

## 2. Phase 0 — Project Bootstrap

**Goal:** A clean, running Flutter skeleton with the full directory scaffold, linting, and theming shell in place.

### P0-T1: Create the Flutter project
- Run: `flutter create --org com.vestwise --project-name vestwise -a kotlin -i swift vestwise`
- Confirm `applicationId`/`bundleId` resolve to `com.vestwise.app` (see Phase 7 for exact edits — at creation time the org flag produces `com.vestwise.vestwise`; it will be corrected in Phase 7, or correct it now in `android/app/build.gradle` (`applicationId`) and iOS `PRODUCT_BUNDLE_IDENTIFIER` to `com.vestwise.app` immediately to avoid rework).
- **Validation:** `flutter run` launches the default counter app on an emulator/simulator with no errors.

### P0-T2: Scaffold the directory structure
- Create every folder listed in §1.4 (empty `.gitkeep` files where needed so empty dirs are tracked).
- **Validation:** `find lib -type d` output matches §1.4 exactly.

### P0-T3: Add lint rules
- Add `flutter_lints` (or `very_good_analysis` for stricter rules) to `dev_dependencies`.
- Create/update `analysis_options.yaml` enabling: `prefer_const_constructors`, `avoid_print`, `always_declare_return_types`, `prefer_relative_imports` (or `always_use_package_imports` — pick one convention and enforce it).
- **Validation:** `flutter analyze` returns zero issues on the fresh skeleton.

### P0-T4: Base pubspec dependencies
- Add every package from §1.3 to `pubspec.yaml` (dependencies vs dev_dependencies as appropriate). Use `flutter pub add <package>` per package so versions resolve to current-compatible releases rather than hand-typing version numbers.
- Add the `isar_community` packages via the `hosted:` syntax pointing at `https://pub.isar-community.dev/` (see §6 pubspec reference block for exact syntax) — confirm this per §1.6 first.
- Register `assets/fonts/` and `assets/icons/` under `flutter: assets:` and `flutter: fonts:` in `pubspec.yaml`.
- **Validation:** `flutter pub get` completes with no version conflicts.

### P0-T5: Base theme shell
- Create `core/theme/app_theme.dart` exporting `AppTheme.light` and `AppTheme.dark`, both `ThemeData` built from `ColorScheme.fromSeed`, `useMaterial3: true`, Inter font family, and the shared shape/spacing tokens from §1.5.
- Create `core/theme/theme_provider.dart`: a Riverpod `NotifierProvider<ThemeModeNotifier, ThemeMode>` defaulting to `ThemeMode.system`.
- Wire into `app.dart` via `MaterialApp.router(theme: ..., darkTheme: ..., themeMode: ref.watch(themeModeProvider))`.
- **Validation:** App launches showing a themed blank scaffold; toggling device dark mode changes the app's appearance live.

**Definition of done for Phase 0:** `flutter run` boots a themed, empty-shell app with the full folder structure and zero analyzer warnings.

---

## 3. Phase 1 — Core Infrastructure

**Goal:** Shared services (database, notifications, storage), navigation shell, error handling, and the reusable widget kit — all built before any feature touches them.

### P1-T1: Result/Failure types
- Create `core/errors/failure.dart`: a sealed/abstract `Failure` class with subtypes `DatabaseFailure`, `FileSystemFailure`, `NotificationFailure`, `ValidationFailure`, each carrying a `message`.
- Create `core/errors/result.dart`: a `Result<T>` sealed class (`Success<T>` / `Error<T>`) with helper getters (`isSuccess`, `dataOrNull`, `fold()`), or use the `dartz`/`fpdart` package if the agent prefers an existing `Either` implementation — pick one and apply it consistently everywhere.
- **Validation:** Unit test constructing both variants and asserting `fold()` dispatches correctly.

### P1-T2: Isar service bootstrap
- Create `core/database/isar_service.dart`:
  - `Future<Isar> openIsar()` — resolves the app documents directory via `path_provider`, opens a single Isar instance with **every** collection schema from all four features registered (`TransactionModelSchema`, `CategoryModelSchema`, `NoteModelSchema`, `ImportedDocumentModelSchema`, `TaskModelSchema`, `CalendarEventModelSchema`).
  - Must be idempotent — if an instance is already open, return it (`Isar.getInstance()` check) rather than throwing.
- Create `core/database/isar_provider.dart`: a Riverpod `FutureProvider<Isar>` wrapping `openIsar()`, and have `main.dart` `await` it before `runApp` (so the first frame never shows a loading spinner for the DB).
- In `main.dart`: call `WidgetsFlutterBinding.ensureInitialized()`, then `await openIsar()`, then `runApp(ProviderScope(overrides: [...], child: const VestWiseApp()))`.
- **Validation:** Cold-start the app, confirm (via a temporary debug print or the Isar Inspector) that the `.isar` file is created under the app's documents directory and reopens cleanly on a second launch (no duplicate-instance exception).

### P1-T3: File storage service
- Create `core/storage/file_storage_service.dart` with:
  - `Future<Directory> getAppDocumentsDir()`
  - `Future<Directory> getImportedFilesDir()` — a `imported_documents/` subfolder, created if missing.
  - `Future<File> copyPickedFileToLocalStorage(PlatformFile pickedFile)` — copies the picked file into `imported_documents/<uuid>_<original_name>` and returns the new `File` (never reference the picker's cache path long-term, since it may be cleared by the OS).
  - `Future<void> deleteLocalFile(String relativePath)`
- **Validation:** Unit/integration test: pick a dummy file (or construct a temp `File` in tests), copy it, assert it exists at the returned path and the original cache copy is untouched.

### P1-T4: Notification service bootstrap
- Create `core/notifications/notification_service.dart`:
  - `Future<void> init()` — initializes `flutter_local_notifications` with Android/iOS init settings, sets the local timezone via the `timezone` package (`tz.initializeTimeZones()` + `tz.setLocalLocation(...)`).
  - `Future<bool> requestPermissions()` — requests notification permission on Android 13+ and iOS.
  - `Future<int> scheduleNotification({required String title, required String body, required DateTime scheduledDate, int? id})` — returns the notification id used (so it can be stored on the `TaskModel`/`CalendarEventModel` for later cancellation).
  - `Future<void> cancelNotification(int id)`
  - `Future<void> cancelAll()`
- Create `core/notifications/notification_provider.dart` exposing the service as a Riverpod provider.
- Call `NotificationService.init()` in `main.dart` alongside Isar init.
- **Validation:** Schedule a test notification for "now + 10 seconds" from a temporary debug button; confirm it fires with the device screen locked and the app backgrounded.

### P1-T5: Navigation shell (go_router)
- Create `core/router/route_paths.dart` with named path constants (`/`, `/finance`, `/notes`, `/tasks`, `/calendar`, plus detail routes like `/tasks/:id`).
- Create `core/router/app_router.dart`:
  - A `ShellRoute` (or `StatefulShellRoute.indexedStack`) wrapping a persistent bottom navigation bar with 5 destinations: Dashboard, Finance, Notes, Tasks, Calendar.
  - Nested routes per feature for detail/edit screens (e.g. `/tasks/:id`, `/notes/:id/edit`, `/finance/add`).
- Wire `GoRouter` into `app.dart` via `MaterialApp.router(routerConfig: ref.watch(appRouterProvider))`.
- **Validation:** Tapping each bottom nav icon navigates correctly, back button/gesture behaves as expected, and deep navigation (e.g. task list → task detail → back) preserves the bottom nav's selected tab.

### P1-T6: Shared widget kit
- Build each widget in `core/widgets/` as a small, documented, stateless component:
  - `VWCard` — the base container for all card-based layouts (padding, radius, border/elevation from theme).
  - `VWButton` — primary/secondary/destructive variants.
  - `VWTextField` — consistent input styling with optional label/error text.
  - `VWEmptyState` — icon + message + optional CTA button, used by every feature's empty list state.
  - `VWSectionHeader` — title + optional trailing action, used on Dashboard and list screens.
  - `VWAppBar` — consistent app bar across feature screens.
  - `VWLoadingIndicator` — centered spinner for async states.
- **Validation:** A `/widgetbook` or simple debug screen renders all of them in both light and dark theme for visual QA (optional but recommended — can also just verify each in isolation via a widget test).

**Definition of done for Phase 1:** Isar opens and persists across restarts, notifications can be scheduled/cancelled, routing works across all five top-level destinations, and every feature screen going forward is built exclusively from the `core/widgets/` kit.

---

## 4. Phase 2 — Data Layer (Isar Schemas & Repositories)

**Goal:** All six Isar collections exist, generate correctly, and each feature has a working repository with full CRUD + reactive watch streams.

### P2-T1: Define all Isar models
Create the six model files exactly as specified in **§10 Data Models**. For each:
- Annotate with `@collection`.
- Add `part '<file>.g.dart';` at the top.
- Index fields that will be filtered/sorted on frequently (dates, completion status).
- **Validation:** `dart run build_runner build --delete-conflicting-outputs` generates all `*.g.dart` files with zero errors.

### P2-T2: Repository interfaces (domain layer)
For each feature, define an abstract repository in `domain/repositories/<feature>_repository.dart` exposing the operations the UI needs — e.g. for Tasks:
```dart
abstract class TasksRepository {
  Stream<List<TaskModel>> watchAllTasks();
  Stream<List<TaskModel>> watchTasksDueToday();
  Future<Result<TaskModel>> getTaskById(int id);
  Future<Result<int>> createTask(TaskModel task);
  Future<Result<void>> updateTask(TaskModel task);
  Future<Result<void>> deleteTask(int id);
  Future<Result<void>> toggleComplete(int id);
}
```
Mirror this pattern for `FinanceRepository`, `NotesRepository`, `CalendarRepository`.

### P2-T3: Repository implementations (data layer)
Implement each interface in `data/repositories/<feature>_repository_impl.dart`, taking an `Isar` instance via constructor injection. Use:
- `isar.collection<T>().watchLazy()` / `.where()...watch(fireImmediately: true)` for reactive streams.
- `isar.writeTxn(() async { ... })` for all writes.
- Wrap every call in try/catch, returning `Result.error(DatabaseFailure(...))` on exception.
- **Validation:** Write a unit test per repository using an in-memory Isar instance (`Isar.open(..., directory: '')` in test mode or a temp dir) that creates, reads, updates, deletes, and asserts the watch stream emits the expected sequence.

### P2-T4: Riverpod providers for repositories
In each feature's `providers/<feature>_providers.dart`, expose:
- A provider for the repository itself (depends on the Isar provider from P1-T2).
- `StreamProvider`s for the watch queries the UI will consume directly.
- **Validation:** A temporary debug screen (or widget test) consumes one `StreamProvider` and shows live-updating data when a row is inserted via the Isar Inspector or a debug button.

**Definition of done for Phase 2:** All CRUD operations for Finance, Notes, Tasks, and Calendar are implemented, tested, and reactive end-to-end from Isar to a Riverpod stream.

---

## 5. Phase 3 — Feature Modules MVP

Build in this order: **Tasks → Calendar → Finance → Notes → Dashboard** (Dashboard last, since it aggregates data from the other four).

### 5.1 Tasks & To-Do

**P3-TASK-1: Task list screen**
- `tasks_list_screen.dart`: list grouped by (or filterable by) priority and due date, each row showing title, priority color dot, due date chip, and a checkbox to toggle completion.
- Use `VWEmptyState` when there are no tasks ("No tasks yet — add your first one").
- Floating action button → navigate to a create/edit form.
- **Validation:** Create 3 tasks with different priorities; confirm sort/group order and that checking a task strikes it through and moves it to a "Completed" section (or filters it out, per design choice — document the choice in a code comment).

**P3-TASK-2: Task create/edit form + sub-tasks**
- `task_detail_screen.dart` (doubles as create/edit): title, description, priority selector (segmented control), due date/time picker, and a dynamic sub-task checklist (add/remove/reorder rows, each independently checkable, stored as `List<SubTask>` embedded objects).
- On save with a due date set, call `NotificationService.scheduleNotification` and persist the returned notification id on the `TaskModel`. On delete/due-date-change, cancel the old notification id first.
- **Validation:** Add 3 sub-tasks, check 2, verify persisted state survives app restart; set a due date 1 minute out and confirm the reminder fires.

### 5.2 Calendar & Events

**P3-CAL-1: Calendar screen**
- `calendar_screen.dart`: month view (consider `table_calendar` package for the grid — add it to §1.3/pubspec if used) with event-dot markers per day, and a selected-day event list below.
- **Validation:** Events created on a given date show a marker on that date and appear in the day list when selected.

**P3-CAL-2: Event create/edit form**
- `event_detail_screen.dart`: title, description, start/end date-time, all-day toggle, repeat option, reminder-minutes-before selector.
- Reminder scheduling follows the same pattern as P3-TASK-2 (schedule on save, cancel on delete/edit, persist `notificationId`).
- **Validation:** Create an event 2 minutes out with a 1-minute-before reminder; confirm notification fires at the correct offset.

### 5.3 Personal Finance Tracker

**P3-FIN-1: Default categories seeding**
- On first app launch (check a simple "seeded" flag, e.g. a `shared_preferences` bool or a sentinel Isar record), insert a sensible default set of `CategoryModel` rows for both income (Salary, Allowance, Gift, Other Income) and expense (Food, Transport, Shopping, Bills, Education, Entertainment, Health, Other).
- **Validation:** Fresh install shows these categories available in the add-transaction form; relaunch does not duplicate them.

**P3-FIN-2: Finance home screen**
- `finance_home_screen.dart`: current balance (sum of all income − all expenses) at the top via `VWCard`, followed by a reverse-chronological transaction list grouped by day, each row showing category icon/color, note, amount (green for income, red for expense).
- **Validation:** Add one income and one expense; balance updates instantly and correctly; list ordering is newest-first.

**P3-FIN-3: Add/edit transaction screen**
- `add_transaction_screen.dart`: income/expense toggle, amount field (numeric keyboard, validated > 0), category picker (filtered by the selected type), date picker (defaults to today), optional note.
- **Validation:** Form rejects empty/zero/negative amounts with inline error via `VWTextField`'s error state; valid submission returns to the list with the new row visible.

**P3-FIN-4: Weekly/monthly summary charts**
- `finance_summary_screen.dart`: a `fl_chart` bar chart (income vs. expense per week/day, toggle between week/month view) plus a simple category breakdown list (top categories by spend, with percentage).
- **Validation:** Chart values sum-check against the raw transaction data for a test dataset of at least 10 transactions across 2 categories.

### 5.4 Notes & Document Workspace

**P3-NOTES-1: Notes list screen**
- `notes_list_screen.dart`: grid or list of notes (title, content preview snippet stripped of rich formatting, last-updated timestamp, pin indicator), plus a separate section/tab for imported documents (file-type icon, file name, size, imported date).
- Search field filtering by title/content (simple case-insensitive substring match against an indexed field — no need for full-text search infra given expected data volume).
- **Validation:** Create 2 notes and import 1 dummy PDF; both appear in their respective sections; typing in search narrows results live.

**P3-NOTES-2: Rich text note editor**
- `note_editor_screen.dart` using `flutter_quill`: title field + `QuillEditor` body, toolbar with bold/italic/underline/lists/headings. Persist `contentJson` as the Quill Delta JSON string, `contentPlainText` (optional derived field) for search/preview.
- Autosave on a debounce (e.g. 800ms after last keystroke) or on screen-exit — pick one and be consistent; debounce is the better UX for a notes app.
- **Validation:** Type content, background the app without manually saving, relaunch — content is preserved.

**P3-NOTES-3: Document import flow**
- Trigger via `file_picker` (`FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf','docx','doc','txt'])`), then `FileStorageService.copyPickedFileToLocalStorage(...)`, then persist an `ImportedDocumentModel` row.
- **Validation:** Import a file, force-close and relaunch the app, confirm the file still opens (proves it was copied into app-owned storage, not referenced from a volatile picker cache path).

**P3-NOTES-4: In-app document viewer**
- `document_viewer_screen.dart`: for `.pdf` files, render via `flutter_pdfview` directly from the local file path. For `.docx`/other formats without a reliable offline Flutter renderer, show a clean metadata card (file name, type, size, imported date) with an "Open in external app" action using a package like `open_filex`/`open_file`, rather than attempting a fragile in-app DOCX renderer — document this limitation visibly in the UI ("Preview not available — open externally") rather than silently failing.
- **Validation:** Imported PDF renders and is scrollable/zoomable in-app; imported DOCX shows the metadata card and successfully opens in an external viewer app.

### 5.5 Dashboard

**P3-DASH-1: Dashboard aggregation provider**
- `dashboard_provider.dart`: combine (via `Riverpod`'s ability to `ref.watch` multiple providers, e.g. with a code-generated `@riverpod` function or `StreamGroup`/`combine`) streams from all four feature repositories into a single `DashboardState` containing: today's incomplete tasks, current balance + this week's net change, next 3 upcoming calendar events/deadlines, and the 2 most recently edited notes.
- **Validation:** Changing data in any one feature (e.g. completing a task) reflects on the Dashboard without a manual refresh.

**P3-DASH-2: Dashboard screen composition**
- `dashboard_screen.dart`: greeting header (time-of-day aware, e.g. "Good morning"), then `TodayTasksCard`, `BalanceSummaryCard`, `UpcomingDeadlinesCard`, `QuickNotesCard` — each a `VWCard` with a `VWSectionHeader` and a "See all →" action routing into the relevant feature tab.
- **Validation:** Each card correctly links to its feature's list screen; empty states render gracefully (e.g. "No tasks for today 🎉") when a feature has no data, via `VWEmptyState`.

**Definition of done for Phase 3:** All five modules are functional end-to-end — a user can log finances, write notes, import a PDF, manage tasks with sub-tasks, schedule calendar events, and see it all summarized on the Dashboard, fully offline.

---

## 6. Phase 4 — Local Notifications & File Management Hardening

**Goal:** Move from "notifications/files work in the happy path" to "they work correctly across edge cases and OS restrictions."

### P4-T1: Android exact-alarm & boot-persistence handling
- Confirm `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM` permission handling (Android 12+ requires this for precise reminders) — detect if exact alarms are disabled by the user and gracefully degrade to inexact scheduling with a one-time in-app notice, rather than crashing.
- Verify notifications survive a device reboot (requires `RECEIVE_BOOT_COMPLETED` + the plugin's boot receiver, see §13).
- **Validation:** Schedule a reminder, reboot the test device/emulator, confirm it still fires at the scheduled time.

### P4-T2: iOS notification permission UX
- Request notification permission at a sensible moment (e.g. the first time the user sets a due date/reminder, not on cold app launch) rather than immediately on first run, since a blind launch-time prompt has poor opt-in rates.
- Handle the "denied" case: if the user declines, show an inline banner on Tasks/Calendar screens explaining reminders are off and linking to system settings — do not repeatedly re-prompt.
- **Validation:** Deny permission on a fresh iOS simulator install, confirm the app doesn't crash and the banner appears; re-enable via Settings and confirm the banner disappears on next relevant screen visit.

### P4-T3: Notification lifecycle correctness
- Ensure editing a task's/event's due date **cancels the old notification id** before scheduling a new one (prevents duplicate/stale reminders).
- Ensure deleting a task/event cancels its notification.
- Ensure marking a task complete cancels its pending reminder (a completed task shouldn't still remind).
- **Validation:** Create a task due in 5 minutes, mark it complete after 2 minutes, confirm no notification fires at the original time.

### P4-T4: Storage footprint & cleanup
- On deleting a note's or an imported document's Isar record, also delete the corresponding file from disk via `FileStorageService.deleteLocalFile`.
- Add a simple "Storage used" readout (sum of file sizes in `imported_documents/`) somewhere reasonable (e.g. a Settings screen, see P5-T4) so the offline-local nature of the app is visible/trustworthy to the user.
- **Validation:** Delete an imported document, confirm the underlying file is gone from the filesystem (not just the Isar row), and the storage readout decreases accordingly.

**Definition of done for Phase 4:** Notifications are reliable across reboots, permission states, and data edits; no orphaned files remain after deletions.

---

## 7. Phase 5 — UI/UX Refinement & Polish

### P5-T1: Micro-interactions & motion
- Add subtle, purposeful animations only: list item insertion/removal (`AnimatedList` or implicit animations), checkbox toggle feedback, page transitions via `go_router`'s built-in transition support. No gratuitous motion — this is a "fast and minimal" app, not a showcase of effects.
- **Validation:** Manual pass confirms no animation exceeds ~250ms and nothing blocks input during a transition.

### P5-T2: Empty, loading, and error states audit
- Walk every screen and confirm it has an explicit design for: first-run empty state, loading state (should be near-instant given local DB, but cover it), and error state (e.g. a corrupted file import) — all via the shared `VWEmptyState`/`VWLoadingIndicator` widgets, never a bare `CircularProgressIndicator()` dropped ad hoc.
- **Validation:** Checklist of all screens with pass/fail per state, attached as a comment or `/docs/qa-checklist.md`.

### P5-T3: Accessibility pass
- Verify minimum tap target size (48x48), sufficient color contrast for text/background pairs (check `priorityHigh`/`priorityMedium`/`priorityLow` colors especially), and that interactive elements have `Semantics` labels where icon-only.
- **Validation:** Run through the app with TalkBack/VoiceOver enabled and confirm all primary actions (add task, add transaction, save note) are operable.

### P5-T4: Settings screen
- Add a minimal Settings screen: theme mode (System/Light/Dark), notification permission status + re-request action, storage usage readout (from P4-T4), app version, and a "Clear all data" destructive action with a confirmation dialog (wipes Isar collections + `imported_documents/` folder — useful for QA and for users who want a true reset).
- **Validation:** Toggling theme mode persists across restart (store the choice, e.g. via `shared_preferences`, read on boot before first frame to avoid a flash of the wrong theme).

### P5-T5: Performance pass
- Confirm long lists (100+ tasks/transactions) use lazy-building list widgets (`ListView.builder`, not `Column` + `map`), and that Isar queries use `.limit()`/pagination where a screen could realistically grow unbounded (e.g. finance history).
- Profile cold-start time and first-frame time using `flutter run --profile` / DevTools; investigate anything over ~2 seconds cold start on a mid-range test device.
- **Validation:** DevTools performance overlay shows no dropped frames scrolling a 200-item seeded list.

**Definition of done for Phase 5:** The app feels fast, consistent, and considered in every state — not just the happy path.

---

## 8. Phase 6 — Testing & QA

### P6-T1: Unit tests
- Repositories (already covered incrementally in Phase 2, confirm coverage) — CRUD + edge cases (e.g. deleting a non-existent id returns a graceful `Result.error`, not a throw).
- Pure logic: currency formatting, date utilities, balance calculation, notification-offset calculation.

### P6-T2: Widget tests
- One widget test per core shared widget (`VWCard`, `VWButton`, `VWEmptyState`, etc.) confirming they render given props correctly.
- One widget test per feature's primary list screen confirming it shows `VWEmptyState` with zero items and a populated list with N items (using a mocked repository/provider override — use `mocktail` + Riverpod's `overrideWith`).

### P6-T3: Integration tests
- Using `integration_test`, cover at least these end-to-end flows on a real/emulated device:
  1. Create a task with a due-date reminder → verify it appears on Dashboard "today's tasks."
  2. Log an income and an expense → verify Dashboard balance updates.
  3. Create a note, background and reopen the app → verify autosave persisted it.
  4. Import a PDF → open it in the in-app viewer.
- **Validation:** `flutter test integration_test/` passes on both an Android emulator and an iOS simulator.

### P6-T4: Regression checklist before release
- Full manual pass through every screen on both a small-screen Android device and an iOS device/simulator, in both light and dark mode, confirming no overflow errors (`flutter run` console clear of `RenderFlex overflowed` warnings).

**Definition of done for Phase 6:** `flutter test` (unit + widget) and `flutter test integration_test/` both pass cleanly; manual regression checklist signed off.

---

## 9. Phase 7 — Release Build & Store Submission

See **§13 Store Readiness Checklist** for the full, detailed list. At a high level, execute in this order:
1. Finalize `com.vestwise.app` as the applicationId (Android) / bundle identifier (iOS) everywhere.
2. Generate app icon + splash screen assets (`flutter_launcher_icons`, `flutter_native_splash`).
3. Configure Android signing (`key.properties` + release keystore) and iOS signing (Xcode Team/Provisioning).
4. Add all required permissions (§13.2, §13.3) with user-facing usage-description strings.
5. Build release artifacts: `flutter build appbundle --release` (Android `.aab`) and `flutter build ipa --release` (iOS `.ipa`).
6. Prepare store listing assets (screenshots, descriptions, privacy policy) and submit.

---

## 10. Data Models / Isar Schemas (Full Reference)

> Field names and types below are the contract the rest of this plan assumes. Run `dart run build_runner build --delete-conflicting-outputs` after creating/editing any of these.

### 10.1 Finance — `lib/features/finance/data/models/category_model.dart`
```dart
import 'package:isar_community/isar.dart';

part 'category_model.g.dart';

enum TransactionType {
  income,
  expense,
}

@collection
class CategoryModel {
  Id id = Isar.autoIncrement;

  late String name;

  /// Material icon codePoint, rendered via IconData(iconCodePoint, fontFamily: ...)
  late int iconCodePoint;

  /// ARGB color value, e.g. Colors.teal.value
  late int colorValue;

  @enumerated
  late TransactionType type;

  bool isDefault = false;
}
```

### 10.2 Finance — `lib/features/finance/data/models/transaction_model.dart`
```dart
import 'package:isar_community/isar.dart';
import 'category_model.dart';

part 'transaction_model.g.dart';

@collection
class TransactionModel {
  Id id = Isar.autoIncrement;

  @Index()
  late DateTime date;

  /// Always stored as a positive value; sign is derived from [type].
  late double amount;

  @enumerated
  late TransactionType type;

  final category = IsarLink<CategoryModel>();

  String? note;

  @Index()
  late DateTime createdAt;

  DateTime? updatedAt;
}
```

### 10.3 Notes — `lib/features/notes/data/models/note_model.dart`
```dart
import 'package:isar_community/isar.dart';

part 'note_model.g.dart';

@collection
class NoteModel {
  Id id = Isar.autoIncrement;

  late String title;

  /// flutter_quill Delta, stored as a JSON string.
  late String contentJson;

  /// Derived plain-text mirror of [contentJson], kept in sync on save,
  /// used for lightweight substring search and list previews.
  String contentPlainText = '';

  List<String> tags = [];

  bool isPinned = false;

  bool isArchived = false;

  @Index()
  late DateTime createdAt;

  @Index()
  late DateTime updatedAt;
}
```

### 10.4 Notes — `lib/features/notes/data/models/imported_document_model.dart`
```dart
import 'package:isar_community/isar.dart';

part 'imported_document_model.g.dart';

@collection
class ImportedDocumentModel {
  Id id = Isar.autoIncrement;

  late String fileName;

  /// Path relative to the app's imported_documents/ directory —
  /// never store an absolute path, since it can change across installs/OS updates.
  late String relativeFilePath;

  /// e.g. "pdf", "docx", "txt"
  late String fileExtension;

  late int fileSizeBytes;

  @Index()
  late DateTime importedAt;

  /// Optional link back to a NoteModel.id if this document was attached
  /// to a specific note rather than imported standalone.
  int? linkedNoteId;
}
```

### 10.5 Tasks — `lib/features/tasks/data/models/task_model.dart`
```dart
import 'package:isar_community/isar.dart';

part 'task_model.g.dart';

enum TaskPriority {
  low,
  medium,
  high,
}

@embedded
class SubTask {
  late String localId; // uuid, generated client-side
  late String title;
  bool isDone = false;
}

@collection
class TaskModel {
  Id id = Isar.autoIncrement;

  late String title;

  String? description;

  @enumerated
  late TaskPriority priority;

  @Index()
  DateTime? dueDate;

  @Index()
  bool isCompleted = false;

  List<SubTask> subTasks = [];

  /// id returned by flutter_local_notifications when a reminder is scheduled;
  /// null if no reminder is set. Used to cancel on edit/delete/complete.
  int? notificationId;

  @Index()
  late DateTime createdAt;

  DateTime? completedAt;
}
```

### 10.6 Calendar — `lib/features/calendar/data/models/calendar_event_model.dart`
```dart
import 'package:isar_community/isar.dart';

part 'calendar_event_model.g.dart';

enum EventRepeat {
  none,
  daily,
  weekly,
  monthly,
  yearly,
}

@collection
class CalendarEventModel {
  Id id = Isar.autoIncrement;

  late String title;

  String? description;

  @Index()
  late DateTime startDateTime;

  DateTime? endDateTime;

  bool isAllDay = false;

  @enumerated
  late EventRepeat repeat;

  bool hasReminder = false;

  int? reminderMinutesBefore;

  /// id returned by flutter_local_notifications; null if hasReminder is false.
  int? notificationId;

  /// Optional link to a TaskModel.id if this event represents a task deadline
  /// surfaced on the calendar, rather than a standalone event.
  int? linkedTaskId;

  int colorValue = 0xFF4F46E5;
}
```

---

## 11. State Management Conventions

- Prefer **code-generated Riverpod** (`@riverpod` annotation + `riverpod_generator`) over hand-written `StateNotifierProvider`/`ChangeNotifierProvider` boilerplate, for consistency and compile-time safety.
- Pattern per feature, in `presentation/providers/<feature>_providers.dart`:
  ```dart
  @riverpod
  TasksRepository tasksRepository(TasksRepositoryRef ref) {
    final isar = ref.watch(isarProvider).requireValue;
    return TasksRepositoryImpl(isar);
  }

  @riverpod
  Stream<List<TaskModel>> watchAllTasks(WatchAllTasksRef ref) {
    return ref.watch(tasksRepositoryProvider).watchAllTasks();
  }
  ```
- Form state (e.g. the add-task or add-transaction form) uses a dedicated `Notifier`/`AsyncNotifier` per form, exposing a `submit()` method that calls the repository and returns success/failure for the UI to react to (e.g. pop the screen or show a validation error) — forms should never write to Isar directly from a widget's `onPressed`.
- Screens consume state via `ConsumerWidget`/`HookConsumerWidget` (`flutter_hooks` + `hooks_riverpod` is an acceptable addition if the agent prefers hooks for local ephemeral UI state like text controllers — optional, not required).

---

## 12. Navigation Map

| Path | Screen | Notes |
|---|---|---|
| `/` | Dashboard | Root of the shell/bottom nav |
| `/finance` | Finance home | Bottom nav tab |
| `/finance/add` | Add/edit transaction | Modal or full-screen push |
| `/finance/summary` | Charts & breakdown | Pushed from Finance home |
| `/notes` | Notes list | Bottom nav tab |
| `/notes/:id/edit` | Note editor | `:id == 'new'` for create flow |
| `/notes/document/:id` | Document viewer | PDF/metadata viewer |
| `/tasks` | Tasks list | Bottom nav tab |
| `/tasks/:id` | Task detail/edit | `:id == 'new'` for create flow |
| `/calendar` | Calendar | Bottom nav tab |
| `/calendar/event/:id` | Event detail/edit | `:id == 'new'` for create flow |
| `/settings` | Settings | Pushed from Dashboard/any app bar action |

---

## 13. Store Readiness Checklist

### 13.1 Application identity
- [ ] Android `applicationId` in `android/app/build.gradle` = `com.vestwise.app`.
- [ ] iOS `PRODUCT_BUNDLE_IDENTIFIER` in Xcode project settings (or `ios/Runner.xcodeproj`) = `com.vestwise.app`.
- [ ] App display name set consistently ("VestWise") in `android/app/src/main/AndroidManifest.xml` (`android:label`) and `ios/Runner/Info.plist` (`CFBundleDisplayName`).
- [ ] App icon generated for all densities/sizes via `flutter_launcher_icons`; splash screen via `flutter_native_splash`.

### 13.2 Android — `android/app/src/main/AndroidManifest.xml`
Add inside `<manifest>`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```
Add inside `<application>` (required receivers for `flutter_local_notifications` scheduled/boot-persisted alarms — confirm exact receiver class names against the installed plugin version's README, as these occasionally change):
```xml
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```
Notes:
- `file_picker` generally does not require a broad storage permission on modern Android (uses the system document picker via Storage Access Framework); do not add `READ_EXTERNAL_STORAGE`/`WRITE_EXTERNAL_STORAGE` unless a specific feature proves it's needed, since unnecessary broad permissions are a Play Store review friction point.
- [ ] `android/app/build.gradle`: set `minSdkVersion` to the level required by `isar_community`/`flutter_local_notifications` (check each package's current requirement), `targetSdkVersion`/`compileSdkVersion` to the latest stable at submission time.
- [ ] Configure release signing: generate a keystore, create `android/key.properties` (gitignored), reference it in `android/app/build.gradle`'s `signingConfigs`.
- [ ] Build: `flutter build appbundle --release` → produces `build/app/outputs/bundle/release/app-release.aab`.

### 13.3 iOS — `ios/Runner/Info.plist`
Add/confirm:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>VestWise needs access to your photo library to attach images to notes.</string>
<key>UIFileSharingEnabled</key>
<true/>
<key>LSSupportsOpeningDocumentsInPlace</key>
<true/>
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```
Notes:
- `flutter_local_notifications` does not require an `Info.plist` key for local (non-push) notifications; permission is requested at runtime via `UNUserNotificationCenter` — ensure `NotificationService.requestPermissions()` (P1-T4) is actually invoked before scheduling, or scheduling will silently no-op.
- `UIFileSharingEnabled` + `LSSupportsOpeningDocumentsInPlace` are optional but recommended so a user can see/manage their imported documents via the iOS Files app, reinforcing the "your data stays on your device" value proposition.
- `ITSAppUsesNonExemptEncryption = false` avoids an App Store Connect export-compliance prompt on every build, assuming the app uses no custom encryption beyond standard OS-provided HTTPS/at-rest protections.
- [ ] Set `CFBundleShortVersionString` / `CFBundleVersion` consistently with the Android `versionName`/`versionCode`.
- [ ] Configure signing in Xcode: select the correct Team, confirm the bundle identifier matches `com.vestwise.app`, enable automatic or manual provisioning.
- [ ] Build: `flutter build ipa --release` → produces an `.ipa` under `build/ios/ipa/`, then upload via Xcode Organizer or Transporter.

### 13.4 Store listing & compliance
- [ ] Privacy policy page/URL — even though VestWise collects no data and has no server, both stores require a privacy policy link; state explicitly that all data is stored locally on-device and never transmitted.
- [ ] Play Store **Data Safety** form: declare "No data collected" (confirm this is accurate by auditing for any inadvertent network calls, e.g. from an analytics SDK that shouldn't be there — there should be none per the offline-first principle).
- [ ] App Store **Privacy Nutrition Label**: same "Data Not Collected" declaration.
- [ ] Screenshots for required device sizes (Android: phone + optionally tablet; iOS: 6.7"/6.5" and other required sizes per current App Store Connect requirements at submission time).
- [ ] Short description, full description, keywords, category (Productivity).
- [ ] Age rating questionnaire (should qualify for the lowest tier — no user-generated-content sharing, no ads, no in-app purchases unless added later).
- [ ] Content rating / target audience — confirm no features inadvertently target the app at children (e.g. no COPPA-triggering elements) unless intentionally designed for that audience.

**Definition of done for Phase 7:** A signed `.aab` installs and runs correctly from a clean device via internal testing track; a signed `.ipa` installs and runs correctly via TestFlight; both store listings are complete and submitted for review.

---

## 14. Appendix: Reference `pubspec.yaml` Dependency Block

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State management
  flutter_riverpod:
  riverpod_annotation:

  # Navigation
  go_router:

  # Local database — community-maintained Isar fork (verify status per §1.6 before use)
  isar_community:
    hosted: https://pub.isar-community.dev/
    version: ^3.0.0 # confirm latest compatible version at install time
  isar_community_flutter_libs:
    hosted: https://pub.isar-community.dev/
    version: ^3.0.0

  # File & document handling
  path_provider:
  file_picker:
  flutter_pdfview:
  open_filex:

  # Rich text editor
  flutter_quill:

  # Notifications
  flutter_local_notifications:
  timezone:

  # Calendar UI
  table_calendar:

  # Charts
  fl_chart:

  # Utilities
  uuid:
  shared_preferences: # theme preference + first-run seeding flag
  permission_handler:

dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_lints:
  build_runner:
  riverpod_generator:
  isar_community_generator:
    hosted: https://pub.isar-community.dev/
    version: ^3.0.0
  mocktail:
  flutter_launcher_icons:
  flutter_native_splash:

flutter:
  uses-material-design: true
  assets:
    - assets/icons/
  fonts:
    - family: Inter
      fonts:
        - asset: assets/fonts/Inter-Regular.ttf
        - asset: assets/fonts/Inter-Medium.ttf
          weight: 500
        - asset: assets/fonts/Inter-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Inter-Bold.ttf
          weight: 700
```

> Run `flutter pub add <package_name>` for each entry above rather than hand-editing version numbers, so `pubspec.yaml` always resolves to versions actually compatible with the installed Flutter SDK at the time of building.

---

## End of Plan

Work phase by phase. Do not begin Phase *n+1* until the "Definition of done" for Phase *n* is satisfied and committed.
