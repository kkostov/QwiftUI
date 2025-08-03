import Foundation
import QtBridge

/// A view that displays one or more lines of informational text.
///
/// Label is the Swift wrapper for Qt's QLabel widget. Use labels to display
/// static text, images, or provide information to users.
///
/// ## Creating Labels
///
/// Create a label with text:
/// ```swift
/// let label = Label("Hello, World!")
/// ```
///
/// Create an empty label and set text later:
/// ```swift
/// let label = Label()
/// label.text = "Dynamic text"
/// ```
///
/// ## Alignment
///
/// Control how text appears within the label:
/// ```swift
/// label.alignment = .center  // Center both horizontally and vertically
/// label.alignment = [.top, .right]  // Top-right corner
/// ```
///
@MainActor
public class Label: QtWidget {
    /// The underlying Qt label stored as a pointer
    /// Marked as nonisolated(unsafe) since pointer operations are inherently unsafe
    nonisolated(unsafe) internal var qtLabel: UnsafeMutablePointer<SwiftQLabel>
    
    /// Protocol conformance - provide mutable pointer
    /// Note: This returns a pointer to the base SwiftQWidget part of SwiftQLabel
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQLabel* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtLabel).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The text displayed by the label
    public var text: String {
        get {
            return String(qtLabel.pointee.text())
        }
        set {
            qtLabel.pointee.setText(std.string(newValue))
        }
    }
    
    /// The alignment of the text within the label
    public var alignment: Qt.Alignment = [] {
        didSet {
            qtLabel.pointee.setAlignment(Int32(alignment.rawValue))
        }
    }
    
    /// Creates a label with the specified text and optional parent widget.
    ///
    /// - Parameters:
    ///   - text: The text to display in the label
    ///   - parent: The parent widget, if any
    public init(_ text: String = "", parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtLabel = UnsafeMutablePointer<SwiftQLabel>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtLabel.initialize(to: SwiftQLabel(std.string(text), parent.getBridgeWidget()))
        } else {
            qtLabel.initialize(to: SwiftQLabel(std.string(text)))
        }
    }
    
    /// Creates a label that displays the string representation of a value.
    ///
    /// - Parameters:
    ///   - value: A value whose string representation will be displayed
    ///   - parent: The parent widget, if any
    public init<T>(_ value: T, parent: (any QtWidget)? = nil) {
        let text = String(describing: value)
        
        // Allocate the C++ object on the heap
        qtLabel = UnsafeMutablePointer<SwiftQLabel>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtLabel.initialize(to: SwiftQLabel(std.string(text), parent.getBridgeWidget()))
        } else {
            qtLabel.initialize(to: SwiftQLabel(std.string(text)))
        }
    }
    
    deinit {
        // Since Label is MainActor-isolated, we can safely access qtLabel
        // The pointer deallocation is safe from deinit
        let ptr = qtLabel
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtLabel.pointee.show()
    }
    
    public func hide() {
        qtLabel.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtLabel.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtLabel.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtLabel.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtLabel.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtLabel.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtLabel.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtLabel.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtLabel.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtLabel.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtLabel.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtLabel.pointee.setParent(nil)
        }
    }
}


// MARK: - Convenience Methods

public extension Label {
    /// Sets both the text and alignment in a single call.
    ///
    /// - Parameters:
    ///   - text: The text to display
    ///   - alignment: How to align the text
    /// - Returns: Self for method chaining
    @discardableResult
    func configure(text: String, alignment: Qt.Alignment = []) -> Self {
        self.text = text
        self.alignment = alignment
        return self
    }
    
    /// Creates a centered label with the specified text.
    ///
    /// - Parameters:
    ///   - text: The text to display
    ///   - parent: The parent widget, if any
    /// - Returns: A new label with centered text
    static func centered(_ text: String, parent: (any QtWidget)? = nil) -> Label {
        let label = Label(text, parent: parent)
        label.alignment = Qt.Alignment.center
        return label
    }
}