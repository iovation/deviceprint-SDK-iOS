// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "DeviceRiskSDK",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "FraudForce",
            targets: ["FraudForce"]
        ),
    ],
    targets: [
        .binaryTarget(
            name: "FraudForce",
            path: "FraudForce.xcframework"
        ),
    ]
)
