// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "OnmyoTCG",
    platforms: [
        .iOS(.v17),
        .macOS(.v13)
    ],
    products: [
        .library(name: "OnmyoTCGCore", targets: ["OnmyoTCGCore"])
    ],
    targets: [
        .target(
            name: "OnmyoTCGCore",
            path: "OnmyoTCG",
            exclude: ["App", "ViewModels", "Views", "Resources"]
        ),
        .testTarget(
            name: "OnmyoTCGCoreTests",
            dependencies: ["OnmyoTCGCore"],
            path: "OnmyoTCGTests"
        )
    ]
)
