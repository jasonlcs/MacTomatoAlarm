// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MacTomatoAlarm",
    platforms: [.macOS(.v14)],
    targets: [
        .executableTarget(
            name: "MacTomatoAlarm",
            path: "Sources/MacTomatoAlarm",
            // These are bundled manually by build-app.sh, not by SwiftPM.
            exclude: [
                "Info.plist",
                "Resources/icon.icns",
            ]
        )
    ]
)
