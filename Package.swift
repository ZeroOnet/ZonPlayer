// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ZonPlayer",
    platforms: [.iOS(.v12)],
    products: [
        .library(name: "ZonPlayer", targets: ["ZonPlayer"]),
    ],
    targets: [
        .target(
            name: "ZonPlayer",
            path: "Sources"
        )
    ]
)
