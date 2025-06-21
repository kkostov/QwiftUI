import QtBridge

/// Options for aligning content within a view.
///
/// Alignment options can be combined to position content precisely within
/// a view's bounds. Use the provided static properties for common alignments,
/// or combine horizontal and vertical options for custom positioning.
///
/// ## Common Alignments
///
/// Center content:
/// ```swift
/// view.alignment = .center
/// ```
///
/// Top-left corner:
/// ```swift
/// view.alignment = [.top, .left]
/// ```
///
/// Right-align with vertical centering:
/// ```swift
/// view.alignment = [.right, .vCenter]
/// ```
///
public struct Alignment: OptionSet, Sendable {
    public let rawValue: Int32
    
    public init(rawValue: Int32) {
        self.rawValue = rawValue
    }
    
    // MARK: - Horizontal Alignment
    
    /// Aligns content to the left edge.
    public static let left = Alignment(rawValue: 0x0001)
    
    /// Aligns content to the right edge.
    public static let right = Alignment(rawValue: 0x0002)
    
    /// Centers content horizontally in the available space.
    public static let hCenter = Alignment(rawValue: 0x0004)
    
    /// Justifies text in the available space (for multi-line text).
    public static let justify = Alignment(rawValue: 0x0008)
    
    // MARK: - Vertical Alignment
    
    /// Aligns content to the top edge.
    public static let top = Alignment(rawValue: 0x0020)
    
    /// Aligns content to the bottom edge.
    public static let bottom = Alignment(rawValue: 0x0040)
    
    /// Centers content vertically in the available space.
    public static let vCenter = Alignment(rawValue: 0x0080)
    
    /// Aligns content with the text baseline.
    public static let baseline = Alignment(rawValue: 0x0100)
    
    // MARK: - Combined Alignments
    
    /// Centers content both horizontally and vertically.
    /// Equivalent to `[.hCenter, .vCenter]`.
    public static let center = Alignment(rawValue: 0x0084)
    
    /// Default alignment: left-aligned and vertically centered.
    /// This matches Qt's default behavior for most widgets.
    public static let `default`: Alignment = [.left, .vCenter]
    
    // MARK: - Layout Direction
    
    /// Ensures consistent alignment across different layout directions.
    /// When set, left/right alignment is not affected by right-to-left layouts.
    public static let absolute = Alignment(rawValue: 0x0010)
    
    /// Aligns to the leading edge (left in LTR, right in RTL).
    /// This is a semantic alias for `.left`.
    public static let leading = left
    
    /// Aligns to the trailing edge (right in LTR, left in RTL).
    /// This is a semantic alias for `.right`.
    public static let trailing = right
}

// MARK: - Convenience Properties

public extension Alignment {
    /// Top-left corner alignment.
    static let topLeft: Alignment = [.top, .left]
    
    /// Top-right corner alignment.
    static let topRight: Alignment = [.top, .right]
    
    /// Bottom-left corner alignment.
    static let bottomLeft: Alignment = [.bottom, .left]
    
    /// Bottom-right corner alignment.
    static let bottomRight: Alignment = [.bottom, .right]
    
    /// Top-center alignment.
    static let topCenter: Alignment = [.top, .hCenter]
    
    /// Bottom-center alignment.
    static let bottomCenter: Alignment = [.bottom, .hCenter]
    
    /// Left-center alignment.
    static let leftCenter: Alignment = [.left, .vCenter]
    
    /// Right-center alignment.
    static let rightCenter: Alignment = [.right, .vCenter]
}

// MARK: - CustomStringConvertible

extension Alignment: CustomStringConvertible {
    public var description: String {
        var parts: [String] = []
        
        // Check horizontal alignment
        if contains(.left) { parts.append("left") }
        else if contains(.right) { parts.append("right") }
        else if contains(.hCenter) { parts.append("hCenter") }
        
        // Check vertical alignment
        if contains(.top) { parts.append("top") }
        else if contains(.bottom) { parts.append("bottom") }
        else if contains(.vCenter) { parts.append("vCenter") }
        
        // Check special flags
        if contains(.justify) { parts.append("justify") }
        if contains(.baseline) { parts.append("baseline") }
        if contains(.absolute) { parts.append("absolute") }
        
        return parts.isEmpty ? "default" : parts.joined(separator: ", ")
    }
}