import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)

    afterEvaluate {
        val project = this
        if (project.hasProperty("android")) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            if (android.namespace == null) {
                val manifestFile = project.file("src/main/AndroidManifest.xml")
                if (manifestFile.exists()) {
                    val manifestContents = manifestFile.readText()
                    val packageMatch = Regex("package=\"([^\"]+)\"").find(manifestContents)
                    if (packageMatch != null) {
                        android.namespace = packageMatch.groupValues[1]
                    }
                }
            }
            
            // Force compileSdk and targetSdk for all plugins to ensure 16KB compatibility
            android.compileSdkVersion(36)
            android.ndkVersion = "28.2.13676358"
            android.defaultConfig {
                targetSdkVersion(36)
            }
            
            // Force 16KB page alignment for all shared libraries in plugins
            android.packagingOptions {
                jniLibs {
                    useLegacyPackaging = false
                }
            }
            
            // Fix for Inconsistent JVM-target compatibility
            if (project.name != "app") {
                android.compileOptions {
                    sourceCompatibility = JavaVersion.VERSION_17
                    targetCompatibility = JavaVersion.VERSION_17
                }
            }
        }
    }

    // Fix for Inconsistent JVM-target compatibility for Kotlin
    if (project.name != "app") {
        tasks.withType<KotlinCompile>().configureEach {
            kotlinOptions {
                jvmTarget = "17"
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}