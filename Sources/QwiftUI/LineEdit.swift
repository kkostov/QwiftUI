// ABOUTME: LineEdit widget implementation conforming to QtTextInput protocol
// ABOUTME: Provides a single-line text input field

import Foundation
import QtBridge

/// A single-line text input widget
@MainActor
public class LineEdit: QtWidget, QtTextInput {
    /// The underlying Qt line edit stored as a pointer
    /// Marked as nonisolated(unsafe) since pointer operations are inherently unsafe
    nonisolated(unsafe) internal var qtLineEdit: UnsafeMutablePointer<SwiftQLineEdit>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQLineEdit* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtLineEdit).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The text content
    public var text: String {
        get { String(qtLineEdit.pointee.text()) }
        set { qtLineEdit.pointee.setText(std.string(newValue)) }
    }
    
    /// Placeholder text shown when empty
    public var placeholderText: String {
        get { String(qtLineEdit.pointee.getPlaceholderText()) }
        set { qtLineEdit.pointee.setPlaceholderText(std.string(newValue)) }
    }
    
    /// Maximum allowed text length
    public var maxLength: Int {
        get { Int.max } // Qt doesn't provide a getter
        set { qtLineEdit.pointee.setMaxLength(Int32(newValue)) }
    }
    
    /// Whether the text is read-only
    public var readOnly: Bool {
        get { false } // Qt doesn't provide a getter
        set { qtLineEdit.pointee.setReadOnly(newValue) }
    }
    
    /// Creates a line edit with optional initial text
    public init(_ text: String = "", parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtLineEdit = UnsafeMutablePointer<SwiftQLineEdit>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtLineEdit.initialize(to: SwiftQLineEdit(std.string(text), parent.getBridgeWidget()))
        } else {
            qtLineEdit.initialize(to: SwiftQLineEdit(std.string(text)))
        }
    }
    
    deinit {
        // Since LineEdit is MainActor-isolated, we can safely access qtLineEdit
        // The pointer deallocation is safe from deinit
        let ptr = qtLineEdit
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    /// Clear all text
    public func clear() {
        qtLineEdit.pointee.clear()
    }
    
    /// Select all text
    public func selectAll() {
        qtLineEdit.pointee.selectAll()
    }
    
    // MARK: - Event Handling
    
    /// Sets a handler for text change events
    /// - Parameter handler: Closure called when the text changes
    public func onTextChanged(_ handler: @escaping (String) -> Void) {
        // TODO: Connect to QLineEdit textChanged signal in QtBridge
        // For now, this is a placeholder
    }
    
    /// Sets a handler for when return/enter is pressed
    /// - Parameter handler: Closure called when return is pressed
    public func onReturnPressed(_ handler: @escaping () -> Void) {
        // TODO: Connect to QLineEdit returnPressed signal in QtBridge
    }
    
    /// Sets a handler for when editing is finished (focus lost or return pressed)
    /// - Parameter handler: Closure called when editing is finished
    public func onEditingFinished(_ handler: @escaping () -> Void) {
        // TODO: Connect to QLineEdit editingFinished signal in QtBridge
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtLineEdit.pointee.show()
    }
    
    public func hide() {
        qtLineEdit.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtLineEdit.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtLineEdit.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtLineEdit.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtLineEdit.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtLineEdit.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtLineEdit.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtLineEdit.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtLineEdit.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtLineEdit.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtLineEdit.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtLineEdit.pointee.setParent(nil)
        }
    }
}