// ABOUTME: Test case that reproduces the Mixed Components demo crash
// ABOUTME: Tests button callback cleanup during widget destruction

import Foundation
import QwiftUI

/// Test to reproduce the Mixed Components crash involving button destruction
@MainActor
public struct MixedComponentsCrashTest {
    
    public static func run() -> Bool {
        print("=== Mixed Components Crash Test ===")
        print("Testing button callback cleanup during widget destruction...")
        
        // We assume QApplication is already created by the test harness
        // Don't create another one
        
        // Create a container similar to the demo
        let container = Widget()
        container.setWindowTitle("Mixed Components Crash Test")
        container.resize(width: 600, height: 400)
        
        // Track widgets for cleanup
        var widgets: [any QtWidget] = []
        
        // Create form group similar to Mixed Components demo
        let formGroup = GroupBox("Test Form", parent: container)
        formGroup.resize(width: 540, height: 280)
        formGroup.move(x: 20, y: 70)
        widgets.append(formGroup)
        
        // Add buttons that have click handlers (these are causing the crash)
        let submitButton = Button("Submit", parent: container)
        submitButton.isDefault = true
        submitButton.resize(width: 100, height: 35)
        submitButton.move(x: 380, y: 360)
        
        // Add a click handler (this is what's causing issues during cleanup)
        submitButton.onClicked {
            print("Submit clicked")
        }
        widgets.append(submitButton)
        
        let cancelButton = Button("Cancel", parent: container)
        cancelButton.resize(width: 100, height: 35)
        cancelButton.move(x: 270, y: 360)
        
        // Add another click handler
        cancelButton.onClicked {
            print("Cancel clicked")
        }
        widgets.append(cancelButton)
        
        // Add more widgets like in the demo
        let nameLabel = Label("Name:", parent: formGroup)
        nameLabel.resize(width: 100, height: 25)
        nameLabel.move(x: 20, y: 30)
        widgets.append(nameLabel)
        
        let nameEdit = LineEdit("", parent: formGroup)
        nameEdit.placeholderText = "Enter name"
        nameEdit.resize(width: 180, height: 25)
        nameEdit.move(x: 130, y: 30)
        widgets.append(nameEdit)
        
        // Show all widgets
        widgets.forEach { $0.show() }
        container.show()
        
        print("Widgets created with click handlers.")
        
        // Simulate the cleanup that happens when switching demos
        print("Starting cleanup (this should trigger the crash)...")
        
        // This is the pattern from ComponentDemos.swift cleanup()
        widgets.forEach { $0.hide() }
        
        // Critical: Test if we can safely remove widgets
        // The crash happens when widgets are deallocated while Qt is still
        // trying to disconnect signals
        print("Removing widgets from array (triggers deallocation)...")
        widgets.removeAll()
        
        // Force a small delay to let Qt process events
        usleep(100000) // 100ms
        
        print("Cleanup completed without crash!")
        
        // Additional test: Create and destroy buttons rapidly
        print("\nTesting rapid button creation/destruction...")
        for i in 1...5 {
            print("  Iteration \(i)...")
            let tempButton = Button("Temp \(i)", parent: container)
            tempButton.onClicked {
                print("Temp button \(i) clicked")
            }
            tempButton.show()
            usleep(10000) // 10ms
            tempButton.hide()
            // Button should deallocate here
        }
        
        print("Rapid creation/destruction test passed!")
        
        // Clean up the test
        container.hide()
        
        print("\n✅ Mixed Components crash test PASSED")
        print("No crashes during widget cleanup with active callbacks")
        
        return true
    }
}