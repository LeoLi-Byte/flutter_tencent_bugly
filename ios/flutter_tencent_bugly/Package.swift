// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_tencent_bugly",
    platforms: [
        .iOS("15.0")
    ],
    products: [
        .library(name: "flutter-tencent-bugly", targets: ["flutter_tencent_bugly"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flutter_tencent_bugly",
            dependencies: ["Bugly"],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ],
            linkerSettings: [
                .linkedFramework("SystemConfiguration"),
                .linkedFramework("Security"),
                .linkedLibrary("c++"),
                .linkedLibrary("z")
            ]
        ),
        .binaryTarget(
            name: "Bugly",
            path: "Frameworks/Bugly.xcframework"
        )
    ]
)
