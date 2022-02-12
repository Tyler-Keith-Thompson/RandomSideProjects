// swift-tools-version:5.4
import PackageDescription

let package = Package(
    name: "todo-server",
    platforms: [
       .macOS(.v10_15)
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor/fluent-sqlite-driver.git", from: "4.0.0"),
        .package(name: "GraphQLKit", url: "https://github.com/alexsteinerde/graphql-kit.git", from: "2.0.0"),
        .package(name: "GraphiQLVapor", url: "https://github.com/alexsteinerde/graphiql-vapor.git", from: "2.0.0"),
        .package(url: "https://github.com/Swinject/Swinject.git", from: "2.7.1"),
    ],
    targets: [
        .target(
            name: "App",
            dependencies: [
                .product(name: "Fluent", package: "fluent"),
                .product(name: "FluentSQLiteDriver", package: "fluent-sqlite-driver"),
                .product(name: "GraphQLKit", package: "GraphQLKit"),
                .product(name: "GraphiQLVapor", package: "GraphiQLVapor"),
                .product(name: "Vapor", package: "vapor"),
                .product(name: "Swinject", package: "Swinject"),
            ],
            swiftSettings: [
                // Enable better optimizations when building in Release configuration. Despite the use of
                // the `.unsafeFlags` construct required by SwiftPM, this flag is recommended for Release
                // builds. See <https://github.com/swift-server/guides/blob/main/docs/building.md#building-for-production> for details.
                .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
            ]
        ),
        .executableTarget(name: "Run", dependencies: [.target(name: "App")]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "Fluent", package: "fluent"),
            .product(name: "GraphQLKit", package: "GraphQLKit"),
            .product(name: "Vapor", package: "vapor"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
