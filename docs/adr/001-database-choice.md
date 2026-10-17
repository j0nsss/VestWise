# ADR 001 — Local database engine

- **Status:** Accepted
- **Date:** 2026-10-17
- **Deciders:** Engineering (VestWise)

## Context

VestWise is offline-first: it must persist structured data (transactions,
categories, notes, imported-document metadata, tasks, calendar events) on-device
with no server. `plan.md` §1.6 mandates verifying the health of the Isar
ecosystem before Phase 2, because the original `isar` / `isar_flutter_libs` /
`isar_generator` packages have had maintenance churn.

## Decision

Use **`isar_community`** (and its `isar_community_flutter_libs` /
`isar_community_generator` companions), the community-maintained fork of Isar.

## Evidence (checked at build time, 2026-10-17)

- `isar_community` `3.4.1` — published 3 days prior, verified publisher
  `isar-community.dev`, 161 likes, 140 pub points, ~117k downloads.
- `isar_community_flutter_libs` `3.4.1` — same publisher, 135 pub points.
- Resolved cleanly against Flutter 3.44.1 / Dart 3.12.1 in `pubspec.yaml`.

The fork is alive and healthy, so the plan's fallback (`drift`) is **not**
needed. The repository interfaces defined in `domain/` keep the data source
swappable: if this changes later, only the `data/` implementations are
affected.

## Consequences

- All six collections in `plan.md` §10 are Isar schemas.
- `part '*.g.dart'` files are generated via
  `dart run build_runner build --delete-conflicting-outputs`.
- If the fork ever goes stale, revisit this ADR and migrate to `drift` behind
  the same `domain/` interfaces.
