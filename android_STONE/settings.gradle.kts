pluginManagement {
    val flutterSdkPath =
        run {
            val properties = java.util.Properties()
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }

    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    // Preso no AGP 8.x: no AGP 9 o Kotlin embutido e obrigatorio, e os plugins
    // que o app usa (flutter_plugin_android_lifecycle, mobile_scanner,
    // package_info_plus) ainda aplicam o Kotlin Gradle Plugin, que o AGP 9
    // recusa. Ja o file_picker 11 deixa de aplicar o KGP quando ve AGP 9 e
    // espera o Kotlin embutido — as duas exigencias nao coexistem. Subir para
    // o 9.x so quando esses plugins migrarem.
    id("com.android.application") version "8.13.2" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
}

include(":app")
