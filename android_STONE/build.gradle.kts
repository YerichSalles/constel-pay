allprojects {
    repositories {
        google()
        mavenCentral()
        // SDK da Stone: Maven privado (o token faz parte da URL) e JitPack para
        // as dependencias transitivas de impressao.
        maven { url = uri("https://packagecloud.io/priv/0a81fdc0ae50cb28b539adc9bc131e69beaa8a032cd7df70/stone/pos-android/maven2") }
        maven { url = uri("https://jitpack.io") }
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
