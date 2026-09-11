# ONE8 Architecture Documentation

ONE8 combines a reactive Flutter frontend with a high-throughput, multi-threaded Rust native compression engine via `flutter_rust_bridge` (v2).

```text
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Presentation                     │
│  (Material 3 · Comparison Slider · Batch Queue · Settings)  │
└──────────────────────────────┬──────────────────────────────┘
                               │
┌──────────────────────────────▼──────────────────────────────┐
│                        Domain Layer                         │
│  (Use Cases · Domain Entities · Repository Abstractions)     │
└──────────────────────────────┬──────────────────────────────┘
                               │
              ┌────────────────┴────────────────┐
              │                                 │
┌─────────────▼──────────────┐   ┌──────────────▼─────────────┐
│    Rust FFI Data Source    │   │ Pure Dart Fallback Engine  │
│ (flutter_rust_bridge v2)   │   │     (image dart package)   │
└─────────────┬──────────────┘   └────────────────────────────┘
              │
┌─────────────▼──────────────┐
│  Rust Native Image Engine  │
│ (Rayon Thread Pool · SIMD) │
└────────────────────────────┘
```

## 1. Presentation Layer (`lib/features/*/presentation`)
- Built using Flutter with Material 3 design tokens and responsive layouts.
- Real-time comparison inspector using interactive gestures and custom split painters.
- State management with observable controllers providing progress telemetry (percentage, MB saved, remaining time).

## 2. Domain Layer (`lib/features/*/domain`)
- Strict separation of business rules.
- Pure Dart entities (`CompressedImage`, `CompressionHistoryItem`, `SelectedImage`).
- Contract interfaces (`IImageCompressionRepository`, `ICompressionHistoryRepository`).

## 3. Data Layer (`lib/features/*/data`)
- **Native Pipeline**: Zero-copy bridge streaming compression progress through `StreamSink<CompressionTaskProgress>`.
- **Automatic Fallback Pipeline**: If native `.so` / `.dll` / `.dylib` libraries are absent in a development environment, the repository dynamically routes image tasks through pure Dart raster decoders and encoders without crashing or interrupting the user.
- **Persistence**: High-speed local database powered by ObjectBox.

## 4. Rust Native Core (`rust/image_engine`)
- Multi-threaded worker pool utilizing Rayon pinned to `max(num_cpus - 1, 1)`.
- Support for JPEG, PNG (deflate), and WebP.
- High performance compiler flags (`opt-level = 3`, `lto = "fat"`, `strip = true`).
