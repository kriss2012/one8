# Changelog

All notable changes to the ONE8 project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-09-11: ONE8 Rebrand

- Rebranded application as **ONE8**.
- Migrated project repository references to [kriss2012/one8](https://github.com/kriss2012/one8).
- Updated application and platform metadata (Android, iOS, macOS, Windows, Linux, Web).
- Updated brand visual assets, icons, logos, and banner.
- Updated documentation, guides, and architectural references.
- Preserved existing native Rust compression architecture and multi-threaded Rayon pipeline.
- Preserved Dart raster fallback engine.
- Preserved upstream MIT licensing and attribution to the original OneCompress project.

## [1.0.0] - 2026-07-22

### Added

- **Rust Native Engine**: Multi-threaded, SIMD-accelerated image compression core for JPEG, PNG, and WebP formats.
- **Flutter Presentation Layer**: Responsive Material 3 desktop and mobile user interface built with Clean Architecture.
- **Interactive Visual Comparison**: Real-time split-screen before/after image inspection tool with zoom controls.
- **Dynamic FFI Engine Bridge**: Zero-copy native binding powered by `flutter_rust_bridge` (v2).
- **Resilient Dart Raster Fallback**: Automatic fallback to pure Dart raster processing if native binaries are not compiled for target devices.
- **Batch Processing Workflow**: Parallel image batch queueing with per-file and global quality presets.
- **Direct Gallery Export**: Integration with system gallery via `gal` for saving compressed media artifacts.
- **Local Telemetry & Storage**: High-performance local database powered by ObjectBox.
- **Developer Workflows**: One-step build and launch target (`make run`), cross-compilation scripts for Android and Apple platforms.
