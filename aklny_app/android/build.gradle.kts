// your_flutter_project/android/build.gradle.kts (Project-level)

// This block defines plugins available to the entire project.
plugins {
    // Standard Android Gradle Plugin for building Android apps
    id("com.android.application") version "8.7.3" apply false
    // FIX: Updated Kotlin version to 2.1.0 to resolve conflict
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false

    // Add the dependency for the Google services Gradle plugin here.
    // 'apply false' means it's declared here but applied in app-level build.gradle.kts
    id("com.google.gms.google-services") version "4.4.1" apply false

    // Flutter's own Gradle plugin
    id("dev.flutter.flutter-gradle-plugin") apply false
}

// This block defines repositories for all projects in the build.
allprojects {
    repositories {
        google()      // Google's Maven repository
        mavenCentral() // Maven Central repository
    }
}

// Configuration for custom build directories (keep as is if this is part of your setup)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    // Ensures that the ':app' module is evaluated before other subprojects if needed
    project.evaluationDependsOn(":app")
}

// Task to clean build directories
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
