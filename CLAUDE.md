# CLAUDE.md — Enterprise Flutter Architecture

These instructions MUST be followed by the AI assistant (Claude) when interacting with this project or generating new Flutter code.

## 1. Context & Architecture Goal

This project uses a **custom Enterprise Flutter Architecture**, optimized for Mobile (iOS/Android) and focused on:

- Strict **Type-Safety**
- **Separation of Concerns (SoC)**
- Minimizing boilerplate

### Core Paradigms

| Aspect | Choice |
|---|---|
| Navigation | Mobile-first Declarative Navigator 2.0 (`Navigator(pages: [...])`) — **NOT** `MaterialApp.router` or `go_router` |
| Routing Definition | Dart 3 `sealed classes` for 100% type-safe route definitions |
| Architecture Pattern | MVVM (Model-View-ViewModel) |
| Dependency Injection | `get_it` + `injectable` |
| State Management (UI/ViewModel) | `provider` (`context.watch` / `context.read`) |
| State Management (Navigation) | Centralized `ChangeNotifier` (`AppRouterState`) acting as a Singleton router |
| Data Modeling | `freezed` for immutable, type-safe data classes |

## 2. Required Packages

Ensure the following packages are included in `pubspec.yaml` when setting up or updating the project:

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2              # UI State Management
  get_it: ^7.7.0                # Service Locator
  injectable: ^2.4.1            # DI Code Generator
  freezed_annotation: ^2.4.1    # Model Code Generator

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.9           # Task runner for code generation
  injectable_generator: ^2.6.1   # Generates DI config
  freezed: ^2.5.2                 # Generates immutable classes
```

> **Note:** Always use the latest stable versions compatible with the current Dart SDK.

## 3. Strict Coding Rules & Workflows

When asked to generate new features, screens, or logic, follow this sequence and structural rules.

### Rule 1 — Data Models (`lib/models/`)

- Always use `@freezed` for data models.
- Never use standard mutable classes for data entities.

### Rule 2 — Routing (`lib/routes/`)

- **NEVER** use string-based routing (`Navigator.pushNamed`).
- **NEVER** use `Navigator.of(context).push(...)` inside UI files.
- When adding a new screen, first define its route as a subclass of the `sealed class AppRoute` in `app_route.dart`.
- Pass required arguments directly into the route's sealed class constructor (e.g., `DetailRoute({required this.product})`).

### Rule 3 — ViewModels (`lib/viewmodels/`)

- ViewModels must extend `ChangeNotifier`.
- ViewModels must be decorated with `@injectable`.
- ViewModels must inject `AppRouterState` via their constructor if they need to navigate.
- ViewModels must not depend on `BuildContext`. Navigation intent is sent to `AppRouterState` (e.g., `_router.push(NewRoute())`).

### Rule 4 — UI Screens (`lib/ui/screens/`)

- Screens should generally be `StatelessWidget`.
- Use `context.watch<YourViewModel>()` to rebuild the UI based on state changes.
- UI actions (button clicks) must only call methods on the ViewModel (e.g., `onPressed: () => viewModel.submit()`).
- The UI must have zero routing logic.

### Rule 5 — Route Mapper (`lib/routes/app_route_mapper.dart`)

- When a new route and screen are created, you MUST update the `AppRouteMapper.toPage()` switch statement.
- If the screen requires a ViewModel, use the functional injection helper: `child: _inject<YourViewModel>(const YourScreen())`.
- Do NOT clutter `main.dart` with Providers. `main.dart` should only initialize DI and provide the global `AppRouterState`.

## 4. Example: Feature Addition Workflow

If the user asks: *"Create a Profile screen where a user can edit their name"*, the response must include:

1. **Model** — (if needed) e.g., a `UserProfile` freezed class.
2. **AppRoute Update** — add `class ProfileRoute extends AppRoute {}`.
3. **ViewModel** — create `ProfileViewModel` (`@injectable`, extends `ChangeNotifier`, takes `AppRouterState`).
4. **UI Screen** — create `ProfileScreen` (Stateless, reads VM via `context.watch`).
5. **Mapper Update** — add `ProfileRoute() => MaterialPage(child: _inject<ProfileViewModel>(const ProfileScreen()))` to the switch statement in `app_route_mapper.dart`.
