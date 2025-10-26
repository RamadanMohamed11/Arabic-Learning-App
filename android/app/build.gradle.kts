plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.ramadan.arabic_learning_app"
    compileSdk = 36  // Required by plugins (audioplayers, path_provider, shared_preferences, speech_to_text)
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.ramadan.arabic_learning_app"
        minSdk = flutter.minSdkVersion  // Android 5.0 - covers 99%+ of devices
        targetSdk = 36  // Match compileSdk for plugin compatibility
        versionCode = 1
        versionName = "1.0.0"
        
        // Enable multidex for better compatibility
        multiDexEnabled = true
        
        // Support for different screen densities
        resConfigs("ar", "en")  // Only include Arabic and English resources
        
        // Note: ABI filters removed to support --split-per-abi builds
        // Flutter handles architecture splitting automatically
    }

    buildTypes {
        release {
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
            
            // Disable minify and shrinking for better compatibility
            isMinifyEnabled = false
            isShrinkResources = false
            isDebuggable = false
            
            // Proguard rules for better compatibility
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
