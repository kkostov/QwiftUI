// ABOUTME: Implementation of Qt Test framework bridge for Swift testing
// ABOUTME: Wraps QTest functionality for safe usage from Swift

#include "include/QtTestBridge.h"
#include "include/QtBridge.h"
#include <QtTest/QTest>
#include <QtTest/qtestmouse.h>
#include <QtTest/qtestkeyboard.h>
#include <QWidget>
#include <QApplication>
#include <QTimer>
#include <QPushButton>
#include <QLabel>
#include <QLineEdit>
#include <QTextEdit>
#include <QCheckBox>
#include <QRadioButton>
#include <QComboBox>
#include <QKeySequence>
#include <algorithm>
#include <chrono>

// Static instance
SwiftQTest* SwiftQTest::instance_ = nullptr;

// SwiftQTest implementation
SwiftQTest::SwiftQTest() : initialized(false) {
}

SwiftQTest::~SwiftQTest() {
    cleanup();
}

SwiftQTest* SwiftQTest::instance() {
    if (!instance_) {
        instance_ = new SwiftQTest();
    }
    return instance_;
}

void SwiftQTest::initialize() {
    if (!initialized) {
        // Ensure QApplication exists
        if (!QApplication::instance()) {
            SwiftQApplication::instance();
        }
        initialized = true;
    }
}

void SwiftQTest::processEvents(int ms) {
    if (ms > 0) {
        QTest::qWait(ms);
    } else {
        QApplication::processEvents();
    }
}

void SwiftQTest::wait(int ms) {
    QTest::qWait(ms);
}

void SwiftQTest::cleanup() {
    // Cleanup is handled by QApplication destructor
    initialized = false;
}

// SwiftQTestFinder implementation
SwiftQTestFinder::SwiftQTestFinder() : rootWidget(nullptr) {
}

SwiftQTestFinder::SwiftQTestFinder(SwiftQWidget* root) : rootWidget(root) {
}

SwiftQTestFinder::~SwiftQTestFinder() {
    // Clean up any cached results if needed
}

void SwiftQTestFinder::setRoot(SwiftQWidget* root) {
    rootWidget = root;
}

SwiftQWidget* SwiftQTestFinder::findByObjectName(const std::string& name) {
    QWidget* searchRoot = rootWidget ? rootWidget->getQWidget() : nullptr;
    if (!searchRoot) {
        // Search all top-level widgets
        for (QWidget* widget : QApplication::topLevelWidgets()) {
            if (widget->objectName() == QString::fromStdString(name)) {
                return new SwiftQWidget(widget);
            }
            // Search children
            QWidget* found = widget->findChild<QWidget*>(QString::fromStdString(name));
            if (found) {
                return new SwiftQWidget(found);
            }
        }
    } else {
        // Search from specific root
        if (searchRoot->objectName() == QString::fromStdString(name)) {
            return rootWidget;
        }
        QWidget* found = searchRoot->findChild<QWidget*>(QString::fromStdString(name));
        if (found) {
            return new SwiftQWidget(found);
        }
    }
    return nullptr;
}

// Internal helper to find all widgets by name
static std::vector<QWidget*> findAllByObjectNameInternal(QWidget* searchRoot, const std::string& name) {
    std::vector<QWidget*> results;
    
    if (!searchRoot) {
        // Search all top-level widgets
        for (QWidget* widget : QApplication::topLevelWidgets()) {
            if (widget->objectName() == QString::fromStdString(name)) {
                results.push_back(widget);
            }
            // Search children
            QList<QWidget*> children = widget->findChildren<QWidget*>(QString::fromStdString(name));
            for (QWidget* child : children) {
                results.push_back(child);
            }
        }
    } else {
        // Search from specific root
        if (searchRoot->objectName() == QString::fromStdString(name)) {
            results.push_back(searchRoot);
        }
        QList<QWidget*> children = searchRoot->findChildren<QWidget*>(QString::fromStdString(name));
        for (QWidget* child : children) {
            results.push_back(child);
        }
    }
    
    return results;
}

int SwiftQTestFinder::countByObjectName(const std::string& name) {
    QWidget* searchRoot = rootWidget ? rootWidget->getQWidget() : nullptr;
    auto widgets = findAllByObjectNameInternal(searchRoot, name);
    return static_cast<int>(widgets.size());
}

SwiftQWidget* SwiftQTestFinder::getByObjectNameAt(const std::string& name, int index) {
    QWidget* searchRoot = rootWidget ? rootWidget->getQWidget() : nullptr;
    auto widgets = findAllByObjectNameInternal(searchRoot, name);
    
    if (index >= 0 && index < static_cast<int>(widgets.size())) {
        return new SwiftQWidget(widgets[index]);
    }
    return nullptr;
}

// Internal helper to find all widgets by class name
static std::vector<QWidget*> findByClassNameInternal(QWidget* searchRoot, const std::string& className) {
    std::vector<QWidget*> results;
    
    auto checkWidget = [&](QWidget* widget) {
        if (!widget) return;
        
        std::string widgetClass = widget->metaObject()->className();
        if (widgetClass == className) {
            results.push_back(widget);
        }
    };
    
    if (!searchRoot) {
        // Search all top-level widgets
        for (QWidget* widget : QApplication::topLevelWidgets()) {
            checkWidget(widget);
            // Search children recursively
            QList<QWidget*> children = widget->findChildren<QWidget*>();
            for (QWidget* child : children) {
                checkWidget(child);
            }
        }
    } else {
        // Search from specific root
        checkWidget(searchRoot);
        QList<QWidget*> children = searchRoot->findChildren<QWidget*>();
        for (QWidget* child : children) {
            checkWidget(child);
        }
    }
    
    return results;
}

int SwiftQTestFinder::countByClassName(const std::string& className) {
    QWidget* searchRoot = rootWidget ? rootWidget->getQWidget() : nullptr;
    auto widgets = findByClassNameInternal(searchRoot, className);
    return static_cast<int>(widgets.size());
}

SwiftQWidget* SwiftQTestFinder::getByClassNameAt(const std::string& className, int index) {
    QWidget* searchRoot = rootWidget ? rootWidget->getQWidget() : nullptr;
    auto widgets = findByClassNameInternal(searchRoot, className);
    
    if (index >= 0 && index < static_cast<int>(widgets.size())) {
        return new SwiftQWidget(widgets[index]);
    }
    return nullptr;
}

int SwiftQTestFinder::countChildren(SwiftQWidget* parent) {
    if (!parent || !parent->getQWidget()) {
        return 0;
    }
    
    QWidget* parentWidget = parent->getQWidget();
    QList<QWidget*> children = parentWidget->findChildren<QWidget*>();
    return children.size();
}

SwiftQWidget* SwiftQTestFinder::getChildAt(SwiftQWidget* parent, int index) {
    if (!parent || !parent->getQWidget()) {
        return nullptr;
    }
    
    QWidget* parentWidget = parent->getQWidget();
    QList<QWidget*> children = parentWidget->findChildren<QWidget*>();
    
    if (index >= 0 && index < children.size()) {
        return new SwiftQWidget(children[index]);
    }
    return nullptr;
}

SwiftQWidget* SwiftQTestFinder::waitForWidget(const std::string& name, int timeoutMs) {
    auto start = std::chrono::steady_clock::now();
    
    while (true) {
        if (SwiftQWidget* widget = findByObjectName(name)) {
            return widget;
        }
        
        auto elapsed = std::chrono::steady_clock::now() - start;
        if (std::chrono::duration_cast<std::chrono::milliseconds>(elapsed).count() > timeoutMs) {
            break;
        }
        
        QTest::qWait(10);  // Process events for 10ms
    }
    
    return nullptr;
}

// Helper function to get QWindow from QWidget
static QWindow* getWindowForWidget(QWidget* widget) {
    if (!widget) return nullptr;
    
    QWindow* window = widget->windowHandle();
    if (!window) {
        // If widget doesn't have a window handle, try to get the top-level widget's window
        QWidget* topLevel = widget->window();
        if (topLevel) {
            topLevel->show(); // Ensure it's shown
            QApplication::processEvents(); // Process events to create window
            window = topLevel->windowHandle();
        }
    }
    return window;
}

// SwiftQTestSimulator implementation
SwiftQTestSimulator::SwiftQTestSimulator() {
    // Ensure test framework is initialized
    SwiftQTest::instance()->initialize();
}

SwiftQTestSimulator::~SwiftQTestSimulator() {
}

void SwiftQTestSimulator::mouseClick(SwiftQWidget* widget, int button, int x, int y) {
    if (!widget || !widget->getQWidget()) return;
    
    QWidget* qw = widget->getQWidget();
    QWindow* window = getWindowForWidget(qw);
    if (!window) return;
    
    Qt::MouseButton qtButton = static_cast<Qt::MouseButton>(button);
    
    // Convert widget coordinates to window coordinates
    QPoint widgetPos = QPoint(x, y);
    QPoint windowPos = qw->mapTo(qw->window(), widgetPos);
    
    QTest::mouseClick(window, qtButton, Qt::NoModifier, windowPos);
}

void SwiftQTestSimulator::mouseClickCenter(SwiftQWidget* widget, int button) {
    if (!widget || !widget->getQWidget()) return;
    
    QWidget* qw = widget->getQWidget();
    QPoint center = qw->rect().center();
    mouseClick(widget, button, center.x(), center.y());
}

void SwiftQTestSimulator::mouseDClick(SwiftQWidget* widget, int button, int x, int y) {
    if (!widget || !widget->getQWidget()) return;
    
    QWidget* qw = widget->getQWidget();
    QWindow* window = getWindowForWidget(qw);
    if (!window) return;
    
    Qt::MouseButton qtButton = static_cast<Qt::MouseButton>(button);
    
    QPoint widgetPos = QPoint(x, y);
    QPoint windowPos = qw->mapTo(qw->window(), widgetPos);
    
    QTest::mouseDClick(window, qtButton, Qt::NoModifier, windowPos);
}

void SwiftQTestSimulator::mouseDClickCenter(SwiftQWidget* widget, int button) {
    if (!widget || !widget->getQWidget()) return;
    
    QWidget* qw = widget->getQWidget();
    QPoint center = qw->rect().center();
    mouseDClick(widget, button, center.x(), center.y());
}

void SwiftQTestSimulator::mouseMove(SwiftQWidget* widget, int x, int y, int delay) {
    if (!widget || !widget->getQWidget()) return;
    
    QWidget* qw = widget->getQWidget();
    QWindow* window = getWindowForWidget(qw);
    if (!window) return;
    
    QPoint widgetPos = QPoint(x, y);
    QPoint windowPos = qw->mapTo(qw->window(), widgetPos);
    
    QTest::mouseMove(window, windowPos, delay);
}

void SwiftQTestSimulator::mouseDrag(SwiftQWidget* widget, int fromX, int fromY, int toX, int toY) {
    if (!widget || !widget->getQWidget()) return;
    
    QWidget* qw = widget->getQWidget();
    
    // Simulate drag by press, move, release
    mousePress(widget, TEST_MOUSE_BUTTON_LEFT, fromX, fromY);
    QTest::qWait(10);
    mouseMove(widget, toX, toY, 100);
    QTest::qWait(10);
    mouseRelease(widget, TEST_MOUSE_BUTTON_LEFT, toX, toY);
}

void SwiftQTestSimulator::mousePress(SwiftQWidget* widget, int button, int x, int y) {
    if (!widget || !widget->getQWidget()) return;
    
    QWidget* qw = widget->getQWidget();
    QWindow* window = getWindowForWidget(qw);
    if (!window) return;
    
    Qt::MouseButton qtButton = static_cast<Qt::MouseButton>(button);
    
    QPoint widgetPos = QPoint(x, y);
    QPoint windowPos = qw->mapTo(qw->window(), widgetPos);
    
    QTest::mousePress(window, qtButton, Qt::NoModifier, windowPos);
}

void SwiftQTestSimulator::mousePressCenter(SwiftQWidget* widget, int button) {
    if (!widget || !widget->getQWidget()) return;
    
    QWidget* qw = widget->getQWidget();
    QPoint center = qw->rect().center();
    mousePress(widget, button, center.x(), center.y());
}

void SwiftQTestSimulator::mouseRelease(SwiftQWidget* widget, int button, int x, int y) {
    if (!widget || !widget->getQWidget()) return;
    
    QWidget* qw = widget->getQWidget();
    QWindow* window = getWindowForWidget(qw);
    if (!window) return;
    
    Qt::MouseButton qtButton = static_cast<Qt::MouseButton>(button);
    
    QPoint widgetPos = QPoint(x, y);
    QPoint windowPos = qw->mapTo(qw->window(), widgetPos);
    
    QTest::mouseRelease(window, qtButton, Qt::NoModifier, windowPos);
}

void SwiftQTestSimulator::mouseReleaseCenter(SwiftQWidget* widget, int button) {
    if (!widget || !widget->getQWidget()) return;
    
    QWidget* qw = widget->getQWidget();
    QPoint center = qw->rect().center();
    mouseRelease(widget, button, center.x(), center.y());
}

void SwiftQTestSimulator::keyClick(SwiftQWidget* widget, int key, int modifiers, int delay) {
    if (!widget || !widget->getQWidget()) return;
    
    QWidget* qw = widget->getQWidget();
    QWindow* window = getWindowForWidget(qw);
    if (!window) return;
    
    // Ensure widget has focus
    qw->setFocus();
    QApplication::processEvents();
    
    Qt::Key qtKey = static_cast<Qt::Key>(key);
    Qt::KeyboardModifiers qtMods = static_cast<Qt::KeyboardModifiers>(modifiers);
    
    QTest::keyClick(window, qtKey, qtMods, delay);
}

void SwiftQTestSimulator::keyClickNoMod(SwiftQWidget* widget, int key) {
    keyClick(widget, key, TEST_KEY_MODIFIER_NONE, -1);
}

void SwiftQTestSimulator::keyPress(SwiftQWidget* widget, int key, int modifiers) {
    if (!widget || !widget->getQWidget()) return;
    
    QWidget* qw = widget->getQWidget();
    QWindow* window = getWindowForWidget(qw);
    if (!window) return;
    
    // Ensure widget has focus
    qw->setFocus();
    QApplication::processEvents();
    
    Qt::Key qtKey = static_cast<Qt::Key>(key);
    Qt::KeyboardModifiers qtMods = static_cast<Qt::KeyboardModifiers>(modifiers);
    
    QTest::keyPress(window, qtKey, qtMods);
}

void SwiftQTestSimulator::keyPressNoMod(SwiftQWidget* widget, int key) {
    keyPress(widget, key, TEST_KEY_MODIFIER_NONE);
}

void SwiftQTestSimulator::keyRelease(SwiftQWidget* widget, int key, int modifiers) {
    if (!widget || !widget->getQWidget()) return;
    
    QWidget* qw = widget->getQWidget();
    QWindow* window = getWindowForWidget(qw);
    if (!window) return;
    
    Qt::Key qtKey = static_cast<Qt::Key>(key);
    Qt::KeyboardModifiers qtMods = static_cast<Qt::KeyboardModifiers>(modifiers);
    
    QTest::keyRelease(window, qtKey, qtMods);
}

void SwiftQTestSimulator::keyReleaseNoMod(SwiftQWidget* widget, int key) {
    keyRelease(widget, key, TEST_KEY_MODIFIER_NONE);
}

void SwiftQTestSimulator::keyClicks(SwiftQWidget* widget, const std::string& text, int modifiers, int delay) {
    if (!widget || !widget->getQWidget()) return;
    
    QWidget* qw = widget->getQWidget();
    
    // Ensure widget has focus
    qw->setFocus();
    QApplication::processEvents();
    
    Qt::KeyboardModifiers qtMods = static_cast<Qt::KeyboardModifiers>(modifiers);
    
    // For now, simulate each character individually since QTest::keyClicks
    // requires including additional Qt private headers which may not be available
    for (char c : text) {
        // Use the widget's window for key events
        QWindow* window = getWindowForWidget(qw);
        if (window) {
            // For printable ASCII characters, use the char overload of keyClick
            // which properly handles the conversion to Qt::Key internally
            if (c >= 32 && c <= 126) {  // Printable ASCII range
                QTest::keyClick(window, c, qtMods, delay);
            }
        }
    }
}

void SwiftQTestSimulator::keyClicksNoMod(SwiftQWidget* widget, const std::string& text) {
    keyClicks(widget, text, TEST_KEY_MODIFIER_NONE, -1);
}

void SwiftQTestSimulator::keySequence(SwiftQWidget* widget, const std::string& sequence) {
    if (!widget || !widget->getQWidget()) return;
    
    QWidget* qw = widget->getQWidget();
    QWindow* window = getWindowForWidget(qw);
    if (!window) return;
    
    // Ensure widget has focus
    qw->setFocus();
    QApplication::processEvents();
    
    QTest::keySequence(window, QKeySequence(QString::fromStdString(sequence)));
}

void SwiftQTestSimulator::setFocus(SwiftQWidget* widget) {
    if (!widget || !widget->getQWidget()) return;
    
    widget->getQWidget()->setFocus();
    QApplication::processEvents();
}

bool SwiftQTestSimulator::hasFocus(SwiftQWidget* widget) {
    if (!widget || !widget->getQWidget()) return false;
    
    return widget->getQWidget()->hasFocus();
}

void SwiftQTestSimulator::wait(int ms) {
    QTest::qWait(ms);
}

void SwiftQTestSimulator::processEvents(int ms) {
    if (ms > 0) {
        QTest::qWait(ms);
    } else {
        QApplication::processEvents();
    }
}

void SwiftQTestSimulator::processEventsDefault() {
    QApplication::processEvents();
}

// Test assertion function implementations
bool testAssertIsVisible(SwiftQWidget* widget) {
    if (!widget || !widget->getQWidget()) return false;
    return widget->getQWidget()->isVisible();
}

bool testAssertIsEnabled(SwiftQWidget* widget) {
    if (!widget || !widget->getQWidget()) return false;
    return widget->getQWidget()->isEnabled();
}

bool testAssertIsHidden(SwiftQWidget* widget) {
    if (!widget || !widget->getQWidget()) return true;
    return widget->getQWidget()->isHidden();
}

bool testAssertHasSize(SwiftQWidget* widget, int width, int height) {
    if (!widget || !widget->getQWidget()) return false;
    QWidget* qw = widget->getQWidget();
    return qw->width() == width && qw->height() == height;
}

bool testAssertHasPosition(SwiftQWidget* widget, int x, int y) {
    if (!widget || !widget->getQWidget()) return false;
    QWidget* qw = widget->getQWidget();
    return qw->x() == x && qw->y() == y;
}

std::string testAssertGetText(SwiftQWidget* widget) {
    if (!widget || !widget->getQWidget()) return "";
    
    QWidget* qw = widget->getQWidget();
    
    // Try different widget types
    if (QLabel* label = qobject_cast<QLabel*>(qw)) {
        return label->text().toStdString();
    } else if (QPushButton* button = qobject_cast<QPushButton*>(qw)) {
        return button->text().toStdString();
    } else if (QLineEdit* lineEdit = qobject_cast<QLineEdit*>(qw)) {
        return lineEdit->text().toStdString();
    } else if (QTextEdit* textEdit = qobject_cast<QTextEdit*>(qw)) {
        return textEdit->toPlainText().toStdString();
    } else if (QCheckBox* checkBox = qobject_cast<QCheckBox*>(qw)) {
        return checkBox->text().toStdString();
    } else if (QRadioButton* radioButton = qobject_cast<QRadioButton*>(qw)) {
        return radioButton->text().toStdString();
    } else if (QComboBox* comboBox = qobject_cast<QComboBox*>(qw)) {
        return comboBox->currentText().toStdString();
    }
    
    // Try window title as fallback
    return qw->windowTitle().toStdString();
}

bool testAssertHasText(SwiftQWidget* widget, const std::string& expected) {
    return testAssertGetText(widget) == expected;
}

bool testAssertHasFocus(SwiftQWidget* widget) {
    if (!widget || !widget->getQWidget()) return false;
    return widget->getQWidget()->hasFocus();
}

bool testAssertCompareWidgets(SwiftQWidget* w1, SwiftQWidget* w2) {
    if (!w1 && !w2) return true;
    if (!w1 || !w2) return false;
    return w1->getQWidget() == w2->getQWidget();
}

// Factory functions
SwiftQTest* createQTest() {
    return SwiftQTest::instance();
}

SwiftQTestFinder* createTestFinder() {
    return new SwiftQTestFinder();
}

SwiftQTestFinder* createTestFinderWithRoot(SwiftQWidget* root) {
    return new SwiftQTestFinder(root);
}

SwiftQTestSimulator* createTestSimulator() {
    return new SwiftQTestSimulator();
}