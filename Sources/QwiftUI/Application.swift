import Foundation
import QtBridge

/// Qt Application wrapper with a clean, safe Swift API
public final class Application: @unchecked Sendable {
    private var app: SwiftQApplication
    
    /// Initialize with command line arguments
    public init(_ args: [String] = CommandLine.arguments) {
        // SwiftQApplication now handles arguments internally
        // It uses a default "qt-app" argument which is sufficient
        app = SwiftQApplication()
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
    
    /// Quit the application
    public func quit() {
        app.quit()
    }
    
    /// Exit the application with a specific return code
    public func exit(returnCode: Int32) {
        app.exit(returnCode)
    }
    
    /// Schedule application exit after a delay to allow event processing to complete
    /// This is safer than calling exit() directly from within event handlers
    public func scheduleExit(returnCode: Int32 = 0, delayMs: Int32 = 1) {
        app.scheduleExit(returnCode, delayMs)
    }
    
    /// Force quit the application, closing all widgets first
    public func forceQuit() {
        app.forceQuit()
    }
    
    /// Process pending Qt events
    public func processEvents() {
        app.processEvents()
    }
    
    /// Schedule a closure to run after a delay (in milliseconds)
    /// This is essential for running tests after the event loop starts
    public func scheduleExecution(after delayMs: Int32, _ closure: @escaping () -> Void) {
        // Create a wrapper that holds the closure
        let wrapper = ClosureWrapper(closure: closure)
        let context = Unmanaged.passRetained(wrapper)
        
        // Define the C function callback
        let callback: @convention(c) (UnsafeMutableRawPointer?) -> Void = { contextPtr in
            guard let contextPtr = contextPtr else { return }
            let wrapper = Unmanaged<ClosureWrapper>.fromOpaque(contextPtr).takeRetainedValue()
            wrapper.closure()
        }
        
        // Schedule the callback
        app.scheduleCallback(delayMs, callback, context.toOpaque())
    }
    
    /// Static method to schedule exit without needing an instance reference
    /// This is useful from within callbacks to avoid concurrent access issues
    public static func scheduleStaticExit(returnCode: Int32 = 0, delayMs: Int32 = 1) {
        SwiftQApplication.staticScheduleExit(returnCode, delayMs)
    }
    
    /// Static method to quit the application
    public static func staticQuit() {
        SwiftQApplication.staticQuit()
    }
    
    /// Force immediate application termination
    /// Use this for test runners where normal quit doesn't exit the event loop
    public static func forceExit(returnCode: Int32 = 0) -> Never {
        SwiftQApplication.staticForceExit(returnCode)
        fatalError("Should never reach here - forceExit terminates the process")
    }
}

// Helper class to wrap Swift closures for C callbacks
private final class ClosureWrapper {
    let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
}