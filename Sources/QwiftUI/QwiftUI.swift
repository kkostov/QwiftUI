/// QwiftUI - A beautiful Swift API for Qt
///
/// QwiftUI provides a SwiftUI-like experience for building Qt applications
/// using Swift 6.2's C++ interoperability features.
///
/// ## Basic Usage
///
/// ```swift
/// import QwiftUI
///
/// let app = SimpleApp()
/// 
/// let window = Widget()
/// window.setWindowTitle("My QwiftUI App")
/// window.resize(width: 800, height: 600)
///
/// let label = Label("Hello, QwiftUI!", parent: window)
/// label.alignment = .center
/// label.frame(x: 0, y: 0, width: 800, height: 600)
///
/// window.show()
/// _ = app.exec()
/// ```

// Re-export all public APIs for convenience
@_exported import QtBridge

// Export our Swift wrappers
// Note: These are already public from their modules,
// but listing them here documents the main API surface