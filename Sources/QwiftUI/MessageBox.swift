// ABOUTME: MessageBox wrapper for showing dialogs and alerts
// ABOUTME: Provides static methods for displaying various types of message boxes

import Foundation
import QtBridge

/// A utility class for displaying message boxes and dialogs
public struct MessageBox {
    
    /// Shows an information message box
    /// - Parameters:
    ///   - title: The title of the message box
    ///   - text: The text content to display
    ///   - parent: Optional parent widget
    public static func showInformation(
        title: String,
        text: String,
        parent: (any QtWidget)? = nil
    ) {
        SwiftQMessageBox.showInformation(
            parent?.getBridgeWidget(),
            std.string(title),
            std.string(text)
        )
    }
    
    /// Shows a warning message box
    /// - Parameters:
    ///   - title: The title of the message box
    ///   - text: The text content to display
    ///   - parent: Optional parent widget
    public static func showWarning(
        title: String,
        text: String,
        parent: (any QtWidget)? = nil
    ) {
        SwiftQMessageBox.showWarning(
            parent?.getBridgeWidget(),
            std.string(title),
            std.string(text)
        )
    }
    
    /// Shows a critical error message box
    /// - Parameters:
    ///   - title: The title of the message box
    ///   - text: The text content to display
    ///   - parent: Optional parent widget
    public static func showCritical(
        title: String,
        text: String,
        parent: (any QtWidget)? = nil
    ) {
        SwiftQMessageBox.showCritical(
            parent?.getBridgeWidget(),
            std.string(title),
            std.string(text)
        )
    }
    
    /// Shows a question message box with Yes/No buttons
    /// - Parameters:
    ///   - title: The title of the message box
    ///   - text: The question to ask
    ///   - parent: Optional parent widget
    /// - Returns: true if Yes was clicked, false if No was clicked
    public static func showQuestion(
        title: String,
        text: String,
        parent: (any QtWidget)? = nil
    ) -> Bool {
        return SwiftQMessageBox.showQuestion(
            parent?.getBridgeWidget(),
            std.string(title),
            std.string(text)
        )
    }
    
    /// Shows an about dialog box
    /// - Parameters:
    ///   - title: The title of the about box
    ///   - text: The about text to display
    ///   - parent: Optional parent widget
    public static func showAbout(
        title: String,
        text: String,
        parent: (any QtWidget)? = nil
    ) {
        SwiftQMessageBox.showAbout(
            parent?.getBridgeWidget(),
            std.string(title),
            std.string(text)
        )
    }
}