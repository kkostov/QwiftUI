# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

QwiftUI is an experimental Swift UI library based on Qt6, implementing cross-platform GUI development using Swift 6.2's C++ interoperability features. The project aims to create a complete implementation of SwiftCrossUI's AppBackend interface using Qt6 widgets.

**Key Goal**: Provide Qt6 access through direct C++ interop without C API bridging, leveraging Swift 6.2's enhanced C++ support.

## Build Commands

```bash
swift build                    # Build the project
swift test                     # Run tests (no tests currently)
swift package resolve          # Resolve dependencies
./.build/debug/QtDemo         # Run the demo application
```

## Architecture

The project has transitioned from a C wrapper approach to direct Swift C++ interoperability:

### Current Target Structure

1. **QtBridge** - C++ wrapper classes for Qt types
   - Location: `Sources/QtBridge/`
   - Purpose: Thin C++ layer providing Swift-compatible Qt widget wrappers
   - Key classes: `SwiftQApplication`, `SwiftQWidget`, `SwiftQLabel`
   - Uses standard C++ types (std::string) for Swift compatibility

2. **QwiftUI** - Swift API layer
   - Location: `Sources/QwiftUI/`
   - Purpose: High-level Swift wrappers around QtBridge C++ classes
   - Key files:
     - `SimpleApp.swift` - Manages Qt application lifecycle
     - `Widget.swift` - Base widget wrapper
     - `Label.swift` - Label widget implementation
     - `Application.swift` - Application management

3. **QtDemo** - Example executable
   - Location: `Sources/QtDemo/`
   - Purpose: Demonstrates direct C++ interop usage
   - Shows window creation, widget hierarchy, and event handling

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

## Project Constraints

1. **Swift Package Manager only** - No additional build systems
2. **Minimal dependencies** - Only SwiftCrossUI when fully integrated
3. **Cross-platform focus** - Primary targets are Linux/Windows where SwiftUI is unavailable
4. **Direct C++ interop** - No C wrapper layer per user requirement

## Code Style

- Follow Swift API Design Guidelines
- Use spaces, not tabs
- Document all public APIs
- C++ code should use modern C++ practices (C++17)
- Prefer Swift-safe C++ patterns (std::string over const char*)

## Beautiful Swift API Goal

The primary goal is to create a beautiful, idiomatic Swift API that feels natural to Swift developers:

- **No raw pointers in Swift code** - Hide all unsafe operations in the C++ bridge
- **Use Swift enumerations** - Replace magic numbers (like `0x0084`) with proper Swift enums
- **Natural naming** - Use names like `widget` or `control` instead of `pointee`
- **Type safety** - Leverage Swift's type system for compile-time safety
- **Documentation** - Include relevant Qt documentation as Swift comments
- **SwiftUI-like feel** - Make the API feel familiar to SwiftUI developers where possible

Example of what we want to avoid:
```swift
// Bad - uses magic numbers and pointee
label.pointee.setAlignment(0x0084)
```

Example of beautiful Swift:
```swift
// Good - uses Swift enum with clear intent
label.setAlignment(.center)
```

## Concurrency

The project uses Swift 6.2's concurrency features with MainActor isolation:

- All targets have `.defaultIsolation(MainActor.self)` in Package.swift
- This means all code is MainActor-isolated by default
- No locks are used - rely on actor isolation for thread safety
- Command line arguments are handled through static storage to avoid deinit concurrency issues
- Qt requires argc/argv to remain valid for QApplication's lifetime