# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Use @agent-swift-cpp-interop.

## Project Overview

QwiftUI is an experimental Swift UI library based on Qt6, implementing cross-platform GUI development using Swift 6.2's C++ interoperability features. The library itself is standalone and does not depend on SwiftCrossUI.

**Key Goals**:

- Provide Qt6 access through direct C++ interop without C API bridging, leveraging Swift 6.2's enhanced C++ support
- Maintain QwiftUI as a standalone library for direct Qt6 access from Swift
- Provide optional SwiftCrossUI integration through a separate Qt6AppBackend target

## Build Commands

```bash
swift build                    # Build the project
swift test                     # Run tests (no tests currently)
swift package resolve          # Resolve dependencies
swift run QtDemo #runs the demo app
swift run SimpleTestDemo         # Run the UI testing app
```

## Architecture

The project has transitioned from a C wrapper approach to direct Swift C++ interoperability:

### Current Target Structure

1. **QtBridge** - C++ wrapper classes for Qt types
   - Location: `Sources/QtBridge/`
   - Purpose: Thin C++ layer providing Swift-compatible Qt widget wrappers
   - Key classes: `SwiftQApplication`, `SwiftQWidget`, `SwiftQLabel`
   - Uses standard C++ types (std::string) for Swift compatibility
   - Dependencies: None (pure C++)

2. **QwiftUI** - Standalone Swift API layer
   - Location: `Sources/QwiftUI/`
   - Purpose: High-level Swift wrappers around QtBridge C++ classes, think UIKit-style API around Qt6 for Swift
   - Key files:
     - `SimpleApp.swift` - Manages Qt application lifecycle
     - `Widget.swift` - Base widget wrapper, other controls can inherit from it
     - `Label.swift` - Label widget implementation
     - `Application.swift` - Application management
   - Dependencies: QtBridge only (no SwiftCrossUI dependency)

3. **Qt6AppBackend** - SwiftCrossUI integration (planned)
   - Location: `Sources/Qt6AppBackend/`
   - Purpose: Implements SwiftCrossUI's AppBackend protocol using QwiftUI
   - Dependencies: QwiftUI + SwiftCrossUI
   - Key components:
     - `QtBackend.swift` - AppBackend protocol implementation
     - `QtWindow.swift` - Window abstraction for SwiftCrossUI
     - `QtBackendWidget.swift` - Widget wrapper for AppBackend

4. **QtDemo** - Example executable
   - Location: `Sources/QtDemo/`
   - Purpose: Demonstrates direct C++ interop usage
   - Shows window creation, widget hierarchy, and event handling
   - Can optionally use Qt6AppBackend for SwiftCrossUI demos

### Legacy Target (Commented Out)

- **CQtWrapper** - Original C API wrapper (deprecated in favor of C++ interop)

## Swift C++ Interop Implementation

### Key Technical Details

- Swift version: 6.2 (required for enhanced C++ interop features)
- Interoperability mode: `.interoperabilityMode(.Cxx)` enabled on all targets
- Qt integration: Direct framework linking without module maps
- Memory management: Raw pointers instead of std::unique_ptr (avoids incomplete type issues)

### Current Implementation Status

**Working**:

- Direct C++ class instantiation from Swift
- Basic widget creation (QWidget, QLabel)
- Window properties (title, size, position)
- Factory functions for widget creation

**Known Issues**:

- QApplication must be created before any QWidget
- Type casting between widget classes needs refinement
- Qt namespace constants not directly accessible in Swift

### C++ Wrapper Design

```cpp
// Example from QtBridge.h
class SwiftQApplication {
private:
    QApplication* app;
public:
    SwiftQApplication(int& argc, char** argv);
    ~SwiftQApplication();
    int exec();
};
```

## Platform-Specific Setup

**macOS (Homebrew)**:

- Qt6 installed via: `brew install qt`
- Expected location: `/opt/homebrew/Cellar/qt/6.9.1/`
- Frameworks linked: QtCore, QtWidgets, QtGui

**Linux**:

- Qt6 headers expected at: `/usr/include/qt6`
- System package installation required

**Note**: Qt paths are hardcoded in Package.swift and need updating for different Qt versions.

## Development Workflow

### Adding New Qt Widget Support

1. Add C++ wrapper class to `QtBridge.h`:

   ```cpp
   class SwiftQButton : public SwiftQWidget {
   public:
       SwiftQButton(const std::string& text);
       void setText(const std::string& text);
   };
   ```

2. Implement in `QtBridge.cpp`

3. Create Swift wrapper in QwiftUI target

4. Use factory functions for complex object creation to avoid initialization order issues

### Updating Qt Version

1. Update paths in Package.swift:
   - `cxxSettings` include paths
   - `linkerSettings` framework paths
2. Ensure Qt version compatibility with C++ features used

### Debugging Tips

- Check QApplication initialization order when encountering "Must construct a QApplication before a QWidget" errors
- Use factory functions (`createWidget`, `createLabel`) to ensure proper C++ object construction
- Print statements help trace initialization order issues
- Qt applications require running event loop, it must always be started for executable targets.

## Project Constraints

1. **Swift Package Manager only** - No additional build systems
2. **Minimal dependencies** - QwiftUI itself has no Swift dependencies; Qt6AppBackend adds SwiftCrossUI
3. **Cross-platform focus** - Primary targets are Linux/Windows where SwiftUI is unavailable
4. **Direct C++ interop** - No C wrapper layer per user requirement
5. **Clean separation** - QwiftUI remains standalone; SwiftCrossUI support is optional via Qt6AppBackend

## Code Style

- Follow Swift API Design Guidelines
- Use spaces, not tabs
- Document all public APIs
- C++ code should use modern C++ practices (C++17)
- Prefer Swift-safe C++ patterns (std::string over const char\*)

## Beautiful Swift API Goal

The primary goal is to create a beautiful, idiomatic Swift API that feels natural to Swift developers:

- **No raw pointers in Swift code** - Hide all unsafe operations in the C++ bridge
- **Use Swift enumerations** - Replace magic numbers (like `0x0084`) with proper Swift enums
- **Natural naming** - Use names like `widget` or `control` instead of `pointee`
- **Type safety** - Leverage Swift's type system for compile-time safety
- **Documentation** - Include relevant Qt documentation as Swift comments
- **SwiftUI-like feel** - Make the API feel familiar to SwiftUI developers where possible
- **Automatic memory management** - No manual memory management required from client code

Example of what we want to avoid:

```swift
// Bad - uses magic numbers and pointee
label.pointee.setAlignment(0x0084)

// Bad - requires manual memory management
storeAllocatedCallback(callback)
```

Example of beautiful Swift:

```swift
// Good - uses Swift enum with clear intent
label.setAlignment(.center)

// Good - automatic memory management
button.onClicked {
    print("Button clicked!")
}
```

## Memory Management Architecture

QwiftUI uses a sophisticated automatic memory management system that provides UIKit/AppKit-like simplicity:

### Callback Memory Management

- **CallbackManager** - Singleton that automatically tracks and deallocates callbacks
- **Automatic cleanup** - Callbacks are automatically freed when widgets are deallocated
- **No manual management** - Client code never needs to call `storeAllocatedCallback` or similar
- **Safe event handling** - All event handlers are automatically managed through `CallbackHelper`

### Widget Lifecycle

- **RAII pattern** - C++ objects are created in init and destroyed in deinit
- **Reference semantics** - Widgets use class semantics with automatic reference counting
- **Parent-child relationships** - Qt's parent-child hierarchy works seamlessly with Swift ARC
- **No manual deletion** - The Swift runtime automatically manages widget lifetime

### Implementation Details

1. **SafeEventWidget base class** - Provides automatic callback cleanup in deinit
2. **CallbackHelper functions** - Automatically register callbacks with CallbackManager
3. **Unified cleanup** - `CallbackManager.shared.remove(for: self)` handles all cleanup
4. **Zero client burden** - Developers never see or interact with memory management

## Concurrency

The project uses Swift 6.2's concurrency features with MainActor isolation:

- All targets have `.defaultIsolation(MainActor.self)` in Package.swift
- This means all code is MainActor-isolated by default
- No locks are used - rely on actor isolation for thread safety
- Command line arguments are handled through static storage to avoid deinit concurrency issues
- Qt requires argc/argv to remain valid for QApplication's lifetime

## Demo Application Organization

The QtDemo target demonstrates QwiftUI capabilities through a dropdown-based gallery system:

### Structure

- **AppMain.swift** - Main entry point with dropdown navigation
- **ComponentDemos.swift** - Individual demo implementations for each widget category
- **main.swift** - Selects which demo to run (defaults to AppMain)

### Demo Categories

1. **Welcome** - Introduction screen
2. **Labels & Alignment** - Text positioning demonstrations
3. **Buttons** - Various button styles and states
4. **Text Input** - LineEdit and TextEdit widgets
5. **Checkboxes & Radio Buttons** - Checkable widgets
6. **Dropdown Lists** - ComboBox demonstrations
7. **Advanced Widgets** - Sliders, ProgressBars, ScrollViews, ImageViews
8. **Mixed Components** - Complex form example

### Adding New Demos

1. Create a new class implementing `ComponentDemo` protocol in ComponentDemos.swift
2. Add the demo to the dropdown in AppMain.swift
3. Implement `setupDemo(in:)` and `cleanup()` methods
4. All widgets should be tracked for proper cleanup

## SwiftCrossUI Integration

For details on implementing SwiftCrossUI's AppBackend protocol with QwiftUI, see `docs/004-swiftcrossui-appbackend.md`. The integration follows these principles:

- **QwiftUI** remains a standalone library for direct Qt6 access from Swift
- **Qt6AppBackend** is a separate target that bridges QwiftUI with SwiftCrossUI
- New Qt widgets should be added to QwiftUI first, then exposed through Qt6AppBackend
- The separation ensures QwiftUI can be used independently by projects that don't need SwiftCrossUI

## Testing and debugging

QwiftUI provides `QwiftUITesting` target for developers to test their apps. Use the same approach:

- Create a testing target under Tests
- Use Swift testing https://developer.apple.com/documentation/testing
- import QwiftUITesting
- creata a single test function (because Swift tests always run concurrently but our application can't) and in it, write out GUI simulations like clicks, and focus and assertions to make sure functionality is as expected.
- You can extend `QwiftUITesting` with functions when they're needed (e.g. additional simulation of events).
- IMPORTANT: All demo apps (QtDemo, Qt6AppBackendDemo) must have such tests.
