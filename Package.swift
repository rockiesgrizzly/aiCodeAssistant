// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AICodeAssistant",
    platforms: [
        .macOS(.v15) // Requires macOS Sequoia or later for FoundationModels
    ],
    products: [
        .executable(name: "aic", targets: ["aic"])
    ],
    dependencies: [],
    targets: [
        // This is the executable target.
        // It depends on our library to do the actual work.
        .executableTarget(
            name: "aic",
            dependencies: ["AICodeAssistant"],
            path: "Sources/aic"
        ),
        
        // This is the library target containing all the core logic.
        .target(
            name: "AICodeAssistant",
            dependencies: [],
            path: "Sources/AICodeAssistant"
        )
    ]
)

