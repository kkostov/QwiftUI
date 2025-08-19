import Foundation
import QtBridge

/// Simplified Qt Application wrapper
/// Beautiful, ergonomic API with zero unsafe code
public final class SimpleApp {
    public var app: SwiftQApplication
    
    /// Initialize with command line arguments automatically
    public init() {
        // SwiftQApplication now handles arguments internally
        app = SwiftQApplication()
    }
    
    /// Run the application
    @discardableResult
    public func exec() -> Int32 {
        return app.exec()
    }
}