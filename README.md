# QwiftUI

This is an experiment to create a Swift UI library based on Qt6. As research, this is a tiny todo application using Swift 6.1 and Qt6 widgets made usable in a safe way (e.g. using Swift's concurrency)

The end-game, is to provide for a complete implementation of a SwiftCrossUI's AppBackend https://github.com/stackotter/swift-cross-ui/blob/main/Sources/SwiftCrossUI/Backend/AppBackend.swift


Some constraints I set for this experiment:

- No additional tooling or build systems - let's try to use only swift features.
- No additional dependencies - let's see if the effort required to write out the wrappers is acceptable for a standalone, dependency-free package.

Currently it builds on macOS and Linux, but the goal is to focus more on Linux and Windows as target platforms where SwiftUI/AppKit are not available.

## Targets

- QwiftUI - the library we intend to build
- QtHelloSwift - simple todo app to run experiments, this will be refactored to depend on QwiftUI.
- CQtWrapper - a target wrapping Qt6 APIs and making them available to QwiftUI

## Setup

This is hardcoded for now:

The Package.swift is configured to expect the qt6 headers in a location used by Homebrew (brew install qt): `opt/homebrew/Cellar/qt/6.9.0` for macOS

On Linux, the path is set to `/usr/include/qt6` which is the default on Fedora.

## License

This project is licensed under the BSD 3-Clause License. See the [LICENSE](LICENSE) file for details.