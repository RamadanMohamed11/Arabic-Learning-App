import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.ramadan.arabic_learning_app"
    compileSdk = 36  // Required by plugins (audioplayers, path_provider, shared_preferences, speech_to_text)
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.ramadan.arabic_learning_app"
        minSdk = flutter.minSdkVersion  // Android 5.0 - covers 99%+ of devices
        targetSdk = 36  // Match compileSdk for plugin compatibility
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Enable multidex for better compatibility
        multiDexEnabled = true
        
        // Support for different screen densities
        resConfigs("ar", "en")  // Only include Arabic and English resources
        
        // Note: ABI filters removed to support --split-per-abi builds
        // Flutter handles architecture splitting automatically
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties.getProperty("keyAlias")
            keyPassword = keystoreProperties.getProperty("keyPassword")
            storeFile = keystoreProperties.getProperty("storeFile")?.let { file(it) }
            storePassword = keystoreProperties.getProperty("storePassword")
        }
    }

    buildTypes {
        release {
            // Signing with the release keys
            signingConfig = signingConfigs.getByName("release")
            
            // Enable minify and shrinking for optimization and smaller size (R8/Proguard)
            isMinifyEnabled = true
            isShrinkResources = true
            isDebuggable = false
            
            // Proguard rules for better compatibility and obfuscation mapping
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
        
        debug {
            isDebuggable = true
            isMinifyEnabled = false
            // Removed applicationIdSuffix to avoid package conflicts
        }
    }
    
    // Add packaging options to avoid conflicts
    packagingOptions {
        resources {
            excludes += listOf(
                "META-INF/DEPENDENCIES",
                "META-INF/LICENSE",
                "META-INF/LICENSE.txt",
                "META-INF/NOTICE",
                "META-INF/NOTICE.txt"
            )
        }
    }
}

dependencies {
    // Multidex support for better compatibility
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}
