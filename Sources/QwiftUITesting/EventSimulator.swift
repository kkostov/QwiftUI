// ABOUTME: Event simulation for UI testing
// ABOUTME: Provides methods to simulate user interactions like clicks, typing, and keyboard shortcuts

import Foundation
import QwiftUI
import QtBridge

/// Mouse button options for event simulation
public enum MouseButton: Int32 {
    case left = 1
    case right = 2
    case middle = 4
}

/// Keyboard key options for event simulation
public enum Key {
    case tab
    case `return`
    case escape
    case space
    case backspace
    case delete
    case up
    case down
    case left
    case right
    case character(Character)
    
    var keyCode: Int32 {
        switch self {
        case .tab: return 0x01000001
        case .return: return 0x01000004
        case .escape: return 0x01000000
        case .space: return 0x20
        case .backspace: return 0x01000003
        case .delete: return 0x01000007
        case .up: return 0x01000013
        case .down: return 0x01000015
        case .left: return 0x01000012
        case .right: return 0x01000014
        case .character(let char):
            // For ASCII characters, use their value directly
            let scalar = char.unicodeScalars.first!
            return Int32(scalar.value)
        }
    }
}

/// Keyboard modifier options
public struct KeyModifiers: OptionSet {
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    public static let none = KeyModifiers(rawValue: 0)
    public static let shift = KeyModifiers(rawValue: 0x02000000)
    public static let control = KeyModifiers(rawValue: 0x04000000)
    public static let alt = KeyModifiers(rawValue: 0x08000000)
    public static let meta = KeyModifiers(rawValue: 0x10000000)
    public static let command = meta  // Alias for macOS users
}

/// Simulates user events for testing QwiftUI applications.
///
/// EventSimulator provides methods to simulate mouse clicks, keyboard input,
/// and other user interactions during tests.
///
/// Example:
/// ```swift
/// let simulator = EventSimulator()
/// simulator.click(button)
/// simulator.typeText("Hello", into: textField)
/// simulator.keyPress(.return)
/// ```
public class EventSimulator {
    
    private var simulator: SwiftQTestSimulator
    
    /// Initialize a new event simulator
    public init() {
        // Create test simulator using C++ class directly
        self.simulator = SwiftQTestSimulator()
    }
    
    deinit {
        // C++ destructor will be called automatically
    }
    
    // MARK: - Mouse Events
    
    /// Simulate a mouse click on a widget
    ///
    /// - Parameters:
    ///   - widget: The widget to click
    ///   - button: The mouse button to use (default: .left)
    ///   - x: Optional x coordinate within the widget (default: center)
    ///   - y: Optional y coordinate within the widget (default: center)
    public func click(_ widget: any QtWidget, button: MouseButton = .left, x: Int? = nil, y: Int? = nil) {
        var bridgeWidget = widget.getBridgeWidget().pointee
        if let x = x, let y = y {
            simulator.mouseClick(&bridgeWidget, button.rawValue, Int32(x), Int32(y))
        } else {
            simulator.mouseClickCenter(&bridgeWidget, button.rawValue)
        }
    }
    
    /// Simulate a double-click on a widget
    ///
    /// - Parameters:
    ///   - widget: The widget to double-click
    ///   - button: The mouse button to use (default: .left)
    ///   - x: Optional x coordinate within the widget (default: center)
    ///   - y: Optional y coordinate within the widget (default: center)
    public func doubleClick(_ widget: any QtWidget, button: MouseButton = .left, x: Int? = nil, y: Int? = nil) {
        var bridgeWidget = widget.getBridgeWidget().pointee
        if let x = x, let y = y {
            simulator.mouseDClick(&bridgeWidget, button.rawValue, Int32(x), Int32(y))
        } else {
            simulator.mouseDClickCenter(&bridgeWidget, button.rawValue)
        }
    }
    
    /// Move the mouse to a position within a widget
    ///
    /// - Parameters:
    ///   - x: The x coordinate within the widget
    ///   - y: The y coordinate within the widget
    ///   - widget: The widget to move the mouse over
    ///   - delay: Optional delay for the movement in milliseconds
    public func moveMouse(to x: Int, _ y: Int, in widget: any QtWidget, delay: Int = 0) {
        var bridgeWidget = widget.getBridgeWidget().pointee
        simulator.mouseMove(&bridgeWidget, Int32(x), Int32(y), Int32(delay))
    }
    
    /// Simulate a drag operation
    ///
    /// - Parameters:
    ///   - fromX: Starting x coordinate
    ///   - fromY: Starting y coordinate
    ///   - toX: Ending x coordinate
    ///   - toY: Ending y coordinate
    ///   - widget: The widget to perform the drag in
    public func drag(from fromX: Int, _ fromY: Int, to toX: Int, _ toY: Int, in widget: any QtWidget) {
        var bridgeWidget = widget.getBridgeWidget().pointee
        simulator.mouseDrag(
            &bridgeWidget,
            Int32(fromX), Int32(fromY),
            Int32(toX), Int32(toY)
        )
    }
    
    /// Press the mouse button down
    ///
    /// - Parameters:
    ///   - widget: The widget to press on
    ///   - button: The mouse button to press
    ///   - x: Optional x coordinate (default: center)
    ///   - y: Optional y coordinate (default: center)
    public func mousePress(_ widget: any QtWidget, button: MouseButton = .left, x: Int? = nil, y: Int? = nil) {
        var bridgeWidget = widget.getBridgeWidget().pointee
        if let x = x, let y = y {
            simulator.mousePress(&bridgeWidget, button.rawValue, Int32(x), Int32(y))
        } else {
            simulator.mousePressCenter(&bridgeWidget, button.rawValue)
        }
    }
    
    /// Release the mouse button
    ///
    /// - Parameters:
    ///   - widget: The widget to release on
    ///   - button: The mouse button to release
    ///   - x: Optional x coordinate (default: center)
    ///   - y: Optional y coordinate (default: center)
    public func mouseRelease(_ widget: any QtWidget, button: MouseButton = .left, x: Int? = nil, y: Int? = nil) {
        var bridgeWidget = widget.getBridgeWidget().pointee
        if let x = x, let y = y {
            simulator.mouseRelease(&bridgeWidget, button.rawValue, Int32(x), Int32(y))
        } else {
            simulator.mouseReleaseCenter(&bridgeWidget, button.rawValue)
        }
    }
    
    // MARK: - Keyboard Events
    
    /// Simulate a key press
    ///
    /// - Parameters:
    ///   - key: The key to press
    ///   - modifiers: Optional keyboard modifiers
    ///   - widget: Optional widget to send the key to (default: focused widget)
    public func keyPress(_ key: Key, modifiers: KeyModifiers = [], widget: (any QtWidget)? = nil) {
        guard let widget = widget else { return }
        var bridgeWidget = widget.getBridgeWidget().pointee
        
        if modifiers.isEmpty {
            simulator.keyClickNoMod(&bridgeWidget, key.keyCode)
        } else {
            simulator.keyClick(&bridgeWidget, key.keyCode, modifiers.rawValue, -1)
        }
    }
    
    /// Type text into a widget
    ///
    /// - Parameters:
    ///   - text: The text to type
    ///   - widget: The widget to type into
    ///   - modifiers: Optional keyboard modifiers
    ///   - delay: Delay between keystrokes in milliseconds
    public func typeText(_ text: String, into widget: any QtWidget, modifiers: KeyModifiers = [], delay: Int = 0) {
        var bridgeWidget = widget.getBridgeWidget().pointee
        let stdString = std.string(text)
        
        if modifiers.isEmpty && delay == 0 {
            simulator.keyClicksNoMod(&bridgeWidget, stdString)
        } else {
            simulator.keyClicks(&bridgeWidget, stdString, modifiers.rawValue, Int32(delay))
        }
    }
    
    /// Simulate a keyboard shortcut
    ///
    /// - Parameters:
    ///   - keys: The key sequence string (e.g., "Ctrl+C", "Cmd+V")
    ///   - widget: Optional widget to send the shortcut to
    public func keyboardShortcut(_ keys: String, widget: (any QtWidget)? = nil) {
        guard let widget = widget else { return }
        var bridgeWidget = widget.getBridgeWidget().pointee
        let stdString = std.string(keys)
        simulator.keySequence(&bridgeWidget, stdString)
    }
    
    // MARK: - Focus Management
    
    /// Set focus to a widget
    ///
    /// - Parameter widget: The widget to focus
    public func setFocus(_ widget: any QtWidget) {
        var bridgeWidget = widget.getBridgeWidget().pointee
        simulator.setFocus(&bridgeWidget)
    }
    
    /// Check if a widget has focus
    ///
    /// - Parameter widget: The widget to check
    /// - Returns: True if the widget has focus
    public func hasFocus(_ widget: any QtWidget) -> Bool {
        var bridgeWidget = widget.getBridgeWidget().pointee
        return simulator.hasFocus(&bridgeWidget)
    }
    
    // MARK: - Timing and Events
    
    /// Wait for the specified duration
    ///
    /// - Parameter milliseconds: Time to wait in milliseconds
    public func wait(_ milliseconds: Int) {
        simulator.wait(Int32(milliseconds))
    }
    
    /// Process Qt events for the specified duration
    ///
    /// - Parameter milliseconds: Time to process events (0 = process pending events only)
    public func processEvents(_ milliseconds: Int = 0) {
        if milliseconds == 0 {
            simulator.processEventsDefault()
        } else {
            simulator.processEvents(Int32(milliseconds))
        }
    }
}