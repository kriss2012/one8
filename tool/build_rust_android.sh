#!/bin/sh
set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
export PATH="$HOME/.cargo/bin:$PATH"
MANIFEST_PATH="$PROJECT_ROOT/rust/image_engine/Cargo.toml"
ANDROID_DIR="$PROJECT_ROOT/android"
LOCAL_PROPERTIES="$ANDROID_DIR/local.properties"
BUILD_MODE="${1:-debug}"

case "$BUILD_MODE" in
  debug)
    PROFILE_DIR="debug"
    CARGO_ARGS=""
    ;;
  release|profile)
    PROFILE_DIR="release"
    CARGO_ARGS="--release"
    ;;
  *)
    echo "Unsupported Android Rust build mode: $BUILD_MODE" >&2
    exit 1
    ;;
esac

SDK_DIR="${ANDROID_SDK_ROOT:-${ANDROID_HOME:-}}"
if [ -z "${SDK_DIR}" ] && [ -f "$LOCAL_PROPERTIES" ]; then
  SDK_DIR=$(sed -n 's/^sdk.dir=//p' "$LOCAL_PROPERTIES" | tail -n 1)
fi

if [ -z "${SDK_DIR}" ] || [ ! -d "$SDK_DIR" ]; then
  echo "Android SDK not found. Set ANDROID_SDK_ROOT or configure android/local.properties." >&2
  exit 1
fi

NDK_DIR="${ANDROID_NDK_HOME:-${ANDROID_NDK_ROOT:-}}"
if [ -z "${NDK_DIR}" ]; then
  for candidate in "$SDK_DIR"/ndk/*; do
    if [ -d "$candidate" ]; then
      NDK_DIR="$candidate"
      break
    fi
  done
fi

if [ -z "${NDK_DIR}" ] || [ ! -d "$NDK_DIR" ]; then
  echo "Android NDK not found under $SDK_DIR/ndk. Install the NDK first." >&2
  exit 1
fi

HOST_OS=$(uname -s)
HOST_ARCH=$(uname -m)
case "$HOST_OS" in
  Linux)
    HOST_TAG="linux-x86_64"
    ;;
  Darwin)
    if [ "$HOST_ARCH" = "arm64" ]; then
      HOST_TAG="darwin-arm64"
    else
      HOST_TAG="darwin-x86_64"
    fi
    ;;
  MINGW*|MSYS*|CYGWIN*)
    HOST_TAG="windows-x86_64"
    ;;
  *)
    echo "Unsupported host OS for Android Rust build: $HOST_OS" >&2
    exit 1
    ;;
esac

LLVM_BIN="$NDK_DIR/toolchains/llvm/prebuilt/$HOST_TAG/bin"
if [ ! -d "$LLVM_BIN" ]; then
  echo "NDK LLVM toolchain not found: $LLVM_BIN" >&2
  exit 1
fi

ensure_target_installed() {
  target="$1"
  if ! rustup target list --installed | grep -qx "$target"; then
    echo "Missing Rust target $target. Run: rustup target add $target" >&2
    exit 1
  fi
}

build_target() {
  abi="$1"
  cargo_target="$2"
  clang_triple="$3"
  ensure_target_installed "$cargo_target"

  env_key=$(printf '%s' "$cargo_target" | tr '[:lower:]-' '[:upper:]_')
  linker="$LLVM_BIN/$clang_triple-clang"
  if [ ! -x "$linker" ]; then
    echo "Android linker not found: $linker" >&2
    exit 1
  fi

  export PATH="$LLVM_BIN:$PATH"
  export "CARGO_TARGET_${env_key}_LINKER=$linker"
  export "CARGO_TARGET_${env_key}_AR=$LLVM_BIN/llvm-ar"
  export "CC_${env_key}=$linker"
  export "AR_${env_key}=$LLVM_BIN/llvm-ar"
  export "CC=$linker"
  export "AR=$LLVM_BIN/llvm-ar"

  cargo build --manifest-path "$MANIFEST_PATH" --target "$cargo_target" $CARGO_ARGS

  output_dir="$ANDROID_DIR/app/src/main/jniLibs/$abi"
  mkdir -p "$output_dir"
  cp \
    "$PROJECT_ROOT/rust/image_engine/target/$cargo_target/$PROFILE_DIR/libimage_engine.so" \
    "$output_dir/libimage_engine.so"
}

build_target "arm64-v8a" "aarch64-linux-android" "aarch64-linux-android21"
build_target "armeabi-v7a" "armv7-linux-androideabi" "armv7a-linux-androideabi21"
build_target "x86_64" "x86_64-linux-android" "x86_64-linux-android21"
build_target "x86" "i686-linux-android" "i686-linux-android21"
