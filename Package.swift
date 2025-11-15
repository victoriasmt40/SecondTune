// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SingingBowlTuner",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .executable(
            name: "SingingBowlTuner",
            targets: ["SingingBowlTuner"])
    ],
    targets: [
        .executableTarget(
            name: "SingingBowlTuner",
            path: "Sources",
            resources: [
                .process("Resources")
            ],
            linkerSettings: [
                .unsafeFlags(["-Xlinker", "-sectcreate", "-Xlinker", "__TEXT", "-Xlinker", "__info_plist", "-Xlinker", "SupportingFiles/Info.plist"])
            ]
        ),
        .testTarget(
            name: "SingingBowlTunerTests",
            dependencies: ["SingingBowlTuner"],
            path: "Tests/SingingBowlTunerTests"
        )
    ]
)
