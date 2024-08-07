import NIOSSL
import Fluent
import FluentSQLiteDriver
import Vapor
import DependencyInjection

extension Application {
    public func configure() async throws {
        @Injected(Container.databaseInfo) var databaseInfo
        databases.use(databaseInfo.database, as: databaseInfo.id)

        migrations.add(CreateTodo())

        // register routes
        try routes()
    }
}

extension Container {
    static let databaseInfo = Factory {
//      .sqlite(.file("db.sqlite")), id: .sqlite
        (database: .sqlite(.memory), id: .sqlite) as (database: DatabaseConfigurationFactory, id: DatabaseID)
    }
}
