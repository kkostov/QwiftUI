#pragma once

#include <memory>
#include <string>
#include <vector>

// Forward declarations
class QApplication;
class QWidget;
class QLabel;

// Simple arguments builder for Qt
class ArgumentsBuilder {
private:
    std::vector<std::string> args;
    
public:
    ArgumentsBuilder() = default;
    void addArg(const std::string& arg) { args.push_back(arg); }
    const std::vector<std::string>& getArgs() const { return args; }
};

// QApplication wrapper - manages Qt application lifecycle
class SwiftQApplication {
private:
    std::vector<std::string> storedArgs;  // Keep args alive
    std::vector<char*> argv;
    int* argc;  // Must be a pointer for Qt
    QApplication* app;
    
    void buildArgv();
    void ensureInitialized();
    
public:
    SwiftQApplication();
    SwiftQApplication(const ArgumentsBuilder& builder);
    ~SwiftQApplication();
    
    // Get the global QApplication instance
    static QApplication* instance();
    
    // Delete copy operations
    SwiftQApplication(const SwiftQApplication&) = delete;
    SwiftQApplication& operator=(const SwiftQApplication&) = delete;
    
    // Allow move operations
    SwiftQApplication(SwiftQApplication&&) = default;
    SwiftQApplication& operator=(SwiftQApplication&&) = default;
    
    int exec();
    void processEvents();
};

// Base widget wrapper - Qt manages lifetime through parent-child relationships
class SwiftQWidget {
protected:
    QWidget* widget;
    bool ownsWidget;
    
public:
    SwiftQWidget();
    SwiftQWidget(SwiftQWidget* parent);
    virtual ~SwiftQWidget();
    
    // Basic operations
    void show();
    void hide();
    void setWindowTitle(const std::string& title);
    void resize(int width, int height);
    void move(int x, int y);
    
    // Get internal widget (ensures widget exists)
    QWidget* getQWidget();
    
protected:
    // Constructor for derived classes
    SwiftQWidget(QWidget* existingWidget, bool takeOwnership);
    
    // Ensure widget is initialized
    virtual void ensureWidget();
    
    // Parent widget for lazy initialization
    SwiftQWidget* parentWidget = nullptr;
};

// Label wrapper
class SwiftQLabel : public SwiftQWidget {
private:
    std::string labelText;
    int labelAlignment = 0;
    
protected:
    void ensureWidget() override;
    
public:
    SwiftQLabel(const std::string& text = "");
    SwiftQLabel(const std::string& text, SwiftQWidget* parent);
    
    void setText(const std::string& text);
    void setAlignment(int alignment);
    void setWordWrap(bool wrap);
};

// Alignment constants accessible from Swift
namespace QtAlignment {
    inline constexpr int Left = 0x0001;
    inline constexpr int Right = 0x0002;
    inline constexpr int HCenter = 0x0004;
    inline constexpr int Top = 0x0020;
    inline constexpr int Bottom = 0x0040;
    inline constexpr int VCenter = 0x0080;
    inline constexpr int Center = HCenter | VCenter;
}

// Factory functions to create widgets
SwiftQWidget* createWidget(SwiftQWidget* parent = nullptr);
SwiftQLabel* createLabel(const std::string& text, SwiftQWidget* parent = nullptr);