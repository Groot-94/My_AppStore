import ProjectDescription
import ProjectDescriptionHelpers

// Games: Impl → AppDetailInterface + SeeAllInterface.
let project = Project.feature(
    name: "Games",
    implDependencies: [
        .featureInterface("AppDetail"),
        .featureInterface("SeeAll"),
    ]
)
