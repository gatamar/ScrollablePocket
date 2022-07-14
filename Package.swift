// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "scrollable_pocket",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "scrollable_pocket",
            targets: ["scrollable-pocket"]
        )
    ]
)
