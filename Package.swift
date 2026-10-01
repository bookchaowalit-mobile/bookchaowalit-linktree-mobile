// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Linktree",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "LinktreeCore", targets: ["LinktreeCore"]),
        .library(name: "LinktreeUI", targets: ["LinktreeUI"]),
    ],
    targets: [
        // Foundation-only domain logic; no SwiftUI so it also builds on Linux.
        .target(name: "LinktreeCore", path: "Sources/LinktreeCore"),
        .target(name: "LinktreeUI", dependencies: ["LinktreeCore"], path: "Sources/LinktreeUI"),
        .testTarget(name: "LinktreeCoreTests", dependencies: ["LinktreeCore"], path: "Tests/LinktreeCoreTests"),
    ]
)
