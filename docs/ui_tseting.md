# QwiftUI Testing Framework

## Overview

The QwiftUI Testing Framework provides automated UI testing capabilities for QwiftUI applications by leveraging Qt6's testing framework through Swift-friendly APIs. It simulates user interactions, verifies widget states, and provides comprehensive test assertions with proper exit codes for CI/CD integration.

## Architecture

### Component Layers

```
┌─────────────────────────────────────────┐
│         Swift Test Code                 │
│      (Test assertions & logic)          │
├─────────────────────────────────────────┤
│         QwiftUITesting                  │
│   (Swift testing API & helpers)         │
├─────────────────────────────────────────┤
│          QtTestBridge                   │
│    (C++ testing bridge layer)           │
├─────────────────────────────────────────┤
│          Qt Test Framework              │
│    (QTest namespace & utilities)        │
└─────────────────────────────────────────┘
```

### Target Dependencies

```
QwiftUITesting
    ├── QtBridge (C++ bridge with Qt Test)
    └── QwiftUI (Swift UI layer)
```

## API Components

### 1. Event Simulation (`EventSimulator`)

Simulates user interactions with beautiful Swift APIs:

```swift
let simulator = EventSimulator()

// Mouse events
simulator.click(button)                          // Click at center
simulator.click(button, x: 10, y: 10)           // Click at specific position
simulator.doubleClick(widget)                    // Double-click
simulator.drag(from: 0, 0, to: 100, 100, in: widget)  // Drag operation

// Keyboard events  
simulator.keyPress(.return, widget: textField)   // Press a key
simulator.typeText("Hello", into: textField)     // Type text
simulator.keyboardShortcut("Ctrl+C", widget: widget)  // Keyboard shortcuts

// Focus management
simulator.setFocus(widget)
let hasFocus = simulator.hasFocus(widget)

// Event processing
simulator.processEvents(100)  // Process events for 100ms
simulator.wait(500)           // Wait for 500ms
```

Key design features:
- Swift enums for keys and mouse buttons (no magic numbers)
- Intuitive method names following Swift conventions
- Support for both specific coordinates and widget center clicking

### 2. Test Runner (`TestRunner`)

Manages test execution with proper result tracking:

```swift
let runner = TestRunner.shared

// Start a test
runner.startTest("Widget Properties")

// Make assertions
runner.assert(condition, "Error message")
runner.assertEqual(actual, expected, "Values should match")

// End test
runner.endTest()

// Check results
runner.printSummary()
if runner.allTestsPassed() {
    exit(0)
} else {
    exit(1)
}
```

Features:
- Result tracking with timing information
- Formatted output with emojis (✅ pass, ❌ fail)
- Automatic exit code management for CI/CD

### 3. Widget Query (`WidgetQuery`)

Find and interact with widgets:

```swift
let query = WidgetQuery()

// Find by object name
if let button = query.findByName("submitButton") as? Button {
    simulator.click(button)
}

// Wait for widget to appear
if let widget = query.waitForWidget("loadingLabel", timeout: 5.0) {
    // Widget is ready
}
```

### 4. Assertions

Test assertions for widget state verification:

```swift
// Basic assertions
testAssert(condition, "Message")
testAssertEqual(actual, expected)

// Widget state assertions (via C++ bridge)
testAssertIsVisible(widget.getBridgeWidget())
testAssertIsEnabled(widget.getBridgeWidget())
testAssertHasFocus(widget.getBridgeWidget())
```

## Example Test Suite

```swift
import Foundation
import QtBridge
import QwiftUI
import QwiftUITesting

// Create application
let app = Application()
let runner = TestRunner.shared

// Test 1: Button click updates label
runner.startTest("Button Click Updates Label")

let window = Widget()
let label = Label("Initial", parent: window)
let button = Button("Click Me", parent: window)

var clicked = false
button.onClicked {
    clicked = true
    label.text = "Clicked!"
}

window.show()

let simulator = EventSimulator()
simulator.wait(100)  // Let window render

// Simulate click
simulator.click(button)
simulator.processEvents(100)

// Verify
runner.assert(clicked, "Button callback should fire")
runner.assert(label.text == "Clicked!", "Label should update")
runner.endTest()

// Print results and exit
runner.printSummary()
exit(runner.allTestsPassed() ? 0 : 1)
```

## Implementation Status

### ✅ Completed

1. **C++ Bridge Layer** (`QtTestBridge.h/.cpp`)
   - `SwiftQTest` - Test lifecycle management with proper exit mechanisms
   - `SwiftQTestFinder` - Widget discovery by object name
   - `SwiftQTestSimulator` - Comprehensive event simulation (mouse, keyboard, focus)
   - Assertion helpers for widget state verification
   - Static exit methods for clean application termination

2. **Swift API** (`QwiftUITesting` target)
   - `EventSimulator.swift` - User interaction simulation with intuitive APIs
   - `TestRunner.swift` - Test execution, timing, and comprehensive reporting
   - `WidgetQuery.swift` - Widget finding utilities with timeout support
   - `Assertions.swift` - Test assertions for all widget properties
   - Supporting enums for keys, mouse buttons, modifiers (no magic numbers!)

3. **Test Executables**
   - **`SimpleTestDemo`** - Comprehensive test suite demonstrating all QwiftUI widgets and testing capabilities
   - **`MinimalExitTest`** - Minimal test demonstrating clean exit with proper codes

4. **Widget Test Coverage**
   - **Label**: Text updates, alignment
   - **Button**: Click simulation, checkable state, toggle functionality
   - **LineEdit**: Text input, placeholder, clear(), readOnly property
   - **CheckBox**: State changes including tri-state support
   - **RadioButton**: Exclusive selection within groups
   - **ComboBox**: Item management, selection changes
   - **GroupBox**: Container organization

5. **Event Simulation Features**
   - Mouse events (click, double-click, drag, position-specific clicks)
   - Keyboard input (key press, text typing, shortcuts)
   - Focus management (set focus, verify focus, tab navigation)
   - Event processing with configurable delays

### ✅ Resolved Issues

**Qt Event Loop Integration**
- **Previous Issue**: Complex widget hierarchies caused segfault during cleanup
- **Solution Implemented**: 
  - Proper event filter lifecycle management
  - Safe widget destruction sequence
  - Signal disconnection before deletion
  - Clean parent-child relationship handling
- **Result**: Tests now exit cleanly with proper exit codes

```swift
// Static methods available for callbacks to avoid Swift exclusivity issues
Application.staticScheduleExit(100, returnCode: exitCode)
```

**Swift 6.2 Concurrency**
- **Issue**: MainActor isolation conflicts with Qt callbacks
- **Solution**: Test executables don't use MainActor isolation
- **Note**: Application marked as `@unchecked Sendable` as workaround

### 🚧 Future Enhancements

- Screenshot capture during tests
- Performance benchmarking
- Test discovery mechanism
- Parallel test execution
- Integration with XCTest (if needed)
- Improved widget cleanup to prevent exit crashes

## Running Tests

```bash
# Build the project
swift build

# Run comprehensive test suite
swift run SimpleTestDemo

# Run minimal exit test
swift run MinimalExitTest

# Expected output from SimpleTestDemo (final lines):
# === Test Demonstration Complete ===
# ✅ All tests passed successfully!
# Exiting with code: 0
# Event loop exited with code: 0

# Expected output from MinimalExitTest:
# === Minimal Exit Test ===
# Starting Qt event loop...
# Test: Calling quit directly...
# Event loop exited with code: 0
```

Both test executables now exit cleanly with proper exit codes, making them fully suitable for CI/CD automation.

## CI/CD Integration

The framework is designed for continuous integration:

```yaml
# GitHub Actions example
- name: Run UI Tests
  run: |
    swift build
    swift run SimpleTestDemo
  # Job fails automatically if exit code is non-zero
```

## Best Practices

1. **Always process events after UI actions**
   ```swift
   simulator.click(button)
   simulator.processEvents(100)  // Give Qt time to handle the click
   ```

2. **Set meaningful object names**
   ```swift
   button.setObjectName("submitButton")
   // Makes finding widgets easier in tests
   ```

3. **Verify initial state before actions**
   ```swift
   runner.assert(label.text == "Initial", "Check initial state")
   simulator.click(button)
   runner.assert(label.text == "Updated", "Check after action")
   ```

4. **Use appropriate wait times**
   ```swift
   window.show()
   simulator.wait(100)  // Let window render before testing
   ```

## Technical Notes

### Qt Test Integration
- Uses Qt Test's `QTest` namespace for low-level operations
- Event simulation goes through Qt's native event system
- Ensures proper widget handle acquisition before events

### Swift/C++ Interop
- All Qt constants exposed as Swift enums
- C++ std::string converted to Swift String
- Pointer safety managed through Swift's unsafe pointer APIs

### MainActor Isolation
- All targets use `.defaultIsolation(MainActor.self)` in Swift 6.2
- Ensures thread safety for UI operations
- No explicit locks needed

## File Locations

- **C++ Bridge**: `Sources/QtBridge/include/QtTestBridge.h`, `Sources/QtBridge/QtTestBridge.cpp`
- **Swift API**: `Sources/QwiftUITesting/*.swift`
- **Test Demo**: `Sources/SimpleTestDemo/main.swift`
- **Package Config**: `Package.swift` (see QwiftUITesting target)

## References

- [Qt Test Overview](https://doc.qt.io/qt-6/qtest-overview.html)
- [Swift C++ Interoperability](https://www.swift.org/documentation/cxx-interop/)
- QwiftUI project documentation