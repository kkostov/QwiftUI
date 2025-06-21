import Foundation
import QtBridge

/// Qt Application wrapper with a clean, safe Swift API
public final class Application {
    private var app: SwiftQApplication
    
    /// Initialize with command line arguments
    public init(_ args: [String] = CommandLine.arguments) {
        // Build arguments in a clean way
        var builder = ArgumentsBuilder()
        for arg in args {
            builder.addArg(std.string(arg))
        }
        
        // Create Qt application fully initialized
        app = SwiftQApplication(builder)
    }
    
    /// Initialize with default arguments
    public convenience init() {
        self.init(CommandLine.arguments)
    }
    
    /// Run the Qt event loop
    @discardableResult
    public func exec() -> Int32 {
        return app.exec()
    }
    
    /// Process pending events
    public func processEvents() {
        app.processEvents()
    }
}