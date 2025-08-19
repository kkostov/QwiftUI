// ABOUTME: Container provides a widget that manages child positioning manually
// ABOUTME: This disables Qt's layout managers for pixel-perfect control

import Foundation
import QtBridge

/// A container widget that allows manual positioning of children.
///
/// Container provides pixel-perfect control over child widget placement,
/// bypassing Qt's automatic layout management. This is essential for
/// implementing SwiftCrossUI's custom layout system.
///
/// ## Example Usage
///
/// ```swift
/// let container = Container()
/// let label = Label("Hello")
/// container.addChild(label)
/// container.setChildPosition(label, x: 10, y: 20)
/// ```
@MainActor
public class Container: Widget {
    /// Storage for child widgets with their positions
    private var childWidgets: [any QtWidget] = []
    private var childPositions: [ObjectIdentifier: (x: Int, y: Int)] = [:]
    
    /// Creates a new container with an optional parent.
    ///
    /// - Parameter parent: The parent widget. If nil, creates a top-level container.
    public override init(parent: (any QtWidget)? = nil) {
        super.init(parent: parent)
        // Disable Qt's layout management
        setupManualLayout()
    }
    
    /// Initialize with an existing Qt widget pointer.
    public override init(fromBridge qtWidgetPtr: UnsafeMutablePointer<SwiftQWidget>, ownsPointer: Bool = true) {
        super.init(fromBridge: qtWidgetPtr, ownsPointer: ownsPointer)
        setupManualLayout()
    }
    
    private func setupManualLayout() {
        // Qt doesn't have a specific "disable layout" flag
        // but we can achieve manual positioning by not using any layout manager
        // and manually positioning children
    }
    
    /// Adds a child widget to the container.
    ///
    /// - Parameter child: The widget to add as a child
    public func addChild(_ child: any QtWidget) {
        child.setParent(self)
        childWidgets.append(child)
        child.show()
    }
    
    /// Removes a child widget from the container.
    ///
    /// - Parameter child: The widget to remove
    public func removeChild(_ child: any QtWidget) {
        if let index = childWidgets.firstIndex(where: { ObjectIdentifier($0) == ObjectIdentifier(child) }) {
            childWidgets.remove(at: index)
            childPositions.removeValue(forKey: ObjectIdentifier(child))
            child.setParent(nil)
        }
    }
    
    /// Removes all children from the container.
    public func removeAllChildren() {
        for child in childWidgets {
            child.setParent(nil)
        }
        childWidgets.removeAll()
        childPositions.removeAll()
    }
    
    /// Sets the position of a child widget.
    ///
    /// - Parameters:
    ///   - child: The child widget to position
    ///   - x: The x coordinate relative to the container
    ///   - y: The y coordinate relative to the container
    public func setChildPosition(_ child: any QtWidget, x: Int, y: Int) {
        let id = ObjectIdentifier(child)
        childPositions[id] = (x: x, y: y)
        child.move(x: x, y: y)
    }
    
    /// Sets the position of a child widget by index.
    ///
    /// - Parameters:
    ///   - index: The index of the child in the children array
    ///   - x: The x coordinate relative to the container
    ///   - y: The y coordinate relative to the container
    public func setChildPosition(at index: Int, x: Int, y: Int) {
        guard index >= 0 && index < childWidgets.count else { return }
        let child = childWidgets[index]
        setChildPosition(child, x: x, y: y)
    }
    
    /// Gets all children of this container.
    public override var children: [any QtWidget] {
        childWidgets
    }
    
    /// Gets the number of children in the container.
    public var childCount: Int {
        childWidgets.count
    }
    
    /// Gets a child widget by index.
    ///
    /// - Parameter index: The index of the child
    /// - Returns: The child widget at the specified index, or nil if out of bounds
    public func child(at index: Int) -> (any QtWidget)? {
        guard index >= 0 && index < childWidgets.count else { return nil }
        return childWidgets[index]
    }
}