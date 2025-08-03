// ABOUTME: Core protocol definitions for QwiftUI widget hierarchy
// ABOUTME: Defines the foundational QtWidget protocol and alignment types

import Foundation
import QtBridge

/// Namespace for Qt-specific types to avoid conflicts with Swift types
public enum Qt {
    /// Text alignment options matching Qt::AlignmentFlag
    public struct Alignment: OptionSet {
        public let rawValue: Int32
        
        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }
        
        // Horizontal alignment
        public static let left = Alignment(rawValue: 0x0001)
        public static let right = Alignment(rawValue: 0x0002)
        public static let hCenter = Alignment(rawValue: 0x0004)
        public static let justify = Alignment(rawValue: 0x0008)
        
        // Vertical alignment
        public static let top = Alignment(rawValue: 0x0020)
        public static let bottom = Alignment(rawValue: 0x0040)
        public static let vCenter = Alignment(rawValue: 0x0080)
        
        // Common combinations
        public static let center: Alignment = [.hCenter, .vCenter]
    }
    
    /// Check state for checkable widgets
    public enum CheckState: Int {
        case unchecked = 0
        case partiallyChecked = 1
        case checked = 2
    }
}

/// Core protocol for all Qt widgets
public protocol QtWidget: AnyObject {
    /// Get a mutable reference to the underlying bridge widget
    /// This is a workaround for Swift C++ interop limitations
    func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget>
    
    /// Show the widget
    func show()
    
    /// Hide the widget  
    func hide()
    
    /// Set whether the widget is enabled
    func setEnabled(_ enabled: Bool)
    
    /// Check if the widget is visible
    var isVisible: Bool { get }
    
    /// Resize the widget
    func resize(width: Int, height: Int)
    
    /// Move the widget
    func move(x: Int, y: Int)
    
    /// Set the widget's geometry
    func setGeometry(x: Int, y: Int, width: Int, height: Int)
    
    /// Set the window title (for top-level widgets)
    func setWindowTitle(_ title: String)
    
    /// Get the window title
    var windowTitle: String { get }
    
    /// Set the object name (used for finding widgets in tests)
    func setObjectName(_ name: String)
    
    /// Get the object name
    var objectName: String { get }
    
    /// Set the widget's parent
    func setParent(_ parent: QtWidget?)
}