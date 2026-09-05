// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "flutter_root_jailbreak_checker",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "flutter-root-jailbreak-checker", targets: ["flutter_root_jailbreak_checker"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "flutter_root_jailbreak_checker",
            dependencies: [],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
