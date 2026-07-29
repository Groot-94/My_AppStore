import ProjectDescription
import ProjectDescriptionHelpers

// Today: Impl → AppDetailInterface.
let project = Project.feature(
    name: "Today",
    implDependencies: [.featureInterface("AppDetail")]
)
