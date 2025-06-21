// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "qwiftui",
    platforms: [
        .macOS(.v15)
    ],
    dependencies: [],
    targets: [
        .target(
            name: "QtBridge",
            sources: ["QtBridge.cpp"],
            publicHeadersPath: "include",
            cxxSettings: [
                .define("QT_NO_KEYWORDS"),
                .unsafeFlags([
                    "-std=c++17",
                    "-I/opt/homebrew/Cellar/qt/6.9.1/include",
                    "-I/opt/homebrew/Cellar/qt/6.9.1/include/QtCore",
                    "-I/opt/homebrew/Cellar/qt/6.9.1/include/QtWidgets",
                    "-I/opt/homebrew/Cellar/qt/6.9.1/include/QtGui",
                    "-F/opt/homebrew/Cellar/qt/6.9.1/lib",
                ]),
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
    ]
)

// Ensure QtWidgets and QtCore are included for QLineEdit/QCheckBox
// Ensure new widget/container management header is included
// (Already included via publicHeadersPath: "include")
// No further changes needed unless new header files are created.
