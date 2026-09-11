RUST_ENGINE_MANIFEST := rust/image_engine/Cargo.toml

.PHONY: run
run: debug

.PHONY: debug
debug:
	./run.sh

.PHONY: android-rust-debug
android-rust-debug:
	PATH="$(HOME)/.cargo/bin:$(PATH)" ./tool/build_rust_android.sh debug

.PHONY: android-rust-release
android-rust-release:
	PATH="$(HOME)/.cargo/bin:$(PATH)" ./tool/build_rust_android.sh release

.PHONY: rust-engine-debug
rust-engine-debug:
	cargo build --manifest-path $(RUST_ENGINE_MANIFEST)

.PHONY: rust-engine-release
rust-engine-release:
	cargo build --manifest-path $(RUST_ENGINE_MANIFEST) --release

.PHONY: frb-codegen
frb-codegen:
	flutter_rust_bridge_codegen generate

.PHONY: rust-engine-check
rust-engine-check:
	cargo check --manifest-path $(RUST_ENGINE_MANIFEST)

.PHONY: flutter-check
flutter-check:
	flutter analyze
	flutter test
