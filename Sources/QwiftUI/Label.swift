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
/// A view that displays text.
///
/// Labels are non-editable text views that display information to users.
/// You can control the text alignment and update the text dynamically.
///
/// Note: This class does not inherit from Widget due to Swift/C++ interop
/// limitations with inheritance. It provides its own widget-like interface.
///
public class Label {
    /// The underlying Qt label pointer
    private let labelPtr: UnsafeMutablePointer<SwiftQLabel>
    
    /// The text displayed by the label
    public var text: String {
        get {
            // For now, return stored value as we can't query Qt
            return _text
        }
        set {
            _text = newValue
            updateText()
        }
    }
    private var _text: String = ""
    
    /// The alignment of the text within the label
    public var alignment: Alignment = .default {
        didSet {
            updateAlignment()
        }
    }
    
    /// Creates a label with the specified text and optional parent widget.
    ///
    /// - Parameters:
    ///   - text: The text to display in the label
    ///   - parent: The parent widget, if any
    public init(_ text: String = "", parent: Widget? = nil) {
        self._text = text
        
        // Create a Qt label using the factory function
        if let parentWidget = parent {
            guard let ptr = createLabel(std.string(text), &parentWidget.qtWidget) else {
                fatalError("Failed to create label")
            }
            self.labelPtr = ptr
        } else {
            guard let ptr = createLabel(std.string(text), nil) else {
                fatalError("Failed to create label")
            }
            self.labelPtr = ptr
        }
        
        // Set initial alignment
        updateAlignment()
    }
    
    /// Creates a label that displays the string representation of a value.
    ///
    /// - Parameters:
    ///   - value: A value whose string representation will be displayed
    ///   - parent: The parent widget, if any
    public init<T>(_ value: T, parent: Widget? = nil) {
        self._text = String(describing: value)
        
        // Create a Qt label using the factory function
        if let parentWidget = parent {
            guard let ptr = createLabel(std.string(_text), &parentWidget.qtWidget) else {
                fatalError("Failed to create label")
            }
            self.labelPtr = ptr
        } else {
            guard let ptr = createLabel(std.string(_text), nil) else {
                fatalError("Failed to create label")
            }
            self.labelPtr = ptr
        }
        
        // Set initial alignment
        updateAlignment()
    }
    
    private func updateText() {
        labelPtr.pointee.setText(std.string(_text))
    }
    
    private func updateAlignment() {
        labelPtr.pointee.setAlignment(Int32(alignment.rawValue))
    }
}

// MARK: - Widget-like Interface

public extension Label {
    /// Shows the label.
    func show() {
        labelPtr.pointee.show()
    }
    
    /// Hides the label.
    func hide() {
        labelPtr.pointee.hide()
    }
    
    /// Resizes the label.
    ///
    /// - Parameters:
    ///   - width: The new width in pixels
    ///   - height: The new height in pixels
    func resize(width: Int, height: Int) {
        labelPtr.pointee.resize(Int32(width), Int32(height))
    }
    
    /// Moves the label to the specified position.
    ///
    /// - Parameters:
    ///   - x: The horizontal position in pixels
    ///   - y: The vertical position in pixels  
    func move(x: Int, y: Int) {
        labelPtr.pointee.move(Int32(x), Int32(y))
    }
    
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
    func configure(text: String, alignment: Alignment = .default) -> Self {
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
    static func centered(_ text: String, parent: Widget? = nil) -> Label {
        let label = Label(text, parent: parent)
        label.alignment = .center
        return label
    }
}