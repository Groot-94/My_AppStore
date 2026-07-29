import ProjectDescription
import ProjectDescriptionHelpers

// Search: Impl → AppDetailInterface + Persistence(RecentSearchStore).
let project = Project.feature(
    name: "Search",
    implDependencies: [
        .featureInterface("AppDetail"),
        .persistence,
    ]
)
