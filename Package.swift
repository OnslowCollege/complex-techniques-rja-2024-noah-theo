// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OCProgram",
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url: "https://github.com/pvieito/PythonKit.git", from: ("0.3.1")),
        .package(url: "https://github.com/OnslowCollege/OCGUI.git", from: ("0.0.6"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "OCProgram",
            dependencies: [
                // .product(name: "package", package: "package")
                .product(name: "PythonKit", package: "PythonKit"),
                .product(name: "OCGUI", package: "OCGUI")
            ],
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        )
    ]
)