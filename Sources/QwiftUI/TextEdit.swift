// ABOUTME: TextEdit widget implementation conforming to QtTextInput protocol
// ABOUTME: Provides a multi-line text input field with rich text support

import Foundation
import QtBridge

/// A multi-line text input widget with rich text support
@MainActor
public class TextEdit: QtWidget, QtTextInput {
    /// The underlying Qt text edit stored as a pointer
    /// Marked as nonisolated(unsafe) since pointer operations are inherently unsafe
    nonisolated(unsafe) internal var qtTextEdit: UnsafeMutablePointer<SwiftQTextEdit>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQTextEdit* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtTextEdit).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The plain text content
    public var text: String {
        get { String(qtTextEdit.pointee.toPlainText()) }
        set { qtTextEdit.pointee.setPlainText(std.string(newValue)) }
    }
    
    /// The HTML content
    public var html: String {
        get { String(qtTextEdit.pointee.toHtml()) }
        set { qtTextEdit.pointee.setHtml(std.string(newValue)) }
    }
    
    /// Placeholder text shown when the text edit is empty
    public var placeholderText: String {
        get { String(qtTextEdit.pointee.placeholderText()) }
        set { qtTextEdit.pointee.setPlaceholderText(std.string(newValue)) }
    }
    
    /// Maximum allowed text length (not directly supported)
    public var maxLength: Int {
        get { Int.max }
        set { /* Not supported */ }
    }
    
    /// Whether the text is read-only
    public var readOnly: Bool {
        get { false } // Qt doesn't provide a getter
        set { qtTextEdit.pointee.setReadOnly(newValue) }
    }
    
    /// Creates a text edit with optional initial text
    public init(_ text: String = "", parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtTextEdit = UnsafeMutablePointer<SwiftQTextEdit>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtTextEdit.initialize(to: SwiftQTextEdit(parent.getBridgeWidget()))
        } else {
            qtTextEdit.initialize(to: SwiftQTextEdit())
        }
        
        if !text.isEmpty {
            qtTextEdit.pointee.setPlainText(std.string(text))
        }
    }
    
    deinit {
        // Since TextEdit is MainActor-isolated, we can safely access qtTextEdit
        // The pointer deallocation is safe from deinit
        let ptr = qtTextEdit
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    /// Clear all text
    public func clear() {
        qtTextEdit.pointee.clear()
    }
    
    /// Select all text (not directly supported)
    public func selectAll() {
        // Not directly supported by our C++ wrapper
    }
    
    // MARK: - Event Handling
    
    /// Sets a handler for text change events
    /// - Parameter handler: Closure called when the text changes
    public func onTextChanged(_ handler: @escaping (String) -> Void) {
        // TODO: Connect to QTextEdit textChanged signal in QtBridge
        // For now, this is a placeholder
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtTextEdit.pointee.show()
    }
    
    public func hide() {
        qtTextEdit.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtTextEdit.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtTextEdit.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtTextEdit.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtTextEdit.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtTextEdit.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtTextEdit.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtTextEdit.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtTextEdit.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtTextEdit.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtTextEdit.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtTextEdit.pointee.setParent(nil)
        }
    }
}