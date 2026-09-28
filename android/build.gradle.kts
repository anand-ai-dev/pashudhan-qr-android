// 🔥 Custom build directory setup
val newBuildDir =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()

rootProject.layout.buildDirectory.set(newBuildDir)

// 🔥 Apply same build directory to subprojects
subprojects {
    val newSubprojectBuildDir = newBuildDir.dir(project.name)
    project.layout.buildDirectory.set(newSubprojectBuildDir)
}

// 🔥 Ensure app module builds first
subprojects {
    project.evaluationDependsOn(":app")
}

// 🔥 Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
