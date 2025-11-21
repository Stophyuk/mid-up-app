# Repository Guidelines

## Project Structure & Modules
- `lib/` Flutter app source; `lib/src/features/*` for domain modules (prescription, note, knowledge_graph), `lib/src/core/` for shared theme/env.
- `android/`, `ios/`, `web/`, `windows/`, `macos/`, `linux/` platform scaffolding; avoid editing generated files.
- `assets/` holds data seeds (`assets/data/data.zip`).
- `test/` widget/unit tests (e.g., `knowledge_graph_navigator_test.dart`).

## Build, Test, Run
- Fetch deps: `flutter pub get`.
- Format: `dart format <paths>`.
- Tests: `flutter test` (uses `PUB_CACHE`, `TMP/TEMP` envs if needed).
- Run on device/emulator: `flutter run -d <deviceId> --debug`.
- Clean: `flutter clean` (removes build/.dart_tool).
- Android NDK: `android/app/build.gradle.kts` pins `ndkVersion = "27.0.12077973"`; set `GRADLE_USER_HOME` if cache issues.

## Coding Style & Naming
- Dart: 2-space indent, prefer const constructors where possible; keep widgets small and focused.
- File naming: snake_case (`freehand_canvas.dart`), classes in PascalCase.
- Lints: `flutter_lints`; rely on `dart format`.
- Copy tone: user-facing text should be gentle/encouraging (No-Stress UX).

## Testing Guidelines
- Frameworks: `flutter_test`, Riverpod for state.
- Keep widget tests resilient: assert on stable labels (e.g., nav/tab titles) rather than volatile copy.
- Name tests descriptively: `renders ...`, `detects ...`; place alongside feature when >1 test per module.

## Commit & PR Guidelines
- Commits: short imperative titles seen in history (`Add micro-motion...`, `Use io.File...`). Group related changes; avoid noisy formatting-only commits unless necessary.
- PRs (if used): include summary, screenshots/gifs for UI changes, note device/OS tested, mention relevant issues.

## Security & Config Tips
- Secrets: keep API keys in `.env` (gitignored); OCR service JSON path via `OCR_CREDENTIALS_PATH`. Do not commit `.env` or credential files.
- Environment: prefer ASCII paths for build/test (`PUB_CACHE`, `TMP/TEMP`, `GRADLE_USER_HOME`) to avoid isolate issues on Windows.

## Architecture Notes
- State: Riverpod notifiers (`dailyPrescriptionController`, `toolWorkspaceController`).
- Styling: centralized theme in `lib/src/core/theme/`; use existing color tokens and typography.
- Drawing: `FreehandCanvas` common component; pass `background` for problem overlays.
