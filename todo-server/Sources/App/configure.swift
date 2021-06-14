import Fluent
import FluentPostgresDriver
import FluentSQLiteDriver
import GraphQLKit
import GraphiQLVapor
import Vapor

// configures your application
extension Application {
    @DependencyInjected private static var _databaseInfo: (database: DatabaseConfigurationFactory, id: DatabaseID)?
    private static var databaseInfo: (database: DatabaseConfigurationFactory, id: DatabaseID) = {
        _databaseInfo ??
        (database: .sqlite(.memory), id: .sqlite)
//        (database: .postgres(
//            hostname: Environment.get("DATABASE_HOST") ?? "localhost",
//            port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? PostgresConfiguration.ianaPortNumber,
//            username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
//            password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
//            database: Environment.get("DATABASE_NAME") ?? "vapor_database"),
//         id: .psql)
    }()

    public func configure() throws {
        databases.use(Self.databaseInfo.database, as: Self.databaseInfo.id)

        register(graphQLSchema: try Schemas.todo, withResolver: TodoResolver())

        migrations.add(CreateTodo())

        try autoMigrate().wait()

        if !environment.isRelease {
            enableGraphiQL()
        }
    }
}
