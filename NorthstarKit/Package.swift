// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NorthstarKit",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        .library(name: "NorthstarKit", targets: ["NorthstarKit"]),
    ],
    targets: [
        .target(name: "NorthstarKit"),
    ]
)
