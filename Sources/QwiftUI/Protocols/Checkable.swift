// ABOUTME: Protocol definitions for checkable widgets
// ABOUTME: Defines QtCheckable protocol for CheckBox and RadioButton widgets

import Foundation
import QtBridge

/// Protocol for widgets that can be checked/unchecked
public protocol QtCheckable: QtWidget {
    /// The text displayed next to the check control
    var text: String { get set }
    
    /// Whether the widget is currently checked
    var isChecked: Bool { get set }
}

/// Extended protocol for tri-state checkable widgets
public protocol QtTristateCheckable: QtCheckable {
    /// Whether the widget supports partial (tri-state) checking
    var isTristate: Bool { get set }
    
    /// The current check state (unchecked, partial, checked)
    var checkState: Qt.CheckState { get set }
}