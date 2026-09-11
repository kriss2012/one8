plugins {
    id("com.android.application")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val repositoryRoot = rootProject.projectDir.parentFile
val rustAndroidBuildMode =
    providers.provider {
        val requestedTasks = gradle.startParameter.taskNames.joinToString(" ").lowercase()
        if ("release" in requestedTasks || "profile" in requestedTasks) "release" else "debug"
    }

val buildRustImageEngine by tasks.registering(Exec::class) {
    group = "build"
    description = "Builds the Rust image engine for Android ABIs."
    workingDir = repositoryRoot
    commandLine(
        "sh",
        "${repositoryRoot.absolutePath}/tool/build_rust_android.sh",
        rustAndroidBuildMode.get(),
    )
    inputs.dir(repositoryRoot.resolve("rust/image_engine/src"))
    inputs.file(repositoryRoot.resolve("rust/image_engine/Cargo.toml"))
    outputs.dir(projectDir.resolve("src/main/jniLibs"))
}

android {
    namespace = "com.kriss2012.one8"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.kriss2012.one8"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    sourceSets.named("main") {
        jniLibs.srcDir("src/main/jniLibs")
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}

tasks.named("preBuild") {
    dependsOn(buildRustImageEngine)
}
