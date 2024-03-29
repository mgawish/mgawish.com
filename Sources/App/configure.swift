import FluentPostgreSQL
import Vapor
import Leaf
import Authentication
import GoogleAnalyticsProvider
import MailCore

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    // Register middleware
    var middlewares = MiddlewareConfig()
    middlewares.use(ErrorMiddleware.self)
    middlewares.use(FileMiddleware.self)
    middlewares.use(SessionsMiddleware.self)
    services.register(middlewares)

    // Configure DB
    let databaseConfig: PostgreSQLDatabaseConfig
    if let url = Environment.get("DATABASE_URL") {
        databaseConfig = PostgreSQLDatabaseConfig(url: url, transport: PostgreSQLConnection.TransportConfig.unverifiedTLS)!
    } else if env == .testing {
        databaseConfig = PostgreSQLDatabaseConfig(hostname: "localhost",
                                                  port: 5433,
                                                  username: "aku-test",
                                                  database: "aku-test",
                                                  password: "password")
    } else {
        databaseConfig = PostgreSQLDatabaseConfig(hostname: "localhost",
                                                  port: 5432,
                                                  username: "aku",
                                                  database: "aku",
                                                  password: "password")
    }
    

    // Register the configured SQLite database to the database config.
    let database = PostgreSQLDatabase(config: databaseConfig)
    var databases = DatabasesConfig()
    databases.add(database: database, as: .psql)
    services.register(databases)

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: DatabaseIdentifier<User.Database>.psql)
    migrations.add(model: Blog.self, database: DatabaseIdentifier<Blog.Database>.psql)
    migrations.add(model: Tag.self, database: DatabaseIdentifier<Tag.Database>.psql)
    migrations.add(model: BlogTagPivot.self, database: DatabaseIdentifier<BlogTagPivot.Database>.psql)
    
    migrations.add(migration: AdminUserMigration.self, database: DatabaseIdentifier<AdminUserMigration.Database>.psql)
    migrations.add(migration: BlogMigration.self, database: DatabaseIdentifier<AdminUserMigration.Database>.psql)
    migrations.add(migration: UniqueSlugMigration.self, database: DatabaseIdentifier<UniqueSlugMigration.Database>.psql)
    
    services.register(migrations)
    
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
    
    try services.register(LeafProvider())
    config.prefer(LeafRenderer.self, for: ViewRenderer.self)
    
    try services.register(AuthenticationProvider())
    config.prefer(MemoryKeyedCache.self, for: KeyedCache.self)
    
    services.register { container -> LeafTagConfig in
    var config = LeafTagConfig.default()
    config.use(Raw(), as: "raw")
        return config
    }
    
    if let googleAnalyticsKey = Environment.get("GOOGLE_ANALYTICS_KEY") {
        let config = GoogleAnalyticsConfig(trackingID: googleAnalyticsKey)
        services.register(config)
        try services.register(GoogleAnalyticsProvider())
    }
    
    if let sendgridKey = Environment.get("SENDGRID_KEY") {
        try Mailer(config: Mailer.Config.sendGrid(key: sendgridKey),
        registerOn: &services)
    }
    
}
