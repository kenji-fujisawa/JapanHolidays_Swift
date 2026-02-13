// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "JapanHolidays",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "JapanHolidays",
            targets: ["JapanHolidays", "JapanHolidaysObjC"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/AliSoftware/OHHTTPStubs?tab=readme-ov-file", from: "9.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "JapanHolidays"
        ),
        .target(
            name: "JapanHolidaysObjC",
            dependencies: ["JapanHolidays"]
        ),
        .testTarget(
            name: "JapanHolidaysTests",
            dependencies: [
                "JapanHolidays",
                .product(name: "OHHTTPStubs", package: "OHHTTPStubs?tab=readme-ov-file"),
                .product(name: "OHHTTPStubsSwift", package: "OHHTTPStubs?tab=readme-ov-file")
            ]
        ),
    ]
)
