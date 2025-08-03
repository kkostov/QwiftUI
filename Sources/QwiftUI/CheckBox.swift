// ABOUTME: CheckBox widget implementation conforming to QtTristateCheckable protocol
// ABOUTME: Provides a checkbox with optional tri-state support

import Foundation
import QtBridge

/// A checkbox widget that can be checked, unchecked, or partially checked
@MainActor
public class CheckBox: QtWidget, QtTristateCheckable {
    /// The underlying Qt checkbox stored as a pointer
    /// Marked as nonisolated(unsafe) since pointer operations are inherently unsafe
    nonisolated(unsafe) internal var qtCheckBox: UnsafeMutablePointer<SwiftQCheckBox>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQCheckBox* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtCheckBox).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The text displayed next to the checkbox
    public var text: String {
        get { String(qtCheckBox.pointee.text()) }
        set { qtCheckBox.pointee.setText(std.string(newValue)) }
    }
    
    /// Whether the checkbox is currently checked
    public var isChecked: Bool {
        get { qtCheckBox.pointee.isChecked() }
        set { qtCheckBox.pointee.setChecked(newValue) }
    }
    
    /// Whether the checkbox supports tri-state (partial) checking
    public var isTristate: Bool {
        get { false } // Qt doesn't provide a getter
        set { qtCheckBox.pointee.setTristate(newValue) }
    }
    
    /// The current check state
    public var checkState: Qt.CheckState {
        get { Qt.CheckState(rawValue: Int(qtCheckBox.pointee.getCheckState())) ?? .unchecked }
        set { qtCheckBox.pointee.setCheckState(Int32(newValue.rawValue)) }
    }
    
    /// Creates a checkbox with optional text
    public init(_ text: String = "", parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtCheckBox = UnsafeMutablePointer<SwiftQCheckBox>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtCheckBox.initialize(to: SwiftQCheckBox(std.string(text), parent.getBridgeWidget()))
        } else {
            qtCheckBox.initialize(to: SwiftQCheckBox(std.string(text)))
        }
    }
    
    deinit {
        // Since CheckBox is MainActor-isolated, we can safely access qtCheckBox
        // The pointer deallocation is safe from deinit
        let ptr = qtCheckBox
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    // MARK: - Event Handling
    
    /// Sets a handler for state change events
    /// - Parameter handler: Closure called when the checkbox state changes
    public func onStateChanged(_ handler: @escaping (Int) -> Void) {
        // TODO: Connect to QCheckBox stateChanged signal in QtBridge
        // State: 0=unchecked, 1=partially, 2=checked
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtCheckBox.pointee.show()
    }
    
    public func hide() {
        qtCheckBox.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtCheckBox.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtCheckBox.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtCheckBox.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtCheckBox.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtCheckBox.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtCheckBox.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtCheckBox.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtCheckBox.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtCheckBox.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtCheckBox.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtCheckBox.pointee.setParent(nil)
        }
    }
}