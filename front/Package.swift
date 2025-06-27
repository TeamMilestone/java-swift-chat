// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "ChatApp",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ChatApp",
            targets: ["ChatApp"]),
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream.git", from: "4.0.6"),
        .package(url: "https://github.com/socketio/socket.io-client-swift", from: "16.0.0")
    ],
    targets: [
        .target(
            name: "ChatApp",
            dependencies: [
                "Starscream",
                .product(name: "SocketIO", package: "socket.io-client-swift")
            ],
            path: "Sources"
        )
    ]
)