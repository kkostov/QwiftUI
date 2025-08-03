// ABOUTME: Splitter provides a resizable divider between widgets
// ABOUTME: This wraps Qt's QSplitter for use in Swift applications

import Foundation
import QtBridge

/// A splitter widget that allows users to resize child widgets by dragging dividers.
///
/// Splitter provides a way to arrange child widgets horizontally or vertically
/// with draggable dividers between them. Users can adjust the relative sizes
/// of the child widgets by dragging these dividers.
///
/// ## Example Usage
///
/// ```swift
/// let splitter = Splitter(orientation: .horizontal)
/// let leftWidget = Widget()
/// let rightWidget = Widget()
/// splitter.addWidget(leftWidget)
/// splitter.addWidget(rightWidget)
/// splitter.setSizes([200, 300])
/// ```
@MainActor
public class Splitter: QtWidget {
    /// Splitter orientation
    public enum Orientation: Int {
        case horizontal = 1  // Qt::Horizontal
        case vertical = 2    // Qt::Vertical
    }
    
    /// The underlying Qt splitter stored as a pointer
    nonisolated(unsafe) internal var qtSplitter: UnsafeMutablePointer<SwiftQSplitter>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQSplitter* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtSplitter).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// Track child widgets to prevent deallocation
    private var childWidgets: [any QtWidget] = []
    
    /// The orientation of the splitter
    public var orientation: Orientation {
        get {
            return Orientation(rawValue: Int(qtSplitter.pointee.orientation())) ?? .horizontal
        }
        set {
            qtSplitter.pointee.setOrientation(Int32(newValue.rawValue))
        }
    }
    
    /// The number of widgets in the splitter
    public var count: Int {
        return Int(qtSplitter.pointee.count())
    }
    
    /// The width of the splitter handle
    public var handleWidth: Int {
        get {
            return Int(qtSplitter.pointee.handleWidth())
        }
        set {
            qtSplitter.pointee.setHandleWidth(Int32(newValue))
        }
    }
    
    /// Whether child widgets can be collapsed
    public var childrenCollapsible: Bool {
        get {
            return qtSplitter.pointee.childrenCollapsible()
        }
        set {
            qtSplitter.pointee.setChildrenCollapsible(newValue)
        }
    }
    
    /// Creates a new splitter with default horizontal orientation
    ///
    /// - Parameter parent: The parent widget. If nil, creates a top-level splitter.
    public init(parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtSplitter = UnsafeMutablePointer<SwiftQSplitter>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtSplitter.initialize(to: SwiftQSplitter(parent.getBridgeWidget()))
        } else {
            qtSplitter.initialize(to: SwiftQSplitter())
        }
    }
    
    /// Creates a new splitter with specified orientation
    ///
    /// - Parameters:
    ///   - orientation: The orientation of the splitter
    ///   - parent: The parent widget. If nil, creates a top-level splitter.
    public init(orientation: Orientation, parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtSplitter = UnsafeMutablePointer<SwiftQSplitter>.allocate(capacity: 1)
        
        // Initialize the C++ object with orientation
        if let parent = parent {
            qtSplitter.initialize(to: SwiftQSplitter(Int32(orientation.rawValue), parent.getBridgeWidget()))
        } else {
            qtSplitter.initialize(to: SwiftQSplitter(Int32(orientation.rawValue)))
        }
    }
    
    deinit {
        // Clean up the C++ object
        let ptr = qtSplitter
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    /// Adds a widget to the splitter
    ///
    /// - Parameter widget: The widget to add
    public func addWidget(_ widget: any QtWidget) {
        childWidgets.append(widget)
        qtSplitter.pointee.addWidget(widget.getBridgeWidget())
    }
    
    /// Inserts a widget at the specified index
    ///
    /// - Parameters:
    ///   - index: The position where the widget should be inserted
    ///   - widget: The widget to insert
    public func insertWidget(_ index: Int, widget: any QtWidget) {
        if index <= childWidgets.count {
            childWidgets.insert(widget, at: index)
        } else {
            childWidgets.append(widget)
        }
        qtSplitter.pointee.insertWidget(Int32(index), widget.getBridgeWidget())
    }
    
    /// Gets the index of a widget in the splitter
    ///
    /// - Parameter widget: The widget to find
    /// - Returns: The index of the widget, or -1 if not found
    public func indexOf(_ widget: any QtWidget) -> Int {
        return Int(qtSplitter.pointee.indexOf(widget.getBridgeWidget()))
    }
    
    /// Sets the sizes of the child widgets
    ///
    /// - Parameter sizes: An array of sizes for each widget
    public func setSizes(_ sizes: [Int]) {
        // Convert to Int32 array and use the array-based method
        let intSizes = sizes.map { Int32($0) }
        intSizes.withUnsafeBufferPointer { buffer in
            qtSplitter.pointee.setSizesArray(buffer.baseAddress, Int32(buffer.count))
        }
    }
    
    /// Gets the current sizes of the child widgets
    ///
    /// - Returns: An array of sizes for each widget
    public func sizes() -> [Int] {
        let count = Int(qtSplitter.pointee.sizesCount())
        var result: [Int] = []
        for i in 0..<count {
            result.append(Int(qtSplitter.pointee.getSizeAt(Int32(i))))
        }
        return result
    }
    
    /// Sets the stretch factor for a widget at the specified index
    ///
    /// - Parameters:
    ///   - index: The index of the widget
    ///   - stretch: The stretch factor (0 means no stretch)
    public func setStretchFactor(_ index: Int, stretch: Int) {
        qtSplitter.pointee.setStretchFactor(Int32(index), Int32(stretch))
    }
    
    /// Sets whether a widget at the specified index can be collapsed
    ///
    /// - Parameters:
    ///   - index: The index of the widget
    ///   - collapsible: Whether the widget can be collapsed
    public func setCollapsible(_ index: Int, collapsible: Bool) {
        qtSplitter.pointee.setCollapsible(Int32(index), collapsible)
    }
    
    /// Checks if a widget at the specified index can be collapsed
    ///
    /// - Parameter index: The index of the widget
    /// - Returns: Whether the widget can be collapsed
    public func isCollapsible(_ index: Int) -> Bool {
        return qtSplitter.pointee.isCollapsible(Int32(index))
    }
    
    /// Gets the widget at the specified index
    ///
    /// - Parameter index: The index of the widget
    /// - Returns: The widget at the specified index, or nil if invalid
    public func widget(at index: Int) -> (any QtWidget)? {
        guard index >= 0 && index < childWidgets.count else { return nil }
        return childWidgets[index]
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtSplitter.pointee.show()
    }
    
    public func hide() {
        qtSplitter.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtSplitter.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtSplitter.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtSplitter.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtSplitter.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtSplitter.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtSplitter.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtSplitter.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtSplitter.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtSplitter.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtSplitter.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtSplitter.pointee.setParent(nil)
        }
    }
}