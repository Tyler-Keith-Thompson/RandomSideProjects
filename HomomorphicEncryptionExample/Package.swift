// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "HomomorphicEncryptionExample",
    platforms: [
       .macOS(.v14)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.99.3"),
        // 🗄 An ORM for SQL and NoSQL databases.
        .package(url: "https://github.com/vapor/fluent.git", from: "4.9.0"),
        // 🪶 Fluent driver for SQLite.
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.6.0"),
        // 🔵 Non-blocking, event-driven networking for Swift. Used for custom executors
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.65.0"),
        // metrics
        .package(url: "https://github.com/apple/swift-metrics.git", "2.0.0" ..< "3.0.0"),
        .package(url: "https://github.com/apple/swift-metrics-extras.git", from: "0.3.1"),
        // tracer
        .package(url: "https://github.com/apple/swift-distributed-tracing.git", from: "1.1.1"),
        // logging
        .package(url: "https://github.com/apple/swift-log.git", from: "1.6.1"),
        // Fluent task management
        .package(url: "https://github.com/Tyler-Keith-Thompson/Afluent.git", from: "0.6.2"),
        // dependency injection
        .package(url: "git@github.com:Tyler-Keith-Thompson/DependencyInjection.git", from: "0.0.7"),
        // Cryptography
        .package(url: "https://github.com/apple/swift-homomorphic-encryption.git", revision: "90e4ce9"),
        
        // test dependencies
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.10.0"),
    ],
    targets: [
        .executableTarget(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "NIOCore", package: "swift-nio"),
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "SystemMetrics", package: "swift-metrics-extras"),
                .product(name: "Metrics", package: "swift-metrics"),
                .product(name: "Tracing", package: "swift-distributed-tracing"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "DependencyInjection", package: "DependencyInjection"),
                .product(name: "Afluent", package: "afluent"),
                .product(name: "HomomorphicEncryption", package: "swift-homomorphic-encryption"),
                .product(name: "PrivateInformationRetrieval", package: "swift-homomorphic-encryption"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                .target(name: "App"),
                .product(name: "XCTVapor", package: "vapor"),
                .product(name: "Testing", package: "swift-testing"),
                .product(name: "HomomorphicEncryption", package: "swift-homomorphic-encryption"),
                .product(name: "PrivateInformationRetrieval", package: "swift-homomorphic-encryption"),
            ],
            swiftSettings: swiftSettings
        )
    ]
)

var swiftSettings: [SwiftSetting] { [
    .enableUpcomingFeature("DisableOutwardActorInference"),
    .enableExperimentalFeature("StrictConcurrency"),
] }
