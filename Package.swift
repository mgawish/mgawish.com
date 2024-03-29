// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "aku",
    products: [
        .library(name: "aku", targets: ["App"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor/leaf.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0"),
        .package(url: "https://github.com/PoissonBallon/google-analytics-provider.git", from: "0.0.1"),
        .package(url: "https://github.com/LiveUI/MailCore.git", .branch("master"))
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentPostgreSQL",
                                            "Vapor",
                                            "Leaf",
                                            "Authentication",
                                            "GoogleAnalyticsProvider",
                                            "MailCore"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)

