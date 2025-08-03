// ABOUTME: Example automated test demonstrating QwiftUI testing framework capabilities
// ABOUTME: Shows best practices for writing automated UI tests with proper assertions

import Foundation
import QwiftUI
import QtBridge
import QwiftUITesting

/// Example of how to write automated QwiftUI tests
///
/// This example demonstrates:
/// - Setting up test windows and widgets
/// - Simulating user interactions
/// - Verifying widget states and properties
/// - Using async testing for event-driven scenarios
public func runExampleTests() {
    // Initialize the application
    let app = Application()
    
    // Test 1: Basic widget property verification
    test("Widget Properties") {
        let window = Widget()
        window.setWindowTitle("Property Test")
        window.resize(width: 300, height: 200)
        
        let label = Label("Test Label", parent: window)
        label.setObjectName("testLabel")
        
        // Verify properties
        testAssertEqual(label.text, "Test Label")
        testAssertEqual(label.objectName, "testLabel")
        
        // Change text and verify
        label.text = "Updated Text"
        testAssertEqual(label.text, "Updated Text")
    }
    
    // Test 2: Button click handling
    testAsync("Button Click Handling", timeout: 2.0) { done in
        let window = Widget()
        window.setWindowTitle("Click Test")
        window.resize(width: 300, height: 200)
        
        let statusLabel = Label("Ready", parent: window)
        statusLabel.move(x: 10, y: 10)
        
        let button = Button("Click Me", parent: window)
        button.move(x: 10, y: 50)
        
        var clicked = false
        button.onClicked {
            clicked = true
            statusLabel.text = "Clicked!"
        }
        
        window.show()
        
        // Simulate the interaction
        let simulator = EventSimulator()
        simulator.processEvents(100) // Let window render
        
        // Verify initial state
        testAssert(!clicked, "Button should not be clicked initially")
        testAssertEqual(statusLabel.text, "Ready")
        
        // Click the button
        simulator.click(button)
        simulator.processEvents(100) // Process the click event
        
        // Verify the click was handled
        testAssert(clicked, "Button should be clicked")
        testAssertEqual(statusLabel.text, "Clicked!")
        
        done()
    }
    
    // Test 3: Counter increment test
    testAsync("Counter Increment", timeout: 2.0) { done in
        let window = Widget()
        window.setWindowTitle("Counter Test")
        
        var count = 0
        let label = Label("Count: 0", parent: window)
        label.move(x: 10, y: 10)
        
        let button = Button("+1", parent: window)
        button.move(x: 10, y: 50)
        button.onClicked {
            count += 1
            label.text = "Count: \(count)"
        }
        
        window.show()
        
        let simulator = EventSimulator()
        simulator.processEvents(100)
        
        // Click multiple times and verify count
        for expected in 1...3 {
            simulator.click(button)
            simulator.processEvents(50)
            
            testAssertEqual(count, expected)
            testAssertEqual(label.text, "Count: \(expected)")
        }
        
        done()
    }
    
    // Test 4: Widget visibility
    test("Widget Visibility") {
        let window = Widget()
        let button = Button("Test", parent: window)
        
        window.show()
        testAssert(window.isVisible, "Window should be visible")
        testAssert(testAssertIsVisible(button.getBridgeWidget()), "Button should be visible")
        
        button.hide()
        testAssert(!testAssertIsVisible(button.getBridgeWidget()), "Button should be hidden")
        
        button.show()
        testAssert(testAssertIsVisible(button.getBridgeWidget()), "Button should be visible again")
    }
    
    // Test 5: Focus management
    testAsync("Focus Management", timeout: 2.0) { done in
        let window = Widget()
        window.setWindowTitle("Focus Test")
        
        let button1 = Button("Button 1", parent: window)
        button1.move(x: 10, y: 10)
        
        let button2 = Button("Button 2", parent: window)
        button2.move(x: 10, y: 50)
        
        window.show()
        
        let simulator = EventSimulator()
        simulator.processEvents(100)
        
        // Set focus to button1
        simulator.setFocus(button1)
        simulator.processEvents(50)
        testAssert(simulator.hasFocus(button1), "Button 1 should have focus")
        
        // Move focus to button2
        simulator.setFocus(button2)
        simulator.processEvents(50)
        testAssert(simulator.hasFocus(button2), "Button 2 should have focus")
        testAssert(!simulator.hasFocus(button1), "Button 1 should not have focus")
        
        done()
    }
    
    // Complete the test suite
    finishTesting()
}

// MARK: - Test Utilities

/// Helper to create a test window with standard setup
func createTestWindow(title: String = "Test Window") -> Widget {
    let window = Widget()
    window.setWindowTitle(title)
    window.resize(width: 400, height: 300)
    window.show()
    return window
}

/// Helper to wait for a condition with timeout
func waitForCondition(
    _ condition: @escaping () -> Bool,
    timeout: TimeInterval = 1.0,
    message: String = "Condition not met"
) -> Bool {
    let simulator = EventSimulator()
    let timeoutMs = Int(timeout * 1000)
    var elapsed = 0
    
    while elapsed < timeoutMs {
        if condition() {
            return true
        }
        simulator.processEvents(50)
        elapsed += 50
    }
    
    testAssert(false, message)
    return false
}