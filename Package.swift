// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Credify",
    defaultLocalization: "en",
    platforms: [.iOS(.v10)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Credify",
            targets: ["Credify"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.4.0"),
        // https://github.com/airbnb/lottie-ios
        // https://www.swiftbysundell.com/articles/managing-dependencies-using-the-swift-package-manager/
        .package(name: "Lottie", url: "https://github.com/airbnb/lottie-ios.git", .exact("3.1.9")),
        .package(name: "SDWebImage", url: "https://github.com/SDWebImage/SDWebImage.git", .exact("5.1.0")),
    ],
    targets: [
        .target(
            name: "Credify",
            dependencies: ["Alamofire", "Lottie", "SDWebImage"],
            path: "Credify",
            resources: [
                .process("Credify/Credify.docc"),
                .copy("Credify/Fonts"),
                .copy("Credify/Views/LoadingView/credify-loading.json")
            ]
        ),
        .testTarget(
            name: "CredifyTests",
            dependencies: ["Credify", "Alamofire", "Lottie", "SDWebImage"],
            path: "CredifyTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)
