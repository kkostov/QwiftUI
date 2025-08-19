// ABOUTME: Widget query and discovery functionality for UI testing
// ABOUTME: Provides methods to find and filter widgets in the widget tree

import Foundation
import QwiftUI
import QtBridge

/// Provides widget query and discovery functionality for testing.
///
/// Use WidgetQuery to find widgets in your application during tests.
/// Supports finding by object name, type, and custom predicates.
///
/// Example:
/// ```swift
/// let query = WidgetQuery()
/// let button = query.widget(named: "submitButton") as? Button
/// let labels = query.widgets(ofType: Label.self)
/// ```
public class WidgetQuery {
    
    private var finder: SwiftQTestFinder
    private var rootWidget: Widget?
    
    /// Initialize a new widget query with an optional root widget
    ///
    /// - Parameter root: The root widget to search from. If nil, searches all top-level widgets.
    public init(root: Widget? = nil) {
        self.rootWidget = root
        if let root = root {
            self.finder = SwiftQTestFinder(root.getBridgeWidget())
        } else {
            self.finder = SwiftQTestFinder()
        }
    }
    
    deinit {
        // C++ destructor will be called automatically
    }
    
    /// Set the root widget for searches
    ///
    /// - Parameter root: The new root widget, or nil to search all top-level widgets
    public func setRoot(_ root: Widget?) {
        self.rootWidget = root
        if let root = root {
            var bridgeWidget = root.getBridgeWidget().pointee
            finder.setRoot(&bridgeWidget)
        } else {
            // Can't pass nil directly to C++ method
            // Create a finder without root instead
            self.finder = SwiftQTestFinder()
        }
    }
    
    /// Find a widget by its object name
    ///
    /// - Parameter name: The object name to search for
    /// - Returns: The first widget with the given name, or nil if not found
    public func widget(named name: String) -> Widget? {
        let stdString = std.string(name)
        if let foundPtr = finder.findByObjectName(stdString) {
            return Widget(fromBridge: foundPtr, ownsPointer: false)
        }
        return nil
    }
    
    /// Find all widgets with the given object name
    ///
    /// - Parameter name: The object name to search for
    /// - Returns: An array of widgets with the given name
    public func widgets(named name: String) -> [Widget] {
        let stdString = std.string(name)
        let count = finder.countByObjectName(stdString)
        var results: [Widget] = []
        
        for i in 0..<count {
            if let widgetPtr = finder.getByObjectNameAt(stdString, Int32(i)) {
                results.append(Widget(fromBridge: widgetPtr, ownsPointer: false))
            }
        }
        
        return results
    }
    
    /// Find widgets by their class name (Qt meta-object class name)
    ///
    /// - Parameter className: The Qt class name (e.g., "QPushButton", "QLabel")
    /// - Returns: An array of widgets of the given class
    public func widgets(byClassName className: String) -> [Widget] {
        let stdString = std.string(className)
        let count = finder.countByClassName(stdString)
        var results: [Widget] = []
        
        for i in 0..<count {
            if let widgetPtr = finder.getByClassNameAt(stdString, Int32(i)) {
                results.append(Widget(fromBridge: widgetPtr, ownsPointer: false))
            }
        }
        
        return results
    }
    
    /// Find all child widgets of a parent
    ///
    /// - Parameter parent: The parent widget
    /// - Returns: An array of child widgets
    public func children(of parent: Widget) -> [Widget] {
        var parentWidget = parent.getBridgeWidget().pointee
        let count = finder.countChildren(&parentWidget)
        var results: [Widget] = []
        
        for i in 0..<count {
            if let widgetPtr = finder.getChildAt(&parentWidget, Int32(i)) {
                results.append(Widget(fromBridge: widgetPtr, ownsPointer: false))
            }
        }
        
        return results
    }
    
    /// Wait for a widget with the given name to appear
    ///
    /// - Parameters:
    ///   - name: The object name to wait for
    ///   - timeout: Maximum time to wait in seconds
    /// - Returns: The widget if found within timeout, nil otherwise
    public func waitForWidget(named name: String, timeout: TimeInterval = 5.0) -> Widget? {
        let timeoutMs = Int32(timeout * 1000)
        let stdString = std.string(name)
        if let foundPtr = finder.waitForWidget(stdString, timeoutMs) {
            return Widget(fromBridge: foundPtr, ownsPointer: false)
        }
        return nil
    }
    
    /// Find widgets matching a custom predicate
    ///
    /// This method finds all widgets and filters them using the provided predicate.
    /// Note: This may be slow for large widget hierarchies.
    ///
    /// - Parameter predicate: A closure that returns true for widgets to include
    /// - Returns: An array of widgets matching the predicate
    public func widgets(matching predicate: (Widget) -> Bool) -> [Widget] {
        // Get all widgets by searching for QWidget base class
        let allWidgets = widgets(byClassName: "QWidget")
        return allWidgets.filter(predicate)
    }
    
    /// Find the first widget of a specific type
    ///
    /// - Parameter type: The widget type to search for
    /// - Returns: The first widget of the given type, or nil if not found
    public func widget<T: QtWidget>(ofType type: T.Type) -> T? {
        // This is a simplified implementation
        // In a real implementation, we'd need type information from Qt
        
        // Try to find by common Qt class names
        let className: String
        switch type {
        case is Button.Type:
            className = "QPushButton"
        case is Label.Type:
            className = "QLabel"
        case is LineEdit.Type:
            className = "QLineEdit"
        case is TextEdit.Type:
            className = "QTextEdit"
        case is CheckBox.Type:
            className = "QCheckBox"
        case is RadioButton.Type:
            className = "QRadioButton"
        case is ComboBox.Type:
            className = "QComboBox"
        case is GroupBox.Type:
            className = "QGroupBox"
        default:
            className = "QWidget"
        }
        
        let widgets = self.widgets(byClassName: className)
        return widgets.first as? T
    }
    
    /// Find all widgets of a specific type
    ///
    /// - Parameter type: The widget type to search for
    /// - Returns: An array of widgets of the given type
    public func widgets<T: QtWidget>(ofType type: T.Type) -> [T] {
        // Similar to widget(ofType:) but returns all matches
        let className: String
        switch type {
        case is Button.Type:
            className = "QPushButton"
        case is Label.Type:
            className = "QLabel"
        case is LineEdit.Type:
            className = "QLineEdit"
        case is TextEdit.Type:
            className = "QTextEdit"
        case is CheckBox.Type:
            className = "QCheckBox"
        case is RadioButton.Type:
            className = "QRadioButton"
        case is ComboBox.Type:
            className = "QComboBox"
        case is GroupBox.Type:
            className = "QGroupBox"
        default:
            className = "QWidget"
        }
        
        let widgets = self.widgets(byClassName: className)
        return widgets.compactMap { $0 as? T }
    }
}