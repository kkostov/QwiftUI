// ABOUTME: ComboBox widget implementation conforming to QtSelectable protocol
// ABOUTME: Provides a dropdown list for selecting from multiple options with safe event handling

import Foundation
import QtBridge

/// A combo box widget for selecting from a dropdown list
@MainActor
public class ComboBox: SafeEventWidget, QtWidget, QtSelectable {
    /// The underlying Qt combo box stored as a pointer
    /// Marked as nonisolated(unsafe) since pointer operations are inherently unsafe
    nonisolated(unsafe) internal var qtComboBox: UnsafeMutablePointer<SwiftQComboBox>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQComboBox* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtComboBox).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The list of available items
    public var items: [String] {
        var result: [String] = []
        let count = qtComboBox.pointee.count()
        for i in 0..<count {
            result.append(String(qtComboBox.pointee.itemText(Int32(i))))
        }
        return result
    }
    
    /// The currently selected index
    public var currentIndex: Int {
        get { Int(qtComboBox.pointee.currentIndex()) }
        set { qtComboBox.pointee.setCurrentIndex(Int32(newValue)) }
    }
    
    /// The text of the currently selected item
    public var currentText: String {
        // Check if there's a valid selection
        let index = qtComboBox.pointee.currentIndex()
        if index < 0 || index >= qtComboBox.pointee.count() {
            return ""
        }
        return String(qtComboBox.pointee.currentText())
    }
    
    /// Creates an empty combo box
    public init(parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtComboBox = UnsafeMutablePointer<SwiftQComboBox>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtComboBox.initialize(to: SwiftQComboBox(parent.getBridgeWidget()))
        } else {
            qtComboBox.initialize(to: SwiftQComboBox())
        }
        
        // Call super.init() after all stored properties are initialized
        super.init()
    }
    
    deinit {
        // Since ComboBox is MainActor-isolated, we can safely access qtComboBox
        // The pointer deallocation is safe from deinit
        let ptr = qtComboBox
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    /// Creates a combo box with initial items
    public convenience init(items: [String], parent: (any QtWidget)? = nil) {
        self.init(parent: parent)
        for item in items {
            addItem(item)
        }
    }
    
    /// Add an item to the list
    public func addItem(_ text: String) {
        qtComboBox.pointee.addItem(std.string(text))
    }
    
    /// Insert an item at a specific position
    public func insertItem(at index: Int, text: String) {
        qtComboBox.pointee.insertItem(Int32(index), std.string(text))
    }
    
    /// Remove an item at a specific position
    public func removeItem(at index: Int) {
        qtComboBox.pointee.removeItem(Int32(index))
    }
    
    /// Clear all items
    public func clear() {
        qtComboBox.pointee.clear()
    }
    
    /// Get the text of an item at a specific index
    public func itemText(at index: Int) -> String {
        String(qtComboBox.pointee.itemText(Int32(index)))
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtComboBox.pointee.show()
    }
    
    public func hide() {
        qtComboBox.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtComboBox.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtComboBox.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtComboBox.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtComboBox.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtComboBox.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtComboBox.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtComboBox.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtComboBox.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtComboBox.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtComboBox.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtComboBox.pointee.setParent(nil)
        }
    }
    
    // MARK: - Event Handling
    
    /// Sets a closure to be called when the selected index changes
    /// - Parameter handler: The closure to execute with the new index
    @discardableResult
    public func onIndexChanged(_ handler: @escaping (Int) -> Void) -> Self {
        // Create a heap-allocated callback (automatically managed)
        let callback = CallbackHelper.createCallbackInt(context: self, handler: handler)
        
        // Pass the callback to C++
        qtComboBox.pointee.setIndexChangedHandler(callback.pointee)
        
        return self
    }
    
    /// Sets a closure to be called when the selected index changes, providing both index and text
    /// - Parameter handler: The closure to execute with the new index and selected text
    @discardableResult
    public func onSelectionChanged(_ handler: @escaping (Int, String) -> Void) -> Self {
        // Create a heap-allocated event callback (automatically managed) that extracts both index and text
        let callback = CallbackHelper.createEventCallback(context: self) { info in
            if info.type == QtEventType.CurrentIndexChanged {
                let index = Int(info.intValue)
                let text = info.stringValue != nil ? String(cString: info.stringValue!) : ""
                handler(index, text)
            }
        }
        
        // Pass the callback to C++
        qtComboBox.pointee.setCurrentIndexChangedHandler(callback.pointee)
        
        return self
    }
    
    /// Sets a closure to be called when the current index changes (simplified version)
    /// - Parameter handler: The closure to execute with the new index
    public func onCurrentIndexChanged(_ handler: @escaping (Int) -> Void) {
        _ = onIndexChanged(handler)
    }
    
    /// Sets a closure to be called when the selected text changes
    /// - Parameter handler: The closure to execute with the new text
    @discardableResult
    public func onTextChanged(_ handler: @escaping (String) -> Void) -> Self {
        // Create a heap-allocated callback (automatically managed)
        let callback = CallbackHelper.createCallbackString(context: self, handler: handler)
        
        // Pass the callback to C++
        qtComboBox.pointee.setTextChangedHandler(callback.pointee)
        
        return self
    }
    
    /// Sets a closure to be called when an item is activated (selected by user action)
    /// - Parameter handler: The closure to execute with the activated index
    @discardableResult
    public func onActivated(_ handler: @escaping (Int) -> Void) -> Self {
        // Create a heap-allocated event callback (automatically managed)
        let callback = CallbackHelper.createEventCallback(context: self) { info in
            if info.type == QtEventType.Activated {
                handler(Int(info.intValue))
            }
        }
        
        // Pass the callback to C++
        qtComboBox.pointee.setActivatedHandler(callback.pointee)
        
        return self
    }
    
    /// Sets a closure to be called when the edit text changes (for editable combo boxes)
    /// - Parameter handler: The closure to execute with the new edit text
    @discardableResult
    public func onEditTextChanged(_ handler: @escaping (String) -> Void) -> Self {
        // Create a heap-allocated event callback (automatically managed)
        let callback = CallbackHelper.createEventCallback(context: self) { info in
            if info.type == QtEventType.TextEdited, let text = info.stringValue {
                handler(String(cString: text))
            }
        }
        
        // Pass the callback to C++
        qtComboBox.pointee.setEditTextChangedHandler(callback.pointee)
        
        return self
    }
}