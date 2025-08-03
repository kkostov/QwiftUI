// ABOUTME: Protocol definition for clickable widgets
// ABOUTME: Defines QtClickable protocol for buttons and other clickable elements

import Foundation
import QtBridge

/// Protocol for widgets that can be clicked
public protocol QtClickable: QtWidget {
    /// The text displayed on the clickable element
    var text: String { get set }
}