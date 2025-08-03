// ABOUTME: Protocol definitions for text input widgets
// ABOUTME: Defines QtTextInput protocol for LineEdit and TextEdit widgets

import Foundation
import QtBridge

/// Protocol for widgets that accept text input
public protocol QtTextInput: QtWidget {
    /// The current text value
    var text: String { get set }
    
    /// Placeholder text shown when empty
    var placeholderText: String { get set }
    
    /// Maximum allowed text length
    var maxLength: Int { get set }
    
    /// Whether the text is read-only
    var readOnly: Bool { get set }
    
    /// Clear all text
    func clear()
    
    /// Select all text
    func selectAll()
}