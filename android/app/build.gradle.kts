import java.io.File
import java.io.FileInputStream
import java.util.Properties

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

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    FileInputStream(keystorePropertiesFile).use { stream ->
        keystoreProperties.load(stream)
    }
}

val isWindows = System.getProperty("os.name").lowercase().contains("windows")
val gitSh = File("C:/Program Files/Git/bin/sh.exe")
val shExecutable: String = if (isWindows && gitSh.exists()) gitSh.absolutePath else "sh"

val buildRustImageEngine by tasks.registering(Exec::class) {
    group = "build"
    description = "Builds the Rust image engine for Android ABIs."
    workingDir = repositoryRoot
    commandLine(
        shExecutable,
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

    signingConfigs {
        create("release") {
            val keyAliasProp: String? = keystoreProperties.getProperty("keyAlias")
            val keyPasswordProp: String? = keystoreProperties.getProperty("keyPassword")
            val storeFileProp: String? = keystoreProperties.getProperty("storeFile")
            val storePasswordProp: String? = keystoreProperties.getProperty("storePassword")

            if (storeFileProp != null && keyAliasProp != null && keyPasswordProp != null && storePasswordProp != null) {
                val resolvedStoreFile = file(storeFileProp).takeIf { it.exists() } ?: rootProject.file(storeFileProp)
                keyAlias = keyAliasProp
                keyPassword = keyPasswordProp
                storeFile = resolvedStoreFile
                storePassword = storePasswordProp
            }
        }
    }

    buildTypes {
        release {
            val storeFileProp: String? = keystoreProperties.getProperty("storeFile")
            val hasKeystore = keystorePropertiesFile.exists() &&
                storeFileProp != null &&
                (file(storeFileProp).exists() || rootProject.file(storeFileProp).exists())

            signingConfig = if (hasKeystore) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
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
