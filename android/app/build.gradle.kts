plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.anape_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.anape_app"
        
        // ML Kit aur Video Compression ke liye 24 recommended hai
        minSdk = 24  
        targetSdk = flutter.targetSdkVersion

        versionCode = flutter.versionCode
        versionName = flutter.versionName

        // IMPORTANT: AI models heavy hote hain, isliye multidex zaroori hai
        multiDexEnabled = true
    }

    buildTypes {
        getByName("release") {
            // Debug signing use ho rahi hai (Sirf testing ke liye)
            signingConfig = signingConfigs.getByName("debug")
            
            // Release build mein unused resources hatane ke liye (Optional)
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Basic Multidex support agar app 64k methods cross kare
    implementation("androidx.multidex:multidex:2.0.1")
}