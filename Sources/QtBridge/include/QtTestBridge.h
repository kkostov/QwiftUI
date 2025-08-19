// ABOUTME: C++ bridge for Qt Test framework functionality
// ABOUTME: Provides Swift-compatible interfaces for widget testing and event simulation

#pragma once

#include <string>

// Forward declarations
class QWidget;
class QPoint;
class SwiftQWidget;  // From QtBridge.h

// Use simple integers for button/key/modifier constants that Swift can understand
// Mouse buttons
static const int TEST_MOUSE_BUTTON_LEFT = 1;
static const int TEST_MOUSE_BUTTON_RIGHT = 2;
static const int TEST_MOUSE_BUTTON_MIDDLE = 4;

// Common keys  
static const int TEST_KEY_TAB = 0x01000001;
static const int TEST_KEY_RETURN = 0x01000004;
static const int TEST_KEY_ESCAPE = 0x01000000;
static const int TEST_KEY_SPACE = 0x20;
static const int TEST_KEY_BACKSPACE = 0x01000003;
static const int TEST_KEY_DELETE = 0x01000007;
static const int TEST_KEY_UP = 0x01000013;
static const int TEST_KEY_DOWN = 0x01000015;
static const int TEST_KEY_LEFT = 0x01000012;
static const int TEST_KEY_RIGHT = 0x01000014;

// Key modifiers
static const int TEST_KEY_MODIFIER_NONE = 0;
static const int TEST_KEY_MODIFIER_SHIFT = 0x02000000;
static const int TEST_KEY_MODIFIER_CONTROL = 0x04000000;
static const int TEST_KEY_MODIFIER_ALT = 0x08000000;
static const int TEST_KEY_MODIFIER_META = 0x10000000;

// Main test class for managing Qt Test lifecycle
class SwiftQTest {
private:
    static SwiftQTest* instance_;
    bool initialized;
    
public:
    SwiftQTest();
    ~SwiftQTest();
    
    static SwiftQTest* instance();
    
    // Initialize Qt Test framework
    void initialize();
    
    // Process events with timeout
    void processEvents(int ms = 0);
    
    // Wait for specified time
    void wait(int ms);
    
    // Cleanup after tests
    void cleanup();
};

// Widget finder for testing - simplified interface
class SwiftQTestFinder {
private:
    SwiftQWidget* rootWidget;
    
public:
    SwiftQTestFinder();
    SwiftQTestFinder(SwiftQWidget* root);
    ~SwiftQTestFinder();
    
    // Find widgets by object name - returns first match
    SwiftQWidget* findByObjectName(const std::string& name);
    
    // Find all widgets by object name - use multiple calls to get each
    int countByObjectName(const std::string& name);
    SwiftQWidget* getByObjectNameAt(const std::string& name, int index);
    
    // Find widgets by class name (type)
    int countByClassName(const std::string& className);
    SwiftQWidget* getByClassNameAt(const std::string& className, int index);
    
    // Find children of a widget
    int countChildren(SwiftQWidget* parent);
    SwiftQWidget* getChildAt(SwiftQWidget* parent, int index);
    
    // Wait for widget to appear
    SwiftQWidget* waitForWidget(const std::string& name, int timeoutMs);
    
    // Set the root widget for searches
    void setRoot(SwiftQWidget* root);
};

// Event simulator for testing - simplified interface
class SwiftQTestSimulator {
public:
    SwiftQTestSimulator();
    ~SwiftQTestSimulator();
    
    // Mouse events - button is an int constant (TEST_MOUSE_BUTTON_*)
    void mouseClick(SwiftQWidget* widget, int button, int x, int y);
    void mouseClickCenter(SwiftQWidget* widget, int button);  // Click at center
    void mouseDClick(SwiftQWidget* widget, int button, int x, int y);
    void mouseDClickCenter(SwiftQWidget* widget, int button);
    void mouseMove(SwiftQWidget* widget, int x, int y, int delay);
    void mouseDrag(SwiftQWidget* widget, int fromX, int fromY, int toX, int toY);
    void mousePress(SwiftQWidget* widget, int button, int x, int y);
    void mousePressCenter(SwiftQWidget* widget, int button);
    void mouseRelease(SwiftQWidget* widget, int button, int x, int y);
    void mouseReleaseCenter(SwiftQWidget* widget, int button);
    
    // Keyboard events - key and modifiers are int constants
    void keyClick(SwiftQWidget* widget, int key, int modifiers, int delay);
    void keyClickNoMod(SwiftQWidget* widget, int key);  // No modifiers, no delay
    void keyPress(SwiftQWidget* widget, int key, int modifiers);
    void keyPressNoMod(SwiftQWidget* widget, int key);
    void keyRelease(SwiftQWidget* widget, int key, int modifiers);
    void keyReleaseNoMod(SwiftQWidget* widget, int key);
    void keyClicks(SwiftQWidget* widget, const std::string& text, int modifiers, int delay);
    void keyClicksNoMod(SwiftQWidget* widget, const std::string& text);  // No modifiers, no delay
    void keySequence(SwiftQWidget* widget, const std::string& sequence);
    
    // Focus events
    void setFocus(SwiftQWidget* widget);
    bool hasFocus(SwiftQWidget* widget);
    
    // Timing
    void wait(int ms);
    void processEvents(int ms);
    void processEventsDefault();  // Process without wait
};

// Test assertions helper - C-style functions for Swift compatibility
// Widget state assertions
bool testAssertIsVisible(SwiftQWidget* widget);
bool testAssertIsEnabled(SwiftQWidget* widget);
bool testAssertIsHidden(SwiftQWidget* widget);

// Geometry assertions
bool testAssertHasSize(SwiftQWidget* widget, int width, int height);
bool testAssertHasPosition(SwiftQWidget* widget, int x, int y);

// Content assertions
std::string testAssertGetText(SwiftQWidget* widget);
bool testAssertHasText(SwiftQWidget* widget, const std::string& expected);

// Focus assertions
bool testAssertHasFocus(SwiftQWidget* widget);

// Comparison utilities
bool testAssertCompareWidgets(SwiftQWidget* w1, SwiftQWidget* w2);

// Factory functions for test components
SwiftQTest* createQTest();
SwiftQTestFinder* createTestFinder();
SwiftQTestFinder* createTestFinderWithRoot(SwiftQWidget* root);
SwiftQTestSimulator* createTestSimulator();