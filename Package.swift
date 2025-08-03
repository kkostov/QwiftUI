// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "qwiftui",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [
        .package(url: "https://github.com/stackotter/swift-cross-ui", branch: "main")
    ],
    targets: [
        .target(
            name: "QtBridge",
            sources: [
                "QtBridge.cpp",
                "QtTestBridge.cpp",
            ],
            publicHeadersPath: "include",
            cxxSettings: [
                .unsafeFlags([
                    "-std=c++17",
                    "-I/opt/homebrew/Cellar/qt/6.9.1/include",
                    "-I/opt/homebrew/Cellar/qt/6.9.1/include/QtCore",
                    "-I/opt/homebrew/Cellar/qt/6.9.1/include/QtWidgets",
                    "-I/opt/homebrew/Cellar/qt/6.9.1/include/QtGui",
                    "-I/opt/homebrew/Cellar/qt/6.9.1/include/QtTest",
                    "-F/opt/homebrew/Cellar/qt/6.9.1/lib",
                ])
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
                .defaultIsolation(MainActor.self),
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-F/opt/homebrew/Cellar/qt/6.9.1/lib",
                    "-framework", "QtCore",
                    "-framework", "QtWidgets",
                    "-framework", "QtGui",
                    "-framework", "QtTest",
                ])
            ]
        ),
        .target(
            name: "QwiftUI",  // Swift API for Qt6 widgets
            dependencies: [
                "QtBridge"
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
                .defaultIsolation(MainActor.self),
            ]),
        .executableTarget(
            name: "QtDemo",
            dependencies: ["QwiftUI"],
            swiftSettings: [
                .interoperabilityMode(.Cxx)
            ]
        ),
        .target(
            name: "QwiftUITesting",  // Testing framework for QwiftUI
            dependencies: [
                "QtBridge",
                "QwiftUI",
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
                .defaultIsolation(MainActor.self),
            ],
            linkerSettings: [
                .unsafeFlags([
                    "-F/opt/homebrew/Cellar/qt/6.9.1/lib",
                    "-framework", "QtTest",  // Link Qt Test framework
                ])
            ]
        ),
        .target(
            name: "Qt6AppBackend",  // SwiftCrossUI backend implementation using QwiftUI
            dependencies: [
                "QwiftUI",
                .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
                // Removed defaultIsolation to avoid Swift 6 concurrency conflicts
                // Using minimal concurrency checking for SwiftCrossUI compatibility
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=minimal"]),
            ]
        ),
        .executableTarget(
            name: "Qt6AppBackendDemo",
            dependencies: [
                "Qt6AppBackend",
                .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
            ],
            swiftSettings: [
                .interoperabilityMode(.Cxx),
                .unsafeFlags(["-Xfrontend", "-strict-concurrency=minimal"]),
            ]
        ),
    ]
)
