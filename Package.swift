// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "Linktree",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "Linktree", targets: ["Linktree"])
    ],
    targets: [
        .target(name: "Linktree", path: "Sources")
    ]
)
