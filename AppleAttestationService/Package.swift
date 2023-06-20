// swift-tools-version:5.8
import PackageDescription

let package = Package(
    name: "AppleAttestationService",
    platforms: [
       .macOS(.v12)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.76.0"),
        .package(url: "https://github.com/apple/swift-crypto.git", from: "2.5.0"),
        .package(url: "https://github.com/valpackett/SwiftCBOR.git", from: "0.4.6"),
        .package(url: "https://github.com/apple/swift-certificates.git", from: "0.6.0"),
        .package(url: "https://github.com/vapor/redis.git", from: "4.0.0"),
        .package(url: "https://github.com/Flight-School/AnyCodable.git", from: "0.6.7"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "SwiftCBOR", package: "SwiftCBOR"),
                .product(name: "X509", package: "swift-certificates"),
                .product(name: "Redis", package: "redis"),
                .product(name: "AnyCodable", package: "AnyCodable"),
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://www.swift.org/server/guides/building.html#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
