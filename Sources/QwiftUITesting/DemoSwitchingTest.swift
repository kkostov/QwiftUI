// ABOUTME: Test that simulates switching between demos like in QtDemo
// ABOUTME: Verifies that cleanup during demo transitions doesn't crash

import Foundation
import QwiftUI

/// Test that simulates the exact demo switching pattern from QtDemo
@MainActor
public struct DemoSwitchingTest {
    
    public static func run() -> Bool {
        print("=== Demo Switching Test ===")
        print("Simulating QtDemo's demo switching pattern...")
        
        // We assume QApplication is already created by the test harness
        // Just create Application for processEvents
        let app = Application()  // Application provides processEvents
        
        // Create main container
        let mainWindow = Widget()
        mainWindow.setWindowTitle("Demo Switching Test")
        mainWindow.resize(width: 640, height: 500)
        
        // Create demo container like in AppMain
        let demoContainer = Widget(parent: mainWindow)
        demoContainer.resize(width: 600, height: 350)
        demoContainer.move(x: 20, y: 140)
        
        mainWindow.show()
        
        // Test switching between different demos
        var currentWidgets: [any QtWidget] = []
        
        print("\n1. Creating Button Demo...")
        // Simulate ButtonDemo
        currentWidgets = createButtonDemo(in: demoContainer)
        currentWidgets.forEach { $0.show() }
        print("   Button demo created with \(currentWidgets.count) widgets")
        
        // Process events
        app.processEvents()
        usleep(50000) // 50ms
        
        print("\n2. Switching to Mixed Components Demo...")
        // Clean up button demo
        currentWidgets.forEach { $0.hide() }
        currentWidgets.removeAll()
        
        // Create Mixed Components demo
        currentWidgets = createMixedComponentsDemo(in: demoContainer)
        currentWidgets.forEach { $0.show() }
        print("   Mixed components created with \(currentWidgets.count) widgets")
        
        // Process events
        app.processEvents()
        usleep(50000) // 50ms
        
        print("\n3. Switching to Advanced Widgets Demo...")
        // Clean up mixed components
        currentWidgets.forEach { $0.hide() }
        currentWidgets.removeAll()
        
        // Create Advanced Widgets demo
        currentWidgets = createAdvancedWidgetsDemo(in: demoContainer)
        currentWidgets.forEach { $0.show() }
        print("   Advanced widgets created with \(currentWidgets.count) widgets")
        
        // Process events
        app.processEvents()
        usleep(50000) // 50ms
        
        print("\n4. Switching back to Mixed Components...")
        // Clean up advanced widgets
        currentWidgets.forEach { $0.hide() }
        currentWidgets.removeAll()
        
        // Create Mixed Components again (this is where the crash often happens)
        currentWidgets = createMixedComponentsDemo(in: demoContainer)
        currentWidgets.forEach { $0.show() }
        print("   Mixed components recreated with \(currentWidgets.count) widgets")
        
        // Process events
        app.processEvents()
        usleep(50000) // 50ms
        
        print("\n5. Final cleanup...")
        currentWidgets.forEach { $0.hide() }
        currentWidgets.removeAll()
        
        // Hide main window
        mainWindow.hide()
        
        print("\n✅ Demo Switching test PASSED")
        print("Successfully switched between demos without crashes")
        
        return true
    }
    
    private static func createButtonDemo(in container: Widget) -> [any QtWidget] {
        var widgets: [any QtWidget] = []
        
        let title = Label("Button Demo", parent: container)
        title.alignment = Qt.Alignment.center
        title.resize(width: 560, height: 40)
        title.move(x: 20, y: 20)
        widgets.append(title)
        
        // Create buttons with handlers
        let normalButton = Button("Normal Button", parent: container)
        normalButton.resize(width: 150, height: 35)
        normalButton.move(x: 20, y: 80)
        normalButton.onClicked {
            print("Normal button clicked")
        }
        widgets.append(normalButton)
        
        let defaultButton = Button("Default Button", parent: container)
        defaultButton.isDefault = true
        defaultButton.resize(width: 150, height: 35)
        defaultButton.move(x: 180, y: 80)
        defaultButton.onClicked {
            print("Default button clicked")
        }
        widgets.append(defaultButton)
        
        return widgets
    }
    
    private static func createMixedComponentsDemo(in container: Widget) -> [any QtWidget] {
        var widgets: [any QtWidget] = []
        
        let title = Label("Mixed Components Demo", parent: container)
        title.alignment = Qt.Alignment.center
        title.resize(width: 560, height: 40)
        title.move(x: 20, y: 20)
        widgets.append(title)
        
        // Form group
        let formGroup = GroupBox("User Registration", parent: container)
        formGroup.resize(width: 540, height: 280)
        formGroup.move(x: 20, y: 70)
        widgets.append(formGroup)
        
        // Name field
        let nameLabel = Label("Full Name:", parent: formGroup)
        nameLabel.resize(width: 100, height: 25)
        nameLabel.move(x: 20, y: 30)
        widgets.append(nameLabel)
        
        let nameEdit = LineEdit("", parent: formGroup)
        nameEdit.placeholderText = "John Doe"
        nameEdit.resize(width: 180, height: 25)
        nameEdit.move(x: 130, y: 30)
        widgets.append(nameEdit)
        
        // Submit and Cancel buttons with handlers
        let submitButton = Button("Register", parent: container)
        submitButton.isDefault = true
        submitButton.resize(width: 100, height: 35)
        submitButton.move(x: 380, y: 360)
        submitButton.onClicked {
            print("Submit clicked in Mixed Components")
        }
        widgets.append(submitButton)
        
        let cancelButton = Button("Cancel", parent: container)
        cancelButton.resize(width: 100, height: 35)
        cancelButton.move(x: 270, y: 360)
        cancelButton.onClicked {
            print("Cancel clicked in Mixed Components")
        }
        widgets.append(cancelButton)
        
        return widgets
    }
    
    private static func createAdvancedWidgetsDemo(in container: Widget) -> [any QtWidget] {
        var widgets: [any QtWidget] = []
        
        let title = Label("Advanced Widgets Demo", parent: container)
        title.alignment = Qt.Alignment.center
        title.resize(width: 560, height: 40)
        title.move(x: 20, y: 10)
        widgets.append(title)
        
        // Slider with handler
        let hSlider = Slider(orientation: .horizontal, parent: container)
        hSlider.move(x: 20, y: 80)
        hSlider.resize(width: 250, height: 30)
        hSlider.minimum = 0
        hSlider.maximum = 100
        hSlider.value = 25
        hSlider.onValueChanged { value in
            print("Slider value: \(value)")
        }
        widgets.append(hSlider)
        
        // Progress bar
        let progressBar = ProgressBar(parent: container)
        progressBar.move(x: 20, y: 120)
        progressBar.resize(width: 250, height: 25)
        progressBar.value = 25
        widgets.append(progressBar)
        
        // Reset button with handler
        let resetButton = Button("Reset All Values", parent: container)
        resetButton.move(x: 20, y: 160)
        resetButton.resize(width: 120, height: 30)
        resetButton.onClicked {
            print("Reset clicked")
            hSlider.value = 50
            progressBar.value = 50
        }
        widgets.append(resetButton)
        
        return widgets
    }
}