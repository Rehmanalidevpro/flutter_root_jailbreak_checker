// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "flutter_root_jailbreak_checker",
    platforms: [
        .iOS("13.0")
    ],
    products: [
        .library(name: "flutter-root-jailbreak-checker", targets: ["flutter_root_jailbreak_checker"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        .target(
            name: "flutter_root_jailbreak_checker",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ],
            resources: [
                .process("PrivacyInfo.xcprivacy")
            ]
        )
    ]
)
