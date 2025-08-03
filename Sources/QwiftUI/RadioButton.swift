// ABOUTME: RadioButton widget implementation conforming to QtCheckable protocol
// ABOUTME: Provides a radio button for exclusive selection within a group

import Foundation
import QtBridge

/// A radio button widget for exclusive selection within a group
@MainActor
public class RadioButton: QtWidget, QtCheckable {
    /// The underlying Qt radio button stored as a pointer
    /// Marked as nonisolated(unsafe) since pointer operations are inherently unsafe
    nonisolated(unsafe) internal var qtRadioButton: UnsafeMutablePointer<SwiftQRadioButton>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQRadioButton* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtRadioButton).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The text displayed next to the radio button
    public var text: String {
        get { String(qtRadioButton.pointee.text()) }
        set { qtRadioButton.pointee.setText(std.string(newValue)) }
    }
    
    /// Whether the radio button is currently selected
    public var isChecked: Bool {
        get { qtRadioButton.pointee.isChecked() }
        set { qtRadioButton.pointee.setChecked(newValue) }
    }
    
    /// Creates a radio button with optional text
    public init(_ text: String = "", parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtRadioButton = UnsafeMutablePointer<SwiftQRadioButton>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtRadioButton.initialize(to: SwiftQRadioButton(std.string(text), parent.getBridgeWidget()))
        } else {
            qtRadioButton.initialize(to: SwiftQRadioButton(std.string(text)))
        }
    }
    
    deinit {
        // Since RadioButton is MainActor-isolated, we can safely access qtRadioButton
        // The pointer deallocation is safe from deinit
        let ptr = qtRadioButton
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtRadioButton.pointee.show()
    }
    
    public func hide() {
        qtRadioButton.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtRadioButton.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtRadioButton.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtRadioButton.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtRadioButton.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtRadioButton.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtRadioButton.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtRadioButton.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtRadioButton.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtRadioButton.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtRadioButton.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtRadioButton.pointee.setParent(nil)
        }
    }
}
