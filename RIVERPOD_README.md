# Riverpod State Management Implementation

This project uses Riverpod for state management, which is a reactive state management solution for Flutter applications.

## Overview

Riverpod is the successor to the Provider package and offers several advantages:
- Compile-time safety and better error messages
- Testability and maintainability
- Ability to easily combine and compose state
- Automatic disposal of resources when they are no longer needed

## Implementation Details

### 1. Dependencies

The following dependencies have been added to the project:
```yaml
dependencies:
  flutter_riverpod: ^2.4.9
  riverpod_annotation: ^2.3.3

dev_dependencies:
  riverpod_generator: ^2.3.9
  build_runner: ^2.4.7
```

### 2. Provider Structure

The Riverpod providers are organized in the `lib/riverpod` directory:

- `auth_provider.dart`: Manages authentication state
- `store_provider.dart`: Manages store-related state (stores list, favorites, etc.)

### 3. Code Generation

This implementation uses the code-generation approach with `riverpod_annotation`. To generate the provider files, run:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. State Classes

For complex state, dedicated state classes have been created:

```dart
class AuthState {
  final bool isAuthenticated;
  final String? userId;
  final String? username;
  final String? errorMessage;
  final bool isLoading;

  // Constructor and copyWith methods
}
```

### 5. Provider Usage

#### Provider Creation
```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return AuthState();
  }

  // Methods to update state
}
```

#### Reading Providers in UI
```dart
// Watching a provider (reactive)
final authState = ref.watch(authNotifierProvider);

// Reading a provider (non-reactive)
final authNotifier = ref.read(authNotifierProvider.notifier);
```

### 6. ConsumerWidget and ConsumerStatefulWidget

UI components that need to access providers use:
- `ConsumerWidget` instead of `StatelessWidget`
- `ConsumerStatefulWidget` instead of `StatefulWidget`

### 7. Migrating from Provider

This codebase is in transition from Provider to Riverpod. Some components may still be using the Provider package. The transition is being done incrementally to ensure stability.

## Best Practices

1. Use `ref.watch` in the build method for reactive UI updates
2. Use `ref.read` in event handlers to access providers without rebuilding
3. Create modular providers that can be composed together
4. Create dedicated state classes for complex state
5. Use AsyncValue for asynchronous data 