import ProjectDescription
import ProjectDescriptionHelpers

// SeeAll: Impl → AppDetailInterface.
let project = Project.feature(
    name: "SeeAll",
    implDependencies: [.featureInterface("AppDetail")]
)
