import Foundation
import QtBridge

/// The base view type in QwiftUI.
///
/// Widget is the Swift wrapper for Qt's QWidget, providing the foundation
/// for all user interface elements. Use Widget directly for custom containers
/// or as a base class for specialized controls.
///
/// ## Creating Widgets
///
/// Create a top-level window:
/// ```swift
/// let window = Widget()
/// window.setWindowTitle("My App")
/// window.show()
/// ```
///
/// Create a child widget:
/// ```swift
/// let container = Widget(parent: window)
/// ```
///
public class Widget {
    /// The underlying Qt widget handle.
    /// Named 'qtWidget' to maintain consistency while being clear about its purpose.
    internal var qtWidget: SwiftQWidget
    
    /// Creates a new widget with an optional parent.
    ///
    /// - Parameter parent: The parent widget. If nil, creates a top-level widget.
    public init(parent: Widget? = nil) {
        if let parent = parent {
            // Pass parent's widget as pointer
            var parentWidget = parent.qtWidget
            qtWidget = SwiftQWidget(&parentWidget)
        } else {
            qtWidget = SwiftQWidget()
        }
    }
    
    /// Initialize with existing Qt widget.
    /// Internal use only for bridging Qt objects.
    internal init(qtWidget: SwiftQWidget) {
        self.qtWidget = qtWidget
    }
    
    /// Shows the widget and makes it visible on screen.
    public func show() {
        qtWidget.show()
    }
    
    /// Hides the widget from view.
    public func hide() {
        qtWidget.hide()
    }
    
    /// Sets the window title for top-level widgets.
    ///
    /// This property only affects widgets that are shown as windows.
    /// Child widgets ignore this property.
    ///
    /// - Parameter title: The title to display in the window's title bar
    public func setWindowTitle(_ title: String) {
        qtWidget.setWindowTitle(std.string(title))
    }
    
    /// Resizes the widget to the specified dimensions.
    ///
    /// - Parameters:
    ///   - width: The new width in pixels
    ///   - height: The new height in pixels
    public func resize(width: Int, height: Int) {
        qtWidget.resize(Int32(width), Int32(height))
    }
    
    /// Moves the widget to the specified position.
    ///
    /// For child widgets, the position is relative to the parent.
    /// For top-level widgets, the position is in screen coordinates.
    ///
    /// - Parameters:
    ///   - x: The horizontal position in pixels
    ///   - y: The vertical position in pixels
    public func move(x: Int, y: Int) {
        qtWidget.move(Int32(x), Int32(y))
    }
}

// MARK: - Convenience Extensions

public extension Widget {
    /// Sets both position and size in a single call.
    ///
    /// - Parameters:
    ///   - x: The horizontal position
    ///   - y: The vertical position
    ///   - width: The width
    ///   - height: The height
    /// - Returns: Self for method chaining
    @discardableResult
    func frame(x: Int, y: Int, width: Int, height: Int) -> Self {
        move(x: x, y: y)
        resize(width: width, height: height)
        return self
    }
    
    /// Centers the widget on screen.
    /// Only works for top-level widgets.
    ///
    /// - Returns: Self for method chaining
    @discardableResult
    func center() -> Self {
        // This would require screen geometry info from Qt
        // For now, just return self
        return self
    }
}