// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "FraudForce",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(
            name: "FraudForce",
            targets: [
                "FraudForce",
            ]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "FraudForce",
            path: "FraudForce.xcframework"
        ),
    ]
)
