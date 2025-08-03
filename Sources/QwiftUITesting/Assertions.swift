// ABOUTME: Test assertion helpers for QwiftUI widget testing
// ABOUTME: Provides convenient assertion methods for common widget properties

import Foundation
import QwiftUI
import QtBridge

/// Assertion helpers for QwiftUI testing.
///
/// These functions provide convenient assertions for common widget properties
/// and states. They integrate with XCTest-style assertions when available.
public enum QwiftUIAssert {
    
    /// Assert that a widget is visible
    ///
    /// - Parameters:
    ///   - widget: The widget to check
    ///   - message: Optional failure message
    ///   - file: Source file (automatically captured)
    ///   - line: Source line (automatically captured)
    public static func assertVisible(
        _ widget: any QtWidget,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let isVisible = testAssertIsVisible(widget.getBridgeWidget())
        if !isVisible {
            let msg = message.isEmpty ? "Widget is not visible" : message
            assertionFailure(msg, file: file, line: line)
        }
    }
    
    /// Assert that a widget is hidden
    ///
    /// - Parameters:
    ///   - widget: The widget to check
    ///   - message: Optional failure message
    ///   - file: Source file (automatically captured)
    ///   - line: Source line (automatically captured)
    public static func assertHidden(
        _ widget: any QtWidget,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let isHidden = testAssertIsHidden(widget.getBridgeWidget())
        if !isHidden {
            let msg = message.isEmpty ? "Widget is not hidden" : message
            assertionFailure(msg, file: file, line: line)
        }
    }
    
    /// Assert that a widget is enabled
    ///
    /// - Parameters:
    ///   - widget: The widget to check
    ///   - message: Optional failure message
    ///   - file: Source file (automatically captured)
    ///   - line: Source line (automatically captured)
    public static func assertEnabled(
        _ widget: any QtWidget,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let isEnabled = testAssertIsEnabled(widget.getBridgeWidget())
        if !isEnabled {
            let msg = message.isEmpty ? "Widget is not enabled" : message
            assertionFailure(msg, file: file, line: line)
        }
    }
    
    /// Assert that a widget is disabled
    ///
    /// - Parameters:
    ///   - widget: The widget to check
    ///   - message: Optional failure message
    ///   - file: Source file (automatically captured)
    ///   - line: Source line (automatically captured)
    public static func assertDisabled(
        _ widget: any QtWidget,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let isEnabled = testAssertIsEnabled(widget.getBridgeWidget())
        if isEnabled {
            let msg = message.isEmpty ? "Widget is not disabled" : message
            assertionFailure(msg, file: file, line: line)
        }
    }
    
    /// Assert that a widget has focus
    ///
    /// - Parameters:
    ///   - widget: The widget to check
    ///   - message: Optional failure message
    ///   - file: Source file (automatically captured)
    ///   - line: Source line (automatically captured)
    public static func assertHasFocus(
        _ widget: any QtWidget,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let hasFocus = testAssertHasFocus(widget.getBridgeWidget())
        if !hasFocus {
            let msg = message.isEmpty ? "Widget does not have focus" : message
            assertionFailure(msg, file: file, line: line)
        }
    }
    
    /// Assert that a widget has specific text content
    ///
    /// - Parameters:
    ///   - widget: The widget to check
    ///   - expected: The expected text
    ///   - message: Optional failure message
    ///   - file: Source file (automatically captured)
    ///   - line: Source line (automatically captured)
    public static func assertText(
        _ widget: any QtWidget,
        equals expected: String,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var bridgeWidget = widget.getBridgeWidget().pointee
        let stdText = testAssertGetText(&bridgeWidget)
        let actualText = String(stdText)
        if actualText != expected {
            let msg = message.isEmpty 
                ? "Text mismatch. Expected: '\(expected)', Got: '\(actualText)'"
                : message
            assertionFailure(msg, file: file, line: line)
        }
    }
    
    /// Assert that a widget contains specific text
    ///
    /// - Parameters:
    ///   - widget: The widget to check
    ///   - substring: The text that should be contained
    ///   - message: Optional failure message
    ///   - file: Source file (automatically captured)
    ///   - line: Source line (automatically captured)
    public static func assertTextContains(
        _ widget: any QtWidget,
        _ substring: String,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        var bridgeWidget = widget.getBridgeWidget().pointee
        let stdText = testAssertGetText(&bridgeWidget)
        let actualText = String(stdText)
        if !actualText.contains(substring) {
            let msg = message.isEmpty 
                ? "Text '\(actualText)' does not contain '\(substring)'"
                : message
            assertionFailure(msg, file: file, line: line)
        }
    }
    
    /// Assert that a widget has a specific size
    ///
    /// - Parameters:
    ///   - widget: The widget to check
    ///   - width: Expected width
    ///   - height: Expected height
    ///   - message: Optional failure message
    ///   - file: Source file (automatically captured)
    ///   - line: Source line (automatically captured)
    public static func assertSize(
        _ widget: any QtWidget,
        width: Int,
        height: Int,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let hasSize = testAssertHasSize(widget.getBridgeWidget(), Int32(width), Int32(height))
        if !hasSize {
            let msg = message.isEmpty 
                ? "Widget size mismatch. Expected: \(width)x\(height)"
                : message
            assertionFailure(msg, file: file, line: line)
        }
    }
    
    /// Assert that a widget is at a specific position
    ///
    /// - Parameters:
    ///   - widget: The widget to check
    ///   - x: Expected x coordinate
    ///   - y: Expected y coordinate
    ///   - message: Optional failure message
    ///   - file: Source file (automatically captured)
    ///   - line: Source line (automatically captured)
    public static func assertPosition(
        _ widget: any QtWidget,
        x: Int,
        y: Int,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let hasPosition = testAssertHasPosition(widget.getBridgeWidget(), Int32(x), Int32(y))
        if !hasPosition {
            let msg = message.isEmpty 
                ? "Widget position mismatch. Expected: (\(x), \(y))"
                : message
            assertionFailure(msg, file: file, line: line)
        }
    }
    
    /// Assert that two widgets are the same
    ///
    /// - Parameters:
    ///   - widget1: First widget
    ///   - widget2: Second widget
    ///   - message: Optional failure message
    ///   - file: Source file (automatically captured)
    ///   - line: Source line (automatically captured)
    public static func assertSame(
        _ widget1: any QtWidget,
        _ widget2: any QtWidget,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let areSame = testAssertCompareWidgets(
            widget1.getBridgeWidget(),
            widget2.getBridgeWidget()
        )
        if !areSame {
            let msg = message.isEmpty ? "Widgets are not the same" : message
            assertionFailure(msg, file: file, line: line)
        }
    }
    
    /// Assert that two widgets are different
    ///
    /// - Parameters:
    ///   - widget1: First widget
    ///   - widget2: Second widget
    ///   - message: Optional failure message
    ///   - file: Source file (automatically captured)
    ///   - line: Source line (automatically captured)
    public static func assertDifferent(
        _ widget1: any QtWidget,
        _ widget2: any QtWidget,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let areSame = testAssertCompareWidgets(
            widget1.getBridgeWidget(),
            widget2.getBridgeWidget()
        )
        if areSame {
            let msg = message.isEmpty ? "Widgets are the same" : message
            assertionFailure(msg, file: file, line: line)
        }
    }
}

// MARK: - Convenience Global Functions

/// Assert that a widget is visible
public func assertVisible(_ widget: any QtWidget, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    QwiftUIAssert.assertVisible(widget, message, file: file, line: line)
}

/// Assert that a widget is hidden
public func assertHidden(_ widget: any QtWidget, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    QwiftUIAssert.assertHidden(widget, message, file: file, line: line)
}

/// Assert that a widget is enabled
public func assertEnabled(_ widget: any QtWidget, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    QwiftUIAssert.assertEnabled(widget, message, file: file, line: line)
}

/// Assert that a widget is disabled
public func assertDisabled(_ widget: any QtWidget, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    QwiftUIAssert.assertDisabled(widget, message, file: file, line: line)
}

/// Assert that a widget has focus
public func assertHasFocus(_ widget: any QtWidget, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    QwiftUIAssert.assertHasFocus(widget, message, file: file, line: line)
}

/// Assert widget text equals expected value
public func assertText(_ widget: any QtWidget, equals expected: String, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    QwiftUIAssert.assertText(widget, equals: expected, message, file: file, line: line)
}

/// Assert widget text contains substring
public func assertTextContains(_ widget: any QtWidget, _ substring: String, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    QwiftUIAssert.assertTextContains(widget, substring, message, file: file, line: line)
}