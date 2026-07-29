import ProjectDescription

// Tuist 4.53 관례: 루트 Tuist.swift 에 Config 선언.
let tuist = Tuist(
    project: .tuist(
        generationOptions: .options(
            enforceExplicitDependencies: true
        )
    )
)
