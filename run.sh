#!/bin/bash
set -e

# Ensure rustup cargo is used for Android target cross-compilation
export PATH="$HOME/.cargo/bin:$PATH"

echo "⚡ Building Rust engine for Android (debug)..."
./tool/build_rust_android.sh debug

echo "🚀 Launching ONE8 on Android..."
flutter run --debug "$@"
