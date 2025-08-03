// ABOUTME: Base test case class for QwiftUI testing framework
// ABOUTME: Provides lifecycle management and core testing infrastructure

import Foundation
import QwiftUI
import QtBridge

/// Base class for QwiftUI UI tests.
///
/// Inherit from this class to create UI tests for QwiftUI applications.
/// The class automatically manages the Qt application lifecycle and provides
/// access to testing utilities.
///
/// Example:
/// ```swift
/// final class MyWidgetTests: QwiftUITestCase {
///     func testButtonClick() {
///         let button = Button("Click Me")
///         button.show()
///         
///         let simulator = EventSimulator()
///         simulator.click(button)
///         
///         // Assertions...
///     }
/// }
/// ```
open class QwiftUITestCase {
    
    /// The application instance for testing
    public private(set) var app: Application!
    
    /// The root widget query for finding widgets
    public private(set) var query: WidgetQuery!
    
    /// The event simulator for user interactions
    public private(set) var simulator: EventSimulator!
    
    /// Initialize a new test case
    public init() {
        // Will be set up in setUp()
    }
    
    /// Set up the test environment before each test
    open func setUp() {
        // Initialize Qt application
        app = Application()
        
        // Initialize testing utilities
        query = WidgetQuery()
        simulator = EventSimulator()
        
        // Ensure Qt Test framework is initialized
        if let test = createQTest() {
            test.pointee.initialize()
        }
    }
    
    /// Clean up after each test
    open func tearDown() {
        // Process any remaining events
        simulator.processEvents()
        
        // Clean up
        query = nil
        simulator = nil
        app = nil
        
        // Clean up Qt Test
        if let test = createQTest() {
            test.pointee.cleanup()
        }
    }
    
    /// Wait for a condition to become true
    ///
    /// - Parameters:
    ///   - condition: A closure that returns true when the wait should end
    ///   - timeout: Maximum time to wait in seconds
    ///   - interval: How often to check the condition in milliseconds
    /// - Returns: True if condition was met, false if timed out
    @discardableResult
    public func waitFor(
        _ condition: () -> Bool,
        timeout: TimeInterval = 5.0,
        interval: Int = 100
    ) -> Bool {
        let timeoutMs = Int(timeout * 1000)
        var elapsed = 0
        
        while elapsed < timeoutMs {
            if condition() {
                return true
            }
            
            simulator.wait(interval)
            elapsed += interval
        }
        
        return false
    }
    
    /// Process Qt events for the specified duration
    ///
    /// - Parameter milliseconds: Time to process events in milliseconds
    public func processEvents(_ milliseconds: Int = 0) {
        simulator.processEvents(milliseconds)
    }
    
    /// Wait for the specified duration
    ///
    /// - Parameter milliseconds: Time to wait in milliseconds
    public func wait(_ milliseconds: Int) {
        simulator.wait(milliseconds)
    }
}