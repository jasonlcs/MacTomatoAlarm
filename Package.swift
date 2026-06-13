// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacTomatoAlarm",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "MacTomatoAlarm",
            path: "Sources/MacTomatoAlarm"
        )
    ]
)
