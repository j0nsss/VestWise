# Ringkasan Proyek VestWise

Dokumen ini merangkum **apa yang sudah dikerjakan**, **error yang ditemukan dan
diperbaiki**, serta **posisi proyek saat ini**. Sumber acuan: `plan.md`
(rencana 7 fase) untuk Phases 0–7, dan `plan2.md` (upgrade design system &
motion) untuk Phases 8–12. Dokumen ini tidak menggantikan keduanya, hanya
melaporkan progres.

Terakhir diperbarui: setelah P12-T1, P12-T4, dan ikon adaptive (`f64c355`,
semuanya sudah di-push ke `origin/main`).

---

## 1. Deskripsi project

**VestWise** adalah aplikasi *productivity suite* **offline-first** yang
menggabungkan empat kebutuhan harian dalam satu aplikasi Android/iOS:

1. **Tasks** — daftar tugas aktif/selesai, sub-task, prioritas, tenggat, reminder.
2. **Finance** — pencatatan pemasukan/pengeluaran, saldo, kategori, riwayat
   per hari, ringkasan mingguan/bulanan (grafik + breakdown kategori).
3. **Notes** — catatan rich-text (Quill) dengan autosave, pencarian, plus impor
   dan pembaca dokumen (PDF) yang tersimpan lokal.
4. **Calendar** — tampilan bulan dengan penanda per hari, daftar event harian,
   form event dengan reminder.

Prinsip desain yang dipegang sejak awal:

- **Offline-first / tanpa cloud.** Semua data disimpan lokal di perangkat
  (Isar) — tidak ada panggilan jaringan untuk fungsi inti, tidak ada akun.
- **Feature isolation.** Tiap fitur berdiri sendiri di `lib/features/<fitur>/`
  dan hanya berbagi lewat `lib/core/`. Menambah/menghapus fitur tidak
  merusak fitur lain.
- **Cepat dan minimal.** Animasi seperlunya (≤ 250 ms), UI konsisten lewat
  widget kit bersama (`VW*`), bukan efek visual.
- **Setiap layar punya desain untuk empty / loading / error**, bukan hanya
  jalur bahagia.

Target perangkat: Android mid-range (uji nyata di Redmi Note 8, Android 11).
Nama paket: `com.vestwise.app`. Versi saat ini: `1.0.0+1`.

---

## 2. Status keseluruhan

| Fase | Judul | Status |
|------|-------|--------|
| Phase 0 | Project Bootstrap | **Selesai** |
| Phase 1 | Core Infrastructure | **Selesai** |
| Phase 2 | Data Layer (Isar & Repositories) | **Selesai** |
| Phase 3 | Feature Modules MVP | **Selesai** |
| Phase 4 | Notifications & File Management Hardening | **Selesai** |
| Phase 5 | UI/UX Refinement & Polish | **Selesai (kode); sebagian validasi perangkat masih terbuka** |
| Phase 6 | Testing & QA | **Sebagian** (P6-T3 selesai lebih awal; T1/T2 baru sebagian; T4 belum) |
| Phase 7 | Release Build & Store Submission | **Dimulai sebagian** (adaptive app icon selesai; splash/signing/release/store belum) |
| plan2 P8 | Design tokens & theme | **Selesai** |
| plan2 P9 | Motion primitives | **Selesai** |
| plan2 P10 | Restyle per fitur (Finance/Notes/Tasks/Calendar/Nav) | **Selesai** (TASKS-4 drag-to-reorder sengaja ditunda) |
| plan2 P11 | Empty/loading/interactive states | **Selesai** |
| plan2 P12 | Cross-cutting QA | **Sebagian** (T1 + T4 selesai; T2/T3 on-device masih terbuka) |
| plan2 P13 | Redesign visual (Obsidian Lumina / Stitch) | **Selesai** (T1–T9), lalu digantikan P14; validasi visual di perangkat masih terbuka |
| plan2 P14 | Redesign visual (Omotive Style / Stitch) | **Selesai** (T1–T9); validasi visual di perangkat masih terbuka |

Ringkas angka:

- **70 commit**; 68 sudah di-push ke `origin/main` dan dua commit Phase 14
  (`f05e8ce` + commit dokumentasi ini) masih lokal.
- **102 file Dart** non-generated, sekitar **12.500 baris** di `lib/`.
- **45 file test**, **302 test host lulus** (`flutter test`), `dart analyze lib
  test integration_test` bersih (0 issue).
- **8 skenario end-to-end** di perangkat asli, **semuanya lulus** — termasuk
  skenario Settings yang sejak Phase 5 tertulis tapi baru kini dijalankan.
- Phases 0–5 = 38 task; plan2 Phases 8–12 = 16 task (1 ditunda dengan alasan).

Kondisi saat ini: **aplikasi berjalan penuh secara fungsional** untuk keempat
fitur + Settings, dengan tampilan mengikuti bahasa desain Stitch terbaru
"Omotive Style" (dark-first, kartu taktil berwarna dengan lift lembut, pil dan
kapsul, dock ikon-saja beraksen amber). Yang tersisa: validasi visual &
performansi/aksesibilitas on-device (P14 + P12-T2/T3), sisa Phase 6, dan sisa
Phase 7 (rilis).

---

## 3. Stack & versi

| Bagian | Pilihan |
|--------|---------|
| Framework | Flutter 3.44.1 / Dart 3.12.1 (SDK `^3.12.1`) |
| Database lokal | `isar_community` 3.4.1 (+ `isar_community_flutter_libs`) |
| State management | `flutter_riverpod` 3.4.3 + `riverpod_annotation` 4.0.7 (codegen) |
| Navigasi | `go_router` 17.5.0 (shell route + bottom navigation) |
| Notifikasi | `flutter_local_notifications` 22.3.2 + `timezone` + `flutter_timezone` |
| Editor catatan | `flutter_quill` 11.6.0 |
| Dokumen | `file_picker` 13.1.0, `flutter_pdfview` 1.4.5, `open_filex` 5.0.0 |
| Grafik | `fl_chart` 1.2.0 |
| Kalender | `table_calendar` 3.2.1 |
| Preferensi | `shared_preferences` 2.5.6 |
| Lain-lain | `intl` 0.20.2, `uuid`, `path_provider`, `app_settings` 9.0.1, `package_info_plus` 10.2.2 |
| Tooling | `build_runner` 2.15.1, `riverpod_generator`, `isar_community_generator`, `flutter_lints` 6.0.0, `mocktail` |

Keputusan pemilihan database dicatat di `docs/adr/001-database-choice.md`.
plan2 §11 mencatat evaluasi dependensi baru: `flutter_slidable` **ditolak**
(diganti `Dismissible` bawaan), `shimmer` **tidak dipakai** (shimmer
hand-rolled dengan `ShaderMask`). Tidak ada paket baru yang ditambahkan
sepanjang Phases 8–12.

---

## 4. Struktur folder

```
lib/
├── core/                    # dipakai bersama semua fitur
│   ├── constants/           # AppColors, AppSpacing, AppStrings, AppMotion
│   ├── database/            # isar_service, isar_provider, app_data_reset
│   ├── errors/              # Result/Failure + result_guard
│   ├── notifications/       # notification_service + provider + banner
│   ├── router/              # app_router, app_shell, route_paths
│   ├── storage/             # file_storage_service (imported_documents/)
│   ├── theme/               # app_theme, theme_store, theme_provider
│   ├── utils/               # byte_format, dll.
│   ├── widgets/             # widget kit "VW*" (VWButton, VWCard, VWEmptyState,
│   │                        #   VWFadeThrough, VWStaggeredList, VWSkeleton,
│   │                        #   VWDelayed, VWCategoryChip, VWSparkline, …)
│   ├── app_info.dart
│   └── main.dart (lib/main.dart)
└── features/
    ├── dashboard/           # kartu ringkasan 4 fitur
    ├── tasks/
    ├── finance/
    ├── notes/
    ├── calendar/
    └── settings/
        └── presentation/
```

Tiap fitur mengikuti pola `data/` (model Isar + implementasi repository),
`domain/` (interface repository), `presentation/` (screens, widgets, providers).

---

## 5. Task yang sudah dikerjakan

### Phase 0 — Project Bootstrap
| Task | Commit | Isi |
|------|--------|-----|
| P0 | `13ec2f0` | Bootstrap project Flutter, struktur folder, lint rules, dependensi dasar, shell tema. |

### Phase 1 — Core Infrastructure
| Task | Commit | Isi |
|------|--------|-----|
| P1-T1 | `4c05c17` | Tipe `Result`/`Failure` (termasuk `resultGuard` agar repository tidak melempar exception). |
| P1-T2 | `7fd5a42` | `isar_service`: enam koleksi (tasks, finance, notes, calendar, dst.) + `isarProvider`. |
| P1-T3 | `8bd367b` | `file_storage_service`: penyimpanan lokal `imported_documents/`. |
| P1-T4 | `1945e0d` | `notification_service` lokal (init, izin, jadwal/batal reminder). |
| P1-T5 | `16e1dec` | Navigasi `go_router` + shell bottom navigation. |
| P1-T6 | `2d8aaae` | Widget kit bersama (`VWButton`, `VWCard`, `VWEmptyState`, `VWAppBar`, …). |

### Phase 2 — Data Layer
| Task | Commit | Isi |
|------|--------|-----|
| P2-T1 | `7fd5a42` | Semua model Isar (tasks, transaction, category, note, document, calendar event) didefinisikan bersama bootstrap Isar. |
| P2-T2 | `1a6fb16` | Interface repository untuk tasks, finance, notes, calendar. |
| P2-T3 | `d97239b` | Implementasi repository Isar dengan operasi yang dibungkus `Result`. |
| P2-T4 | `3d93fd9` | Provider Riverpod per fitur + test repository + `.gitignore` untuk native core Isar. |

### Phase 3 — Feature Modules MVP
| Task | Commit | Isi |
|------|--------|-----|
| P3-TASK-1 | `a0d5307` | Daftar tugas dengan seksi aktif/selesai. |
| P3-TASK-2 | `53a6e9d` | Form buat/edit tugas: sub-task, prioritas, tenggat, reminder. |
| P3-CAL-1 | `625e3be` | Tampilan bulan kalender + penanda per hari + daftar event harian. |
| P3-CAL-2 | `d976d03` | Form buat/edit event dengan reminder. |
| P3-FIN-1 | `ea1b09d` | Seed kategori keuangan default saat pertama kali jalan. |
| P3-FIN-2 | `1a78ec8` | Finance home: kartu saldo + riwayat dikelompokkan per hari. |
| P3-FIN-3 | `0509f2a` | Form tambah/edit transaksi dengan link kategori. |
| P3-FIN-4 | `dfff842` | Ringkasan mingguan/bulanan: grafik batang + breakdown kategori. |
| P3-NOTES-1,3 | `4a8b5f5` | Tab Notes/Documents, pencarian, impor dokumen. |
| P3-NOTES-2 | `ede7738` | Editor Quill dengan autosave *debounced*. |
| P3-NOTES-4 | `f052b91` | Penampil PDF in-app + fallback buka via aplikasi eksternal. |
| P3-DASH-1 | `7f48f5c` | Provider agregasi dashboard di atas stream tiap fitur. |
| P3-DASH-2 | `527e37b` | Kartu ringkasan dashboard + deep link per fitur. |

### Phase 4 — Notifications & File Management Hardening
| Task | Commit | Isi |
|------|--------|-----|
| *(persiapan)* | `afdcea0` | Aktifkan desugaring Android, buang `permission_handler` yang tak terpakai, tambah `app_settings`. |
| P4-T1 | `c6c06da` | Turun ke *inexact alarm* saat exact alarm dimatikan OS; reminder bertahan setelah reboot. |
| P4-T2, T3 | `8132a7a` | Banner "reminder dimatikan" + tautan ke pengaturan; reminder dibatalkan saat tugas selesai. |
| P4-T4 | `cfe0821` | Tampilkan pemakaian storage file impor + refresh otomatis setelah hapus. |

### Phase 5 — UI/UX Refinement & Polish
| Task | Commit | Isi |
|------|--------|-----|
| P5-T1 | `1f8a6b8` | Micro-interaction: token `AppMotion` (semua ≤ 250 ms), transisi halaman `go_router`, animasi masuk item list, dukungan *reduced motion*. |
| P5-T2 | `fffd1f3` | Audit seluruh layar untuk state *empty/loading/error*; tambah tombol Retry (tasks, finance, summary, notes), perbaiki state loading/error kalender & dashboard; tulis `docs/qa-checklist.md`. |
| P5-T3 | `5b47e82` | Accessibility: warna kontras WCAG untuk angka income/expense, tap target ≥ 48 px, tooltip/semantics untuk semua kontrol ikon-only (FAB & delete). |
| P5-T4 | `8c001cf` | **Layar Settings**: mode tema (System/Light/Dark, persisten & dibaca sebelum frame pertama), status izin notifikasi + aksi minta izin/buka pengaturan, pemakaian storage, versi aplikasi, dan "Clear all data" dengan dialog konfirmasi. |
| P5-T5 | `4123fb4` | **Performa**: riwayat keuangan di-*window* (`watchRecentTransactions` + tombol "Load older", 50 baris per window), ringkasan memakai query rentang (`watchTransactionsInRange`), dashboard memakai agregat (`sum()` + rentang minggu) agar tidak menarik seluruh riwayat ke memori. |

### Phase 6 (sebagian, dikerjakan lebih awal)
| Task | Commit | Isi |
|------|--------|-----|
| P6-T3 | `391f997` | Skenario smoke end-to-end di perangkat: boot dashboard, buat task, catat pengeluaran, tulis catatan. |
| P6-T3 | `16c7d0d` | Perkuat test on-device: batas waktu `pumpAndSettle` 20 s, `settleUntilFound`, dump teks saat gagal, assertion uang yang aman terhadap locale. |
| P6-T3 | *(unstaged lalu masuk `8c001cf`)* | Skenario baru: ganti tema di Settings + "Clear all data" (baru dijalankan pada P12-T4, lulus). |

### plan2 Phase 8 — Design Tokens & Theme (`16fee91`…`b8f6bcf`)
| Task | Commit | Isi |
|------|--------|-----|
| P8-T1 | `16fee91` | Palet netral hangat + tag palette (pasangan fg/bg per hue, kontras 4.5:1 dan 3:1 diuji di kedua tema); pemetaan tema jujur (tidak lagi menimpa warna Material). |
| P8-T2 | `86e990a` | Token bentuk & elevasi (`AppRadii`, `AppElevation`), kebijakan *flat-by-default*: hairline border menggantikan shadow; shadow hanya untuk overlay. |
| P8-T3 | `f650467` | Type scale lengkap; keluarga font Inter yang sebelumnya hilang kembali didefinisikan. |
| P8-T4 | `b8f6bcf` | `VWCard` dengan varian flat/soft/elevated + press feedback (scale 2% saat ditekan, `AppMotion.stateChange`, dilewati saat reduced motion). |

### plan2 Phase 9 — Motion Primitives (`e633d68`…`5abc6cb`)
| Task | Commit | Isi |
|------|--------|-----|
| P9-T1 | `e633d68` | Token motion baru: `signature` (320 ms, satu-satunya pengecualian terdokumentasi dari plafon 250 ms), `curveEmphasized`, token stagger; `motionDuration()` jadi satu-satunya titik keputusan reduced-motion. |
| P9-T2 | `76b157f` | `VWFadeThrough` (cross-fade) dan `VWStaggeredList` (entrance berjenjang, dibatasi 5 item agar total ≤ `signature`). |
| P9-T3 | `1ea7a51` | Pergantian tab di shell *settle in* (fade) alih-alih hard-cut; reduced motion memotongnya total. |
| P9-T4 | `5abc6cb` | Morph task-complete (checkmark dengan overshoot ringan + haptic), menunggu *write* Isar benar-benar selesai sebelum animasi jalan. |

### plan2 Phase 10 — Restyle per Fitur (`c90f96a`…`df31280`)
| Task | Commit | Isi |
|------|--------|-----|
| P10-FIN-1 | `c90f96a` | `VWCategoryChip` + warna kategori yang di-*check* kontrasnya. |
| P10-FIN-2 | `6cb6285` | `VWSparkline` (7 hari, query terbatas `watchLast7DaysNet`). |
| P10-FIN-3 | `626b77d` | Spending ring di samping breakdown kategori, berbagi satu set angka. |
| P10-FIN-4 | `dcbfe8d` | Kartu saldo dashboard menampilkan tren minggu (delta + sparkline), bukan sekadar angka. |
| P10-NOTES-1 | `e3200ee` | Judul catatan keluar dari app bar, jadi heading dokumen di dalam halaman (`DocumentTitleField`). |
| P10-NOTES-2 | `4645b3d` | Catatan punya ikon (`NoteModel.iconCodePoint` — perubahan skema kedua dan terakhir), `NoteIconPicker`. |
| P10-NOTES-3 | `8b06402` | Seksi Pinned/Others yang bisa dilipat (`VWSectionDisclosure`). |
| P10-NOTES-4 | `2947798` | Toolbar format Quill diratakan (panel dropdown font/ukuran dihilangkan — deviasi terdokumentasi, reversible). |
| P10-TASKS-1 | `af257ba` | Task dikelompokkan Today / Upcoming / No due date / Completed. |
| P10-TASKS-2 | `ebf8158` | Baris quick-add satu baris di atas daftar (type → enter → jadi). |
| P10-TASKS-3 | `5b1ce56` | Swipe kanan = selesai, swipe kiri = hapus (dialog konfirmasi); `Dismissible` dengan `confirmDismiss` selalu `false` — stream yang memindahkan baris, bukan animasi. |
| P10-TASKS-4 | — | Drag-to-reorder **sengaja ditunda** (keputusan user); `TaskModel.sortIndex` tidak dipakai, pengecualian skema terakhir disimpan untuk kebutuhan yang lebih penting. |
| P10-CAL-1 | `2c4a38e` | Header kalender bulan diratakan (today = ring, selected = lingkaran penuh, tanpa garis pemisah). |
| P10-CAL-2 | `5a7e4fc` | Event card minimal dengan aksen warna 4px di tepi kiri. |
| P10-NAV-1 | `df31280` | Bottom bar flat: latar `surface`, indikator pill 12% alpha, hairline 1px pemisah halaman. |

### plan2 Phase 11 — Empty, Loading & Interactive States (`1712760`…`23e6cad`)
| Task | Commit | Isi |
|------|--------|-----|
| P11-T1 | `1712760` | `VWSkeleton` + `VWShimmer` (satu `ShaderMask`, loop 1200 ms `AppMotion.skeletonSweep` — pengecualian terdokumentasi dari plafon transisi) + 4 skeleton per fitur yang ukurannya ≤3px dari baris aslinya. |
| P11-T2 | `a4328df` | Gerbang anti-kedip: `VWDelayed` (~100 ms) menahan skeleton; kalau Isar menjawab lebih cepat, skeleton tidak pernah tampil. Empat list dibungkus `VWFadeThrough` + key per state. Tab Documents tetap spinner — bentuk baris dokumen tidak bisa diwakili skeleton jujur (dikomentari di kode). |
| P11-T3 | `0059f72` | `VWEmptyState` direstyle: ikon muted dalam disc `surfaceSoft` 80px. Struktur `Center + SingleChildScrollView` yang pernah dua kali crash **tidak disentuh**; kedua mode crash kini dijaga test. |
| P11-T4 | `23e6cad` | Satu bahasa press: `AppMotion.pressedScale` (0,98) dipakai kartu *dan* tombol; tombol disabled/loading tidak bereaksi; reduced motion melewatinya. |

### plan2 Phase 12 — Cross-Cutting QA (`96ee696`, `45c8ec9`) + ikon (`f64c355`)
| Task | Commit | Isi |
|------|--------|-----|
| P12-T1 | `96ee696` | Suite otomatis ditutup hijau: `dart analyze` 0 issue, `flutter test -j 1` **300 test** lulus; checklist Phase 12 ditambahkan. |
| P12-T4 | `45c8ec9` | Suite on-device dijalankan penuh: **8/8 skenario lulus** di Redmi Note 8 (±54 s). Tiga skenario baru: swipe-to-complete, quick-add, collapse/expand grup. **Menemukan bug nyata** (lihat §6 #6) dan memperbaikinya. |
| P7-icon | `f64c355` | **Adaptive app icon** dari master art `assets/app_icon.png`: logo diisolasi via flood-fill, background jadi color resource `#1C1C1C`, safe zone 66%, legacy tile < API 26 dikomposit ulang, monochrome (themed icon Android 13) ikut disiapkan. Diverifikasi `flutter build apk` + install perangkat. |

### plan2 Phase 13 — Redesign Visual "Obsidian Lumina" (`bf193e0`…`b9388f6`)

Seluruh UI disejajarkan dengan design system Stitch **Obsidian Lumina**
(project `248785710936191983`): kanvas `#131318`, kontainer `#1F1F24`, primary
`#C0C1FF`, secondary mint `#4EDEA3`, tertiary coral `#FFB2B7`, Plus Jakarta
Sans, kontrol pill, dock kaca melayang, glow orb. Dark-first, `ThemeMode` tetap
tiga opsi.

| Task | Commit | Isi |
|------|--------|-----|
| P13-T1 | `bf193e0` | Fondasi token: Plus Jakarta Sans dibundel sebagai aset (`assets/fonts/`), `app_colors.dart`/`app_text_styles.dart`/`app_theme.dart` ditulis ulang ke palet Obsidian Lumina; radius sheet 20→24; tambah `AppColors.accentMintFor`. |
| P13-T2 | `92e0341` | Primitif visual baru `vw_luminous.dart`: `VWGlowOrb`, `VWGlass`, `vwGlowShadow()`, `vwHeroCardDecoration()`, `vwDockClearance` (88). Semua digambar kode — tanpa aset gambar. |
| P13-T3 | `7416c4b` | Kerangka navigasi: dock kaca melayang `VWDock` (key `appShellDockKey`/`appShellSettleKey`) menggantikan `NavigationBar`; `VWScreenHeader` (judul + slot aksi) dan `VWFab`/`VWFabLocation`. |
| P13-T4 | `d071107` | Dashboard direstyle penuh mengikuti mockup (header, hero saldo, orb, kartu-kartu seksi). |
| P13-T5 | `9f2c088` | Tasks: `VWScreenHeader` + banner notifikasi + quick-add + `VWFadeThrough` + `VWFab`; `task_list_tile` jadi kartu (checkbox radius 6px, pill prioritas uppercase, chip due, pill subtask); `task_row_skeleton` ditulis ulang mengikuti kartu. |
| P13-T6 | `d651ed6` | Finance: hero `_BalanceCard` (`vwHeroCardDecoration`, orb violet+mint, label "NET LIQUID ASSETS", pulse mint, `displaySmall`) + `_HeaderSummaryAction`; `transaction_list_tile` jadi kartu dengan slot `CategoryChip` 44px dan nominal berwarna. Delta bulanan & ikon privasi mockup **sengaja tidak dipakai** (tidak ada datanya). |
| P13-T7 | `38ba231` | Calendar: `CustomScrollView` sliver — `TableCalendar` + strip agenda ("ACTIVE SCHEDULE", judul `titleMedium`, pill "N Events") + daftar hari `SliverFillRemaining`; hari terpilih = fill `primaryContainer` + `vwGlowShadow`, teks `onPrimaryContainer`, marker mint. |
| P13-T8 | `4923c99` | Notes: header dengan aksi import, `TabBar`/`TabBarView`, `VWFab`; `note_list_tile`/`document_list_tile` jadi kartu; clearance dock 96. Tab Documents tetap spinner (bentuknya tidak bisa diwakili skeleton jujur). |
| P13-T9 | `b9388f6` | 14 ekspektasi test lama (kontrak visual Phase 8) diarahkan ulang ke kontrak Phase 13 — bukan dihapus: kartu borderless (`shape.side.width == 0`, warna `surfaceContainer`), radius sheet 24, keluarga `PlusJakartaSans`, skala sengaja non-monoton (`displaySmall 36 > titleLarge 26 > headlineMedium 24`), hero dashboard menggantikan soft `VWCard`, dan `widget_test.dart` kini menggerakkan dock kaca (blur, warna item aktif, clearance tepi) alih-alih `NavigationBar`. Analyze bersih, `flutter test -j 1` **301 test lulus**. Checklist Phase 13 ditambahkan ke `docs/qa-checklist.md`. |

### plan2 Phase 14 — Redesign Visual "Omotive Style" (`f05e8ce`)

Seluruh UI diganti total ke design system Stitch **Omotive Style** (project
`248785710936191983`) dan **menggantikan** Obsidian Lumina: kanvas `#131315`
(container `#1F1F21`, container-high `#2A2A2C`, container-highest `#353437`,
lowest `#0E0E10`), primary near-white `#F8FFDD` dengan container pistachio
`#D4E79E`, secondary amber `#EAC162`, tertiary coral `#FFD5D1`. Kartu taktil
radius 28 dengan lift berwarna isi kartu, baris 24, header 80px, dock ikon-saja
dengan lingkaran amber untuk tab aktif. Mockup hanya dark; light mode diturunkan
manual dan tetap lolos audit kontras.

Karena seluruh redesign dikerjakan sebagai satu sweep (bukan bertahap per task),
T1–T9 digabung dalam satu commit kode; dokumentasi menyusul di commit terpisah.

| Task | Commit | Isi |
|------|--------|-----|
| P14-T1 | `f05e8ce` | Token: `app_colors.dart` (tangga surface, pistachio/amber/coral + varian `…Deep`, tag palette diwarnai ulang), `app_text_styles.dart` (skala Omotive: headline-xl 36/44 w800, headline-lg 26/32 w700, body w500, label w700), `app_spacing.dart` (`AppRadii.tactileValue 28`/`rowValue 24`, `AppElevation.tactile/dock`), `app_theme.dart` (ColorScheme Omotive light+dark eksplisit, `cardTheme` = `surfaceContainerHigh` + radius 24, indikator nav amber, FAB pistachio). |
| P14-T2 | `f05e8ce` | Primitive baru `vw_omotive.dart`: `VWTactileCard`/`VWTactileKicker`/`VWCardShelf`/`VWCardAction`/`VWPill`/`VWDateCapsule`/`VWCapsuleStrip`/`VWBentoTile`/`VWIconTile`/`VWGlass` + `vwTactileShadow()`; `vw_luminous.dart` dihapus — Omotive tidak memakai glow. |
| P14-T3 | `f05e8ce` | Shell: `VWScreenHeader` 80px dengan pil amber "Create" + avatar 32px; dock jadi ikon-saja (slot 48px, lingkaran amber untuk tab aktif, label hanya lewat `Semantics`, lebar maks 384); `VWFab` memakai shadow taktil. |
| P14-T4 | `f05e8ce` | Dashboard: strip kapsul 7 hari, heading "Active Overview", kartu saldo pistachio (kicker "TOTAL NET BALANCE", delta pill, `VWSparkline` di shelf), kartu momentum amber, kartu urgent coral (muncul kondisional), bento Weekly net / Active tasks, kartu NEXT EVENT + recent note. |
| P14-T5 | `f05e8ce` | Tasks: kartu momentum amber + header `onCreate`; `task_list_tile` jadi baris `surfaceContainerHigh` radius 24; `task_row_skeleton` disamakan. |
| P14-T6 | `f05e8ce` | Finance: strip kapsul bulan, kartu saldo pistachio, kartu outflow amber (nyata + % vs bulan lalu via rentang bulan), kartu pengeluaran terbesar coral, recent activity dikelompokkan per hari; `transaction_list_tile` jadi baris Omotive. |
| P14-T7 | `f05e8ce` | Calendar: header `onCreate`, hari terpilih = lingkaran amber, hari ini = cincin amber, marker pistachio, strip agenda memakai `VWPill`, padding `vwPageMargin`. |
| P14-T8 | `f05e8ce` | Notes/Documents (tanpa mockup, diturunkan dari bahasa Omotive): header `onCreate`, tab indicator amber, pencarian `vwPageMargin`, `note_list_tile`/`document_list_tile` jadi baris radius 24, skeleton catatan ditulis ulang mengikuti bentuk baris baru. |
| P14-T9 | `f05e8ce` + commit ini | Test lama diarahkan ulang, bukan dihapus: `cardTheme` kini `surfaceContainerHigh`/radius 24, bobot body w500 & label w700, state kalender amber/pistachio, dock diuji lewat label semantik + cakram amber (plus satu test kebijakan elevasi baru), test grouping task men-scroll daftar yang kini lebih tinggi. **Dua bug nyata ditemukan**: `_StatTiles` memakai `Row(stretch)` di dalam ListView tak terbatas (assertion tinggi tak hingga + 9 exception berantai) dan `textTertiary` light hanya 4.29:1 di `surfaceContainerHighest`. Analyze bersih, `flutter test -j 1` **302 test lulus**. Checklist Phase 14 ditambahkan. |

---

## 6. Error yang sudah ditemukan & diperbaiki

Bagian ini hanya berisi **bug yang benar-benar muncul saat aplikasi/test
dijalankan** — ditemukan lewat `flutter test`, test perangkat, atau analyze.

| # | Gejala | Akar masalah | Perbaikan | Commit |
|---|--------|--------------|-----------|--------|
| 1 | Crash/overflow pada widget empty state saat dipakai di dalam parent tanpa tinggi terbatas. | `VWEmptyState` memakai `Column` tanpa pembatas, dan pada pemakaian tertentu mengandalkan tinggi intrinsik parent. | Buat `VWEmptyState` aman-overflow dan tambahkan penjagaan terhadap parent tanpa tinggi terbatas; sekaligus perbaiki lint `prefer_initializing_formals` di `file_storage_service`. | `76a855e`, `c0a9214` |
| 2 | **Finance home selalu menampilkan "Could not load your transactions"** — daftar transaksi tidak pernah muncul. | `watchAllTransactions` mengurutkan dengan `.thenByIdDesc()`. Isar tidak mendukung sort berdasarkan primary key pada query native → `IsarError: Unknown property "id"` dilempar saat runtime (kode tetap lolos compile). | Ganti tie-break ke `.thenByCreatedAtDesc()`; tambah test repository `watchAllTransactions emits linked transactions without error` agar regresi ini tidak lolos lagi. | `7095692` |
| 3 | **Crash saat membuka Finance dalam keadaan kosong.** Pesan: `LayoutBuilder does not support returning intrinsic dimensions`. | `VWEmptyState` dibungkus `LayoutBuilder`, sedangkan pemakaian di finance memakai `SliverFillRemaining(hasScrollBody: false)` yang meminta dimensi intrinsik — `LayoutBuilder` tidak menyediakannya. | Tulis ulang `VWEmptyState` menjadi `Center + SingleChildScrollView`; gunakan `SliverFillRemaining` dengan `hasScrollBody: true` (default). | `02a28fc` |
| 4 | Test perangkat **flaky**: kadang timeout di `pumpAndSettle` (default 10 menit) dan assertion nominal uang gagal tergantung locale perangkat. | Stream Isar mengirim data di event loop nyata, bukan sinkron; dan format uang bergantung locale (`100.00` vs `100,00`). | Bounded `settle` 20 s, helper `settleUntilFound`, dump teks yang terlihat saat gagal, dan assertion memakai formatter aplikasi sendiri (`formatMoney`). | `16c7d0d` |
| 5 | `dart analyze` melaporkan issue setelah penambahan Settings. | Import sisa (`document_list_tile` di `document_viewer_screen`) dan parameter konstruktor yang ditulis manual (langgar `prefer_initializing_formals`). | Bersihkan import; ubah ke parameter posisional ber-default `ThemeModeNotifier([this._initial = ThemeMode.system])`. | `8c001cf` |
| 6 | **Halaman Settings tidak punya jalan kembali** — ditemukan saat skenario Settings akhirnya dijalankan di perangkat (P12-T4): test gagal karena `NavigationBar` tidak ada, dan dump widget menunjukkan tidak ada `BackButton`/tooltip "Back" sama sekali. | Dashboard membuka Settings dengan `context.go(RoutePaths.settings)`. Karena `/settings` adalah route saudara shell di `go_router`, `go` **mengganti** stack alih-alih menumpuk: halaman Settings jadi satu-satunya route — tidak ada route di bawahnya, jadi tidak ada back button tersirat, dan system back akan keluar dari aplikasi. | Ganti ke `context.push(...)`; dikunci tanpa perangkat oleh widget test baru ("settings route (P12-T4)") yang men-tap ikon Settings, memeriksa `BackButton` ada, lalu kembali dan memeriksa shell masih utuh. Test skenario juga diperbaiki untuk pop Settings dulu sebelum mengejar bottom bar (layar memang sengaja tetap terbuka di belakang banner "All local data cleared."). | `45c8ec9` |

Catatan: `thenByIdDesc()` tetap ada di kode generated tapi **tidak boleh dipakai**
untuk mengurutkan — Isar melempar error hanya saat query dijalankan, sehingga
kesalahan seperti ini harus ditangkap test repository, bukan sekadar analyze.

### Error yang hanya terjadi di loop pengembangan/test (bukan bug produksi)

- **Test bantu gagal jalan**: import relatif `../helpers/isar_test_harness.dart`
  seharusnya `../../helpers/...`, serta `TransactionType` yang ternyata
  didefinisikan di `category_model.dart`.
- **`createTask` mengembalikan `Result.error` di test**: `TaskModel.priority`
  bertanda `late` tanpa default, jadi wajib diisi saat membuat objek di test.
- **Error tipe** `int` → `double` pada helper `_txn(...)` di test repository.
- **Tipe `Override` tidak diekspor** oleh riverpod yang dipakai: helper test
  yang menerima override bertipe `Override` gagal compile; solusinya membangun
  `ProviderScope` inline per test (list literal mengambil tipe dari konteks).
- **`pumpAndSettle` tidak boleh dipakai saat skeleton/shimmer tampil**: shimmer
  berulang tanpa henti sehingga settle tidak pernah selesai — test gerbang
  loading (P11-T2) memakai `pump()` berbatas.
- **`tester.pageBack()` gagal di layar tanpa back button**: pageBack mencari
  tooltip "Back" lalu `CupertinoNavigationBarBackButton`; di Settings (bug #6)
  keduanya tidak ada. Diagnosanya justru yang mengungkap bug produksi.
- **`adb shell input text`**: spasi tidak lolos tanpa `%s`, dan fokus field
  tidak bertahan setelah submit quick-add — seeding 200 task via UI harus
  tap field ulang tiap iterasi.

### Hambatan lingkungan (bukan bug kode)

- **MIUI (Redmi Note 8)**: muncul dialog izin "Izinkan" ±100 detik setelah
  `flutter test integration_test` mulai; kalau tidak ditekan, instalasi gagal
  (`INSTALL_FAILED_USER_RESTRICTED`). Sama juga berlaku saat `flutter run
  --profile` (pernah gagal install jam 04:00 karena HP tidur).
- **iOS/CocoaPods tidak tersedia** di mesin ini, sehingga jalur iOS belum
  pernah divalidasi (pesan CocoaPods di output hanya informatif).
- **`dumpsys gfxinfo` mencatat 0 frame untuk aplikasi ini** — pada stack
  Flutter 3.44 + MIUI, aplikasi Flutter mengomposisi surface-nya sendiri di
  luar view-system Android (dan backend Impeller/Vulkan tidak melapor ke
  jalur statistik legacy), sehingga pengukuran frame-time harus lewat
  timeline engine via VM Service (lihat §7).
- Perangkat uji sempat tidak terhubung beberapa kali (`adb devices` kosong),
  sehingga sebagian validasi perangkat bergeser mengikuti ketersediaan HP.

---

## 7. Validasi & pengujian

**Otomatis (host)** — dijalankan dari root project:

```sh
dart analyze lib test integration_test   # 0 issue
flutter test -j 1                        # 301 test lulus (± 7 menit)
```

Cakupan test host (42 file):

| Area | File |
|------|------|
| Core: error handling, DB, storage, tema, motion, warna, widget kit | `test/core/…` |
| Widget kit baru plan2: `VWFadeThrough`, `VWStaggeredList`, `VWSkeleton`, `VWDelayed`, `VWCategoryChip`, `VWSparkline`, `VWSectionDisclosure`, `VWEmptyState` (termasuk regresi §1.4 #1/#3) | `test/core/widgets/…`, `test/core/constants/app_motion_test.dart` |
| Skeleton per fitur (tinggi ≤3px dari baris asli + survives scroll contexts) | `test/features/*/presentation/*_skeleton_test.dart` |
| Gerbang loading per layar (fast read tidak pernah menampilkan skeleton) | `test/features/list_loading_test.dart` |
| Repository tiap fitur (tasks, finance, notes, calendar) | `test/features/**/…_test.dart` |
| Boot aplikasi, navigasi dock kaca, settle tab, route Settings | `test/widget_test.dart` |
| Audit aksesibilitas | `test/core/constants/app_colors_test.dart` (kontras WCAG), `test/core/widgets/vw_button_test.dart` (tap target 48 px, semantics, spinner, press feedback) |
| Tema persisten & reset data | `test/core/theme/theme_store_test.dart`, `test/core/database/app_data_reset_test.dart` |

**Perangkat asli (Redmi Note 8, Android 11)** — **8/8 skenario E2E lulus**
(`flutter test integration_test -d 134b63b3`):

boot dashboard → buat task (FAB) → quick-add task → swipe-to-complete →
collapse/expand grup → catat pengeluaran (saldo ter-update) → tulis catatan →
ganti tema + clear all data di Settings.

**Pengukuran performa on-device (P12-T2, parsial):**

- **Cold start terukur** (`flutter run --profile --trace-startup`):
  engine → framework init **740 ms**; time to first frame (rasterized)
  **2806 ms**; gap framework-init → frame pertama **2009 ms** (kerja async
  Dart: buka Isar, seed kategori, init notifikasi, load tema). Target lunak
  "< ~2 s" **belum tercapai** — tercatat jujur di checklist, bukan diasumsikan.
- **Frame-time interaksi**: `dumpsys gfxinfo` ternyata selalu 0 frame untuk
  aplikasi Flutter ini (lihat §6 hambatan lingkungan). Jalur pengukuran yang
  benar adalah timeline engine via VM Service (recorder Dart+Embedder, hanya
  tersedia di mode profile); instrumentasi sudah siap dan terekam saat
  pengukuran dihentikan oleh user — belum ada angka frame-time yang valid.

**Checklist manual** yang didokumentasikan di `docs/qa-checklist.md`
(hanya status yang benar-benar terverifikasi ditandai PASS):

- Phase 5 T2 (empty/loading/error per layar) — **PASS/terverifikasi**.
- Phase 5 T3 (kontras, tap target, label) — **PASS** untuk bagian otomatis;
  **TalkBack pass belum dijalankan**.
- Phase 5 T4 (tema persisten, clear-all) — **PASS** via test host **dan**
  kini juga terverifikasi on-device (skenario Settings, P12-T4).
- Phase 5 T5 (windowed history, range query) — **PASS** via kode + test;
  **cold start terukur 2806 ms** (di atas target lunak); **200-item scroll
  dan frame-time belum terukur**.
- Phase 8–11 — seluruh baris otomatis **PASS**; baris `MANUAL` perangkat
  (feel skeleton, sweep, press button vs card, empty state) masih menunggu
  sesi review visual di HP.
- plan2 P12 — T1 **PASS**; T4 **PASS**; T2/T3 **terbuka**.
- plan2 P13 — seluruh baris otomatis **PASS** (analyze bersih, 301 test,
  kontrak lama diarahkan ulang bukan dihapus, tanpa dependensi baru);
  baris `MANUAL` (paritas layar vs render Stitch, blur/glow di panel HP,
  reduced motion setelah restyle) menunggu sesi di perangkat.

---

## 8. Yang belum selesai / tertunda

**plan2 P14 — verifikasi visual di perangkat (terbuka):**

1. Bandingkan Dashboard, Tasks, Finance, Calendar, Notes dengan render Stitch
   Omotive di Redmi Note 8 — ritme spacing, lift kartu taktil, strip kapsul,
   clearance dock atas baris terakhir. Render emulator tidak dianggap bukti.
2. Pastikan lift kartu berwarna (shadow bertint isi kartu) dan blur dock tidak
   menimbulkan banding/ghost di panel HP, terang dan gelap.
3. Ulangi pass reduced-motion: pemilihan dock, transisi kapsul/tab, tekan kartu
   dan sweep skeleton harus jadi instan, bukan sekadar lebih cepat.

**plan2 P12-T2 — performansi on-device (parsial):**

1. Frame-time interaksi (tab walk, toggle task, scroll, icon-picker) via
   timeline engine — instrumentasi siap, angka belum ada.
2. Scroll daftar 200 transaksi — butuh seeding data (156 task test masih
   tertinggal di DB perangkat; bisa dibersihkan via Settings → Clear all data).
3. Cold start **sudah terukur** (2806 ms) — opsi optimasi (mis. defer init
   notifikasi) belum dievaluasi.

**plan2 P12-T3 — reduced motion & aksesibilitas:**

1. Verifikasi on-device bahwa semua animasi Phase 9–11 kolaps ke instan saat
   OS "Remove animations" aktif (di sisi kode sudah dijaga test).
2. TalkBack pass atas kontrol baru: quick-add, swipe actions, icon picker,
   section disclosure, chips.

**Phase 6 (plan.md):** P6-T1 (audit edge case unit test), P6-T2 (widget test
alur layar terhadap UI baru), P6-T4 (regression checklist pra-rilis).

**Phase 7 (plan.md):** splash screen, signing release, build `--release`,
store listing. Adaptive icon sudah beres (`f64c355`); splash belum.

**Rumah tangga:** `ringkasan.md` (file ini) kini ikut ter-track; dua commit
Phase 14 (`f05e8ce` + dokumentasi) belum di-push ke `origin/main`.

---

## 9. Langkah berikutnya

1. Selesaikan **P12-T2/T3** saat HP tersambung: ukur frame-time via timeline
   engine, seed data untuk uji scroll 200 baris, lalu reduced-motion +
   TalkBack pass; perbarui baris `MANUAL` di `docs/qa-checklist.md`.
2. Jalankan sesi review visual **P14** di perangkat (paritas dengan render
   Stitch Omotive, lift kartu, reduced motion) — baris `MANUAL` di
   `docs/qa-checklist.md`.
3. Lanjut **Phase 6** plan.md: P6-T1, P6-T2 (ditulis terhadap UI baru),
   P6-T4.
4. Masuk **Phase 7**: splash, signing, build release, store listing —
   screenshot store memakai UI Omotive yang sudah jadi.
5. Bersihkan data uji di perangkat (156 task "PerfTask…") sebelum demo/rilis.

---

## 10. Cara menjalankan

```sh
# sekali setelah clone / setelah ubah model Isar atau provider ber-anotasi
flutter pub get
dart run build_runner build --delete-conflicting-outputs

# cek cepat
dart analyze lib test integration_test
flutter test

# jalankan di perangkat
flutter run -d <device-id>

# test end-to-end di perangkat (butuh HP tersambung + acc dialog MIUI)
flutter test integration_test -d <device-id>

# ukur cold start (mode profile)
flutter run --profile --trace-startup -d <device-id>
# hasil: build/start_up_info.json + build/start_up_timeline.json
```

Konvensi commit yang dipakai: `feat(Px-Ty): …`, `fix(area): …`,
`perf(Px-Ty): …`, `test(Px-Ty): …`, `chore(area): …` — satu commit per task.
`docs/qa-checklist.md` adalah sumber kebenaran status verifikasi per item.
