import Fluent
import FluentSQLiteDriver
import GraphQLKit
import GraphiQLVapor
import Vapor

extension Application {
    @DependencyInjected private static var _databaseInfo: (database: DatabaseConfigurationFactory, id: DatabaseID)?
    private static var databaseInfo: (database: DatabaseConfigurationFactory, id: DatabaseID) = {
        _databaseInfo ??
        (database: .sqlite(.memory), id: .sqlite)
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
