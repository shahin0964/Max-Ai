import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.max.ai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }

    defaultConfig {
        applicationId = "com.max.ai"
        minSdk = 26
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val keyProperties = Properties()
            val keyPropertiesFile = file("key.properties")
            val rootKeyPropertiesFile = rootProject.file("key.properties")
            if (keyPropertiesFile.exists()) {
                keyProperties.load(FileInputStream(keyPropertiesFile))
            } else if (rootKeyPropertiesFile.exists()) {
                keyProperties.load(FileInputStream(rootKeyPropertiesFile))
            }

            val customStorePath = keyProperties.getProperty("storeFile")
            val keystoreFile = if (customStorePath != null && file(customStorePath).exists()) {
                file(customStorePath)
            } else if (customStorePath != null && rootProject.file(customStorePath).exists()) {
                rootProject.file(customStorePath)
            } else if (file("release.jks").exists()) {
                file("release.jks")
            } else if (file("../release.jks").exists()) {
                file("../release.jks")
            } else if (file("../../release.jks").exists()) {
                file("../../release.jks")
            } else {
                null
            }

            if (keystoreFile != null) {
                storeFile = keystoreFile
                val rawStorePass = keyProperties.getProperty("storePassword")
                    ?: (project.findProperty("KEYSTORE_PASSWORD") as? String)
                    ?: System.getenv("KEYSTORE_PASSWORD")
                    ?: "AbdurRahman321@@"

                val rawKeyPass = keyProperties.getProperty("keyPassword")
                    ?: (project.findProperty("KEY_PASSWORD") as? String)
                    ?: System.getenv("KEY_PASSWORD")
                    ?: "AbdurRahman321@@"

                val rawAlias = keyProperties.getProperty("keyAlias")
                    ?: (project.findProperty("KEY_ALIAS") as? String)
                    ?: System.getenv("KEY_ALIAS")
                    ?: "maxai"

                storePassword = rawStorePass
                keyAlias = rawAlias
                keyPassword = rawKeyPass
                enableV1Signing = true
                enableV2Signing = true
                println("==> Configured release signing with keystore: ${keystoreFile.absolutePath}, alias: $rawAlias, V1/V2 enabled")
            } else {
                println("==> No release keystore file found! Fallback will be used.")
            }
        }
    }

    buildTypes {
        release {
            val releaseSigning = signingConfigs.findByName("release")
            if (releaseSigning?.storeFile != null) {
                signingConfig = releaseSigning
            } else {
                signingConfig = signingConfigs.getByName("debug")
            }
        }
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

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("androidx.core:core-ktx:1.13.1")
}
