// ABOUTME: GroupBox widget implementation for grouping related widgets
// ABOUTME: Provides a container with optional title and checkable functionality

import Foundation
import QtBridge

/// A group box widget for visually grouping related widgets
@MainActor
public class GroupBox: QtWidget {
    /// The underlying Qt group box stored as a pointer
    /// Marked as nonisolated(unsafe) since pointer operations are inherently unsafe
    nonisolated(unsafe) internal var qtGroupBox: UnsafeMutablePointer<SwiftQGroupBox>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQGroupBox* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtGroupBox).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The title displayed at the top of the group box
    public var title: String {
        get { 
            return String(qtGroupBox.pointee.getTitle())
        }
        set { qtGroupBox.pointee.setTitle(std.string(newValue)) }
    }
    
    /// Whether the group box can be checked/unchecked
    public var isCheckable: Bool {
        get { false } // Qt doesn't provide a getter
        set { qtGroupBox.pointee.setCheckable(newValue) }
    }
    
    /// Whether the group box is currently checked (if checkable)
    public var isChecked: Bool {
        get { qtGroupBox.pointee.isChecked() }
        set { qtGroupBox.pointee.setChecked(newValue) }
    }
    
    /// Creates a group box with optional title
    public init(_ title: String = "", parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtGroupBox = UnsafeMutablePointer<SwiftQGroupBox>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtGroupBox.initialize(to: SwiftQGroupBox(std.string(title), parent.getBridgeWidget()))
        } else {
            qtGroupBox.initialize(to: SwiftQGroupBox(std.string(title)))
        }
    }
    
    deinit {
        // Since GroupBox is MainActor-isolated, we can safely access qtGroupBox
        // The pointer deallocation is safe from deinit
        let ptr = qtGroupBox
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtGroupBox.pointee.show()
    }
    
    public func hide() {
        qtGroupBox.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtGroupBox.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtGroupBox.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtGroupBox.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtGroupBox.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtGroupBox.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtGroupBox.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        return String(qtGroupBox.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtGroupBox.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        return String(qtGroupBox.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtGroupBox.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtGroupBox.pointee.setParent(nil)
        }
    }
}