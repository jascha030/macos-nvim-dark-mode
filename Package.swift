// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "InterfaceStyleObserver",
    products: [
        .executable(name: "nvim-dark-mode", targets: ["InterfaceStyleObserver"])
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "InterfaceStyleObserver",
            dependencies: []),
        .testTarget(
            name: "InterfaceStyleObserverTests",
            dependencies: ["InterfaceStyleObserver"]),
    ]
)
