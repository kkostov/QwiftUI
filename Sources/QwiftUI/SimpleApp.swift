import Foundation
import QtBridge

/// Simplified Qt Application wrapper
/// Beautiful, ergonomic API with zero unsafe code
public final class SimpleApp {
    public var app: SwiftQApplication
    
    /// Initialize with command line arguments automatically
    public init() {
        // Build arguments from command line
        var builder = ArgumentsBuilder()
        for arg in CommandLine.arguments {
            builder.addArg(std.string(arg))
        }
        
        // Create fully initialized Qt application
        app = SwiftQApplication(builder)
    }
    
    /// Run the application
    @discardableResult
    public func exec() -> Int32 {
        return app.exec()
    }
}