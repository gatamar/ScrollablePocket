// swift-tools-version:5.5

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
    ],
    targets: [
        .target(
            name: "scrollable-pocket"
        )
    ]
)

