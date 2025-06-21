// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "qwiftui",
    platforms: [
        .macOS(.v15),
    ],
    targets: [
        .executableTarget(
            name: "QtHelloSwift",
            dependencies: ["CQtWrapper"]
        ),
        .target(
            name: "CQtWrapper",
            publicHeadersPath: "include",
            cxxSettings: {
#if os(macOS)
                return [
                    .headerSearchPath("include"),
                    .define("QT_NO_KEYWORDS"),
                    .unsafeFlags([
                        "-fPIC",
                        "-std=c++17",
                        "-F/opt/homebrew/Cellar/qt/6.9.0/lib",
                        "-I/opt/homebrew/Cellar/qt/6.9.0/include",
                        "-I/opt/homebrew/Cellar/qt/6.9.0/include/QtCore",
                        "-I/opt/homebrew/Cellar/qt/6.9.0/include/QtWidgets",
                        "-I/opt/homebrew/Cellar/qt/6.9.0/include/QtGui",
                        "-I/opt/homebrew/Cellar/qt/6.9.0/include/QtNetwork",
                        "-I/opt/homebrew/Cellar/qt/6.9.0/include/QtPrintSupport"
                    ])
                ]
#else // Linux
                return [
                    .headerSearchPath("include"),
                    .define("QT_NO_KEYWORDS"),
                    .unsafeFlags([
                        "-fPIC",
                        "-std=c++17",
                        "-I/usr/include/qt6",
                        "-I/usr/include/qt6/QtCore",
                        "-I/usr/include/qt6/QtWidgets",
                        "-I/usr/include/qt6/QtGui",
                        "-I/usr/include/qt6/QtNetwork",
                        "-I/usr/include/qt6/QtPrintSupport"
                    ])
                ]
#endif
            }(),
            linkerSettings: {
#if os(macOS)
                return [
                    .unsafeFlags([
                        "-F/opt/homebrew/Cellar/qt/6.9.0/lib",
                        "-framework", "QtCore",
                        "-framework", "QtWidgets",
                        "-framework", "QtGui",
                        "-framework", "QtNetwork",
                        "-framework", "QtPrintSupport"
                    ])
                ]
#else // Linux
                return [
                    .linkedLibrary("Qt6Core"),
                    .linkedLibrary("Qt6Widgets"),
                    .linkedLibrary("Qt6Gui"),
                    .linkedLibrary("Qt6Network"),
                    .linkedLibrary("Qt6PrintSupport")
                ]
#endif
            }()
        ),
    ]
)

// Ensure QtWidgets and QtCore are included for QLineEdit/QCheckBox
