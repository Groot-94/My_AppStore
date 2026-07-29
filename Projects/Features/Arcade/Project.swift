import ProjectDescription
import ProjectDescriptionHelpers

// Arcade: Impl → AppDetailInterface.
let project = Project.feature(
    name: "Arcade",
    implDependencies: [.featureInterface("AppDetail")]
)
