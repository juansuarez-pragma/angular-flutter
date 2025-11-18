## Quick guide for AI coding agents

This repository is a mobile PoC: Flutter acts as the shell/orchestrator and an Angular app is a Micro Frontend (MFE) rendered inside a native WebView. The Angular MFE is a "dumb view" — Flutter owns business logic and state.

Keep answers and edits actionable and minimal: reference exact files and show diffs when modifying code.

Key architecture (short):

- Flutter shell (lib/) — BLoC state management, `go_router`, `flutter_inappwebview`.
  - Main files: `flutter_shell_orchestrator/lib/main.dart`, `lib/core/bloc/app_bloc.dart`, `lib/core/services/bridge_service.dart`, `lib/presentation/screens/webview_host_screen.dart`.
- Angular MFE (angular_mfe_ui/) — UI-only, standalone components, bridge service.
  - Main files: `angular_mfe_ui/src/app/app.component.ts`, `angular_mfe_ui/src/app/services/bridge.service.ts`.

Essential developer workflows (what to run):

- Start Angular dev server (terminal A):
  - `cd angular_mfe_ui && npm install && npm start` (serves on :4200)
- Start Flutter shell (terminal B):
  - `cd flutter_shell_orchestrator && flutter pub get && flutter run` (or `flutter run -d <id>`)

Platform and URL notes (crucial):

- Android emulator must use `10.0.2.2:4200` instead of `localhost`. The WebView URL is configured in `webview_host_screen.dart` via `_mfeUrl`.
- iOS simulator may have WKWebView localhost restrictions; prefer a physical device or use local network IP and `npm start -- --host 0.0.0.0`.

Bridge contract (copyable examples):

- Angular → Flutter (post):
  ```ts
  window.flutter_inappwebview.callHandler("AppBridge", {
    event: "UPDATE_NAME",
    payload: { newName: "Juan" },
  });
  ```
- Flutter → Angular (CustomEvent):
  ```dart
  controller.evaluateJavascript(source: ""
    "const e=new CustomEvent('flutterDataUpdate',{detail:${jsonEncode(payload)}});document.dispatchEvent(e);"
  """);
  ```

State and responsibilities:

- Flutter is authoritative for state. BLoC files live in `lib/core/bloc/*` (events: `app_event.dart`, states: `app_state.dart`).
- Angular must not implement business logic, HTTP calls, or complex state. It only renders and sends events to Flutter.

When adding a new feature involving the bridge (recommended small checklist):

1. Add new event type and payload in Angular `bridge.service.ts`.
2. Add corresponding event class in Flutter `app_event.dart`.
3. Handle it in `app_bloc.dart` and emit updated state.
4. Send state back to Angular via `bridge_service.dart` (use `sendDataUpdate()` pattern).
5. Update Angular listener (`document.addEventListener('flutterDataUpdate', ...)`) and UI.

Debugging quick tips:

- Flutter logs: `flutter logs` (or `flutter run` console). Filter with `grep AppBridge|BridgeService`.
- Android logcat: `adb logcat | grep -E "AppBridge|BridgeService|webview"`.
- Safari Develop → Device → App for iOS WebView console.

Tests & lint:

- Flutter: `cd flutter_shell_orchestrator && flutter test` and `dart analyze` / `dart format .`.
- Angular: `cd angular_mfe_ui && npm test` (Karma) and `ng lint` if configured.

Files to read first (prioritize):

- `README.md`, `QUICKSTART.md`, `ARCHITECTURE.md`, `CLAUDE.md`, `PROJECT_CONTEXT.md` — these contain project-specific commands and patterns.

Conventions to enforce when editing:

- Never move business logic from Flutter into Angular. If a change needs logic, implement it in BLoC and expose results via the bridge.
- Use existing bridge helpers and message shapes. Reuse `sendAppState()` / `sendDataUpdate()` patterns.
- Prefer minimal changes to `webview_host_screen.dart` URL constants — call out platform-specific diffs in PRs.

If something is missing or ambiguous, propose one of two reasonable options and include the code diff for each; prefer the smallest change.

For large or risky changes (native code, plugin upgrades, platform entitlements), list required manual steps (Xcode changes, Info.plist, AndroidManifest) and mark as high-risk.

Reference docs: `ARCHITECTURE.md`, `QUICKSTART.md`, `CLAUDE.md`, `angular_mfe_ui/README.md`, `flutter_shell_orchestrator/README.md`.

If you want, I can draft a compact PR template that enforces these checks (bridge changes, BLoC updates, platform URL notes).
