// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Credify",
    platforms: [.iOS(.v10)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Credify",
            targets: ["Credify"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.4.0")
    ],
    targets: [
        .target(
            name: "Credify",
            dependencies: ["Alamofire"],
            path: "Credify",
            resources: [.process("Credify/Credify.docc"), .copy("Credify/Fonts")]),
//        .testTarget(
//            name: "CredifyTests",
////            dependencies: ["Credify"],
//            path: "Credify"),
    ],
    swiftLanguageVersions: [.v5]
)
