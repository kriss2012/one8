#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
MANIFEST_PATH="$PROJECT_ROOT/rust/image_engine/Cargo.toml"
APPLE_PLATFORM="${1:-macos}"
CONFIGURATION="${CONFIGURATION:-Debug}"
ARCHS_VALUE="${ARCHS:-$(uname -m)}"

case "$CONFIGURATION" in
  Debug)
    PROFILE_DIR="debug"
    CARGO_ARGS=""
    ;;
  *)
    PROFILE_DIR="release"
    CARGO_ARGS="--release"
    ;;
esac

ensure_target_installed() {
  target="$1"
  if ! rustup target list --installed | grep -qx "$target"; then
    echo "Missing Rust target $target. Run: rustup target add $target" >&2
    exit 1
  fi
}

build_one() {
  cargo_target="$1"
  output_file="$2"
  ensure_target_installed "$cargo_target"
  cargo build --manifest-path "$MANIFEST_PATH" --target "$cargo_target" $CARGO_ARGS
  cp \
    "$PROJECT_ROOT/rust/image_engine/target/$cargo_target/$PROFILE_DIR/libimage_engine.a" \
    "$output_file"
}

TEMP_DIR=$(mktemp -d)
cleanup() {
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

ARCH_OUTPUTS=""

case "$APPLE_PLATFORM" in
  ios)
    PROJECT_DIR_VALUE="${PROJECT_DIR:-$PROJECT_ROOT/ios}"
    PLATFORM_NAME_VALUE="${PLATFORM_NAME:-iphonesimulator}"
    OUTPUT_DIR="$PROJECT_DIR_VALUE/Flutter/Rust/$CONFIGURATION/$PLATFORM_NAME_VALUE"
    mkdir -p "$OUTPUT_DIR"

    for arch in $ARCHS_VALUE; do
      case "$PLATFORM_NAME_VALUE:$arch" in
        iphoneos:arm64)
          cargo_target="aarch64-apple-ios"
          ;;
        iphonesimulator:arm64)
          cargo_target="aarch64-apple-ios-sim"
          ;;
        iphonesimulator:x86_64)
          cargo_target="x86_64-apple-ios"
          ;;
        *)
          echo "Unsupported iOS arch combination: $PLATFORM_NAME_VALUE / $arch" >&2
          exit 1
          ;;
      esac

      output_file="$TEMP_DIR/$arch-libimage_engine.a"
      build_one "$cargo_target" "$output_file"
      ARCH_OUTPUTS="$ARCH_OUTPUTS $output_file"
    done

    ;;
  macos)
    PROJECT_DIR_VALUE="${PROJECT_DIR:-$PROJECT_ROOT/macos}"
    OUTPUT_DIR="$PROJECT_DIR_VALUE/Flutter/Rust/$CONFIGURATION"
    mkdir -p "$OUTPUT_DIR"

    for arch in $ARCHS_VALUE; do
      case "$arch" in
        arm64)
          cargo_target="aarch64-apple-darwin"
          ;;
        x86_64)
          cargo_target="x86_64-apple-darwin"
          ;;
        *)
          echo "Unsupported macOS arch: $arch" >&2
          exit 1
          ;;
      esac

      output_file="$TEMP_DIR/$arch-libimage_engine.a"
      build_one "$cargo_target" "$output_file"
      ARCH_OUTPUTS="$ARCH_OUTPUTS $output_file"
    done
    ;;
  *)
    echo "Unsupported Apple platform: $APPLE_PLATFORM" >&2
    exit 1
    ;;
esac

set -- $ARCH_OUTPUTS
if [ "$#" -eq 1 ]; then
  cp "$1" "$OUTPUT_DIR/libimage_engine.a"
else
  lipo -create "$@" -output "$OUTPUT_DIR/libimage_engine.a"
fi
