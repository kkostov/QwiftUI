# QwiftUI

This is an experiment to create a Swift UI library based on Qt6. As research, this is a tiny todo application using Swift 6.2 and Qt6 widgets made usable in a safe way (e.g. using Swift's concurrency)

Some constraints I set for this experiment:

- No additional tooling or build systems - let's try to use only swift features.
- No additional dependencies - let's see if the effort required to write out the wrappers is acceptable for a standalone, dependency-free package.

Currently it builds on macOS and Linux, but the goal is to focus more on Linux and Windows as target platforms where SwiftUI/AppKit are not available.

## Targets

- `QwiftUI` - the library
- `QtBridge` - bridging between Qt6 and Swift based on C++ interop, abstraction for event handling and other facilities to make using widgets easier and safer.
- `QwiftUITest` - testing helpers to wrap around Qt Test
- `QtDemo` - simple demo app to run experiments, this will be refactored to depend on QwiftUI.
- `Qt6AppBackend` - target in which we try to implement a Qt backend for SwiftCrossUI https://github.com/stackotter/swift-cross-ui/blob/main/Sources/SwiftCrossUI/Backend/AppBackend.swift

## Setup

This is hardcoded for now:

The Package.swift is configured to expect the qt6 headers in a location used by Homebrew (brew install qt): `opt/homebrew/Cellar/qt/6.9.1` for macOS

On Linux, the path is set to `/usr/include/qt6` which is the default on Fedora.

## Resources

- [Qt Documentation](https://doc.qt.io/qt-6/)
- [Qt Widgets](https://doc.qt.io/qt-6/qtwidgets-index.html)
- [Qt Test](https://doc.qt.io/qt-6/qttest-index.html)

## License

This project is licensed under the BSD 3-Clause License. See the [LICENSE](LICENSE) file for details.
