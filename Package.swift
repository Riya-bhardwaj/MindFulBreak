// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MindfulBreak",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "MindfulBreak",
            path: "Sources"
        )
    ]
)
