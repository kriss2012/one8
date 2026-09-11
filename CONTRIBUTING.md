# Contributing to ONE8

Thank you for your interest in contributing to ONE8. We welcome bug reports, feature suggestions, documentation improvements, and code contributions.

## Code of Conduct

Please review and adhere to our [Code of Conduct](CODE_OF_CONDUCT.md) in all interactions within this project.

## Architecture Principles

ONE8 uses a Clean Architecture design pattern with strict decoupling between UI, business domain logic, and high-performance native engines:

1. **Presentation Layer (`lib/features/*/presentation`)**: Flutter UI widgets, Material 3 design tokens, state management controllers.
2. **Domain Layer (`lib/features/*/domain`)**: Core business rules, value objects, domain entities, and abstract repository contracts. No UI or platform dependencies.
3. **Data Layer (`lib/features/*/data`)**: Implementations of repositories, FFI native engine calls (`flutter_rust_bridge`), file handling, and Dart fallback processing.
4. **Native Core (`rust/image_engine`)**: SIMD-accelerated image compression written in Rust.

## Local Environment Setup

### Requirements

- **Flutter SDK**: 3.12.0 or higher
- **Rust Toolchain**: `rustup`, `cargo` (edition 2021/2024)
- **flutter_rust_bridge_codegen**: `v2.12.0` or higher
- **Make**: Available on Linux, macOS, and Windows (via Git Bash / WSL)

### Setting Up

1. Clone the repository:
   ```bash
   git clone https://github.com/kriss2012/one8.git
   cd one8
   ```

2. Install Dart dependencies:
   ```bash
   flutter pub get
   ```

3. Compile the Rust engine and launch the app:
   ```bash
   make run
   ```

## Development Workflow

### Regenerating FFI Bindings

If you modify function signatures inside `rust/image_engine/src/lib.rs`, regenerate the FFI bridge bindings:

```bash
make frb-codegen
```

### Running Static Analysis and Tests

Before submitting a pull request, run all project checks:

```bash
make flutter-check
```

This target runs:
- `flutter analyze`
- `flutter test`
- `cargo check --manifest-path rust/image_engine/Cargo.toml`

## Coding Standards

### Dart & Flutter

- Follow standard Dart style conventions (`flutter_lints`).
- Keep UI widgets small, modular, and declarative.
- Place business logic inside domain use cases and state controllers, not inside widget build methods.
- Ensure all new public classes and non-trivial methods include clear doc comments.

### Rust

- Run `cargo fmt` to format Rust code.
- Avoid introducing unhandled `panic!` calls in native FFI exports. Always return structured error results to Dart.

## Submitting Pull Requests

1. Fork the repository and create a new branch from `main`.
2. Keep pull requests focused on a single feature or bug fix.
3. Ensure all tests pass locally (`make flutter-check`).
4. Write clear, descriptive commit messages.
5. Submit the pull request against the `main` branch.
