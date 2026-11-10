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
            val keystoreFile = if (file("release.jks").exists()) {
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
                val rawStorePass = (project.findProperty("KEYSTORE_PASSWORD") as? String)
                    ?: System.getenv("KEYSTORE_PASSWORD")
                    ?: "AbdurRahman321@@"

                val rawKeyPass = (project.findProperty("KEY_PASSWORD") as? String)
                    ?: System.getenv("KEY_PASSWORD")
                    ?: "AbdurRahman321@@"

                val rawAlias = (project.findProperty("KEY_ALIAS") as? String)
                    ?: System.getenv("KEY_ALIAS")
                    ?: "maxai"

                storePassword = rawStorePass
                keyAlias = rawAlias
                keyPassword = rawKeyPass
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
}
