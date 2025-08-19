// ABOUTME: Protocol definition for selectable widgets
// ABOUTME: Defines QtSelectable protocol for ComboBox and similar selection widgets

import Foundation
import QtBridge

/// Protocol for widgets that present a list of selectable options
public protocol QtSelectable: QtWidget {
    /// The list of available items
    var items: [String] { get }
    
    /// The currently selected index
    var currentIndex: Int { get set }
    
    /// The text of the currently selected item
    var currentText: String { get }
    
    /// Add an item to the list
    func addItem(_ text: String)
    
    /// Insert an item at a specific position
    func insertItem(at index: Int, text: String)
    
    /// Remove an item at a specific position
    func removeItem(at index: Int)
    
    /// Clear all items
    func clear()
    
    /// Get the text of an item at a specific index
    func itemText(at index: Int) -> String
}