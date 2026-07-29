import ProjectDescription
import ProjectDescriptionHelpers

// Search: Impl → AppDetailInterface + Persistence(RecentSearchStore).
// SearchTests → Search(@testable) + Persistence + ITunesKit(DTO 픽스처) + CoreKit.
let project = Project.feature(
    name: "Search",
    implDependencies: [
        .featureInterface("AppDetail"),
        .persistence,
    ],
    tests: true,
    testDependencies: [
        .persistence,
        .iTunesKit,
        .coreKit,
    ],
    testHasResources: true
)
