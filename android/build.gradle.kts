buildscript {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://android-sdk.is.com/") }
        maven { url = uri("https://artifact.bytedance.com/repository/pangle/") }
        maven { url = uri("https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea") }
        maven { url = uri("https://artifacts.applovin.com/android") }
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.2")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
        maven { url = uri("https://android-sdk.is.com/") }
        maven { url = uri("https://artifact.bytedance.com/repository/pangle/") }
        maven { url = uri("https://dl-maven-android.mintegral.com/repository/mbridge_android_sdk_oversea") }
        maven { url = uri("https://artifacts.applovin.com/android") }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    if (project.name != "jni" && project.name != "jni_flutter") {
        val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
        project.layout.buildDirectory.value(newSubprojectBuildDir)
    }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
