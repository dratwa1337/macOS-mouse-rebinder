// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MouseRebinder",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MouseRebinderApp", targets: ["MouseRebinderApp"])
    ],
    targets: [
        .executableTarget(
            name: "MouseRebinderApp",
            linkerSettings: [
                .linkedFramework("AppKit"),
                .linkedFramework("ApplicationServices"),
                .linkedFramework("SwiftUI")
            ]
        )
    ]
)
