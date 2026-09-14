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
}
subprojects {
    project.evaluationDependsOn(":app")
}

// FlutterFire (firebase_analytics / crashlytics / app_check) ship Kotlin-only
// Android sources. Some plugin build.gradle files skip applying kotlin-android
// depending on AGP / builtInKotlin flags, which leaves
// FlutterFirebaseAnalyticsPlugin off the app compile classpath.
// Force KGP onto Android library plugins so those classes are compiled.
subprojects {
    pluginManager.withPlugin("com.android.library") {
        if (!pluginManager.hasPlugin("org.jetbrains.kotlin.android") &&
            !pluginManager.hasPlugin("kotlin-android")
        ) {
            pluginManager.apply("org.jetbrains.kotlin.android")
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
