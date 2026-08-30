// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "FraudForce",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "FraudForce",
            targets: ["FraudForce"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "FraudForce",
            path: "FraudForce.xcframework"
        )
    ]
)
