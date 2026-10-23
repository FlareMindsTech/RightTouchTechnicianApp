import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

val googleServicesFile = file("google-services.json")
if (googleServicesFile.exists()) {
    apply(plugin = "com.google.gms.google-services")
}

android {
    namespace = "com.righttouchpartner.app"
    compileSdk = 36
    ndkVersion = "28.2.13676358"
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = "17"
    }
    defaultConfig {
        applicationId = "com.righttouchpartner.app"
        
        minSdk = flutter.minSdkVersion
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        ndk {
            abiFilters.addAll(setOf("armeabi-v7a", "arm64-v8a", "x86_64"))
        }
        externalNativeBuild {
            cmake {
                arguments("-DANDROID_SUPPORT_FLEXIBLE_PAGE_SIZES=ON")
            }
        }
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = rootProject.file("key.properties")
            if (!keystorePropertiesFile.exists()) {
                throw GradleException("Release build failed: key.properties file not found at ${keystorePropertiesFile.absolutePath}")
            }
            val keystoreProperties = Properties()
            keystoreProperties.load(FileInputStream(keystorePropertiesFile))
            
            val keyStoreFilePath = keystoreProperties.getProperty("storeFile") 
                ?: throw GradleException("Release build failed: 'storeFile' property missing in key.properties")
            val resolvedStoreFile = file(keyStoreFilePath)
            if (!resolvedStoreFile.exists()) {
                throw GradleException("Release build failed: keystore file not found at ${resolvedStoreFile.absolutePath}")
            }
            storeFile = resolvedStoreFile
            storePassword = keystoreProperties.getProperty("storePassword") 
                ?: throw GradleException("Release build failed: 'storePassword' missing in key.properties")
            keyAlias = keystoreProperties.getProperty("keyAlias") 
                ?: throw GradleException("Release build failed: 'keyAlias' missing in key.properties")
            keyPassword = keystoreProperties.getProperty("keyPassword") 
                ?: throw GradleException("Release build failed: 'keyPassword' missing in key.properties")
        }
    }
    buildTypes {
        release {
            isMinifyEnabled = true
            isShrinkResources = true  
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
            signingConfig = signingConfigs.getByName("release")
        }
    }

    packaging {
        jniLibs {
            useLegacyPackaging = false
        }
    }
}

flutter {
    source = "../.."
}

configurations.all {
    resolutionStrategy {
        force("androidx.browser:browser:1.8.0")
        force("androidx.activity:activity:1.10.1")
        force("androidx.activity:activity-ktx:1.10.1")
        force("androidx.core:core:1.16.0")
        force("androidx.core:core-ktx:1.16.0")
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    implementation("com.google.android.play:feature-delivery:2.1.0")
    implementation("com.google.android.play:feature-delivery-ktx:2.1.0")
}
