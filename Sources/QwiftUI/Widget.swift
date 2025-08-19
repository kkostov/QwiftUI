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
@MainActor
public class Widget: QtWidget {
    /// The underlying Qt widget handle stored as a pointer.
    /// This ensures the pointer remains valid throughout the widget's lifetime.
    /// Marked as nonisolated(unsafe) since pointer operations are inherently unsafe
    nonisolated(unsafe) internal var qtWidget: UnsafeMutablePointer<SwiftQWidget>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        return qtWidget
    }
    
    
    /// Creates a new widget with an optional parent.
    ///
    /// - Parameter parent: The parent widget. If nil, creates a top-level widget.
    public init(parent: (any QtWidget)? = nil) {
        // Create the C++ object directly using factory function
        // We can't use Swift's initialize(to:) because SwiftQWidget isn't safely copyable
        if let parent = parent {
            qtWidget = createWidget(parent.getBridgeWidget())
        } else {
            qtWidget = createWidget(nil)
        }
    }
    
    /// Initialize with an existing Qt widget pointer.
    /// Used for bridging Qt objects from C++ code.
    /// - Parameter qtWidgetPtr: A pointer to an existing SwiftQWidget
    /// - Parameter ownsPointer: Whether this Swift object owns the C++ pointer and should deallocate it
    public init(fromBridge qtWidgetPtr: UnsafeMutablePointer<SwiftQWidget>, ownsPointer: Bool = true) {
        // We always take ownership of the pointer now since we're using factory functions
        self.qtWidget = qtWidgetPtr
    }
    
    deinit {
        // CallbackManager automatically handles callback cleanup
        CallbackManager.shared.remove(for: self)
        
        // Since we're using factory functions that allocate with new,
        // we need to delete the C++ object
        deleteQWidget(qtWidget)
    }
    
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtWidget.pointee.show()
    }
    
    public func hide() {
        qtWidget.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtWidget.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtWidget.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtWidget.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtWidget.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtWidget.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtWidget.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtWidget.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtWidget.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtWidget.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtWidget.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtWidget.pointee.setParent(nil)
        }
    }
    
    // MARK: - Window Management
    
    /// Sets a widget attribute
    public func setAttribute(_ attribute: WidgetAttribute, on: Bool = true) {
        qtWidget.pointee.setAttribute(Int32(attribute.rawValue), on)
    }
    
    /// Sets the minimum size for the widget
    public func setMinimumSize(width: Int, height: Int) {
        qtWidget.pointee.setMinimumSize(Int32(width), Int32(height))
    }
    
    /// Raises the widget to the front
    public func raise() {
        qtWidget.pointee.raise()
    }
    
    /// Activates the widget's window
    public func activateWindow() {
        qtWidget.pointee.activateWindow()
    }
    
    /// Gets the width of the widget
    public var width: Int {
        Int(qtWidget.pointee.width())
    }
    
    /// Gets the height of the widget
    public var height: Int {
        Int(qtWidget.pointee.height())
    }
    
    /// Gets the children of this widget
    public var children: [any QtWidget] {
        // TODO: Implement proper child tracking
        // For now, return empty array
        []
    }
    
    // MARK: - Event Handling
    
    /// Sets a handler for resize events
    /// - Parameter handler: Closure called when the widget is resized with the new size (width, height)
    public func onResize(_ handler: @escaping (Int, Int) -> Void) {
        let eventCallback = CallbackHelper.createEventCallback(context: self) { info in
            if info.type == QtEventType.Resize {
                handler(Int(info.intValue), Int(info.intValue2))
            }
        }
        qtWidget.pointee.setEventHandler(QtEventType.Resize, eventCallback.pointee)
    }
    
    /// Sets a handler for mouse press events
    /// - Parameter handler: Closure called when the mouse is pressed with the position (x, y)
    public func onMousePress(_ handler: @escaping (Int, Int) -> Void) {
        let eventCallback = CallbackHelper.createEventCallback(context: self) { info in
            if info.type == QtEventType.MousePress {
                handler(Int(info.intValue), Int(info.intValue2))
            }
        }
        qtWidget.pointee.setEventHandler(QtEventType.MousePress, eventCallback.pointee)
    }
    
    /// Sets a handler for mouse release events
    /// - Parameter handler: Closure called when the mouse is released with the position (x, y)  
    public func onMouseRelease(_ handler: @escaping (Int, Int) -> Void) {
        let eventCallback = CallbackHelper.createEventCallback(context: self) { info in
            if info.type == QtEventType.MouseRelease {
                handler(Int(info.intValue), Int(info.intValue2))
            }
        }
        qtWidget.pointee.setEventHandler(QtEventType.MouseRelease, eventCallback.pointee)
    }
    
    /// Sets a handler for focus in events
    /// - Parameter handler: Closure called when the widget gains focus
    public func onFocusIn(_ handler: @escaping () -> Void) {
        let eventCallback = CallbackHelper.createEventCallback(context: self) { info in
            if info.type == QtEventType.FocusIn {
                handler()
            }
        }
        qtWidget.pointee.setEventHandler(QtEventType.FocusIn, eventCallback.pointee)
    }
    
    /// Sets a handler for focus out events
    /// - Parameter handler: Closure called when the widget loses focus
    public func onFocusOut(_ handler: @escaping () -> Void) {
        let eventCallback = CallbackHelper.createEventCallback(context: self) { info in
            if info.type == QtEventType.FocusOut {
                handler()
            }
        }
        qtWidget.pointee.setEventHandler(QtEventType.FocusOut, eventCallback.pointee)
    }
}

// MARK: - Widget Attributes

public enum WidgetAttribute: Int {
    case window = 0x00000001  // Qt::WA_Window
    case dialog = 0x00000002  // Qt::WA_Dialog
    case popup = 0x00000004   // Qt::WA_Popup
    case desktop = 0x00000008 // Qt::WA_Desktop
    case x11NetWmWindowTypeDock = 0x0000000a // Qt::WA_X11NetWmWindowTypeDock
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
    public func centerOnScreen() {
        qtWidget.pointee.centerOnScreen()
    }
    
    /// Lowers this widget to the bottom of the parent widget's stack
    public func lower() {
        qtWidget.pointee.lower()
    }
    
    /// Shows the widget maximized
    public func showMaximized() {
        qtWidget.pointee.showMaximized()
    }
    
    /// Shows the widget minimized
    public func showMinimized() {
        qtWidget.pointee.showMinimized()
    }
    
    /// Shows the widget in fullscreen mode
    public func showFullScreen() {
        qtWidget.pointee.showFullScreen()
    }
    
    /// Shows the widget in normal mode (not maximized, minimized, or fullscreen)
    public func showNormal() {
        qtWidget.pointee.showNormal()
    }
    
    /// Closes the widget
    public func close() -> Bool {
        return qtWidget.pointee.close()
    }
    
    /// Updates the widget (triggers a repaint)
    public func update() {
        qtWidget.pointee.update()
    }
    
    
    /// Sets the maximum size of the widget
    ///
    /// - Parameters:
    ///   - width: Maximum width
    ///   - height: Maximum height
    public func setMaximumSize(width: Int, height: Int) {
        qtWidget.pointee.setMaximumSize(Int32(width), Int32(height))
    }
    
    /// Sets the fixed size of the widget (cannot be resized)
    ///
    /// - Parameters:
    ///   - width: Fixed width
    ///   - height: Fixed height
    public func setFixedSize(width: Int, height: Int) {
        qtWidget.pointee.setFixedSize(Int32(width), Int32(height))
    }
    
    
    
    /// The x position of the widget
    public var x: Int {
        Int(qtWidget.pointee.x())
    }
    
    /// The y position of the widget  
    public var y: Int {
        Int(qtWidget.pointee.y())
    }
}