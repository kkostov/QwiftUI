// ABOUTME: ProgressBar provides a widget for displaying progress
// ABOUTME: This wraps Qt's QProgressBar for use in Swift applications

import Foundation
import QtBridge

/// A progress bar widget for displaying task completion.
///
/// ProgressBar provides visual feedback about the progress of a long-running
/// operation. It can show a definite progress (with a percentage) or an
/// indefinite progress (busy indicator).
///
/// ## Example Usage
///
/// ```swift
/// let progressBar = ProgressBar()
/// progressBar.minimum = 0
/// progressBar.maximum = 100
/// progressBar.value = 45
/// progressBar.showText = true
/// ```
@MainActor
public class ProgressBar: QtWidget {
    /// The underlying Qt progress bar stored as a pointer
    nonisolated(unsafe) internal var qtProgressBar: UnsafeMutablePointer<SwiftQProgressBar>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQProgressBar* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtProgressBar).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The current value of the progress bar
    public var value: Int {
        get {
            return Int(qtProgressBar.pointee.value())
        }
        set {
            qtProgressBar.pointee.setValue(Int32(newValue))
        }
    }
    
    /// The minimum value of the progress bar
    public var minimum: Int {
        get {
            return Int(qtProgressBar.pointee.minimum())
        }
        set {
            qtProgressBar.pointee.setMinimum(Int32(newValue))
        }
    }
    
    /// The maximum value of the progress bar
    public var maximum: Int {
        get {
            return Int(qtProgressBar.pointee.maximum())
        }
        set {
            qtProgressBar.pointee.setMaximum(Int32(newValue))
        }
    }
    
    /// The orientation of the progress bar
    public enum Orientation: Int {
        case horizontal = 1  // Qt::Horizontal
        case vertical = 2    // Qt::Vertical
    }
    
    /// The orientation of the progress bar
    public var orientation: Orientation = .horizontal {
        didSet {
            qtProgressBar.pointee.setOrientation(Int32(orientation.rawValue))
        }
    }
    
    /// Whether to show the progress text
    public var showText: Bool = true {
        didSet {
            qtProgressBar.pointee.setTextVisible(showText)
        }
    }
    
    /// The format of the progress text
    /// Use %p for percentage, %v for value, %m for maximum
    public var format: String = "%p%" {
        didSet {
            qtProgressBar.pointee.setFormat(std.string(format))
        }
    }
    
    /// The text alignment
    public var textAlignment: Alignment = .center {
        didSet {
            // Note: Qt doesn't directly support alignment for progress bar text
            // This would require custom painting
        }
    }
    
    /// Text alignment options
    public enum Alignment: Int {
        case left = 0x0001      // Qt::AlignLeft
        case right = 0x0002     // Qt::AlignRight
        case center = 0x0004    // Qt::AlignHCenter
        case top = 0x0020       // Qt::AlignTop
        case bottom = 0x0040    // Qt::AlignBottom
        case vCenter = 0x0080   // Qt::AlignVCenter
    }
    
    /// Whether the progress bar is in busy/indeterminate mode
    public var isBusy: Bool {
        get {
            // When min == max == 0, QProgressBar shows busy indicator
            return minimum == 0 && maximum == 0
        }
        set {
            if newValue {
                // Set to busy mode
                minimum = 0
                maximum = 0
            } else {
                // Reset to normal mode
                minimum = 0
                maximum = 100
            }
        }
    }
    
    /// Creates a new progress bar
    ///
    /// - Parameters:
    ///   - orientation: The orientation of the progress bar
    ///   - parent: The parent widget. If nil, creates a top-level progress bar.
    public init(orientation: Orientation = .horizontal, parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtProgressBar = UnsafeMutablePointer<SwiftQProgressBar>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtProgressBar.initialize(to: SwiftQProgressBar(parent.getBridgeWidget()))
        } else {
            qtProgressBar.initialize(to: SwiftQProgressBar())
        }
        
        self.orientation = orientation
        self.showText = true
        self.format = "%p%"
    }
    
    deinit {
        // Clean up the C++ object
        let ptr = qtProgressBar
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    /// Sets the progress bar to busy/indeterminate mode
    public func setBusy() {
        isBusy = true
    }
    
    /// Resets the progress bar to its initial state
    public func reset() {
        qtProgressBar.pointee.reset()
    }
    
    /// Sets a handler for value change events
    /// - Parameter handler: Closure called when the progress value changes
    public func onValueChanged(_ handler: @escaping (Int) -> Void) {
        // QProgressBar doesn't have a valueChanged signal by default
        // This would need to be implemented using a custom event filter or timer
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtProgressBar.pointee.show()
    }
    
    public func hide() {
        qtProgressBar.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtProgressBar.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtProgressBar.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtProgressBar.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtProgressBar.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtProgressBar.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtProgressBar.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtProgressBar.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtProgressBar.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtProgressBar.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtProgressBar.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtProgressBar.pointee.setParent(nil)
        }
    }
}