// swift-tools-version:5.10
import PackageDescription


let package = Package(
    name: "Terrier",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "Terrier-Swift",
            targets: ["Terrier-Swift"])
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Terrier-Swift",
            dependencies: ["CTerrier"],
            path: "Sources/Terrier-Bridge"
        ),
        .target(
            name: "CTerrier",
            dependencies: [
                .target(name: "Terrier", condition: .when(platforms: [.iOS])),
                .target(name: "WhirlyGlobe", condition: .when(platforms: [.iOS]))],
            path: "Sources/CTerrier"
        ),
        .binaryTarget(
            name: "Terrier",
            path: "libraries/Terrier.xcframework"
        ),
        .binaryTarget(
            name: "WhirlyGlobe",
            path: "libraries/WhirlyGlobe.xcframework"
        ),
    ]
)
