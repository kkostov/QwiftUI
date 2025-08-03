// ABOUTME: ScrollView provides a scrollable viewport for content
// ABOUTME: This wraps Qt's QScrollArea for use in Swift applications

import Foundation
import QtBridge

/// A scroll view widget that provides a scrollable viewport for its content.
///
/// ScrollView allows you to display content that is larger than the visible area,
/// providing scroll bars as needed to navigate the content.
///
/// ## Example Usage
///
/// ```swift
/// let scrollView = ScrollView()
/// let content = Widget()
/// content.resize(width: 800, height: 600)
/// scrollView.setContent(content)
/// scrollView.horizontalScrollBarPolicy = .asNeeded
/// ```
@MainActor
public class ScrollView: QtWidget {
    /// Scroll bar display policy
    public enum ScrollBarPolicy: Int {
        case alwaysOff = 0   // Qt::ScrollBarAlwaysOff
        case alwaysOn = 1    // Qt::ScrollBarAlwaysOn
        case asNeeded = 2    // Qt::ScrollBarAsNeeded
    }
    
    /// The underlying Qt scroll area stored as a pointer
    nonisolated(unsafe) internal var qtScrollArea: UnsafeMutablePointer<SwiftQScrollArea>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQScrollArea* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtScrollArea).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The content widget being scrolled
    private(set) public var content: (any QtWidget)?
    
    /// Horizontal scroll bar policy
    public var horizontalScrollBarPolicy: ScrollBarPolicy = .asNeeded {
        didSet {
            qtScrollArea.pointee.setHorizontalScrollBarPolicy(Int32(horizontalScrollBarPolicy.rawValue))
        }
    }
    
    /// Vertical scroll bar policy
    public var verticalScrollBarPolicy: ScrollBarPolicy = .asNeeded {
        didSet {
            qtScrollArea.pointee.setVerticalScrollBarPolicy(Int32(verticalScrollBarPolicy.rawValue))
        }
    }
    
    /// Whether the content widget should resize with the scroll area
    /// When false (default), the scroll area honors the size of its widget and shows scrollbars when needed.
    /// When true, the scroll area will automatically resize the widget to fit available space.
    public var widgetResizable: Bool = false {
        didSet {
            qtScrollArea.pointee.setWidgetResizable(widgetResizable)
        }
    }
    
    /// The current horizontal scroll position
    public var horizontalScrollValue: Int {
        get {
            return Int(qtScrollArea.pointee.horizontalScrollValue())
        }
        set {
            qtScrollArea.pointee.setHorizontalScrollValue(Int32(newValue))
        }
    }
    
    /// The current vertical scroll position
    public var verticalScrollValue: Int {
        get {
            return Int(qtScrollArea.pointee.verticalScrollValue())
        }
        set {
            qtScrollArea.pointee.setVerticalScrollValue(Int32(newValue))
        }
    }
    
    /// The maximum horizontal scroll value
    public var horizontalScrollMaximum: Int {
        return Int(qtScrollArea.pointee.horizontalScrollMaximum())
    }
    
    /// The maximum vertical scroll value
    public var verticalScrollMaximum: Int {
        return Int(qtScrollArea.pointee.verticalScrollMaximum())
    }
    
    /// Creates a new scroll view
    ///
    /// - Parameter parent: The parent widget. If nil, creates a top-level scroll view.
    public init(parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtScrollArea = UnsafeMutablePointer<SwiftQScrollArea>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtScrollArea.initialize(to: SwiftQScrollArea(parent.getBridgeWidget()))
        } else {
            qtScrollArea.initialize(to: SwiftQScrollArea())
        }
        
        // Configure default settings to show scrollbars when content is larger
        qtScrollArea.pointee.setWidgetResizable(false)
    }
    
    deinit {
        // Clean up the C++ object
        let ptr = qtScrollArea
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    /// Sets the content widget to be scrolled
    ///
    /// - Parameter widget: The widget to display in the scroll area
    public func setContent(_ widget: any QtWidget) {
        // Remove old content if any
        content?.setParent(nil)
        
        // Set new content
        content = widget
        qtScrollArea.pointee.setWidget(widget.getBridgeWidget())
    }
    
    /// Removes the content widget
    public func clearContent() {
        content?.setParent(nil)
        content = nil
        qtScrollArea.pointee.setWidget(nil)
    }
    
    /// Scrolls to ensure a specific rectangle is visible
    ///
    /// - Parameters:
    ///   - x: X coordinate of the rectangle
    ///   - y: Y coordinate of the rectangle
    ///   - width: Width of the rectangle
    ///   - height: Height of the rectangle
    public func ensureVisible(x: Int, y: Int, width: Int = 50, height: Int = 50) {
        qtScrollArea.pointee.ensureVisible(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    /// Scrolls to ensure a child widget is visible
    ///
    /// - Parameter widget: The widget to make visible
    public func ensureWidgetVisible(_ widget: any QtWidget) {
        qtScrollArea.pointee.ensureWidgetVisible(widget.getBridgeWidget(), 50, 50)
    }
    
    /// Scrolls to the top of the content
    public func scrollToTop() {
        verticalScrollValue = 0
    }
    
    /// Scrolls to the bottom of the content
    public func scrollToBottom() {
        verticalScrollValue = verticalScrollMaximum
    }
    
    /// Scrolls to the left of the content
    public func scrollToLeft() {
        horizontalScrollValue = 0
    }
    
    /// Scrolls to the right of the content
    public func scrollToRight() {
        horizontalScrollValue = horizontalScrollMaximum
    }
    
    /// Sets a handler for vertical scroll events
    /// - Parameter handler: Closure called when vertical scrolling occurs with the new value
    public func onVerticalScroll(_ handler: @escaping (Int) -> Void) {
        // TODO: Connect to QScrollBar valueChanged signal
        // This would require access to the scroll bars and connecting to their signals
    }
    
    /// Sets a handler for horizontal scroll events
    /// - Parameter handler: Closure called when horizontal scrolling occurs with the new value
    public func onHorizontalScroll(_ handler: @escaping (Int) -> Void) {
        // TODO: Connect to QScrollBar valueChanged signal
        // This would require access to the scroll bars and connecting to their signals
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtScrollArea.pointee.show()
    }
    
    public func hide() {
        qtScrollArea.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtScrollArea.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtScrollArea.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtScrollArea.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtScrollArea.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtScrollArea.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtScrollArea.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtScrollArea.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtScrollArea.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtScrollArea.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtScrollArea.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtScrollArea.pointee.setParent(nil)
        }
    }
}