// ABOUTME: TabWidget provides a tabbed interface for organizing content
// ABOUTME: This wraps Qt's QTabWidget for use in Swift applications

import Foundation
import QtBridge

/// A tab widget that displays pages in a tabbed format.
///
/// TabWidget allows you to organize content into separate tabs, with each tab
/// containing its own widget hierarchy. Users can switch between tabs by clicking
/// on the tab bar.
///
/// ## Example Usage
///
/// ```swift
/// let tabWidget = TabWidget()
/// let page1 = Widget()
/// let page2 = Widget()
/// tabWidget.addTab(page1, label: "First Tab")
/// tabWidget.addTab(page2, label: "Second Tab")
/// ```
@MainActor
public class TabWidget: QtWidget {
    /// Tab position enumeration
    public enum TabPosition: Int {
        case north = 0  // Tabs at the top (default)
        case south = 1  // Tabs at the bottom
        case west = 2   // Tabs on the left
        case east = 3   // Tabs on the right
    }
    
    /// The underlying Qt tab widget stored as a pointer
    nonisolated(unsafe) internal var qtTabWidget: UnsafeMutablePointer<SwiftQTabWidget>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQTabWidget* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtTabWidget).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// Track child widgets to prevent deallocation
    private var childTabs: [(widget: any QtWidget, label: String)] = []
    
    /// The current tab index
    public var currentIndex: Int {
        get {
            return Int(qtTabWidget.pointee.currentIndex())
        }
        set {
            qtTabWidget.pointee.setCurrentIndex(Int32(newValue))
        }
    }
    
    /// The number of tabs
    public var count: Int {
        return Int(qtTabWidget.pointee.count())
    }
    
    /// The position of the tabs
    public var tabPosition: TabPosition {
        get {
            return TabPosition(rawValue: Int(qtTabWidget.pointee.tabPosition())) ?? .north
        }
        set {
            qtTabWidget.pointee.setTabPosition(Int32(newValue.rawValue))
        }
    }
    
    /// Whether tabs can be moved by the user
    public var isMovable: Bool {
        get {
            return qtTabWidget.pointee.isMovable()
        }
        set {
            qtTabWidget.pointee.setMovable(newValue)
        }
    }
    
    /// Whether tabs show close buttons
    public var tabsClosable: Bool {
        get {
            return qtTabWidget.pointee.tabBarAutoHide()
        }
        set {
            qtTabWidget.pointee.setTabBarAutoHide(newValue)
        }
    }
    
    /// Creates a new tab widget
    ///
    /// - Parameter parent: The parent widget. If nil, creates a top-level tab widget.
    public init(parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtTabWidget = UnsafeMutablePointer<SwiftQTabWidget>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtTabWidget.initialize(to: SwiftQTabWidget(parent.getBridgeWidget()))
        } else {
            qtTabWidget.initialize(to: SwiftQTabWidget())
        }
    }
    
    deinit {
        // Clean up the C++ object
        let ptr = qtTabWidget
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    /// Adds a new tab with the specified widget and label
    ///
    /// - Parameters:
    ///   - widget: The widget to display in the tab
    ///   - label: The text to display on the tab
    /// - Returns: The index of the newly added tab
    @discardableResult
    public func addTab(_ widget: any QtWidget, label: String) -> Int {
        childTabs.append((widget: widget, label: label))
        return Int(qtTabWidget.pointee.addTab(widget.getBridgeWidget(), std.string(label)))
    }
    
    /// Inserts a new tab at the specified index
    ///
    /// - Parameters:
    ///   - index: The position where the tab should be inserted
    ///   - widget: The widget to display in the tab
    ///   - label: The text to display on the tab
    /// - Returns: The index of the newly inserted tab
    @discardableResult
    public func insertTab(_ index: Int, widget: any QtWidget, label: String) -> Int {
        if index <= childTabs.count {
            childTabs.insert((widget: widget, label: label), at: index)
        } else {
            childTabs.append((widget: widget, label: label))
        }
        return Int(qtTabWidget.pointee.insertTab(Int32(index), widget.getBridgeWidget(), std.string(label)))
    }
    
    /// Removes the tab at the specified index
    ///
    /// - Parameter index: The index of the tab to remove
    public func removeTab(_ index: Int) {
        guard index >= 0 && index < childTabs.count else { return }
        childTabs.remove(at: index)
        qtTabWidget.pointee.removeTab(Int32(index))
    }
    
    /// Sets the text of the tab at the specified index
    ///
    /// - Parameters:
    ///   - index: The index of the tab
    ///   - text: The new text for the tab
    public func setTabText(_ index: Int, text: String) {
        qtTabWidget.pointee.setTabText(Int32(index), std.string(text))
        if index >= 0 && index < childTabs.count {
            childTabs[index].label = text
        }
    }
    
    /// Gets the text of the tab at the specified index
    ///
    /// - Parameter index: The index of the tab
    /// - Returns: The tab text, or empty string if index is invalid
    public func tabText(_ index: Int) -> String {
        return String(qtTabWidget.pointee.tabText(Int32(index)))
    }
    
    /// Sets whether the tab at the specified index is enabled
    ///
    /// - Parameters:
    ///   - index: The index of the tab
    ///   - enabled: Whether the tab should be enabled
    public func setTabEnabled(_ index: Int, enabled: Bool) {
        qtTabWidget.pointee.setTabEnabled(Int32(index), enabled)
    }
    
    /// Checks if the tab at the specified index is enabled
    ///
    /// - Parameter index: The index of the tab
    /// - Returns: Whether the tab is enabled
    public func isTabEnabled(_ index: Int) -> Bool {
        return qtTabWidget.pointee.isTabEnabled(Int32(index))
    }
    
    /// Removes all tabs
    public func clear() {
        childTabs.removeAll()
        qtTabWidget.pointee.clear()
    }
    
    /// Gets the widget at the specified tab index
    ///
    /// - Parameter index: The index of the tab
    /// - Returns: The widget at the specified index, or nil if invalid
    public func widget(at index: Int) -> (any QtWidget)? {
        guard index >= 0 && index < childTabs.count else { return nil }
        return childTabs[index].widget
    }
    
    /// Sets a handler for tab change events
    /// - Parameter handler: Closure called when the current tab changes
    public func onCurrentChanged(_ handler: @escaping (Int) -> Void) {
        // TODO: Connect to currentChanged signal
        // This would require signal/slot connection implementation
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtTabWidget.pointee.show()
    }
    
    public func hide() {
        qtTabWidget.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtTabWidget.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtTabWidget.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtTabWidget.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtTabWidget.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtTabWidget.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtTabWidget.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtTabWidget.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtTabWidget.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtTabWidget.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtTabWidget.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtTabWidget.pointee.setParent(nil)
        }
    }
}