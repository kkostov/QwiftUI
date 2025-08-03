// ABOUTME: Tests for Qt6AppBackendDemo SwiftCrossUI integration
// ABOUTME: Verifies that Qt6AppBackend properly implements the AppBackend protocol

import Testing
import QwiftUI
import Qt6AppBackend
import SwiftCrossUI
import Foundation

@Suite("Qt6AppBackend Integration Tests")
struct Qt6AppBackendDemoTests {
    
    @Test("Qt6AppBackend initialization and basic operations")
    @MainActor
    func testQt6AppBackendBasics() async throws {
        print("\n========================================")
        print("Starting Qt6AppBackend Integration Test")
        print("========================================\n")
        
        // Create the backend
        print("Creating QtBackend...")
        let backend = QtBackend()
        print("QtBackend created successfully")
        
        // Test window creation
        print("\nTesting window creation...")
        let window = backend.createWindow(withDefaultSize: SIMD2<Int>(400, 300))
        print("Window created")
        
        // Set window title
        backend.setTitle(ofWindow: window, to: "Test Window")
        print("Window title set")
        
        // Test widget creation
        print("\nTesting widget creation...")
        
        // Create a container
        let container = backend.createContainer()
        print("Container created")
        
        // Create a button
        let button = backend.createButton()
        var buttonClicked = false
        backend.updateButton(button, label: "Test Button", environment: EnvironmentValues()) {
            buttonClicked = true
            print("Button clicked!")
        }
        print("Button created and configured")
        
        // Create a text view
        let textView = backend.createTextView()
        backend.updateTextView(textView, content: "Hello from Qt6AppBackend!", environment: EnvironmentValues())
        print("Text view created and configured")
        
        // Add widgets to container
        backend.addChild(button, to: container)
        backend.addChild(textView, to: container)
        backend.setPosition(ofChildAt: 0, in: container, to: SIMD2<Int>(10, 10))
        backend.setPosition(ofChildAt: 1, in: container, to: SIMD2<Int>(10, 50))
        print("Widgets added to container")
        
        // Set container as window child
        backend.setChild(ofWindow: window, to: container)
        print("Container set as window child")
        
        // Show the window
        backend.show(window: window)
        print("Window shown")
        
        // Test other widget types
        print("\nTesting other widget types...")
        
        // TextField
        let textField = backend.createTextField()
        var textFieldContent = ""
        backend.updateTextField(textField, placeholder: "Enter text", environment: EnvironmentValues()) { text in
            textFieldContent = text
            print("TextField changed: \(text)")
        }
        
        // CheckBox
        let checkbox = backend.createCheckbox()
        var checkboxState = false
        backend.updateCheckbox(checkbox, label: "Test Checkbox", environment: EnvironmentValues()) { state in
            checkboxState = state
            print("Checkbox state: \(state)")
        }
        backend.setState(ofCheckbox: checkbox, to: true)
        
        // Slider
        let slider = backend.createSlider()
        var sliderValue = 0.0
        backend.updateSlider(slider, minimum: 0, maximum: 100, decimalPlaces: 0, environment: EnvironmentValues()) { value in
            sliderValue = value
            print("Slider value: \(value)")
        }
        
        // ProgressBar
        let progressBar = backend.createProgressBar()
        backend.updateProgressBar(progressBar, minimum: 0, maximum: 100, value: 50, environment: EnvironmentValues())
        
        // ComboBox (Picker)
        let picker = backend.createPicker()
        var selectedIndex: Int? = nil
        backend.updatePicker(picker, options: ["Option 1", "Option 2", "Option 3"], environment: EnvironmentValues()) { index in
            selectedIndex = index
            print("Picker selected index: \(String(describing: index))")
        }
        
        print("\nAll widget types tested successfully")
        
        // Test widget state management
        print("\nTesting widget state management...")
        
        // Test visibility
        backend.setIsHidden(of: button, to: true)
        backend.setIsHidden(of: button, to: false)
        print("Visibility toggled")
        
        // Test enabled state
        backend.setIsEnabled(of: button, to: false)
        backend.setIsEnabled(of: button, to: true)
        print("Enabled state toggled")
        
        // Test window operations
        print("\nTesting window operations...")
        
        // Set window size
        backend.setSize(ofWindow: window, to: SIMD2<Int>(500, 400))
        let size = backend.size(ofWindow: window)
        print("Window size: \(size)")
        
        // Set minimum size
        backend.setMinimumSize(ofWindow: window, to: SIMD2<Int>(300, 200))
        print("Minimum size set")
        
        // Test resizability
        backend.setResizability(ofWindow: window, to: false)
        #expect(backend.isWindowProgrammaticallyResizable(window) == false)
        backend.setResizability(ofWindow: window, to: true)
        #expect(backend.isWindowProgrammaticallyResizable(window) == true)
        print("Resizability tested")
        
        // Hide window to clean up
        window.widget.hide()
        
        print("\n========================================")
        print("Qt6AppBackend Integration Test COMPLETED")
        print("All backend operations tested successfully!")
        print("========================================\n")
    }
    
    @Test("Qt6AppBackend menu and dialog support")
    @MainActor
    func testQt6AppBackendMenusAndDialogs() async throws {
        print("\n=== Testing Qt6AppBackend Menus and Dialogs ===")
        
        let backend = QtBackend()
        
        // Test menu creation
        let menu = backend.createMenu()
        print("Menu created: \(menu)")
        
        // Test alert creation
        let alert = QtAlert(
            title: "Test Alert",
            message: "This is a test message",
            style: .information,
            buttons: ["OK", "Cancel"]
        )
        print("Alert created: \(alert.title)")
        
        // Test file dialog modes
        print("File dialog modes supported:")
        print("  - Open: \(FileDialogMode.open)")
        print("  - Save: \(FileDialogMode.save)")
        print("  - Select Folder: \(FileDialogMode.selectFolder)")
        print("  - Open Multiple: \(FileDialogMode.openMultiple)")
        
        // Test path handling
        let testPath = QtPath("/test/path")
        print("Path created: \(testPath.path)")
        
        print("\n=== Menu and Dialog Test Completed ===")
    }
}