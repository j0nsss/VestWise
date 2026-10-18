# VestWise — Design System & Motion Upgrade Plan

**Project:** VestWise — Offline-First Productivity Platform
**Relation to other docs:** `plan.md` (Phases 0–7) is still the canonical architecture reference and is **not replaced**. `ringkasan.md` is the current, real progress report this plan is grounded in. This document adds **Phases 8–12**: a presentation-layer upgrade that takes VestWise's already-working functionality (Phase 0–5 complete, Phase 6 partial, Phase 7 not started, per `ringkasan.md`) and gives it a Notion-caliber look and feel.
**Document type:** Execution roadmap for an AI coding agent (Cursor / Windsurf / Cline / Roo Code)

---

## 0. How to Use This Document

1. Read §1 first — it is a condensed, accurate snapshot of what already exists in the codebase today, pulled directly from `ringkasan.md`. Do not re-derive architecture from `plan.md` alone; `plan.md` describes intent, `ringkasan.md` (and this section) describe what was actually built, including real package versions and known gotchas.
2. Work phases in order: **8 → 9 → 10 → 11 → 12**. Phase 10 has five independent sub-tracks (Notes, Tasks, Finance/Dashboard, Calendar/Nav) that can be parallelized across sessions if useful, but each sub-track still depends on Phases 8 and 9 being done first.
3. Follow the same discipline already established on this project: one commit per task (`feat(P8-T1): ...`), `dart analyze lib test integration_test` + `flutter test` must stay clean after every task, and every task below ends with a concrete validation step.
4. See §3 for the hard rule on what this plan is and is not allowed to touch in `data/`/`domain/`.
5. See §9 for exactly where this plan fits relative to the unfinished Phase 6 and Phase 7 work.

---

## 0.5 Decisions Locked During Review

These were settled by reviewing this plan against the actual codebase, and every
section below has been corrected to match. Treat them as binding.

| # | Decision | Rationale |
|---|---|---|
| 1 | Motion token names are the real ones (`pageTransition` 200ms, `listItemEnter` 180ms, `stateChange` 150ms, `maxDuration` 250ms, `standardCurve`) — there is no `fast`/`medium`. | Those names never existed; adding aliases would give two names to one concept. |
| 2 | `AppMotion.signature = 320ms` is the **single documented exception** to the 250ms budget, reserved for the 2–3 emphasized moments. The motion test asserts "everything except `signature` ≤250ms; `signature` ≤400ms". | The task-complete morph genuinely benefits from the extra ~70ms; an undocumented exception would be worse. |
| 3 | New colour tokens follow the plan's context-based signatures (`AppColors.surfaceSoft(context)`), delegating to public `...For(Brightness)` resolvers so the existing contrast test can exercise them without a widget tree. | Keeps the requested call-site API and keeps the WCAG test meaningful. |
| 4 | `VWCard` stays on Material `Card` + `InkWell`; variants only override colour/border/elevation; default `padding` stays `AppSpacing.lg`. | `cardTheme` remains the single source of truth, ripple/semantics survive, 10 call sites don't shift, and the existing `find.byType(Card)` test keeps passing. |
| 5 | Swipe actions use the built-in `Dismissible`, not `flutter_slidable`. | No new dependency; both gestures covered by `confirmDismiss`. |
| 6 | Skeletons are gated behind a ~100ms delay so an instant local read never flashes one. | Enforces the plan's own anti-flicker requirement. |
| 7 | Both pre-approved schema exceptions are taken (`TaskModel.sortIndex`, `NoteModel.iconCodePoint`). | The optional tasks add real UX value and the migration test pattern is already established. |
| 8 | `VWStaggeredList` wraps the existing `VWAnimatedListItem` instead of reimplementing row entry, and its stagger must fit inside the `signature` budget. | One row-animation implementation, reused. |

---

## 1. Current State Snapshot (from `ringkasan.md`)

Use these as ground truth — they are what's actually installed and actually built, not placeholders.

### 1.1 Stack & pinned versions already in use
| Concern | Package | Version |
|---|---|---|
| Framework | Flutter / Dart | 3.44.1 / 3.12.1 (SDK `^3.12.1`) |
| Database | `isar_community` (+ `isar_community_flutter_libs`) | 3.4.1 |
| State management | `flutter_riverpod` + `riverpod_annotation` (codegen) | 3.4.3 / 4.0.7 |
| Navigation | `go_router` (shell route + bottom nav) | 17.5.0 |
| Notifications | `flutter_local_notifications` + `timezone` + `flutter_timezone` | 22.3.2 |
| Notes editor | `flutter_quill` | 11.6.0 |
| Documents | `file_picker`, `flutter_pdfview`, `open_filex` | 13.1.0 / 1.4.5 / 5.0.0 |
| Charts | `fl_chart` | 1.2.0 |
| Calendar | `table_calendar` | 3.2.0 |
| Prefs | `shared_preferences` | 2.5.6 |
| Misc | `intl`, `uuid`, `path_provider`, `app_settings`, `package_info_plus` | 0.20.2 / – / – / 9.0.1 / 10.2.2 |

When this plan adds a new package (§10 lists the candidates), verify it against Dart SDK `^3.12.1` / Flutter 3.44.1 before adding, the same way earlier phases did.

### 1.2 Folder structure already in place
```
lib/
├── core/
│   ├── constants/       # AppColors, AppSpacing, AppStrings, AppMotion (already exists, ≤250ms tokens + reduced-motion support)
│   ├── database/        # isar_service, isar_provider, app_data_reset
│   ├── errors/          # Result/Failure + result_guard
│   ├── notifications/   # notification_service + provider + banner
│   ├── router/          # app_router, route_paths
│   ├── storage/         # file_storage_service (imported_documents/)
│   ├── theme/           # app_theme, theme_store, theme_provider
│   ├── utils/           # byte_format, ...
│   └── widgets/         # VW* kit: VWButton, VWCard, VWEmptyState, VWAppBar, ...
└── features/
    ├── dashboard/
    ├── tasks/
    ├── finance/
    ├── notes/
    ├── calendar/
    └── settings/
```
Every feature already follows `data/` (Isar models + repo impl) → `domain/` (repo interface) → `presentation/` (screens, widgets, providers). **This plan operates almost entirely inside `presentation/` and `core/theme/`, `core/constants/`, `core/widgets/`.**

### 1.3 What already exists and must not be rebuilt from scratch
- `AppMotion` (`core/constants/`) already defines motion tokens — `maxDuration` 250ms, `pageTransition` 200ms, `listItemEnter` 180ms, `stateChange` 150ms, `enterCurve`, `standardCurve` — and reduced motion is already respected via the top-level `prefersReducedMotion(context)` helper (not a member of `AppMotion`), which *skips* transitions outright rather than shortening them. Phase 9 below **extends** this file — it does not replace it, and it adds the one documented exception to the 250ms ceiling (`signature`, §0.5 #2).
- `VWEmptyState` was already rewritten once to fix two real crashes (see §1.4) and is now `Center + SingleChildScrollView`-based with `SliverFillRemaining(hasScrollBody: true)` at call sites. Any restyling in Phase 11 must preserve this structure — **do not reintroduce `LayoutBuilder`** around it.
- Accessibility work is done: WCAG contrast tested in `test/core/constants/app_colors_test.dart`, 48px tap targets and semantics tested in `test/core/widgets/vw_button_test.dart`. Phase 8/9/11 changes must keep these tests passing (updating expected *values* is fine; dropping the *checks* is not).
- Finance screens already query in windows, not full history: `watchRecentTransactions` (50 rows/page, "Load older" button), `watchTransactionsInRange` for summaries, and dashboard aggregates use Isar's `sum()` rather than pulling all rows into memory. Any new Finance/Dashboard visual (§6.3) must consume these existing queries — **do not add a new unbounded "fetch everything" query** to feed a chart.
- Settings screen already has: theme mode (System/Light/Dark, persisted, read before first frame), notification permission status + re-request/open-settings actions, storage usage readout, app version, "Clear all data."
- 59 host tests pass, `dart analyze` is at 0 issues, and there's an existing on-device integration suite (`integration_test/app_flow_test.dart`) covering dashboard boot, task creation, expense logging, note writing, and (written but not yet run) a Settings flow. Target validation device is a **Redmi Note 8, Android 11** — treat this as the real performance budget, not a flagship phone.

### 1.4 Known gotchas — do not repeat these
| # | What happened | Takeaway for this plan |
|---|---|---|
| 1 | `VWEmptyState` crashed when nested in a parent with unbounded height. | Never wrap empty/skeleton states in `LayoutBuilder` inside a `Sliver` context without `hasScrollBody: true`. |
| 2 | `.thenByIdDesc()` compiles fine but throws `IsarError` **at query runtime**, not at analyze time — Isar doesn't support sorting by primary key natively. | If any new sorted query is added in this plan (e.g. for a sparkline), tie-break on an indexed field like `createdAt`, never on `id`, and add a repository test that actually *runs* the query — `dart analyze` passing is not sufficient proof. |
| 3 | Money assertions in device tests were locale-dependent (`100.00` vs `100,00`). | Any new widget/integration test touching currency text must use the app's own `formatMoney` helper for its expected value, never a hardcoded string. |
| 4 | MIUI shows a permission dialog ~100s into `integration_test` runs on the Redmi Note 8; iOS has never been validated on this machine (no CocoaPods). | Phase 12's on-device performance/accessibility validation is Android-only for now; note iOS as an explicit open item, don't claim it as validated. |

---

## 2. Design Vision: Notion-Caliber Aesthetic

VestWise should read as **calm software**: generous whitespace, a warm (not cold/pure-black) neutral palette, hairline borders instead of shadows, and motion that confirms an action happened rather than decorating the screen. Concretely:

- **Warm neutrals, not pure black/white.** Notion's signature trait is that "black" text is actually a warm dark gray (`~#37352F`-class, not `#000000`) and backgrounds carry a faint warm tint rather than stark white. This alone is most of what makes an interface feel "designed" rather than default Material.
- **Borders over shadows.** A 1px low-opacity hairline border (`outlineVariant`-class) replaces most card elevation. Reserve any shadow for true overlays (bottom sheets, dialogs) and keep it small (blur ≤ 8dp).
- **One accent color doing the work.** The existing seeded primary color stays the single accent for primary actions; everything else (tags, categories, priorities) uses *muted, desaturated* pastel pairs (soft background tint + a readable, slightly-darker foreground of the same hue) — never a competing saturated color next to the brand accent on the same screen.
- **Motion confirms, it doesn't perform.** Every animation added in this plan has a reason tied to feedback (a task completing, a sheet opening, a value changing) — never decorative looping/glowing/parallax.
- **Information density is a dial, not a default.** Prefer a clean list with breathing room over a dense dashboard full of simultaneous widgets; collapsible sections (Phase 10) exist specifically so density is user-controlled.

---

## 3. Architectural Guidelines for UI-Only Upgrades

This plan must not destabilize the working `data/`/`domain/` layers or the 59 passing tests. Hard rules:

1. **This plan lives in `core/theme/`, `core/constants/`, `core/widgets/`, and each feature's `presentation/`.** `data/` and `domain/` folders are off-limits **except** the two explicitly-flagged exceptions below.
2. **Two, and only two, additive schema exceptions are pre-approved in this plan:**
   - `TaskModel` gains an additive, defaulted `int sortIndex = 0` field if/when drag-to-reorder (§6.2) is implemented — needed because Isar has nothing else that encodes a user-chosen manual order.
   - `NoteModel` gains an additive, defaulted `int? iconCodePoint` field if/when the Notion-style note icon header (§6.1) is implemented.
   Both follow the exact Phase 2 pattern: edit the model → `dart run build_runner build --delete-conflicting-outputs` → confirm pre-existing records still load (Isar fills the declared default for the new field on old rows) → add/extend a repository test proving it. Any other schema change is **out of scope** for this plan — raise it as a `plan.md` Phase 2 follow-up instead.
3. **No repository method signatures change.** New data needs (e.g., a trimmed dataset for a sparkline) are served by *adding* a new method to the existing repository interface + impl, following the Phase 2 pattern, never by editing an existing method's signature — Finance's existing windowed queries (§1.3) in particular must stay untouched.
4. **No provider renames without a full-codebase pass.** If a Riverpod provider is already consumed across screens and tests, keep its name stable or update every consumer and every test in the same commit.
5. **Visual-regression test churn is expected and fine; behavioral-test churn is not.** A widget test asserting an exact old color/text style will need its expectation updated — that's this plan working as intended. A test failing because a tap no longer navigates, a form no longer submits, or a stream no longer emits is a real regression and blocks the task.
6. **Every new interactive element still meets the Phase 5 accessibility bar**: ≥48px tap targets, semantics/tooltips on icon-only controls, WCAG-AA contrast. Don't relitigate this bar — extend the existing tests that already check it.

---

## 4. Phase 8 — Design Token & Theme System Overhaul

**Goal:** `core/theme/` and `core/constants/` describe a Notion-grade palette, type scale, and shape language that every feature inherits automatically, with zero behavior change.

### P8-T1: Extend `AppColors` with the Notion-style neutral & semantic scale
- **File:** `lib/core/constants/app_colors.dart`
- **Do not rename or remove any existing field** another file already references — `grep -r "AppColors\." lib test` first to see what's actually consumed, then *add* new tokens alongside them:
  - `textPrimary` (warm dark gray, ~`#37352F` light / ~`#E6E6E4` dark — exact values must pass the existing contrast test, see validation), `textSecondary`, `textTertiary`.
  - `surfaceSoft` (the faint warm-tinted background used behind grouped sections, distinct from the pure page background).
  - `borderSubtle` (the hairline border color used instead of elevation — low-opacity neutral, ~6–10% alpha over the surface it sits on).
  - A `tagPalette` — a fixed list of ~6–8 muted background/foreground color pairs (soft red, soft orange, soft yellow, soft green, soft blue, soft purple, soft gray) used for category/priority/tag chips project-wide. Each pair must independently pass WCAG AA for its own foreground-on-background combination.
- **Signatures:** `surfaceSoft` and `borderSubtle` take a `BuildContext` (as written in this plan), so call sites read `AppColors.surfaceSoft(context)`. To keep them testable without a widget tree — `test/core/constants/app_colors_test.dart` works on plain `Color`s through its exported `contrastRatio` — each context-based method must delegate to a public `...For(Brightness)` resolver (the same convention the file already uses for `incomeFor`/`expenseFor`), and the test asserts against that resolver for both brightnesses.
- Update `app_theme.dart`'s `ColorScheme.fromSeed(...)` call only to adjust `surfaceTint`/`surfaceContainerHighest` mapping so Material's own surfaces pick up the warmer tint — keep the existing seed hue so the brand accent doesn't shift.
- **Validation:** Extend `test/core/constants/app_colors_test.dart` with contrast assertions for every new token pair (reuse its existing WCAG helper, which already loops over `AppTheme.light`/`AppTheme.dark` × `surface`/`surfaceContainerHighest`). Run `flutter test test/core/constants/app_colors_test.dart` — must pass for both light and dark.

### P8-T2: Shape & elevation tokens
- **File:** `app_radii.dart` already exists as `abstract final class AppRadii` **inside** `lib/core/constants/app_spacing.dart:14` — extend it there, do not create a second file. It currently defines `cardValue = 16`, `inputValue = 12`, `card` and `input`.
- Add `sheet` (e.g. 20px for bottom sheets) and `chip` (fully rounded/pill) alongside them, plus the matching `sheetValue`/`chipValue` doubles if the file's existing convention is kept (`cardValue`/`inputValue` exist).
- Keep `card` = 16 unless there is a deliberate reason to move to 12–14; it is already used by `cardTheme`, `VWCard`'s `InkWell` borderRadius and every `InputDecoration` in `app_theme.dart`.
- Add a single `AppElevation` concept: effectively "flat" (`elevation: 0`, border-defined) for cards/list rows, and one reserved elevated value *only* for true overlays (dialogs, bottom sheets, snackbars).
- **Validation:** `flutter analyze` clean; spot-check in a debug screen (or existing widget tests) that `VWCard`'s default has no shadow and shows a border instead, in both themes.

### P8-T3: Type scale refinement
- **File:** `lib/core/constants/app_text_styles.dart`
- The file currently defines only **five** roles (`displaySmall`, `titleLarge`, `titleMedium`, `bodyMedium`, `labelSmall`), but `app_theme.dart:29` installs it with `textTheme: AppTextStyles.textTheme.apply(...)`, which *replaces* the whole theme rather than merging it. Every role the code actually uses but does not define — `titleSmall` (8 call sites), `bodySmall` (6), `headlineMedium` (3), `labelMedium`, `labelLarge`, `headlineSmall`, `bodyLarge` — therefore resolves to `null` today and falls back to the default `TextStyle`. **Defining the full scale is part of this task**, not optional; it is the main reason this task exists.
- Tighten line-heights slightly and confirm the weight contrast between `titleMedium`/`titleLarge` (semibold, 600) and `bodyMedium` (regular, 400) is clearly legible at small sizes — Inter is already bundled, no font change needed.
- **Validation:** No analyzer issues; no existing test asserts a `TextStyle`, so expect no test breakage — confirm the whole suite anyway: `flutter test`.

### P8-T4: `VWCard` — the Notion-flat variant
- **File:** `lib/core/widgets/vw_card.dart`
- Add a `VWCardVariant` (`flat` default, `soft` for `surfaceSoft` background, `elevated` reserved for overlay contexts) rather than ad hoc boolean flags, so every feature screen picks one of three intentional looks instead of inventing new ones.
- **Keep `VWCard` on top of Material's `Card` + `InkWell`** (as it is today) and express the variants by overriding the theme's colour/border/shadow, rather than hand-rolling a `Container` + `GestureDetector`. Reason: `app_theme.dart`'s `cardTheme` is the single source of truth for card surfaces (currently `surfaceContainerHighest` + a 1px `outlineVariant` border + `elevation: 0`), `InkWell` keeps ripple/focus semantics and the existing `find.byType(Card)` assertion in `test/core/widgets/vw_widgets_test.dart:21` intact. `borderSubtle` (P8-T1) is additive — it does **not** replace `outlineVariant` in `cardTheme`.
- **Do not change the default `padding`** — it stays `AppSpacing.lg` (16). Tightening it to `md` would shift the layout of all 10 existing `VWCard` call sites and is a separate, deliberate visual decision; 0 of them currently pass a custom padding.
- Add a lightweight pressed-state: on tap-down, animate `scale` to ~0.98 using `AppMotion.stateChange` (150ms), revert on release — this is the single most "Notion/native-app" feeling micro-interaction available for near-zero cost. Only apply it when `onTap` is non-null, and skip it under reduced motion.
  ```dart
  // lib/core/widgets/vw_card.dart (pattern — Card/InkWell-based, not a raw Container)
  enum VWCardVariant { flat, soft, elevated }

  class VWCard extends StatefulWidget {
    const VWCard({
      super.key,
      required this.child,
      this.variant = VWCardVariant.flat,
      this.onTap,
      this.padding = const EdgeInsets.all(AppSpacing.lg), // unchanged default
    });

    final Widget child;
    final VWCardVariant variant;
    final VoidCallback? onTap;
    final EdgeInsetsGeometry padding;

    @override
    State<VWCard> createState() => _VWCardState();
  }

  class _VWCardState extends State<VWCard> {
    bool _pressed = false;

    @override
    Widget build(BuildContext context) {
      final theme = Theme.of(context);
      final colors = theme.colorScheme;
      final VoidCallback? tap = widget.onTap;

      // flat  -> theme's Card defaults (surfaceContainerHighest + hairline border)
      // soft  -> AppColors.surfaceSoft(context), no border
      // elevated -> surface + the single allowed small shadow (overlays only)
      final Color background = switch (widget.variant) {
        VWCardVariant.flat => colors.surfaceContainerHighest,
        VWCardVariant.soft => AppColors.surfaceSoft(context),
        VWCardVariant.elevated => colors.surface,
      };

      final Widget content = Padding(padding: widget.padding, child: widget.child);

      final Card card = Card(
        clipBehavior: Clip.antiAlias,
        color: background,
        elevation: widget.variant == VWCardVariant.elevated ? 2 : 0,
        child: tap == null
            ? content
            : InkWell(onTap: tap, borderRadius: AppRadii.card, child: content),
      );

      if (tap == null || prefersReducedMotion(context)) {
        return card;
      }

      return GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.98 : 1,
          duration: AppMotion.stateChange,
          curve: Curves.easeOut,
          child: card,
        ),
      );
    }
  }
  ```
- **Validation:** `flutter test test/core/widgets/` — the existing `Card` assertion must still pass; extend it with a variant test (soft background resolves, elevated is the only one with elevation > 0) and a press-state test. Manually confirm on-device (or emulator) that tapping a `VWCard` with an `onTap` gives a visible, snappy press response with no jank.

**Definition of done for Phase 8:** Every screen still renders (no feature code changed yet), `flutter analyze` is clean, `flutter test` passes, and the app now visually reads as warm-neutral/flat-bordered instead of default Material in both light and dark mode.

---

## 5. Phase 9 — Advanced Motion & Animation System

**Goal:** Extend the existing `AppMotion` tokens (don't replace them) with a small, disciplined set of reusable transition/interaction primitives that every feature in Phase 10 draws from, so motion stays consistent instead of ad hoc per screen.

### P9-T1: Extend `AppMotion` with curves and a signature duration
- **File:** `lib/core/constants/app_motion.dart`
- Keep all existing token names/values exactly as-is — other code depends on them. The real names are `maxDuration` (250ms), `pageTransition` (200ms), `listItemEnter` (180ms), `stateChange` (150ms), `enterCurve`, `standardCurve`. (There is no `fast`/`medium`.) *Add*:
  - `AppMotion.curveEmphasized` = a custom spring-like curve for "satisfying" moments (task-complete checkmark, swipe-reveal snap) — implement via a small `Curves`-compatible `Cubic`/`ElasticOutCurve` or a hand-rolled `SpringSimulation`-backed curve; do not add an animation package just for this. (`standardCurve` = `Curves.easeInOut` already exists and is the general-transition curve; do not duplicate it under a second name.)
  - `AppMotion.signature` = **320ms**, reserved for the 2–3 genuinely emphasized interactions in §6; everything else continues using the existing tokens.
  - `AppMotion.staggerStep` = 24ms, the per-index delay used by `VWStaggeredList` (§5 P9-T2), capped at 5 items.
- **Documented exception to the Phase 5 budget:** `maxDuration` stays 250ms as the default ceiling for everything except `signature`. This is deliberate and must be stated in the code comment and in the test, so a future reader does not "fix" it.
- Confirm `AppMotion`'s existing reduced-motion check (already implemented per `ringkasan.md` — it is the top-level `prefersReducedMotion(context)` helper, not a member of `AppMotion`) wraps these new tokens too — i.e., any widget using `curveEmphasized`/`signature` must still collapse to an instant/near-instant transition when reduced motion is on.
- **Validation:** Extend the existing motion test file with assertions that (a) every token **except `signature`** is ≤250ms, (b) `signature` is ≤400ms, (c) `listItemEnter + 5 × staggerStep ≤ signature`, (d) reduced-motion mode still short-circuits new tokens the same way it does existing ones. `flutter test`.

### P9-T2: Reusable transition widgets in `core/widgets/`
- Add two small, generic widgets other features compose rather than re-implement:
  - `VWFadeThrough` — a thin wrapper around `AnimatedSwitcher` using `standardCurve`/`stateChange`, for swapping content in place (e.g., list ↔ empty state, tab content).
  - `VWStaggeredList` — a thin public wrapper around the **existing** `VWAnimatedListItem` primitive (`visibleCount = 8`, `animates(index)`), applying a small index-based delay of `AppMotion.staggerStep` (24ms) capped at 5 items. Do not reimplement the row animation: `VWAnimatedListItem` already fades+slides a row on mount and is already used by every feature list. The stagger must stay inside the `AppMotion.signature` budget (180ms + 5 × 24ms = 300ms ≤ 320ms) — that is why the cap is 5 and why the delay is a token, not a magic number.
  - `VWAnimatedListItem`'s existing comment explains why there was deliberately **no** stagger (a stagger pushes the last row past the 250ms budget). Update that comment to point at the documented `signature` exception from P9-T1 instead of deleting the reasoning.
- **Validation:** Widget test confirming `VWStaggeredList` renders all items (no items silently dropped by the animation wrapper) and that reduced-motion mode disables the stagger (all items appear immediately).

### P9-T3: Page-transition polish in `go_router`
- **File:** `lib/core/router/app_router.dart` — **this is already implemented.** Every route already goes through the shared `_transitionPage` helper (`app_router.dart:153-183`): `CustomTransitionPage` with a 200ms fade + 2% rise using `AppMotion.standardCurve`, skipped entirely under `prefersReducedMotion`. Do not rewrite it.
- What is actually left to do: **verify** it. The five tabs live in `StatefulShellRoute.indexedStack` (`app_shell.dart`), and switching branches there does not run a page transition at all — so confirm the tab switch feels intentional rather than abrupt, and decide whether a subtle cross-fade at the `AppShell` level is wanted. Leaving native back gestures untouched remains a requirement.
- **Validation:** Manual pass tapping through all five tabs and into at least one detail screen per feature — confirm no visual "pop" or flash, and that the Android system back gesture still works smoothly.

### P9-T4: Signature micro-interaction — task-complete morph
- **File:** `lib/features/tasks/presentation/widgets/` (wherever the task row checkbox currently lives)
- On checking a task complete: animate the checkbox fill + a brief strikethrough sweep on the title text using `AppMotion.signature` / `curveEmphasized`, then (after the animation completes) let the existing active/completed section logic (already built, per `ringkasan.md` P3-TASK-1) move the row — don't fight the existing state transition, just precede it with this animation.
- Pair with a light haptic tap (`HapticFeedback.lightImpact()`) on the toggle — guard it so it's skipped if the OS reports no haptics engine rather than throwing.
- **Validation:** On-device (Redmi Note 8 or current test device): toggling a task gives a visible morph + haptic tick, and the task still correctly reclassifies into active/completed afterward (this must not regress the existing Phase 3 behavior) — confirm against the existing task widget/integration tests, updating only the parts that assert on the old instant-toggle visual.

**Definition of done for Phase 9:** A small, named set of motion primitives exists and is reused (not reinvented) by every feature touched in Phase 10; reduced-motion continues to be respected everywhere; no animation exceeds 400ms.

---

## 6. Phase 10 — Notion-Style Module Refinement

Each sub-track below only touches that feature's `presentation/` folder (plus the two pre-approved schema exceptions from §3.2 where noted) and consumes the Phase 8/9 tokens — it does not touch `data/`/`domain/` otherwise.

### 6.1 Notes & Documents (`P10-NOTES-*`)

**P10-NOTES-1: Clean document header**
- `note_editor_screen.dart`: replace any default `AppBar` title with a Notion-style in-page header — large title field (auto-growing, no visible border until focused), a muted "last edited" timestamp beneath it, using `AppTextStyles`/`AppColors` from Phase 8.
- **Validation:** Create/edit a note, confirm title editing feels like editing a document heading, not filling a form field; autosave behavior (already built, per `ringkasan.md` P3-NOTES-2) is unchanged.

**P10-NOTES-2: Note icon selector** *(uses the pre-approved `NoteModel.iconCodePoint` schema exception, §3.2)*
- Add a small icon-picker affordance above the title (tap a muted circular icon placeholder → bottom sheet grid of a curated icon set, not a full emoji keyboard — keep it minimal and offline, no emoji-asset downloads).
- Persist via the new additive field; default existing notes to a neutral document icon.
- **Validation:** Repository test confirming an existing pre-migration note (no icon set) still loads with the default icon and doesn't throw; new notes can set/change their icon and it persists across restart.

**P10-NOTES-3: Collapsible sections in the notes list**
- `notes_list_screen.dart`: the Notes tab groups into collapsible sections — **Pinned / Others** — using `ExpansionTile`-style disclosure, client-side expand/collapse state only (a simple local/Riverpod UI-state provider — **not persisted to Isar**, this is ephemeral view state). Note: Documents is a *separate tab* (`TabBar` with Notes/Documents, `notes_list_screen.dart:50-64`), not a section of the Notes list, so do not try to fold it in here. The pinned/others split is derivable client-side from `NoteModel.isPinned`; the repository already sorts pinned-first (`sortByIsPinnedDesc().thenByUpdatedAtDesc()`) so no new query is needed.
- **Validation:** Collapsing a section hides its items without affecting the underlying data/providers; state resets to a sensible default on next app launch (don't over-engineer persistence here).

**P10-NOTES-4: Minimalist Quill toolbar**
- Restyle the existing `flutter_quill` simple toolbar: flat background (no container/border), tighter icon spacing, icon-only (no labels), using `AppColors`/`AppSpacing` tokens.
- **Validation:** All existing formatting actions (bold/italic/underline/lists/headings) still function identically — this is a restyle, not a toolbar rebuild; confirm via the existing notes widget tests plus a manual formatting pass.

### 6.2 Tasks & To-Do (`P10-TASKS-*`)

**P10-TASKS-1: Collapsible grouped sections**
- `tasks_list_screen.dart`: group into Today / Upcoming / No Due Date / Completed, each collapsible (same local-state pattern as P10-NOTES-3). Preserve the existing active/completed split logic underneath — this only changes presentation grouping, not the query.
- **Validation:** All existing tasks still appear exactly once across the groups (no task silently hidden); existing task-list widget test extended to assert group headers render and are independently collapsible.

**P10-TASKS-2: Inline quick-add row**
- A persistent, minimal single-line input pinned above the list (or as the first list item) — typing a title and hitting submit/Enter creates a task with default priority (Medium) and no due date via the existing `TasksRepository.createTask`, no modal required. The full `task_detail_screen.dart` form remains the way to set priority/due-date/sub-tasks afterward.
- **Validation:** Submitting via the quick-add row results in a new task visible in the correct group immediately (stream-driven, no manual refresh); empty-title submits are no-ops (reuse existing form validation logic rather than duplicating it).

**P10-TASKS-3: Swipe actions**
- Add swipe-to-complete and swipe-to-delete on task rows with Flutter's **built-in `Dismissible`** — no new dependency. (`flutter_slidable` was evaluated and rejected: `Dismissible` covers both gestures via `direction: DismissDirection.horizontal` + a `confirmDismiss` callback that branches on the swipe direction, and this project's habit is to prefer what is already installed.) Delete must reuse the existing confirmation pattern already used elsewhere in the app (don't silently hard-delete on a swipe).
- The existing completion path is `_toggleComplete` in `tasks_list_screen.dart:140-152` (cancels the reminder, then `toggleComplete(task.id)`), and the existing delete path already cancels the notification — reuse both code paths, do not reimplement cancellation logic.
- **Validation:** Swipe-complete toggles the task (and triggers the P9-T4 morph); swipe-delete prompts confirmation and, on confirm, removes the task and cancels its notification exactly as the existing delete path already does.

**P10-TASKS-4 (optional): Drag-to-reorder** *(uses the pre-approved `TaskModel.sortIndex` schema exception, §3.2)*
- Only within a single group (e.g. reordering "Today" manually), via `ReorderableListView.builder` (built into Flutter, no new package). On reorder, persist new `sortIndex` values for the affected rows in one `writeTxn`.
- **Validation:** Reorder, restart the app, confirm the manual order persisted; repository test covering `sortIndex` writes; explicitly mark this task optional/deferrable if time-boxed — it is the least essential item in Phase 10.

### 6.3 Finance & Dashboard (`P10-FIN-*`)

**P10-FIN-1: `VWCategoryChip`**
- New shared widget in `core/widgets/` rendering a category as a soft pill (background/foreground pair from Phase 8's `tagPalette`, category icon via the existing `CategoryModel.iconCodePoint`). Used in the transaction list, the add-transaction form's category picker, and the summary breakdown — one implementation, three call sites.
- **Validation:** Widget test rendering a chip for each seeded default category (per `plan.md` P3-FIN-1) confirms contrast-safe pairing and correct icon.

**P10-FIN-2: `VWSparkline` on the Dashboard balance card**
- New lightweight `CustomPainter`-based widget (no new chart package) plotting the last 7 days' net daily change, fed by a *new, additive* repository method (e.g. `watchLast7DaysNet()`) built the same way existing windowed queries are — bounded, indexed, no full-table scan. This is additive to the repository interface per §3.3, not a modification of `watchRecentTransactions`/`watchTransactionsInRange`.
- **Validation:** Repository test for the new method's output against a seeded 7-day dataset; widget test confirming the sparkline renders without throwing on an empty dataset (new install, no transactions yet) — must degrade to a flat/empty-safe line, not crash.

**P10-FIN-3: Category breakdown ring**
- On `finance_summary_screen.dart`, add a compact donut/ring chart (via the already-installed `fl_chart` `PieChart` — no new dependency) next to the existing category breakdown list, both fed by the same existing range-query data already powering that screen.
- **Validation:** Ring segment proportions sum-check against the same test dataset already used for the existing bar chart validation (`plan.md` P3-FIN-4) — reuse that fixture rather than inventing a new one.

**P10-FIN-4: Dashboard card restyle**
- Apply `VWCard(variant: .soft)` + the new chip/sparkline widgets to `BalanceSummaryCard`; confirm the card still correctly degrades to an empty state (`VWEmptyState`) on a zero-transaction fresh install per the existing Phase 5 empty-state audit.

### 6.4 Calendar & Navigation (`P10-CAL-*`, `P10-NAV-*`)

**P10-CAL-1: Calendar header refinement**
- Restyle `table_calendar`'s header (month/year label + prev/next controls) to a flatter, minimal look via its existing `headerStyle`/`calendarStyle` customization API — no fork/replacement of the package.
- **Validation:** Month navigation still works identically; today/selected-day markers remain visually distinct in both themes.

**P10-CAL-2: Minimalist event cards**
- Restyle the day's event list rows as `VWCard(variant: .flat)` with a small color-coded left accent bar or `VWCategoryChip`-style tag using the existing `CalendarEventModel.colorValue` field — no schema change needed, the data already exists.
- **Validation:** Events with different `colorValue`s render visually distinct, legible tags in both themes.

**P10-NAV-1: Bottom navigation restyle**
- Reduce the bottom `NavigationBar`'s default Material elevation/indicator styling to a flatter, pill-indicator look consistent with Phase 8 tokens, keeping all five destinations and their existing routes untouched.
- **Validation:** All five tabs still navigate correctly (reuse `plan.md` P1-T5's validation); confirm the selected-tab indicator is clearly legible in both themes.

**Definition of done for Phase 10:** All four features visually match the Notion-inspired vision from §2, every pre-existing behavior (CRUD, notifications, windowed queries, empty states) is provably unchanged via the existing + extended test suite, and the only schema deltas are the two pre-approved additive fields (used only if their optional tasks were taken).

---

## 7. Phase 11 — Empty, Loading, and Interactive States Polish

**Goal:** Replace generic spinners with content-shaped skeleton loaders, and make `VWEmptyState` feel intentional rather than placeholder-ish — without regressing the two real crashes already fixed in this widget (§1.4).

### P11-T1: `VWSkeleton` primitive
- New `core/widgets/vw_skeleton.dart`: a simple shimmering rectangle/pill (animated gradient sweep, `AppMotion`-governed duration, respects reduced motion by freezing to a static tint instead of animating). Either hand-roll via `ShaderMask` + `AnimationController`, or add the small, well-maintained `shimmer` package if hand-rolling proves slower than expected — verify its current health/compatibility first, consistent with this project's existing package-vetting habit.
- Compose feature-shaped skeletons from it: `TaskRowSkeleton`, `TransactionRowSkeleton`, `NoteCardSkeleton`, `EventCardSkeleton` — each matching its real counterpart's layout dimensions so there's no layout shift when real data arrives.
- **Validation:** Widget test confirming each skeleton renders without a bounded-height crash inside the same scroll contexts (`Sliver`/list) that previously caused the `VWEmptyState` bug (§1.4 #1) — i.e., explicitly test the failure mode that already bit this project once.

### P11-T2: Wire skeletons into loading states
- Replace `VWLoadingIndicator` with the matching skeleton wherever a screen is loading a *list* (task list, transaction list, notes list, calendar day list); **keep `VWLoadingIndicator`** for short, inline loading (e.g. a submit button's in-progress state) — skeletons are for "waiting for a shape," spinners are for "waiting for an action."
- **Anti-flicker policy (decided):** local Isar usually resolves in well under 100ms, so an immediately-rendered skeleton would flash on almost every open. Gate each skeleton behind a ~100ms delay — if data arrives before that, no skeleton is ever shown — and swap it out through `VWFadeThrough` (§5 P9-T2) so the handover never pops. Implement the delay once as a small shared widget (e.g. `VWDelayed`), not per screen.
- **Validation:** Cold-start each of the four feature list screens and confirm either no skeleton at all (instant Isar) or a smooth skeleton→content fade — never a one-frame flash. Widget test the `VWDelayed` gate itself (shows nothing before the delay elapses, shows the child after) so the flicker policy is enforced by a test rather than by eye.

### P11-T3: `VWEmptyState` restyle
- Keep the exact `Center + SingleChildScrollView` / `SliverFillRemaining(hasScrollBody: true)` structure (§1.4 #1, #3 — do not touch this). Restyle only the *content*: a muted icon inside a soft circular `AppColors.surfaceSoft` container (no external illustration assets, no AI-generated imagery — stay code-drawn and on-brand), a short primary line, an optional secondary line, and the existing CTA button pattern.
- **Validation:** Re-run the exact two regression scenarios from §1.4 (#1 generic overflow, #3 Finance-empty `LayoutBuilder`/`SliverFillRemaining` crash) manually or via their existing tests — both must still pass after the restyle.

### P11-T4: Button/press state consistency
- Audit `VWButton` against the new `VWCard` press-state pattern (P8-T4) so buttons and cards feel like one coherent interaction language (consistent scale/opacity feedback and duration token) rather than two different press behaviors.
- **Validation:** `flutter test test/core/widgets/vw_button_test.dart` (existing accessibility assertions — tap target, semantics — must still pass unchanged) plus a manual side-by-side tap of a button and a card confirming matching feel.

**Definition of done for Phase 11:** No bare `CircularProgressIndicator` remains in any list-loading context; `VWEmptyState`'s two previously-fixed crash modes remain fixed; loading/empty/interactive states feel like one designed system instead of ad hoc per-screen choices.

---

## 8. Phase 12 — Cross-Cutting QA: Performance, Accessibility & Regression

**Goal:** Prove the Phase 8–11 upgrade didn't cost correctness, accessibility, or speed — on the project's actual target hardware.

### P12-T1: Full automated suite
- `dart analyze lib test integration_test` → must return 0 issues.
- `flutter test` → must return to all-green; expect some test *expectations* to have changed per §3.5, confirm nothing failed for a *behavioral* reason.
- **Validation:** paste/attach the final clean run output as the commit's evidence, same bar as the rest of this project's history.

### P12-T2: On-device performance pass (Redmi Note 8 / Android 11)
- `flutter run --profile -d <device-id>`, exercise: scrolling a 200+-row seeded transaction list, toggling several tasks (P9-T4 morph), navigating all five tabs repeatedly, opening/closing the notes icon-picker sheet.
- Use DevTools' performance overlay/timeline to confirm no sustained dropped-frame runs (>16ms/frame) during these interactions — this was already an open, unmeasured item from Phase 5 (`ringkasan.md` §8) and should be closed out together with this phase rather than left open twice.
- **Validation:** Record frame-time results in `docs/qa-checklist.md` alongside the existing Phase 5 rows (reuse that file rather than starting a new one).

### P12-T3: Reduced-motion & accessibility re-pass
- Enable OS-level reduced-motion, confirm every new Phase 9/10/11 animation collapses to an instant/near-instant transition (not just the pre-existing ones).
- Re-run a TalkBack pass over the newly-added interactive elements specifically (quick-add row, swipe actions, icon picker, collapsible section headers, chips if tappable) — the general TalkBack pass was already an open item from Phase 5 (`ringkasan.md` §8); this closes it for the full, now-larger interactive surface.
- **Validation:** Update `docs/qa-checklist.md` with pass/fail rows for each new control, same format as existing entries.

### P12-T4: Update/extend the on-device integration suite
- Extend `integration_test/app_flow_test.dart` (or add a sibling file) to cover at least: completing a task via swipe, adding a task via the quick-add row, toggling a collapsible section, and the already-written-but-unrun Settings scenario (`ringkasan.md` §8) — run all of them together on-device rather than leaving the Settings one perpetually "written but not executed."
- **Validation:** `flutter test integration_test -d <device-id>` all green on the Redmi Note 8. iOS remains explicitly out of scope until CocoaPods is available on a build machine — note this plainly rather than silently skipping it.

**Definition of done for Phase 12:** Automated suite green, on-device performance measured (not assumed) on the real target device, accessibility re-verified for the expanded interactive surface, and the previously-open Phase 5/6 validation items (device perf, TalkBack, Settings E2E) are closed out as part of this same pass rather than carried forward a second time.

---

## 9. Sequencing: Where This Fits Relative to Phase 6/7

Per `ringkasan.md`, Phase 6 (Testing & QA) is partially done and Phase 7 (Release) hasn't started. Recommended order:

1. **Finish the cheap, UI-independent part of Phase 6 first:** `plan.md` P6-T1's remaining edge-case audit (e.g. delete-by-nonexistent-id) doesn't depend on visuals — knock it out now so it's not blocking later.
2. **Run this document, Phases 8–12, in full.** Phase 12 already subsumes and closes the open Phase 5 device-validation items and the open Settings E2E scenario, so you are not validating the same things twice.
3. **Return to `plan.md` Phase 6** for what's left: P6-T2 (widget tests for screen flows) should be (re)written *against the new UI*, not the pre-upgrade one — writing them before Phase 8–11 would mean rewriting them anyway. P6-T4 (regression checklist) should likewise be run once, after the upgrade, not before.
4. **Then `plan.md` Phase 7** (icons/splash, signing, release build, store listing) — so the screenshots and store listing reflect the final Notion-style UI, not the pre-upgrade one.

---

## 10. Anti-"AI Slop" Design Review Checklist

Run this against every screen touched in Phase 10, before marking that sub-track done:

- [ ] No gradient on any surface unless it is the one allowed case (skeleton shimmer sweep, P11-T1) — no decorative background gradients, no gradient buttons.
- [ ] No shadow with blur > 8dp anywhere outside a true overlay (dialog/bottom sheet).
- [ ] No more than one *saturated* accent color visible on screen at once; everything else is a muted `tagPalette` pair or a neutral.
- [ ] Every spacing value on the screen is one of the Phase 8 tokens — no ad hoc `SizedBox(height: 13)`-style magic numbers.
- [ ] Every animation on the screen is traceable to a Phase 9 token/widget — no inline `Duration(milliseconds: ...)` invented per-widget.
- [ ] No icon-only control lacks a tooltip/semantic label (already enforced by Phase 5, re-check it wasn't dropped during restyle).
- [ ] The screen still reads correctly with the system font size turned up one notch (basic text-scaling sanity check — nothing truncates/overlaps).
- [ ] Nothing animates on a loop or without a user-triggered or data-triggered reason.

---

## 11. Appendix: New Dependencies Introduced by This Plan

Everything else in this plan reuses packages already installed (`fl_chart`, `flutter_quill`, `table_calendar`, etc.). **No new package is required by this plan.**

| Package | Used by | Notes |
|---|---|---|
| `flutter_slidable` | P10-TASKS-3 (swipe actions) | **Evaluated and rejected** in favour of Flutter's built-in `Dismissible` (no version/compatibility risk against Dart `^3.12.1`, and it covers both swipe directions via `confirmDismiss`). Kept here only to record the decision. |
| `shimmer` | P11-T1 | **Prefer the hand-rolled `ShaderMask` approach**; only consider this if hand-rolling clearly costs more than it saves. Not expected to be needed. |

No other new dependency should be needed — `ReorderableListView` (P10-TASKS-4) and the sparkline/ring visuals (P10-FIN-2/3) are deliberately built on what's already installed to keep the app's footprint exactly as "lightweight" as `plan.md`'s original brief demanded.

---

## End of Plan

Work Phases 8 → 12 in order (Phase 10's four sub-tracks may interleave with each other, not with 8/9/11/12). Do not begin Phase 7 of `plan.md` until Phase 12 of this document is signed off.
