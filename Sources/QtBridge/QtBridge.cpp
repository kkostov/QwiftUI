#include "include/QtBridge.h"
#include <cstdlib>
#include <QtWidgets/QApplication>
#include <QtWidgets/QWidget>
#include <QtWidgets/QLabel>
#include <QtWidgets/QPushButton>
#include <QtWidgets/QLineEdit>
#include <QtWidgets/QTextEdit>
#include <QtWidgets/QCheckBox>
#include <QtWidgets/QRadioButton>
#include <QtWidgets/QComboBox>
#include <QtWidgets/QGroupBox>
#include <QtWidgets/QMessageBox>
#include <QtWidgets/QSlider>
#include <QtWidgets/QProgressBar>
#include <QtWidgets/QScrollArea>
#include <QtWidgets/QScrollBar>
#include <QtWidgets/QTabWidget>
#include <QtWidgets/QSplitter>
#include <QtWidgets/QSpinBox>
#include <QtWidgets/QDoubleSpinBox>
#include <QtWidgets/QDateEdit>
#include <QtWidgets/QTimeEdit>
#include <QtWidgets/QDateTimeEdit>
#include <QtWidgets/QDial>
#include <QtWidgets/QLCDNumber>
#include <QtWidgets/QCalendarWidget>
#include <QtGui/QPixmap>
#include <QtCore/QString>
#include <QtCore/QDate>
#include <QtCore/QTime>
#include <QtCore/QDateTime>
#include <QtCore/QObject>
#include <QtCore/QEvent>
#include <QtCore/QTimer>
#include <QtCore/QEventLoop>
#include <QtGui/QMouseEvent>
#include <QtGui/QKeyEvent>
#include <QtGui/QFocusEvent>
#include <QtGui/QResizeEvent>
#include <QtGui/QMoveEvent>
#include <QtGui/QScreen>
#include <QtGui/QWindow>
#include <QtGui/QPaintEvent>
#include <QtGui/QCloseEvent>
#include <QtGui/QShowEvent>
#include <QtGui/QHideEvent>
#include <QtCore/QThread>

// Static instance pointer and exit code
SwiftQApplication* SwiftQApplication::g_appInstance = nullptr;
int SwiftQApplication::exitReturnCode = 0;

// SwiftQApplication implementation
void SwiftQApplication::buildArgv() {
    if (!argc) {
        argc = new int;
    }
    *argc = static_cast<int>(storedArgs.size());
    argv.clear();
    argv.reserve(*argc);
    for (auto& arg : storedArgs) {
        argv.push_back(const_cast<char*>(arg.c_str()));
    }
}

void SwiftQApplication::ensureInitialized() {
    if (!app && !QApplication::instance()) {
        app = new QApplication(*argc, argv.data());
    } else if (!app && QApplication::instance()) {
        app = qobject_cast<QApplication*>(QApplication::instance());
    }
}

SwiftQApplication::SwiftQApplication() : argc(nullptr), app(nullptr) {
    g_appInstance = this;
    storedArgs.push_back("qt-app");
    buildArgv();
    ensureInitialized();
}

SwiftQApplication::~SwiftQApplication() {
    if (g_appInstance == this) {
        g_appInstance = nullptr;
    }
    delete argc;
}

int SwiftQApplication::exec() {
    ensureInitialized();
    int result = -1;
    if (app) {
        result = app->exec();
    } else if (QApplication::instance()) {
        result = QApplication::instance()->exec();
    }
    // Return our stored exit code if it was set, otherwise return Qt's result
    return (exitReturnCode != 0) ? exitReturnCode : result;
}

void SwiftQApplication::quit() {
    if (QApplication::instance()) {
        QApplication::quit();
    }
}

void SwiftQApplication::exit(int returnCode) {
    if (QApplication::instance()) {
        QApplication::exit(returnCode);
    }
}

void SwiftQApplication::scheduleExit(int returnCode, int delayMs) {
    // Store the return code for later retrieval
    exitReturnCode = returnCode;
    
    // Schedule the exit to happen after a small delay to allow current event processing to complete
    QTimer::singleShot(delayMs, []() {
        // First hide all widgets to stop rendering and events
        const auto topLevelWidgets = QApplication::topLevelWidgets();
        for (QWidget* widget : topLevelWidgets) {
            if (widget) {
                // Hide if visible
                if (widget->isVisible()) {
                    widget->hide();
                }
                // Note: We don't use wildcard disconnect() here as it can cause warnings
                // Qt will handle signal disconnection during widget destruction
            }
        }
        
        // Process any remaining events
        QApplication::processEvents();
        
        // Schedule deletion of widgets
        for (QWidget* widget : QApplication::topLevelWidgets()) {
            if (widget) {
                widget->deleteLater();
            }
        }
        
        // Schedule the actual quit after deletions are processed
        QTimer::singleShot(1, []() {
            // Process deleteLater events  
            QApplication::sendPostedEvents(nullptr, QEvent::DeferredDelete);
            QApplication::processEvents();
            // Use quit() which is more reliable than exit()
            QApplication::quit();
        });
    });
}

void SwiftQApplication::forceQuit() {
    if (QApplication::instance()) {
        // Close all top-level widgets first
        const auto topLevelWidgets = QApplication::topLevelWidgets();
        for (QWidget* widget : topLevelWidgets) {
            if (widget) {
                widget->close();
                widget->deleteLater();
            }
        }
        // Process events to handle deleteLater calls
        QApplication::processEvents();
        // Force quit
        QApplication::quit();
    }
}

void SwiftQApplication::processEvents() {
    if (QApplication::instance()) {
        QApplication::processEvents();
    }
}

SwiftQApplication* SwiftQApplication::instance() {
    return g_appInstance;
}

void SwiftQApplication::staticScheduleExit(int returnCode, int delayMs) {
    if (g_appInstance) {
        g_appInstance->scheduleExit(returnCode, delayMs);
    }
}

void SwiftQApplication::staticQuit() {
    if (QApplication::instance()) {
        QApplication::quit();
    }
}

void SwiftQApplication::staticForceExit(int returnCode) {
    // For test runners and scenarios where we need immediate termination
    // First try to clean up Qt resources
    if (QApplication::instance()) {
        // Close all widgets
        const auto topLevelWidgets = QApplication::topLevelWidgets();
        for (QWidget* widget : topLevelWidgets) {
            if (widget) {
                widget->close();
            }
        }
        // Process any remaining events
        QApplication::processEvents();
        // Tell Qt to quit
        QApplication::quit();
        QApplication::processEvents();
    }
    // Force immediate termination
    std::exit(returnCode);
}

void SwiftQApplication::scheduleCallback(int delayMs, void (*callback)(void*), void* context) {
    ensureInitialized();
    if (callback) {
        QTimer::singleShot(delayMs, [callback, context]() {
            callback(context);
        });
    }
}

// Forward declaration for friend class
class SwiftEventFilter;

// Custom event filter class for handling Qt events
class SwiftEventFilter : public QObject {
private:
    SwiftQWidget* swiftWidget;
    
public:
    SwiftEventFilter(SwiftQWidget* widget) : QObject(), swiftWidget(widget) {}
    
    ~SwiftEventFilter() override {
        // Safely disconnect from widget when filter is destroyed
        if (swiftWidget) {
            swiftWidget->eventFilter = nullptr;
        }
    }
    
    void clearWidget() {
        swiftWidget = nullptr;
    }
    
protected:
    bool eventFilter(QObject* obj, QEvent* event) override;
};

// SwiftQWidget implementation
void SwiftQWidget::ensureWidget() {
    if (!widget && QApplication::instance()) {
        if (parentWidget) {
            widget = new QWidget(parentWidget->getQWidget());
        } else {
            widget = new QWidget(nullptr);
        }
        setupEventFilter();
    }
}

void SwiftQWidget::setupEventFilter() {
    if (widget && !eventFilter) {
        // Make the filter a child of the widget so it gets deleted automatically
        SwiftEventFilter* filter = new SwiftEventFilter(this);
        filter->setParent(widget);
        widget->installEventFilter(filter);
        eventFilter = filter;
    }
}

bool SwiftQWidget::handleEvent(QEvent* event) {
    if (!event) return false;
    
    QtEventType eventType = QtEventType::Custom;
    QtEventInfo info = {QtEventType::Custom, 0, 0, nullptr, false, nullptr};
    
    // Map Qt events to our event types
    switch (event->type()) {
    case QEvent::MouseButtonPress:
        eventType = QtEventType::MousePress;
        if (auto* mouseEvent = static_cast<QMouseEvent*>(event)) {
            info.intValue = mouseEvent->button();
            info.intValue2 = mouseEvent->modifiers();
        }
        break;
    case QEvent::MouseButtonRelease:
        eventType = QtEventType::MouseRelease;
        if (auto* mouseEvent = static_cast<QMouseEvent*>(event)) {
            info.intValue = mouseEvent->button();
            info.intValue2 = mouseEvent->modifiers();
        }
        break;
    case QEvent::MouseMove:
        eventType = QtEventType::MouseMove;
        break;
    case QEvent::MouseButtonDblClick:
        eventType = QtEventType::MouseDoubleClick;
        break;
    case QEvent::Enter:
        eventType = QtEventType::MouseEnter;
        break;
    case QEvent::Leave:
        eventType = QtEventType::MouseLeave;
        break;
    case QEvent::KeyPress:
        eventType = QtEventType::KeyPress;
        if (auto* keyEvent = static_cast<QKeyEvent*>(event)) {
            info.intValue = keyEvent->key();
            info.intValue2 = keyEvent->modifiers();
        }
        break;
    case QEvent::KeyRelease:
        eventType = QtEventType::KeyRelease;
        if (auto* keyEvent = static_cast<QKeyEvent*>(event)) {
            info.intValue = keyEvent->key();
            info.intValue2 = keyEvent->modifiers();
        }
        break;
    case QEvent::FocusIn:
        eventType = QtEventType::FocusIn;
        break;
    case QEvent::FocusOut:
        eventType = QtEventType::FocusOut;
        break;
    case QEvent::Show:
        eventType = QtEventType::Show;
        break;
    case QEvent::Hide:
        eventType = QtEventType::Hide;
        break;
    case QEvent::Close:
        eventType = QtEventType::Close;
        break;
    case QEvent::Resize:
        eventType = QtEventType::Resize;
        if (auto* resizeEvent = static_cast<QResizeEvent*>(event)) {
            info.intValue = resizeEvent->size().width();
            info.intValue2 = resizeEvent->size().height();
        }
        break;
    case QEvent::Move:
        eventType = QtEventType::Move;
        if (auto* moveEvent = static_cast<QMoveEvent*>(event)) {
            info.intValue = moveEvent->pos().x();
            info.intValue2 = moveEvent->pos().y();
        }
        break;
    case QEvent::Paint:
        eventType = QtEventType::Paint;
        break;
    default:
        return false;
    }
    
    info.type = eventType;
    
    // Call the handler if registered
    auto it = eventCallbacks.find(eventType);
    if (it != eventCallbacks.end() && it->second.handler) {
        it->second.handler(it->second.context, &info);
        return true;
    }
    
    return false;
}

SwiftQWidget::SwiftQWidget() : widget(nullptr), parentWidget(nullptr), ownsWidget(true), eventFilter(nullptr) {
}

SwiftQWidget::SwiftQWidget(SwiftQWidget* parent) : widget(nullptr), parentWidget(parent), ownsWidget(true), eventFilter(nullptr) {
}

SwiftQWidget::SwiftQWidget(QWidget* existingWidget) 
    : widget(existingWidget), parentWidget(nullptr), ownsWidget(false), eventFilter(nullptr) {
    if (widget) {
        setupEventFilter();
    }
}

SwiftQWidget::SwiftQWidget(const SwiftQWidget& other)
    : widget(other.widget), parentWidget(other.parentWidget), ownsWidget(false), eventFilter(nullptr) {
    // Copy constructor creates a shallow copy
    // The new object doesn't own the widget to prevent double deletion
    // Don't copy the event filter - each instance manages its own
}

SwiftQWidget& SwiftQWidget::operator=(const SwiftQWidget& other) {
    if (this != &other) {
        // Clean up existing widget if we own it
        if (ownsWidget && widget && !widget->parent()) {
            delete widget;
        }
        
        // Copy the values
        widget = other.widget;
        parentWidget = other.parentWidget;
        ownsWidget = false; // Copies don't own the widget
        eventCallbacks = other.eventCallbacks;
    }
    return *this;
}

SwiftQWidget::~SwiftQWidget() {
    // First, clear event filter to prevent callbacks during destruction
    if (eventFilter) {
        eventFilter->clearWidget();
        eventFilter = nullptr;
    }
    
    clearEventHandlers();
    
    // Only delete the widget if we own it AND it doesn't have a parent
    // If it has a parent, Qt will handle the deletion
    if (ownsWidget && widget) {
        // Check if widget is still valid by testing a QObject property
        // This helps detect if Qt already deleted it
        try {
            if (widget->thread() && !widget->parent()) {
                // Note: We don't use wildcard disconnect() here as it can cause warnings
                // when Qt is already in the process of destroying the widget
                // Qt will handle signal disconnection during widget destruction
                delete widget;
            }
        } catch (...) {
            // Widget was already deleted by Qt, just clear the pointer
        }
        // Always clear the pointer
        widget = nullptr;
    }
}

void SwiftQWidget::show() {
    ensureWidget();
    if (widget) {
        widget->show();
    }
}

void SwiftQWidget::hide() {
    if (widget) {
        widget->hide();
    }
}

void SwiftQWidget::setEnabled(bool enabled) {
    ensureWidget();
    if (widget) {
        widget->setEnabled(enabled);
    }
}

bool SwiftQWidget::isVisible() const {
    // Need to ensure widget is created before checking visibility
    // Cast away const to call ensureWidget (safe because it only creates widget if needed)
    const_cast<SwiftQWidget*>(this)->ensureWidget();
    
    // Check if widget pointer is valid before calling isVisible
    if (!widget) {
        return false;
    }
    // Also check if the widget is still a valid QObject
    // This helps detect when Qt has already deleted the widget
    try {
        return widget->isVisible();
    } catch (...) {
        // Widget was already deleted by Qt
        return false;
    }
}

void SwiftQWidget::resize(int width, int height) {
    ensureWidget();
    if (widget) {
        widget->resize(width, height);
    }
}

void SwiftQWidget::move(int x, int y) {
    ensureWidget();
    if (widget) {
        widget->move(x, y);
    }
}

void SwiftQWidget::setGeometry(int x, int y, int width, int height) {
    ensureWidget();
    if (widget) {
        widget->setGeometry(x, y, width, height);
    }
}

void SwiftQWidget::setWindowTitle(const std::string& title) {
    ensureWidget();
    if (widget) {
        widget->setWindowTitle(QString::fromStdString(title));
    }
}

std::string SwiftQWidget::windowTitle() const {
    // Ensure widget exists before getting title
    const_cast<SwiftQWidget*>(this)->ensureWidget();
    if (widget) {
        return widget->windowTitle().toStdString();
    }
    return "";
}

void SwiftQWidget::setObjectName(const std::string& name) {
    ensureWidget();
    if (widget) {
        widget->setObjectName(QString::fromStdString(name));
    }
}

std::string SwiftQWidget::objectName() const {
    // Ensure widget exists before getting object name
    const_cast<SwiftQWidget*>(this)->ensureWidget();
    if (widget) {
        return widget->objectName().toStdString();
    }
    return "";
}

void SwiftQWidget::setParent(SwiftQWidget* parent) {
    parentWidget = parent;
    if (widget && parent && parent->widget) {
        widget->setParent(parent->widget);
    }
}

QWidget* SwiftQWidget::getQWidget() {
    ensureWidget();
    return widget;
}

std::vector<SwiftQWidget*> SwiftQWidget::getChildren() const {
    std::vector<SwiftQWidget*> children;
    if (widget) {
        // Note: This returns Qt's child widgets, not necessarily SwiftQWidget wrappers
        // In a real implementation, we'd need to track the SwiftQWidget wrappers
        // For now, return empty vector
    }
    return children;
}

void SwiftQWidget::setAttribute(int attribute, bool on) {
    ensureWidget();
    widget->setAttribute(static_cast<Qt::WidgetAttribute>(attribute), on);
}

void SwiftQWidget::setMinimumSize(int width, int height) {
    ensureWidget();
    widget->setMinimumSize(width, height);
}

void SwiftQWidget::raise() {
    ensureWidget();
    widget->raise();
}

void SwiftQWidget::activateWindow() {
    ensureWidget();
    widget->activateWindow();
}

int SwiftQWidget::width() const {
    if (widget) {
        return widget->width();
    }
    return 0;
}

int SwiftQWidget::height() const {
    if (widget) {
        return widget->height();
    }
    return 0;
}

void SwiftQWidget::setMaximumSize(int width, int height) {
    ensureWidget();
    widget->setMaximumSize(width, height);
}

void SwiftQWidget::setFixedSize(int width, int height) {
    ensureWidget();
    widget->setFixedSize(width, height);
}

void SwiftQWidget::lower() {
    ensureWidget();
    widget->lower();
}

void SwiftQWidget::showMaximized() {
    ensureWidget();
    widget->showMaximized();
}

void SwiftQWidget::showMinimized() {
    ensureWidget();
    widget->showMinimized();
}

void SwiftQWidget::showFullScreen() {
    ensureWidget();
    widget->showFullScreen();
}

void SwiftQWidget::showNormal() {
    ensureWidget();
    widget->showNormal();
}

bool SwiftQWidget::close() {
    ensureWidget();
    return widget->close();
}

void SwiftQWidget::update() {
    ensureWidget();
    widget->update();
}

int SwiftQWidget::x() const {
    if (widget) {
        return widget->x();
    }
    return 0;
}

int SwiftQWidget::y() const {
    if (widget) {
        return widget->y();
    }
    return 0;
}

void SwiftQWidget::centerOnScreen() {
    ensureWidget();
    if (widget && !widget->parent()) {  // Only works for top-level widgets
        // Get the screen that the widget is on (or primary screen if not shown yet)
        QScreen* screen = nullptr;
        if (widget->windowHandle()) {
            screen = widget->windowHandle()->screen();
        }
        if (!screen) {
            screen = QApplication::primaryScreen();
        }
        
        if (screen) {
            // Get the available geometry (excludes taskbars, docks, etc.)
            QRect screenGeometry = screen->availableGeometry();
            
            // Calculate the center position
            int x = (screenGeometry.width() - widget->width()) / 2 + screenGeometry.x();
            int y = (screenGeometry.height() - widget->height()) / 2 + screenGeometry.y();
            
            // Move the widget to the center
            widget->move(x, y);
        }
    }
}

void SwiftQWidget::setEventHandler(QtEventType type, SwiftEventCallback callback) {
    eventCallbacks[type] = callback;
}

void SwiftQWidget::removeEventHandler(QtEventType type) {
    eventCallbacks.erase(type);
}

void SwiftQWidget::clearEventHandlers() {
    eventCallbacks.clear();
}

// SwiftEventFilter implementation
bool SwiftEventFilter::eventFilter(QObject* obj, QEvent* event) {
    // Check if swiftWidget is still valid before accessing it
    // Also check for destruction events to clean up early
    if (event && event->type() == QEvent::Destroy) {
        // Widget is being destroyed, clear our reference
        if (swiftWidget) {
            swiftWidget->widget = nullptr;
            swiftWidget->eventFilter = nullptr;
        }
        swiftWidget = nullptr;
        return false;
    }
    
    if (swiftWidget && swiftWidget->widget) {
        if (swiftWidget->handleEvent(event)) {
            return true;
        }
    }
    return QObject::eventFilter(obj, event);
}

// SwiftQLabel implementation
void SwiftQLabel::ensureWidget() {
    if (!widget && QApplication::instance()) {
        QLabel* label = nullptr;
        if (parentWidget) {
            label = new QLabel(parentWidget->getQWidget());
        } else {
            label = new QLabel(nullptr);
        }
        
        if (!labelText.empty()) {
            label->setText(QString::fromStdString(labelText));
        }
        if (labelAlignment != 0) {
            label->setAlignment(static_cast<Qt::Alignment>(labelAlignment));
        }
        
        widget = label;
    }
}

SwiftQLabel::SwiftQLabel() : SwiftQWidget(), labelAlignment(0) {
}

SwiftQLabel::SwiftQLabel(const std::string& text) 
    : SwiftQWidget(), labelText(text), labelAlignment(0) {
}

SwiftQLabel::SwiftQLabel(const std::string& text, SwiftQWidget* parent)
    : SwiftQWidget(parent), labelText(text), labelAlignment(0) {
}

void SwiftQLabel::setText(const std::string& text) {
    labelText = text;
    ensureWidget();
    if (widget) {
        QLabel* label = qobject_cast<QLabel*>(widget);
        if (label) {
            label->setText(QString::fromStdString(text));
        }
    }
}

std::string SwiftQLabel::text() const {
    if (widget) {
        QLabel* label = qobject_cast<QLabel*>(widget);
        if (label) {
            return label->text().toStdString();
        }
    }
    return labelText;
}

void SwiftQLabel::setAlignment(int alignment) {
    labelAlignment = alignment;
    ensureWidget();
    if (widget) {
        QLabel* label = qobject_cast<QLabel*>(widget);
        if (label) {
            label->setAlignment(static_cast<Qt::Alignment>(alignment));
        }
    }
}

bool SwiftQLabel::setPixmap(const std::string& imagePath) {
    ensureWidget();
    if (widget) {
        QLabel* label = qobject_cast<QLabel*>(widget);
        if (label) {
            QPixmap pixmap(QString::fromStdString(imagePath));
            if (!pixmap.isNull()) {
                label->setPixmap(pixmap);
                return true;
            }
        }
    }
    return false;
}

void SwiftQLabel::setScaledContents(bool scaled) {
    ensureWidget();
    if (widget) {
        QLabel* label = qobject_cast<QLabel*>(widget);
        if (label) {
            label->setScaledContents(scaled);
        }
    }
}

void SwiftQLabel::clearPixmap() {
    ensureWidget();
    if (widget) {
        QLabel* label = qobject_cast<QLabel*>(widget);
        if (label) {
            label->clear();
        }
    }
}

// SwiftQPushButton implementation
void SwiftQPushButton::ensureWidget() {
    if (!widget && QApplication::instance()) {
        QPushButton* button = nullptr;
        if (parentWidget) {
            button = new QPushButton(parentWidget->getQWidget());
        } else {
            button = new QPushButton(nullptr);
        }
        
        if (!buttonText.empty()) {
            button->setText(QString::fromStdString(buttonText));
        }
        
        widget = button;
        setupEventFilter();
        setupConnections();
    }
}

SwiftQPushButton::SwiftQPushButton() : SwiftQWidget() {
}

SwiftQPushButton::SwiftQPushButton(const std::string& text) 
    : SwiftQWidget(), buttonText(text) {
}

SwiftQPushButton::SwiftQPushButton(const std::string& text, SwiftQWidget* parent)
    : SwiftQWidget(parent), buttonText(text) {
}

SwiftQPushButton::~SwiftQPushButton() {
    // Clear stored functions first to prevent callbacks during cleanup
    clickedFunc = nullptr;
    pressedFunc = nullptr;
    releasedFunc = nullptr;
    toggledFunc = nullptr;
    
    // Note: We don't need to manually disconnect signals here.
    // Qt automatically handles signal disconnection when widgets are destroyed.
    // Trying to disconnect signals during destruction can cause crashes if
    // Qt is already in the process of cleaning up the widget hierarchy.
    // The std::function destructors above ensure our callbacks are cleaned up.
}

void SwiftQPushButton::setText(const std::string& text) {
    buttonText = text;
    ensureWidget();
    if (widget) {
        QPushButton* button = qobject_cast<QPushButton*>(widget);
        if (button) {
            button->setText(QString::fromStdString(text));
        }
    }
}

std::string SwiftQPushButton::text() const {
    if (widget) {
        QPushButton* button = qobject_cast<QPushButton*>(widget);
        if (button) {
            return button->text().toStdString();
        }
    }
    return buttonText;
}

void SwiftQPushButton::setDefault(bool isDefault) {
    ensureWidget();
    if (widget) {
        QPushButton* button = qobject_cast<QPushButton*>(widget);
        if (button) {
            button->setDefault(isDefault);
        }
    }
}

void SwiftQPushButton::setFlat(bool flat) {
    ensureWidget();
    if (widget) {
        QPushButton* button = qobject_cast<QPushButton*>(widget);
        if (button) {
            button->setFlat(flat);
        }
    }
}

void SwiftQPushButton::setCheckable(bool checkable) {
    ensureWidget();
    if (widget) {
        QPushButton* button = qobject_cast<QPushButton*>(widget);
        if (button) {
            button->setCheckable(checkable);
        }
    }
}

bool SwiftQPushButton::isChecked() const {
    if (widget) {
        QPushButton* button = qobject_cast<QPushButton*>(widget);
        if (button) {
            return button->isChecked();
        }
    }
    return false;
}

void SwiftQPushButton::setChecked(bool checked) {
    ensureWidget();
    if (widget) {
        QPushButton* button = qobject_cast<QPushButton*>(widget);
        if (button && button->isCheckable()) {
            button->setChecked(checked);
        }
    }
}

void SwiftQPushButton::setupConnections() {
    if (widget) {
        QPushButton* button = qobject_cast<QPushButton*>(widget);
        if (button) {
            // Disconnect existing connections for specific signals
            QObject::disconnect(button, &QPushButton::clicked, nullptr, nullptr);
            QObject::disconnect(button, &QPushButton::pressed, nullptr, nullptr);
            QObject::disconnect(button, &QPushButton::released, nullptr, nullptr);
            QObject::disconnect(button, &QPushButton::toggled, nullptr, nullptr);
            
            // Connect signals to stored functions
            if (clickedFunc) {
                QObject::connect(button, &QPushButton::clicked, clickedFunc);
            }
            if (pressedFunc) {
                QObject::connect(button, &QPushButton::pressed, pressedFunc);
            }
            if (releasedFunc) {
                QObject::connect(button, &QPushButton::released, releasedFunc);
            }
            if (toggledFunc) {
                QObject::connect(button, &QPushButton::toggled, toggledFunc);
            }
        }
    }
}

void SwiftQPushButton::setClickHandler(SwiftCallback callback) {
    // Legacy support - convert to new system
    if (callback.handler) {
        // Capture the callback data in a lambda
        clickedFunc = [callback]() {
            if (callback.handler) {
                callback.handler(callback.context);
            }
        };
    } else {
        clickedFunc = nullptr;
    }
    
    // Ensure widget exists and reconnect signals
    ensureWidget();
    setupConnections();
}

void SwiftQPushButton::setClickedHandler(SwiftEventCallback callback) {
    if (callback.handler) {
        clickedFunc = [callback]() {
            QtEventInfo info = {QtEventType::Clicked, 0, 0, nullptr, false, nullptr};
            callback.handler(callback.context, &info);
        };
    } else {
        clickedFunc = nullptr;
    }
    
    // Ensure widget exists and reconnect signals
    ensureWidget();
    setupConnections();
}

void SwiftQPushButton::setPressedHandler(SwiftEventCallback callback) {
    if (callback.handler) {
        pressedFunc = [callback]() {
            QtEventInfo info = {QtEventType::Pressed, 0, 0, nullptr, false, nullptr};
            callback.handler(callback.context, &info);
        };
    } else {
        pressedFunc = nullptr;
    }
    
    // Ensure widget exists and reconnect signals
    ensureWidget();
    setupConnections();
}

void SwiftQPushButton::setReleasedHandler(SwiftEventCallback callback) {
    if (callback.handler) {
        releasedFunc = [callback]() {
            QtEventInfo info = {QtEventType::Released, 0, 0, nullptr, false, nullptr};
            callback.handler(callback.context, &info);
        };
    } else {
        releasedFunc = nullptr;
    }
    
    // Ensure widget exists and reconnect signals
    ensureWidget();
    setupConnections();
}

void SwiftQPushButton::setToggledHandler(SwiftEventCallback callback) {
    if (callback.handler) {
        toggledFunc = [callback](bool checked) {
            QtEventInfo info = {QtEventType::Toggled, 0, 0, nullptr, checked, nullptr};
            callback.handler(callback.context, &info);
        };
    } else {
        toggledFunc = nullptr;
    }
    
    // Ensure widget exists and reconnect signals
    ensureWidget();
    setupConnections();
}

// SwiftQLineEdit implementation
void SwiftQLineEdit::ensureWidget() {
    if (!widget && QApplication::instance()) {
        QLineEdit* edit = nullptr;
        if (parentWidget) {
            edit = new QLineEdit(parentWidget->getQWidget());
        } else {
            edit = new QLineEdit(nullptr);
        }
        
        if (!lineText.empty()) {
            edit->setText(QString::fromStdString(lineText));
        }
        if (!placeholderText.empty()) {
            edit->setPlaceholderText(QString::fromStdString(placeholderText));
        }
        
        widget = edit;
    }
}

SwiftQLineEdit::SwiftQLineEdit() : SwiftQWidget() {}

SwiftQLineEdit::SwiftQLineEdit(const std::string& text) 
    : SwiftQWidget(), lineText(text) {}

SwiftQLineEdit::SwiftQLineEdit(const std::string& text, SwiftQWidget* parent)
    : SwiftQWidget(parent), lineText(text) {}

void SwiftQLineEdit::setText(const std::string& text) {
    lineText = text;
    ensureWidget();
    if (widget) {
        QLineEdit* edit = qobject_cast<QLineEdit*>(widget);
        if (edit) {
            edit->setText(QString::fromStdString(text));
        }
    }
}

std::string SwiftQLineEdit::text() const {
    if (widget) {
        QLineEdit* edit = qobject_cast<QLineEdit*>(widget);
        if (edit) {
            return edit->text().toStdString();
        }
    }
    return lineText;
}

void SwiftQLineEdit::setPlaceholderText(const std::string& text) {
    placeholderText = text;
    ensureWidget();
    if (widget) {
        QLineEdit* edit = qobject_cast<QLineEdit*>(widget);
        if (edit) {
            edit->setPlaceholderText(QString::fromStdString(text));
        }
    }
}

std::string SwiftQLineEdit::getPlaceholderText() const {
    if (widget) {
        QLineEdit* edit = qobject_cast<QLineEdit*>(widget);
        if (edit) {
            return edit->placeholderText().toStdString();
        }
    }
    return placeholderText;
}

void SwiftQLineEdit::setMaxLength(int length) {
    ensureWidget();
    if (widget) {
        QLineEdit* edit = qobject_cast<QLineEdit*>(widget);
        if (edit) {
            edit->setMaxLength(length);
        }
    }
}

void SwiftQLineEdit::setReadOnly(bool readOnly) {
    ensureWidget();
    if (widget) {
        QLineEdit* edit = qobject_cast<QLineEdit*>(widget);
        if (edit) {
            edit->setReadOnly(readOnly);
        }
    }
}

void SwiftQLineEdit::clear() {
    lineText.clear();
    if (widget) {
        QLineEdit* edit = qobject_cast<QLineEdit*>(widget);
        if (edit) {
            edit->clear();
        }
    }
}

void SwiftQLineEdit::selectAll() {
    ensureWidget();
    if (widget) {
        QLineEdit* edit = qobject_cast<QLineEdit*>(widget);
        if (edit) {
            edit->selectAll();
        }
    }
}

// SwiftQTextEdit implementation
void SwiftQTextEdit::ensureWidget() {
    if (!widget && QApplication::instance()) {
        QTextEdit* edit = nullptr;
        if (parentWidget) {
            edit = new QTextEdit(parentWidget->getQWidget());
        } else {
            edit = new QTextEdit(nullptr);
        }
        
        if (!textContent.empty()) {
            edit->setPlainText(QString::fromStdString(textContent));
        }
        
        widget = edit;
    }
}

SwiftQTextEdit::SwiftQTextEdit() : SwiftQWidget() {}

SwiftQTextEdit::SwiftQTextEdit(const std::string& text) 
    : SwiftQWidget(), textContent(text) {}

SwiftQTextEdit::SwiftQTextEdit(SwiftQWidget* parent) 
    : SwiftQWidget(parent) {}

void SwiftQTextEdit::setText(const std::string& text) {
    setPlainText(text);
}

std::string SwiftQTextEdit::toPlainText() const {
    if (widget) {
        QTextEdit* edit = qobject_cast<QTextEdit*>(widget);
        if (edit) {
            return edit->toPlainText().toStdString();
        }
    }
    return textContent;
}

void SwiftQTextEdit::setPlainText(const std::string& text) {
    textContent = text;
    ensureWidget();
    if (widget) {
        QTextEdit* edit = qobject_cast<QTextEdit*>(widget);
        if (edit) {
            edit->setPlainText(QString::fromStdString(text));
        }
    }
}

void SwiftQTextEdit::setHtml(const std::string& html) {
    textContent = html;
    ensureWidget();
    if (widget) {
        QTextEdit* edit = qobject_cast<QTextEdit*>(widget);
        if (edit) {
            edit->setHtml(QString::fromStdString(html));
        }
    }
}

std::string SwiftQTextEdit::toHtml() const {
    if (widget) {
        QTextEdit* edit = qobject_cast<QTextEdit*>(widget);
        if (edit) {
            return edit->toHtml().toStdString();
        }
    }
    return textContent;
}

void SwiftQTextEdit::clear() {
    textContent.clear();
    if (widget) {
        QTextEdit* edit = qobject_cast<QTextEdit*>(widget);
        if (edit) {
            edit->clear();
        }
    }
}

void SwiftQTextEdit::setReadOnly(bool readOnly) {
    ensureWidget();
    if (widget) {
        QTextEdit* edit = qobject_cast<QTextEdit*>(widget);
        if (edit) {
            edit->setReadOnly(readOnly);
        }
    }
}

void SwiftQTextEdit::setPlaceholderText(const std::string& text) {
    ensureWidget();
    if (widget) {
        QTextEdit* edit = qobject_cast<QTextEdit*>(widget);
        if (edit) {
            edit->setPlaceholderText(QString::fromStdString(text));
        }
    }
}

std::string SwiftQTextEdit::placeholderText() const {
    if (widget) {
        QTextEdit* edit = qobject_cast<QTextEdit*>(widget);
        if (edit) {
            return edit->placeholderText().toStdString();
        }
    }
    return "";
}

// SwiftQCheckBox implementation
void SwiftQCheckBox::ensureWidget() {
    if (!widget && QApplication::instance()) {
        QCheckBox* box = nullptr;
        if (parentWidget) {
            box = new QCheckBox(parentWidget->getQWidget());
        } else {
            box = new QCheckBox(nullptr);
        }
        
        if (!checkText.empty()) {
            box->setText(QString::fromStdString(checkText));
        }
        box->setCheckState(static_cast<Qt::CheckState>(checkState));
        
        widget = box;
    }
}

SwiftQCheckBox::SwiftQCheckBox() : SwiftQWidget(), checkState(0) {}

SwiftQCheckBox::SwiftQCheckBox(const std::string& text) 
    : SwiftQWidget(), checkText(text), checkState(0) {}

SwiftQCheckBox::SwiftQCheckBox(const std::string& text, SwiftQWidget* parent)
    : SwiftQWidget(parent), checkText(text), checkState(0) {}

void SwiftQCheckBox::setText(const std::string& text) {
    checkText = text;
    ensureWidget();
    if (widget) {
        QCheckBox* box = qobject_cast<QCheckBox*>(widget);
        if (box) {
            box->setText(QString::fromStdString(text));
        }
    }
}

std::string SwiftQCheckBox::text() const {
    if (widget) {
        QCheckBox* box = qobject_cast<QCheckBox*>(widget);
        if (box) {
            return box->text().toStdString();
        }
    }
    return checkText;
}

void SwiftQCheckBox::setChecked(bool checked) {
    checkState = checked ? 2 : 0;
    ensureWidget();
    if (widget) {
        QCheckBox* box = qobject_cast<QCheckBox*>(widget);
        if (box) {
            box->setChecked(checked);
        }
    }
}

bool SwiftQCheckBox::isChecked() const {
    if (widget) {
        QCheckBox* box = qobject_cast<QCheckBox*>(widget);
        if (box) {
            return box->isChecked();
        }
    }
    return checkState == 2;
}

void SwiftQCheckBox::setTristate(bool tristate) {
    ensureWidget();
    if (widget) {
        QCheckBox* box = qobject_cast<QCheckBox*>(widget);
        if (box) {
            box->setTristate(tristate);
        }
    }
}

void SwiftQCheckBox::setCheckState(int state) {
    checkState = state;
    ensureWidget();
    if (widget) {
        QCheckBox* box = qobject_cast<QCheckBox*>(widget);
        if (box) {
            box->setCheckState(static_cast<Qt::CheckState>(state));
        }
    }
}

int SwiftQCheckBox::getCheckState() const {
    if (widget) {
        QCheckBox* box = qobject_cast<QCheckBox*>(widget);
        if (box) {
            return static_cast<int>(box->checkState());
        }
    }
    return checkState;
}

// SwiftQRadioButton implementation
void SwiftQRadioButton::ensureWidget() {
    if (!widget && QApplication::instance()) {
        QRadioButton* button = nullptr;
        if (parentWidget) {
            button = new QRadioButton(parentWidget->getQWidget());
        } else {
            button = new QRadioButton(nullptr);
        }
        
        if (!radioText.empty()) {
            button->setText(QString::fromStdString(radioText));
        }
        button->setChecked(checked);
        
        widget = button;
    }
}

SwiftQRadioButton::SwiftQRadioButton() : SwiftQWidget(), checked(false) {}

SwiftQRadioButton::SwiftQRadioButton(const std::string& text) 
    : SwiftQWidget(), radioText(text), checked(false) {}

SwiftQRadioButton::SwiftQRadioButton(const std::string& text, SwiftQWidget* parent)
    : SwiftQWidget(parent), radioText(text), checked(false) {}

void SwiftQRadioButton::setText(const std::string& text) {
    radioText = text;
    ensureWidget();
    if (widget) {
        QRadioButton* button = qobject_cast<QRadioButton*>(widget);
        if (button) {
            button->setText(QString::fromStdString(text));
        }
    }
}

std::string SwiftQRadioButton::text() const {
    if (widget) {
        QRadioButton* button = qobject_cast<QRadioButton*>(widget);
        if (button) {
            return button->text().toStdString();
        }
    }
    return radioText;
}

void SwiftQRadioButton::setChecked(bool isChecked) {
    checked = isChecked;
    ensureWidget();
    if (widget) {
        QRadioButton* button = qobject_cast<QRadioButton*>(widget);
        if (button) {
            button->setChecked(isChecked);
        }
    }
}

bool SwiftQRadioButton::isChecked() const {
    if (widget) {
        QRadioButton* button = qobject_cast<QRadioButton*>(widget);
        if (button) {
            return button->isChecked();
        }
    }
    return checked;
}

// SwiftQComboBox implementation
void SwiftQComboBox::ensureWidget() {
    if (!widget && QApplication::instance()) {
        QComboBox* combo = nullptr;
        if (parentWidget) {
            combo = new QComboBox(parentWidget->getQWidget());
        } else {
            combo = new QComboBox(nullptr);
        }
        
        for (const auto& item : items) {
            combo->addItem(QString::fromStdString(item));
        }
        if (currentIdx >= 0 && currentIdx < static_cast<int>(items.size())) {
            combo->setCurrentIndex(currentIdx);
        }
        
        widget = combo;
        setupEventFilter();
        setupConnections();
    }
}

SwiftQComboBox::SwiftQComboBox() : SwiftQWidget(), currentIdx(-1) {
}

SwiftQComboBox::SwiftQComboBox(SwiftQWidget* parent) 
    : SwiftQWidget(parent), currentIdx(-1) {
}

SwiftQComboBox::~SwiftQComboBox() {
    // Clear stored functions first to prevent callbacks during cleanup
    indexChangedFunc = nullptr;
    textChangedFunc = nullptr;
    activatedFunc = nullptr;
    editTextChangedFunc = nullptr;
    
    // Note: We don't need to manually disconnect signals here.
    // Qt automatically handles signal disconnection when widgets are destroyed.
    // Trying to disconnect signals during destruction can cause crashes if
    // Qt is already in the process of cleaning up the widget hierarchy.
    // The std::function destructors above ensure our callbacks are cleaned up.
}

void SwiftQComboBox::addItem(const std::string& text) {
    items.push_back(text);
    if (widget) {
        QComboBox* combo = qobject_cast<QComboBox*>(widget);
        if (combo) {
            combo->addItem(QString::fromStdString(text));
        }
    }
}

void SwiftQComboBox::insertItem(int index, const std::string& text) {
    if (index >= 0 && index <= static_cast<int>(items.size())) {
        items.insert(items.begin() + index, text);
        if (widget) {
            QComboBox* combo = qobject_cast<QComboBox*>(widget);
            if (combo) {
                combo->insertItem(index, QString::fromStdString(text));
            }
        }
    }
}

void SwiftQComboBox::removeItem(int index) {
    if (index >= 0 && index < static_cast<int>(items.size())) {
        items.erase(items.begin() + index);
        if (widget) {
            QComboBox* combo = qobject_cast<QComboBox*>(widget);
            if (combo) {
                combo->removeItem(index);
            }
        }
    }
}

void SwiftQComboBox::clear() {
    items.clear();
    currentIdx = -1;
    if (widget) {
        QComboBox* combo = qobject_cast<QComboBox*>(widget);
        if (combo) {
            combo->clear();
        }
    }
}

int SwiftQComboBox::count() const {
    if (widget) {
        QComboBox* combo = qobject_cast<QComboBox*>(widget);
        if (combo) {
            return combo->count();
        }
    }
    return static_cast<int>(items.size());
}

int SwiftQComboBox::currentIndex() const {
    if (widget) {
        QComboBox* combo = qobject_cast<QComboBox*>(widget);
        if (combo) {
            return combo->currentIndex();
        }
    }
    return currentIdx;
}

void SwiftQComboBox::setCurrentIndex(int index) {
    currentIdx = index;
    ensureWidget();
    if (widget) {
        QComboBox* combo = qobject_cast<QComboBox*>(widget);
        if (combo && index >= 0 && index < combo->count()) {
            combo->setCurrentIndex(index);
            // Ensure our cached index is in sync
            currentIdx = combo->currentIndex();
        }
    }
}

std::string SwiftQComboBox::currentText() const {
    // IMPORTANT: This method should NOT be called during Qt signal emission (callbacks)
    // as it can cause crashes in Qt's accessibility system. Use the cached value instead.
    
    // First try to get from our cached items to avoid Qt accessibility issues
    if (currentIdx >= 0 && currentIdx < static_cast<int>(items.size())) {
        return items[currentIdx];
    }
    
    // Fallback to Qt widget if we don't have cached data
    // WARNING: This path can crash if called during signal emission!
    if (widget) {
        QComboBox* combo = qobject_cast<QComboBox*>(widget);
        if (combo && combo->count() > 0) {
            // Check if we're in the middle of signal emission
            // If so, return empty to avoid crash
            if (combo->signalsBlocked()) {
                return "";
            }
            
            // Safely get the text, avoiding potential crashes in callbacks
            int idx = combo->currentIndex();
            if (idx >= 0 && idx < combo->count()) {
                try {
                    // Temporarily block signals to prevent re-entrancy issues
                    bool oldState = combo->blockSignals(true);
                    QString text = combo->itemText(idx);
                    combo->blockSignals(oldState);
                    
                    if (!text.isNull()) {
                        // Update cache for next time
                        const_cast<SwiftQComboBox*>(this)->currentIdx = idx;
                        while (static_cast<int>(const_cast<SwiftQComboBox*>(this)->items.size()) <= idx) {
                            const_cast<SwiftQComboBox*>(this)->items.push_back("");
                        }
                        const_cast<SwiftQComboBox*>(this)->items[idx] = text.toStdString();
                        return text.toStdString();
                    }
                } catch (...) {
                    // If Qt throws, return empty
                    return "";
                }
            }
        }
    }
    return "";
}

std::string SwiftQComboBox::itemText(int index) const {
    if (widget) {
        QComboBox* combo = qobject_cast<QComboBox*>(widget);
        if (combo && index >= 0 && index < combo->count()) {
            return combo->itemText(index).toStdString();
        }
    }
    if (index >= 0 && index < static_cast<int>(items.size())) {
        return items[index];
    }
    return "";
}

void SwiftQComboBox::setEditable(bool editable) {
    ensureWidget();
    if (widget) {
        QComboBox* combo = qobject_cast<QComboBox*>(widget);
        if (combo) {
            combo->setEditable(editable);
        }
    }
}

bool SwiftQComboBox::isEditable() const {
    if (widget) {
        QComboBox* combo = qobject_cast<QComboBox*>(widget);
        if (combo) {
            return combo->isEditable();
        }
    }
    return false;
}

void SwiftQComboBox::setupConnections() {
    if (widget) {
        QComboBox* combo = qobject_cast<QComboBox*>(widget);
        if (combo) {
            // Disconnect existing connections for specific signals
            typedef void (QComboBox::*IndexSignal)(int);
            typedef void (QComboBox::*TextSignal)(const QString&);
            
            QObject::disconnect(combo, static_cast<IndexSignal>(&QComboBox::currentIndexChanged), nullptr, nullptr);
            QObject::disconnect(combo, static_cast<TextSignal>(&QComboBox::currentTextChanged), nullptr, nullptr);
            QObject::disconnect(combo, static_cast<IndexSignal>(&QComboBox::activated), nullptr, nullptr);
            QObject::disconnect(combo, &QComboBox::editTextChanged, nullptr, nullptr);
            
            // Connect signals to stored functions
            if (indexChangedFunc) {
                QObject::connect(combo, QOverload<int>::of(&QComboBox::currentIndexChanged), 
                    [this, combo](int index) {
                        // Update our cached index when user changes selection
                        currentIdx = index;
                        
                        // Cache the text BEFORE calling the handler to avoid Qt accessibility crashes
                        // This prevents issues when accessing Qt properties during signal emission
                        if (index >= 0 && index < static_cast<int>(items.size())) {
                            // We already have the text cached, no need to query Qt
                        } else if (index >= 0 && combo && index < combo->count()) {
                            // If we don't have it cached, get it now before the callback
                            try {
                                QString qtText = combo->itemText(index);
                                if (!qtText.isNull()) {
                                    // Ensure our items vector is large enough
                                    while (static_cast<int>(items.size()) <= index) {
                                        items.push_back("");
                                    }
                                    items[index] = qtText.toStdString();
                                }
                            } catch (...) {
                                // Ignore any exceptions during text retrieval
                            }
                        }
                        
                        if (indexChangedFunc) {
                            indexChangedFunc(index);
                        }
                    });
            }
            
            if (textChangedFunc) {
                QObject::connect(combo, &QComboBox::currentTextChanged,
                    [this](const QString& text) {
                        if (textChangedFunc) {
                            textChangedFunc(text.toStdString());
                        }
                    });
            }
            
            if (activatedFunc) {
                QObject::connect(combo, QOverload<int>::of(&QComboBox::activated),
                    activatedFunc);
            }
            
            if (editTextChangedFunc) {
                QObject::connect(combo, &QComboBox::editTextChanged,
                    [this](const QString& text) {
                        if (editTextChangedFunc) {
                            editTextChangedFunc(text.toStdString());
                        }
                    });
            }
        }
    }
}

void SwiftQComboBox::setIndexChangedHandler(SwiftCallbackInt callback) {
    // Legacy support - convert to new system
    if (callback.handler) {
        // Capture the callback data in a lambda
        indexChangedFunc = [callback](int index) {
            if (callback.handler) {
                callback.handler(callback.context, index);
            }
        };
    } else {
        indexChangedFunc = nullptr;
    }
    
    if (widget) {
        setupConnections();
    }
}

void SwiftQComboBox::setTextChangedHandler(SwiftCallbackString callback) {
    // Legacy support - convert to new system
    if (callback.handler) {
        // Capture the callback data in a lambda
        // Note: We need to store the string to ensure it remains valid
        textChangedFunc = [callback](const std::string& text) {
            if (callback.handler) {
                callback.handler(callback.context, text.c_str());
            }
        };
    } else {
        textChangedFunc = nullptr;
    }
    
    if (widget) {
        setupConnections();
    }
}

void SwiftQComboBox::setCurrentIndexChangedHandler(SwiftEventCallback callback) {
    if (callback.handler) {
        indexChangedFunc = [this, callback](int index) {
            // Get the text from our cache to avoid Qt accessibility issues
            const char* textPtr = nullptr;
            std::string text;
            if (index >= 0 && index < static_cast<int>(items.size())) {
                text = items[index];
                textPtr = text.c_str();
            }
            
            QtEventInfo info = {QtEventType::CurrentIndexChanged, index, 0, textPtr, false, nullptr};
            callback.handler(callback.context, &info);
        };
    } else {
        indexChangedFunc = nullptr;
    }
    
    if (widget) {
        setupConnections();
    }
}

void SwiftQComboBox::setCurrentTextChangedHandler(SwiftEventCallback callback) {
    if (callback.handler) {
        // We need to store the string safely
        textChangedFunc = [callback](const std::string& text) {
            QtEventInfo info = {QtEventType::CurrentTextChanged, 0, 0, text.c_str(), false, nullptr};
            callback.handler(callback.context, &info);
        };
    } else {
        textChangedFunc = nullptr;
    }
    
    if (widget) {
        setupConnections();
    }
}

void SwiftQComboBox::setActivatedHandler(SwiftEventCallback callback) {
    if (callback.handler) {
        activatedFunc = [callback](int index) {
            QtEventInfo info = {QtEventType::Activated, index, 0, nullptr, false, nullptr};
            callback.handler(callback.context, &info);
        };
    } else {
        activatedFunc = nullptr;
    }
    
    if (widget) {
        setupConnections();
    }
}

void SwiftQComboBox::setEditTextChangedHandler(SwiftEventCallback callback) {
    if (callback.handler) {
        editTextChangedFunc = [callback](const std::string& text) {
            QtEventInfo info = {QtEventType::TextEdited, 0, 0, text.c_str(), false, nullptr};
            callback.handler(callback.context, &info);
        };
    } else {
        editTextChangedFunc = nullptr;
    }
    
    if (widget) {
        setupConnections();
    }
}

// SwiftQGroupBox implementation
void SwiftQGroupBox::ensureWidget() {
    if (!widget && QApplication::instance()) {
        QGroupBox* group = nullptr;
        if (parentWidget) {
            group = new QGroupBox(parentWidget->getQWidget());
        } else {
            group = new QGroupBox(nullptr);
        }
        
        if (!title.empty()) {
            group->setTitle(QString::fromStdString(title));
        }
        
        widget = group;
    }
}

SwiftQGroupBox::SwiftQGroupBox() : SwiftQWidget() {}

SwiftQGroupBox::SwiftQGroupBox(const std::string& groupTitle) 
    : SwiftQWidget(), title(groupTitle) {}

SwiftQGroupBox::SwiftQGroupBox(const std::string& groupTitle, SwiftQWidget* parent)
    : SwiftQWidget(parent), title(groupTitle) {}

void SwiftQGroupBox::setTitle(const std::string& groupTitle) {
    title = groupTitle;
    ensureWidget();
    if (widget) {
        QGroupBox* group = qobject_cast<QGroupBox*>(widget);
        if (group) {
            group->setTitle(QString::fromStdString(groupTitle));
        }
    }
}

std::string SwiftQGroupBox::getTitle() const {
    if (widget) {
        QGroupBox* group = qobject_cast<QGroupBox*>(widget);
        if (group) {
            return group->title().toStdString();
        }
    }
    return title;
}

void SwiftQGroupBox::setCheckable(bool checkable) {
    ensureWidget();
    if (widget) {
        QGroupBox* group = qobject_cast<QGroupBox*>(widget);
        if (group) {
            group->setCheckable(checkable);
        }
    }
}

void SwiftQGroupBox::setChecked(bool checked) {
    ensureWidget();
    if (widget) {
        QGroupBox* group = qobject_cast<QGroupBox*>(widget);
        if (group && group->isCheckable()) {
            group->setChecked(checked);
        }
    }
}

bool SwiftQGroupBox::isChecked() const {
    if (widget) {
        QGroupBox* group = qobject_cast<QGroupBox*>(widget);
        if (group && group->isCheckable()) {
            return group->isChecked();
        }
    }
    return false;
}

// SwiftQSlider implementation
void SwiftQSlider::ensureWidget() {
    if (!widget && QApplication::instance()) {
        QSlider* slider = nullptr;
        if (parentWidget) {
            slider = new QSlider(static_cast<Qt::Orientation>(sliderOrientation), parentWidget->getQWidget());
        } else {
            slider = new QSlider(static_cast<Qt::Orientation>(sliderOrientation));
        }
        
        slider->setMinimum(sliderMin);
        slider->setMaximum(sliderMax);
        slider->setValue(sliderValue);
        
        widget = slider;
        ownsWidget = true;
        setupEventFilter();
        setupConnections();
    }
}

void SwiftQSlider::setupConnections() {
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            // Disconnect any existing connections
            QObject::disconnect(slider, nullptr, nullptr, nullptr);
            
            // Set up valueChanged connection
            if (valueChangedFunc) {
                QObject::connect(slider, &QSlider::valueChanged, [this](int value) {
                    if (valueChangedFunc) {
                        valueChangedFunc(value);
                    }
                });
            }
            
            // Set up sliderPressed connection
            if (sliderPressedFunc) {
                QObject::connect(slider, &QSlider::sliderPressed, [this]() {
                    if (sliderPressedFunc) {
                        sliderPressedFunc();
                    }
                });
            }
            
            // Set up sliderReleased connection
            if (sliderReleasedFunc) {
                QObject::connect(slider, &QSlider::sliderReleased, [this]() {
                    if (sliderReleasedFunc) {
                        sliderReleasedFunc();
                    }
                });
            }
            
            // Set up sliderMoved connection
            if (sliderMovedFunc) {
                QObject::connect(slider, &QSlider::sliderMoved, [this](int value) {
                    if (sliderMovedFunc) {
                        sliderMovedFunc(value);
                    }
                });
            }
        }
    }
}

SwiftQSlider::SwiftQSlider()
    : SwiftQWidget(), sliderValue(0), sliderMin(0), sliderMax(100), sliderOrientation(1) {
}

SwiftQSlider::SwiftQSlider(int orientation)
    : SwiftQWidget(), sliderValue(0), sliderMin(0), sliderMax(100), sliderOrientation(orientation) {
}

SwiftQSlider::SwiftQSlider(int orientation, SwiftQWidget* parent)
    : SwiftQWidget(parent), sliderValue(0), sliderMin(0), sliderMax(100), sliderOrientation(orientation) {
}

SwiftQSlider::~SwiftQSlider() {
    // Clear callbacks to prevent any dangling references
    valueChangedFunc = nullptr;
    sliderPressedFunc = nullptr;
    sliderReleasedFunc = nullptr;
    sliderMovedFunc = nullptr;
}

void SwiftQSlider::setValue(int value) {
    sliderValue = value;
    ensureWidget();
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            slider->setValue(value);
        }
    }
}

int SwiftQSlider::value() const {
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            return slider->value();
        }
    }
    return sliderValue;
}

void SwiftQSlider::setMinimum(int min) {
    sliderMin = min;
    ensureWidget();
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            slider->setMinimum(min);
        }
    }
}

int SwiftQSlider::minimum() const {
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            return slider->minimum();
        }
    }
    return sliderMin;
}

void SwiftQSlider::setMaximum(int max) {
    sliderMax = max;
    ensureWidget();
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            slider->setMaximum(max);
        }
    }
}

int SwiftQSlider::maximum() const {
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            return slider->maximum();
        }
    }
    return sliderMax;
}

void SwiftQSlider::setRange(int min, int max) {
    sliderMin = min;
    sliderMax = max;
    ensureWidget();
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            slider->setRange(min, max);
        }
    }
}

void SwiftQSlider::setOrientation(int orientation) {
    sliderOrientation = orientation;
    ensureWidget();
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            slider->setOrientation(static_cast<Qt::Orientation>(orientation));
        }
    }
}

int SwiftQSlider::orientation() const {
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            return static_cast<int>(slider->orientation());
        }
    }
    return sliderOrientation;
}

void SwiftQSlider::setTickPosition(int position) {
    ensureWidget();
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            slider->setTickPosition(static_cast<QSlider::TickPosition>(position));
        }
    }
}

void SwiftQSlider::setTickInterval(int interval) {
    ensureWidget();
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            slider->setTickInterval(interval);
        }
    }
}

int SwiftQSlider::tickInterval() const {
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            return slider->tickInterval();
        }
    }
    return 0;
}

void SwiftQSlider::setSingleStep(int step) {
    ensureWidget();
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            slider->setSingleStep(step);
        }
    }
}

int SwiftQSlider::singleStep() const {
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            return slider->singleStep();
        }
    }
    return 1;
}

void SwiftQSlider::setPageStep(int step) {
    ensureWidget();
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            slider->setPageStep(step);
        }
    }
}

int SwiftQSlider::pageStep() const {
    if (widget) {
        QSlider* slider = qobject_cast<QSlider*>(widget);
        if (slider) {
            return slider->pageStep();
        }
    }
    return 10;
}

void SwiftQSlider::setValueChangedHandler(SwiftEventCallback callback) {
    valueChangedFunc = [callback](int value) {
        if (callback.handler) {
            QtEventInfo info;
            info.type = QtEventType::Custom;
            info.intValue = value;
            info.intValue2 = 0;
            info.stringValue = nullptr;
            info.boolValue = false;
            info.customData = nullptr;
            callback.handler(callback.context, &info);
        }
    };
    setupConnections();
}

void SwiftQSlider::setSliderPressedHandler(SwiftEventCallback callback) {
    sliderPressedFunc = [callback]() {
        if (callback.handler) {
            QtEventInfo info;
            info.type = QtEventType::Pressed;
            info.intValue = 0;
            info.intValue2 = 0;
            info.stringValue = nullptr;
            info.boolValue = false;
            info.customData = nullptr;
            callback.handler(callback.context, &info);
        }
    };
    setupConnections();
}

void SwiftQSlider::setSliderReleasedHandler(SwiftEventCallback callback) {
    sliderReleasedFunc = [callback]() {
        if (callback.handler) {
            QtEventInfo info;
            info.type = QtEventType::Released;
            info.intValue = 0;
            info.intValue2 = 0;
            info.stringValue = nullptr;
            info.boolValue = false;
            info.customData = nullptr;
            callback.handler(callback.context, &info);
        }
    };
    setupConnections();
}

void SwiftQSlider::setSliderMovedHandler(SwiftEventCallback callback) {
    sliderMovedFunc = [callback](int value) {
        if (callback.handler) {
            QtEventInfo info;
            info.type = QtEventType::Move;
            info.intValue = value;
            info.intValue2 = 0;
            info.stringValue = nullptr;
            info.boolValue = false;
            info.customData = nullptr;
            callback.handler(callback.context, &info);
        }
    };
    setupConnections();
}

// SwiftQProgressBar implementation
void SwiftQProgressBar::ensureWidget() {
    if (!widget && QApplication::instance()) {
        QProgressBar* progressBar = nullptr;
        if (parentWidget) {
            progressBar = new QProgressBar(parentWidget->getQWidget());
        } else {
            progressBar = new QProgressBar(nullptr);
        }
        
        progressBar->setMinimum(progressMin);
        progressBar->setMaximum(progressMax);
        progressBar->setValue(progressValue);
        if (!progressFormat.empty()) {
            progressBar->setFormat(QString::fromStdString(progressFormat));
        }
        
        widget = progressBar;
        ownsWidget = true;
        setupEventFilter();
    }
}

SwiftQProgressBar::SwiftQProgressBar()
    : SwiftQWidget(), progressValue(0), progressMin(0), progressMax(100), progressFormat("%p%") {
}

SwiftQProgressBar::SwiftQProgressBar(SwiftQWidget* parent)
    : SwiftQWidget(parent), progressValue(0), progressMin(0), progressMax(100), progressFormat("%p%") {
}

void SwiftQProgressBar::setValue(int value) {
    progressValue = value;
    ensureWidget();
    if (widget) {
        QProgressBar* progressBar = qobject_cast<QProgressBar*>(widget);
        if (progressBar) {
            progressBar->setValue(value);
        }
    }
}

int SwiftQProgressBar::value() const {
    if (widget) {
        QProgressBar* progressBar = qobject_cast<QProgressBar*>(widget);
        if (progressBar) {
            return progressBar->value();
        }
    }
    return progressValue;
}

void SwiftQProgressBar::setMinimum(int min) {
    progressMin = min;
    ensureWidget();
    if (widget) {
        QProgressBar* progressBar = qobject_cast<QProgressBar*>(widget);
        if (progressBar) {
            progressBar->setMinimum(min);
        }
    }
}

int SwiftQProgressBar::minimum() const {
    if (widget) {
        QProgressBar* progressBar = qobject_cast<QProgressBar*>(widget);
        if (progressBar) {
            return progressBar->minimum();
        }
    }
    return progressMin;
}

void SwiftQProgressBar::setMaximum(int max) {
    progressMax = max;
    ensureWidget();
    if (widget) {
        QProgressBar* progressBar = qobject_cast<QProgressBar*>(widget);
        if (progressBar) {
            progressBar->setMaximum(max);
        }
    }
}

int SwiftQProgressBar::maximum() const {
    if (widget) {
        QProgressBar* progressBar = qobject_cast<QProgressBar*>(widget);
        if (progressBar) {
            return progressBar->maximum();
        }
    }
    return progressMax;
}

void SwiftQProgressBar::setRange(int min, int max) {
    progressMin = min;
    progressMax = max;
    ensureWidget();
    if (widget) {
        QProgressBar* progressBar = qobject_cast<QProgressBar*>(widget);
        if (progressBar) {
            progressBar->setRange(min, max);
        }
    }
}

void SwiftQProgressBar::setTextVisible(bool visible) {
    ensureWidget();
    if (widget) {
        QProgressBar* progressBar = qobject_cast<QProgressBar*>(widget);
        if (progressBar) {
            progressBar->setTextVisible(visible);
        }
    }
}

bool SwiftQProgressBar::isTextVisible() const {
    if (widget) {
        QProgressBar* progressBar = qobject_cast<QProgressBar*>(widget);
        if (progressBar) {
            return progressBar->isTextVisible();
        }
    }
    return true;
}

void SwiftQProgressBar::setFormat(const std::string& format) {
    progressFormat = format;
    ensureWidget();
    if (widget) {
        QProgressBar* progressBar = qobject_cast<QProgressBar*>(widget);
        if (progressBar) {
            progressBar->setFormat(QString::fromStdString(format));
        }
    }
}

std::string SwiftQProgressBar::format() const {
    if (widget) {
        QProgressBar* progressBar = qobject_cast<QProgressBar*>(widget);
        if (progressBar) {
            return progressBar->format().toStdString();
        }
    }
    return progressFormat;
}

void SwiftQProgressBar::setOrientation(int orientation) {
    ensureWidget();
    if (widget) {
        QProgressBar* progressBar = qobject_cast<QProgressBar*>(widget);
        if (progressBar) {
            progressBar->setOrientation(static_cast<Qt::Orientation>(orientation));
        }
    }
}

int SwiftQProgressBar::orientation() const {
    if (widget) {
        QProgressBar* progressBar = qobject_cast<QProgressBar*>(widget);
        if (progressBar) {
            return static_cast<int>(progressBar->orientation());
        }
    }
    return 1; // Qt::Horizontal
}

void SwiftQProgressBar::reset() {
    progressValue = progressMin;
    ensureWidget();
    if (widget) {
        QProgressBar* progressBar = qobject_cast<QProgressBar*>(widget);
        if (progressBar) {
            progressBar->reset();
        }
    }
}

// SwiftQScrollArea implementation
void SwiftQScrollArea::ensureWidget() {
    if (!widget && QApplication::instance()) {
        QScrollArea* scrollArea = nullptr;
        if (parentWidget) {
            scrollArea = new QScrollArea(parentWidget->getQWidget());
        } else {
            scrollArea = new QScrollArea(nullptr);
        }
        
        scrollArea->setWidgetResizable(true);
        
        widget = scrollArea;
        ownsWidget = true;
        setupEventFilter();
    }
}

SwiftQScrollArea::SwiftQScrollArea()
    : SwiftQWidget(), contentWidget(nullptr) {
}

SwiftQScrollArea::SwiftQScrollArea(SwiftQWidget* parent)
    : SwiftQWidget(parent), contentWidget(nullptr) {
}

SwiftQScrollArea::~SwiftQScrollArea() {
    // The content widget will be deleted automatically by Qt
    contentWidget = nullptr;
}

void SwiftQScrollArea::setWidget(SwiftQWidget* widget) {
    contentWidget = widget;
    ensureWidget();
    if (this->widget) {
        QScrollArea* scrollArea = qobject_cast<QScrollArea*>(this->widget);
        if (scrollArea) {
            if (widget) {
                scrollArea->setWidget(widget->getQWidget());
            } else {
                scrollArea->setWidget(nullptr);
            }
        }
    }
}

SwiftQWidget* SwiftQScrollArea::getWidget() const {
    return contentWidget;
}

void SwiftQScrollArea::setWidgetResizable(bool resizable) {
    ensureWidget();
    if (widget) {
        QScrollArea* scrollArea = qobject_cast<QScrollArea*>(widget);
        if (scrollArea) {
            scrollArea->setWidgetResizable(resizable);
        }
    }
}

bool SwiftQScrollArea::widgetResizable() const {
    if (widget) {
        QScrollArea* scrollArea = qobject_cast<QScrollArea*>(widget);
        if (scrollArea) {
            return scrollArea->widgetResizable();
        }
    }
    return true;
}

void SwiftQScrollArea::setHorizontalScrollBarPolicy(int policy) {
    ensureWidget();
    if (widget) {
        QScrollArea* scrollArea = qobject_cast<QScrollArea*>(widget);
        if (scrollArea) {
            scrollArea->setHorizontalScrollBarPolicy(static_cast<Qt::ScrollBarPolicy>(policy));
        }
    }
}

void SwiftQScrollArea::setVerticalScrollBarPolicy(int policy) {
    ensureWidget();
    if (widget) {
        QScrollArea* scrollArea = qobject_cast<QScrollArea*>(widget);
        if (scrollArea) {
            scrollArea->setVerticalScrollBarPolicy(static_cast<Qt::ScrollBarPolicy>(policy));
        }
    }
}

int SwiftQScrollArea::horizontalScrollBarPolicy() const {
    if (widget) {
        QScrollArea* scrollArea = qobject_cast<QScrollArea*>(widget);
        if (scrollArea) {
            return static_cast<int>(scrollArea->horizontalScrollBarPolicy());
        }
    }
    return 0; // Qt::ScrollBarAsNeeded
}

int SwiftQScrollArea::verticalScrollBarPolicy() const {
    if (widget) {
        QScrollArea* scrollArea = qobject_cast<QScrollArea*>(widget);
        if (scrollArea) {
            return static_cast<int>(scrollArea->verticalScrollBarPolicy());
        }
    }
    return 0; // Qt::ScrollBarAsNeeded
}

void SwiftQScrollArea::ensureVisible(int x, int y, int xmargin, int ymargin) {
    ensureWidget();
    if (widget) {
        QScrollArea* scrollArea = qobject_cast<QScrollArea*>(widget);
        if (scrollArea) {
            scrollArea->ensureVisible(x, y, xmargin, ymargin);
        }
    }
}

void SwiftQScrollArea::ensureWidgetVisible(SwiftQWidget* childWidget, int xmargin, int ymargin) {
    if (!childWidget) return;
    ensureWidget();
    if (widget) {
        QScrollArea* scrollArea = qobject_cast<QScrollArea*>(widget);
        if (scrollArea) {
            QWidget* child = childWidget->getQWidget();
            if (child) {
                scrollArea->ensureWidgetVisible(child, xmargin, ymargin);
            }
        }
    }
}

int SwiftQScrollArea::horizontalScrollValue() const {
    if (widget) {
        QScrollArea* scrollArea = qobject_cast<QScrollArea*>(widget);
        if (scrollArea && scrollArea->horizontalScrollBar()) {
            return scrollArea->horizontalScrollBar()->value();
        }
    }
    return 0;
}

void SwiftQScrollArea::setHorizontalScrollValue(int value) {
    ensureWidget();
    if (widget) {
        QScrollArea* scrollArea = qobject_cast<QScrollArea*>(widget);
        if (scrollArea && scrollArea->horizontalScrollBar()) {
            scrollArea->horizontalScrollBar()->setValue(value);
        }
    }
}

int SwiftQScrollArea::verticalScrollValue() const {
    if (widget) {
        QScrollArea* scrollArea = qobject_cast<QScrollArea*>(widget);
        if (scrollArea && scrollArea->verticalScrollBar()) {
            return scrollArea->verticalScrollBar()->value();
        }
    }
    return 0;
}

void SwiftQScrollArea::setVerticalScrollValue(int value) {
    ensureWidget();
    if (widget) {
        QScrollArea* scrollArea = qobject_cast<QScrollArea*>(widget);
        if (scrollArea && scrollArea->verticalScrollBar()) {
            scrollArea->verticalScrollBar()->setValue(value);
        }
    }
}

int SwiftQScrollArea::horizontalScrollMaximum() const {
    if (widget) {
        QScrollArea* scrollArea = qobject_cast<QScrollArea*>(widget);
        if (scrollArea && scrollArea->horizontalScrollBar()) {
            return scrollArea->horizontalScrollBar()->maximum();
        }
    }
    return 0;
}

int SwiftQScrollArea::verticalScrollMaximum() const {
    if (widget) {
        QScrollArea* scrollArea = qobject_cast<QScrollArea*>(widget);
        if (scrollArea && scrollArea->verticalScrollBar()) {
            return scrollArea->verticalScrollBar()->maximum();
        }
    }
    return 0;
}

// SwiftQTabWidget implementation
void SwiftQTabWidget::ensureWidget() {
    if (!widget) {
        widget = new QTabWidget();
    }
    if (!tabWidget) {
        tabWidget = qobject_cast<QTabWidget*>(widget);
    }
}

SwiftQTabWidget::SwiftQTabWidget() : SwiftQWidget(), tabWidget(nullptr) {
    ensureWidget();
}

SwiftQTabWidget::SwiftQTabWidget(SwiftQWidget* parent) : SwiftQWidget(parent), tabWidget(nullptr) {
    ensureWidget();
}

SwiftQTabWidget::~SwiftQTabWidget() {
    // Widget is deleted by base class
}

int SwiftQTabWidget::addTab(SwiftQWidget* widget, const std::string& label) {
    ensureWidget();
    if (tabWidget && widget && widget->getQWidget()) {
        return tabWidget->addTab(widget->getQWidget(), QString::fromStdString(label));
    }
    return -1;
}

int SwiftQTabWidget::insertTab(int index, SwiftQWidget* widget, const std::string& label) {
    ensureWidget();
    if (tabWidget && widget && widget->getQWidget()) {
        return tabWidget->insertTab(index, widget->getQWidget(), QString::fromStdString(label));
    }
    return -1;
}

void SwiftQTabWidget::removeTab(int index) {
    ensureWidget();
    if (tabWidget) {
        tabWidget->removeTab(index);
    }
}

void SwiftQTabWidget::setTabText(int index, const std::string& text) {
    ensureWidget();
    if (tabWidget) {
        tabWidget->setTabText(index, QString::fromStdString(text));
    }
}

std::string SwiftQTabWidget::tabText(int index) const {
    if (tabWidget) {
        return tabWidget->tabText(index).toStdString();
    }
    return "";
}

void SwiftQTabWidget::setTabEnabled(int index, bool enabled) {
    ensureWidget();
    if (tabWidget) {
        tabWidget->setTabEnabled(index, enabled);
    }
}

bool SwiftQTabWidget::isTabEnabled(int index) const {
    if (tabWidget) {
        return tabWidget->isTabEnabled(index);
    }
    return false;
}

int SwiftQTabWidget::currentIndex() const {
    if (tabWidget) {
        return tabWidget->currentIndex();
    }
    return -1;
}

void SwiftQTabWidget::setCurrentIndex(int index) {
    ensureWidget();
    if (tabWidget) {
        tabWidget->setCurrentIndex(index);
    }
}

SwiftQWidget* SwiftQTabWidget::currentWidget() const {
    // This would require maintaining a mapping of QWidget* to SwiftQWidget*
    // For now, returning nullptr
    return nullptr;
}

void SwiftQTabWidget::setCurrentWidget(SwiftQWidget* widget) {
    ensureWidget();
    if (tabWidget && widget && widget->getQWidget()) {
        tabWidget->setCurrentWidget(widget->getQWidget());
    }
}

int SwiftQTabWidget::count() const {
    if (tabWidget) {
        return tabWidget->count();
    }
    return 0;
}

void SwiftQTabWidget::clear() {
    ensureWidget();
    if (tabWidget) {
        tabWidget->clear();
    }
}

void SwiftQTabWidget::setTabPosition(int position) {
    ensureWidget();
    if (tabWidget) {
        tabWidget->setTabPosition(static_cast<QTabWidget::TabPosition>(position));
    }
}

int SwiftQTabWidget::tabPosition() const {
    if (tabWidget) {
        return static_cast<int>(tabWidget->tabPosition());
    }
    return 0;
}

void SwiftQTabWidget::setMovable(bool movable) {
    ensureWidget();
    if (tabWidget) {
        tabWidget->setMovable(movable);
    }
}

bool SwiftQTabWidget::isMovable() const {
    if (tabWidget) {
        return tabWidget->isMovable();
    }
    return false;
}

void SwiftQTabWidget::setTabBarAutoHide(bool hide) {
    ensureWidget();
    if (tabWidget) {
        tabWidget->setTabsClosable(hide); // Using closable as a similar feature
    }
}

bool SwiftQTabWidget::tabBarAutoHide() const {
    if (tabWidget) {
        return tabWidget->tabsClosable();
    }
    return false;
}

// SwiftQSplitter implementation
void SwiftQSplitter::ensureWidget() {
    if (!SwiftQWidget::widget) {
        SwiftQWidget::widget = new QSplitter();
    }
    if (!splitter) {
        splitter = qobject_cast<QSplitter*>(SwiftQWidget::widget);
    }
}

SwiftQSplitter::SwiftQSplitter() : SwiftQWidget(), splitter(nullptr) {
    ensureWidget();
}

SwiftQSplitter::SwiftQSplitter(int orientation) : SwiftQWidget(), splitter(nullptr) {
    SwiftQWidget::widget = new QSplitter(static_cast<Qt::Orientation>(orientation));
    splitter = qobject_cast<QSplitter*>(SwiftQWidget::widget);
}

SwiftQSplitter::SwiftQSplitter(SwiftQWidget* parent) : SwiftQWidget(parent), splitter(nullptr) {
    ensureWidget();
}

SwiftQSplitter::SwiftQSplitter(int orientation, SwiftQWidget* parent) : SwiftQWidget(parent), splitter(nullptr) {
    SwiftQWidget::widget = new QSplitter(static_cast<Qt::Orientation>(orientation), parent ? parent->getQWidget() : nullptr);
    splitter = qobject_cast<QSplitter*>(SwiftQWidget::widget);
}

SwiftQSplitter::~SwiftQSplitter() {
    // Widget is deleted by base class
}

void SwiftQSplitter::addWidget(SwiftQWidget* widget) {
    ensureWidget();
    if (splitter && widget && widget->getQWidget()) {
        splitter->addWidget(widget->getQWidget());
    }
}

void SwiftQSplitter::insertWidget(int index, SwiftQWidget* widget) {
    ensureWidget();
    if (splitter && widget && widget->getQWidget()) {
        splitter->insertWidget(index, widget->getQWidget());
    }
}

int SwiftQSplitter::count() const {
    if (splitter) {
        return splitter->count();
    }
    return 0;
}

SwiftQWidget* SwiftQSplitter::widget(int index) const {
    // This would require maintaining a mapping of QWidget* to SwiftQWidget*
    // For now, returning nullptr
    return nullptr;
}

int SwiftQSplitter::indexOf(SwiftQWidget* widget) const {
    if (splitter && widget && widget->getQWidget()) {
        return splitter->indexOf(widget->getQWidget());
    }
    return -1;
}

void SwiftQSplitter::setOrientation(int orientation) {
    ensureWidget();
    if (splitter) {
        splitter->setOrientation(static_cast<Qt::Orientation>(orientation));
    }
}

int SwiftQSplitter::orientation() const {
    if (splitter) {
        return static_cast<int>(splitter->orientation());
    }
    return 1; // Horizontal
}

void SwiftQSplitter::setSizes(const std::vector<int>& sizes) {
    ensureWidget();
    if (splitter) {
        QList<int> qsizes;
        for (int size : sizes) {
            qsizes.append(size);
        }
        splitter->setSizes(qsizes);
    }
}

void SwiftQSplitter::setSizesArray(const int* sizes, int count) {
    ensureWidget();
    if (splitter && sizes && count > 0) {
        QList<int> qsizes;
        for (int i = 0; i < count; ++i) {
            qsizes.append(sizes[i]);
        }
        splitter->setSizes(qsizes);
    }
}

std::vector<int> SwiftQSplitter::sizes() const {
    std::vector<int> result;
    if (splitter) {
        QList<int> qsizes = splitter->sizes();
        for (int size : qsizes) {
            result.push_back(size);
        }
    }
    return result;
}

int SwiftQSplitter::getSizeAt(int index) const {
    if (splitter) {
        QList<int> qsizes = splitter->sizes();
        if (index >= 0 && index < qsizes.size()) {
            return qsizes[index];
        }
    }
    return 0;
}

int SwiftQSplitter::sizesCount() const {
    if (splitter) {
        return splitter->sizes().size();
    }
    return 0;
}

void SwiftQSplitter::setStretchFactor(int index, int stretch) {
    ensureWidget();
    if (splitter) {
        splitter->setStretchFactor(index, stretch);
    }
}

void SwiftQSplitter::setCollapsible(int index, bool collapsible) {
    ensureWidget();
    if (splitter) {
        splitter->setCollapsible(index, collapsible);
    }
}

bool SwiftQSplitter::isCollapsible(int index) const {
    if (splitter) {
        return splitter->isCollapsible(index);
    }
    return true;
}

void SwiftQSplitter::setChildrenCollapsible(bool collapsible) {
    ensureWidget();
    if (splitter) {
        splitter->setChildrenCollapsible(collapsible);
    }
}

bool SwiftQSplitter::childrenCollapsible() const {
    if (splitter) {
        return splitter->childrenCollapsible();
    }
    return true;
}

void SwiftQSplitter::setHandleWidth(int width) {
    ensureWidget();
    if (splitter) {
        splitter->setHandleWidth(width);
    }
}

int SwiftQSplitter::handleWidth() const {
    if (splitter) {
        return splitter->handleWidth();
    }
    return 0;
}

// SwiftQSpinBox implementation
void SwiftQSpinBox::ensureWidget() {
    if (!widget) {
        widget = new QSpinBox();
    }
    if (!spinBox) {
        spinBox = qobject_cast<QSpinBox*>(widget);
    }
}

SwiftQSpinBox::SwiftQSpinBox() : SwiftQWidget(), spinBox(nullptr) {
    ensureWidget();
}

SwiftQSpinBox::SwiftQSpinBox(SwiftQWidget* parent) : SwiftQWidget(parent), spinBox(nullptr) {
    ensureWidget();
}

SwiftQSpinBox::~SwiftQSpinBox() {
    // Widget is deleted by base class
}

int SwiftQSpinBox::value() const {
    if (spinBox) {
        return spinBox->value();
    }
    return 0;
}

void SwiftQSpinBox::setValue(int value) {
    ensureWidget();
    if (spinBox) {
        spinBox->setValue(value);
    }
}

int SwiftQSpinBox::minimum() const {
    if (spinBox) {
        return spinBox->minimum();
    }
    return 0;
}

void SwiftQSpinBox::setMinimum(int min) {
    ensureWidget();
    if (spinBox) {
        spinBox->setMinimum(min);
    }
}

int SwiftQSpinBox::maximum() const {
    if (spinBox) {
        return spinBox->maximum();
    }
    return 99;
}

void SwiftQSpinBox::setMaximum(int max) {
    ensureWidget();
    if (spinBox) {
        spinBox->setMaximum(max);
    }
}

void SwiftQSpinBox::setRange(int min, int max) {
    ensureWidget();
    if (spinBox) {
        spinBox->setRange(min, max);
    }
}

int SwiftQSpinBox::singleStep() const {
    if (spinBox) {
        return spinBox->singleStep();
    }
    return 1;
}

void SwiftQSpinBox::setSingleStep(int step) {
    ensureWidget();
    if (spinBox) {
        spinBox->setSingleStep(step);
    }
}

std::string SwiftQSpinBox::prefix() const {
    if (spinBox) {
        return spinBox->prefix().toStdString();
    }
    return "";
}

void SwiftQSpinBox::setPrefix(const std::string& prefix) {
    ensureWidget();
    if (spinBox) {
        spinBox->setPrefix(QString::fromStdString(prefix));
    }
}

std::string SwiftQSpinBox::suffix() const {
    if (spinBox) {
        return spinBox->suffix().toStdString();
    }
    return "";
}

void SwiftQSpinBox::setSuffix(const std::string& suffix) {
    ensureWidget();
    if (spinBox) {
        spinBox->setSuffix(QString::fromStdString(suffix));
    }
}

std::string SwiftQSpinBox::specialValueText() const {
    if (spinBox) {
        return spinBox->specialValueText().toStdString();
    }
    return "";
}

void SwiftQSpinBox::setSpecialValueText(const std::string& text) {
    ensureWidget();
    if (spinBox) {
        spinBox->setSpecialValueText(QString::fromStdString(text));
    }
}

bool SwiftQSpinBox::wrapping() const {
    if (spinBox) {
        return spinBox->wrapping();
    }
    return false;
}

void SwiftQSpinBox::setWrapping(bool wrap) {
    ensureWidget();
    if (spinBox) {
        spinBox->setWrapping(wrap);
    }
}

void SwiftQSpinBox::setButtonSymbols(int symbols) {
    ensureWidget();
    if (spinBox) {
        spinBox->setButtonSymbols(static_cast<QAbstractSpinBox::ButtonSymbols>(symbols));
    }
}

int SwiftQSpinBox::buttonSymbols() const {
    if (spinBox) {
        return static_cast<int>(spinBox->buttonSymbols());
    }
    return 0;
}

void SwiftQSpinBox::setAlignment(int alignment) {
    ensureWidget();
    if (spinBox) {
        spinBox->setAlignment(static_cast<Qt::Alignment>(alignment));
    }
}

int SwiftQSpinBox::alignment() const {
    if (spinBox) {
        return static_cast<int>(spinBox->alignment());
    }
    return 0;
}

bool SwiftQSpinBox::isReadOnly() const {
    if (spinBox) {
        return spinBox->isReadOnly();
    }
    return false;
}

void SwiftQSpinBox::setReadOnly(bool readOnly) {
    ensureWidget();
    if (spinBox) {
        spinBox->setReadOnly(readOnly);
    }
}

// SwiftQDoubleSpinBox implementation
void SwiftQDoubleSpinBox::ensureWidget() {
    if (!widget) {
        widget = new QDoubleSpinBox();
    }
    if (!spinBox) {
        spinBox = qobject_cast<QDoubleSpinBox*>(widget);
    }
}

SwiftQDoubleSpinBox::SwiftQDoubleSpinBox() : SwiftQWidget(), spinBox(nullptr) {
    ensureWidget();
}

SwiftQDoubleSpinBox::SwiftQDoubleSpinBox(SwiftQWidget* parent) : SwiftQWidget(parent), spinBox(nullptr) {
    ensureWidget();
}

SwiftQDoubleSpinBox::~SwiftQDoubleSpinBox() {
    // Widget is deleted by base class
}

double SwiftQDoubleSpinBox::value() const {
    if (spinBox) {
        return spinBox->value();
    }
    return 0.0;
}

void SwiftQDoubleSpinBox::setValue(double value) {
    ensureWidget();
    if (spinBox) {
        spinBox->setValue(value);
    }
}

double SwiftQDoubleSpinBox::minimum() const {
    if (spinBox) {
        return spinBox->minimum();
    }
    return 0.0;
}

void SwiftQDoubleSpinBox::setMinimum(double min) {
    ensureWidget();
    if (spinBox) {
        spinBox->setMinimum(min);
    }
}

double SwiftQDoubleSpinBox::maximum() const {
    if (spinBox) {
        return spinBox->maximum();
    }
    return 99.99;
}

void SwiftQDoubleSpinBox::setMaximum(double max) {
    ensureWidget();
    if (spinBox) {
        spinBox->setMaximum(max);
    }
}

void SwiftQDoubleSpinBox::setRange(double min, double max) {
    ensureWidget();
    if (spinBox) {
        spinBox->setRange(min, max);
    }
}

double SwiftQDoubleSpinBox::singleStep() const {
    if (spinBox) {
        return spinBox->singleStep();
    }
    return 1.0;
}

void SwiftQDoubleSpinBox::setSingleStep(double step) {
    ensureWidget();
    if (spinBox) {
        spinBox->setSingleStep(step);
    }
}

int SwiftQDoubleSpinBox::decimals() const {
    if (spinBox) {
        return spinBox->decimals();
    }
    return 2;
}

void SwiftQDoubleSpinBox::setDecimals(int prec) {
    ensureWidget();
    if (spinBox) {
        spinBox->setDecimals(prec);
    }
}

std::string SwiftQDoubleSpinBox::prefix() const {
    if (spinBox) {
        return spinBox->prefix().toStdString();
    }
    return "";
}

void SwiftQDoubleSpinBox::setPrefix(const std::string& prefix) {
    ensureWidget();
    if (spinBox) {
        spinBox->setPrefix(QString::fromStdString(prefix));
    }
}

std::string SwiftQDoubleSpinBox::suffix() const {
    if (spinBox) {
        return spinBox->suffix().toStdString();
    }
    return "";
}

void SwiftQDoubleSpinBox::setSuffix(const std::string& suffix) {
    ensureWidget();
    if (spinBox) {
        spinBox->setSuffix(QString::fromStdString(suffix));
    }
}

std::string SwiftQDoubleSpinBox::specialValueText() const {
    if (spinBox) {
        return spinBox->specialValueText().toStdString();
    }
    return "";
}

void SwiftQDoubleSpinBox::setSpecialValueText(const std::string& text) {
    ensureWidget();
    if (spinBox) {
        spinBox->setSpecialValueText(QString::fromStdString(text));
    }
}

bool SwiftQDoubleSpinBox::wrapping() const {
    if (spinBox) {
        return spinBox->wrapping();
    }
    return false;
}

void SwiftQDoubleSpinBox::setWrapping(bool wrap) {
    ensureWidget();
    if (spinBox) {
        spinBox->setWrapping(wrap);
    }
}

void SwiftQDoubleSpinBox::setButtonSymbols(int symbols) {
    ensureWidget();
    if (spinBox) {
        spinBox->setButtonSymbols(static_cast<QAbstractSpinBox::ButtonSymbols>(symbols));
    }
}

int SwiftQDoubleSpinBox::buttonSymbols() const {
    if (spinBox) {
        return static_cast<int>(spinBox->buttonSymbols());
    }
    return 0;
}

void SwiftQDoubleSpinBox::setAlignment(int alignment) {
    ensureWidget();
    if (spinBox) {
        spinBox->setAlignment(static_cast<Qt::Alignment>(alignment));
    }
}

int SwiftQDoubleSpinBox::alignment() const {
    if (spinBox) {
        return static_cast<int>(spinBox->alignment());
    }
    return 0;
}

bool SwiftQDoubleSpinBox::isReadOnly() const {
    if (spinBox) {
        return spinBox->isReadOnly();
    }
    return false;
}

void SwiftQDoubleSpinBox::setReadOnly(bool readOnly) {
    ensureWidget();
    if (spinBox) {
        spinBox->setReadOnly(readOnly);
    }
}

// Factory functions
SwiftQWidget* createWidget(SwiftQWidget* parent) {
    return new SwiftQWidget(parent);
}

SwiftQLabel* createLabel(const std::string& text, SwiftQWidget* parent) {
    return new SwiftQLabel(text, parent);
}

SwiftQPushButton* createButton(const std::string& text, SwiftQWidget* parent) {
    return new SwiftQPushButton(text, parent);
}

SwiftQLineEdit* createLineEdit(const std::string& text, SwiftQWidget* parent) {
    return new SwiftQLineEdit(text, parent);
}

SwiftQTextEdit* createTextEdit(SwiftQWidget* parent) {
    return new SwiftQTextEdit(parent);
}

SwiftQCheckBox* createCheckBox(const std::string& text, SwiftQWidget* parent) {
    return new SwiftQCheckBox(text, parent);
}

SwiftQRadioButton* createRadioButton(const std::string& text, SwiftQWidget* parent) {
    return new SwiftQRadioButton(text, parent);
}

SwiftQComboBox* createComboBox(SwiftQWidget* parent) {
    return new SwiftQComboBox(parent);
}

SwiftQGroupBox* createGroupBox(const std::string& title, SwiftQWidget* parent) {
    return new SwiftQGroupBox(title, parent);
}

SwiftQSlider* createSlider(int orientation, SwiftQWidget* parent) {
    return new SwiftQSlider(orientation, parent);
}

SwiftQProgressBar* createProgressBar(SwiftQWidget* parent) {
    return new SwiftQProgressBar(parent);
}

SwiftQScrollArea* createScrollArea(SwiftQWidget* parent) {
    return new SwiftQScrollArea(parent);
}

// Delete function for proper cleanup
void deleteQWidget(SwiftQWidget* widget) {
    if (widget) {
        delete widget;
    }
}

// SwiftQDateEdit implementation
SwiftQDateEdit::SwiftQDateEdit() : SwiftQWidget(), dateEdit(nullptr) {
    ensureWidget();
}

SwiftQDateEdit::SwiftQDateEdit(SwiftQWidget* parent) : SwiftQWidget(parent), dateEdit(nullptr) {
    ensureWidget();
}

SwiftQDateEdit::~SwiftQDateEdit() {
    // Widget cleanup handled by base class
}

void SwiftQDateEdit::ensureWidget() {
    if (!widget) {
        dateEdit = new QDateEdit(parentWidget ? parentWidget->getQWidget() : nullptr);
        widget = dateEdit;
        setupEventFilter();
    }
}

void SwiftQDateEdit::setDate(int year, int month, int day) {
    if (dateEdit) {
        dateEdit->setDate(QDate(year, month, day));
    }
}

void SwiftQDateEdit::getDate(int* year, int* month, int* day) const {
    if (dateEdit) {
        QDate date = dateEdit->date();
        if (year) *year = date.year();
        if (month) *month = date.month();
        if (day) *day = date.day();
    }
}

void SwiftQDateEdit::setMinimumDate(int year, int month, int day) {
    if (dateEdit) {
        dateEdit->setMinimumDate(QDate(year, month, day));
    }
}

void SwiftQDateEdit::getMinimumDate(int* year, int* month, int* day) const {
    if (dateEdit) {
        QDate date = dateEdit->minimumDate();
        if (year) *year = date.year();
        if (month) *month = date.month();
        if (day) *day = date.day();
    }
}

void SwiftQDateEdit::setMaximumDate(int year, int month, int day) {
    if (dateEdit) {
        dateEdit->setMaximumDate(QDate(year, month, day));
    }
}

void SwiftQDateEdit::getMaximumDate(int* year, int* month, int* day) const {
    if (dateEdit) {
        QDate date = dateEdit->maximumDate();
        if (year) *year = date.year();
        if (month) *month = date.month();
        if (day) *day = date.day();
    }
}

void SwiftQDateEdit::setDisplayFormat(const std::string& format) {
    if (dateEdit) {
        dateEdit->setDisplayFormat(QString::fromStdString(format));
    }
}

std::string SwiftQDateEdit::displayFormat() const {
    if (dateEdit) {
        return dateEdit->displayFormat().toStdString();
    }
    return "";
}

void SwiftQDateEdit::setCalendarPopup(bool enable) {
    if (dateEdit) {
        dateEdit->setCalendarPopup(enable);
    }
}

bool SwiftQDateEdit::calendarPopup() const {
    return dateEdit ? dateEdit->calendarPopup() : false;
}

bool SwiftQDateEdit::isReadOnly() const {
    return dateEdit ? dateEdit->isReadOnly() : false;
}

void SwiftQDateEdit::setReadOnly(bool readOnly) {
    if (dateEdit) {
        dateEdit->setReadOnly(readOnly);
    }
}

// SwiftQTimeEdit implementation
SwiftQTimeEdit::SwiftQTimeEdit() : SwiftQWidget(), timeEdit(nullptr) {
    ensureWidget();
}

SwiftQTimeEdit::SwiftQTimeEdit(SwiftQWidget* parent) : SwiftQWidget(parent), timeEdit(nullptr) {
    ensureWidget();
}

SwiftQTimeEdit::~SwiftQTimeEdit() {
    // Widget cleanup handled by base class
}

void SwiftQTimeEdit::ensureWidget() {
    if (!widget) {
        timeEdit = new QTimeEdit(parentWidget ? parentWidget->getQWidget() : nullptr);
        widget = timeEdit;
        setupEventFilter();
    }
}

void SwiftQTimeEdit::setTime(int hour, int minute, int second) {
    if (timeEdit) {
        timeEdit->setTime(QTime(hour, minute, second));
    }
}

void SwiftQTimeEdit::getTime(int* hour, int* minute, int* second) const {
    if (timeEdit) {
        QTime time = timeEdit->time();
        if (hour) *hour = time.hour();
        if (minute) *minute = time.minute();
        if (second) *second = time.second();
    }
}

void SwiftQTimeEdit::setMinimumTime(int hour, int minute, int second) {
    if (timeEdit) {
        timeEdit->setMinimumTime(QTime(hour, minute, second));
    }
}

void SwiftQTimeEdit::getMinimumTime(int* hour, int* minute, int* second) const {
    if (timeEdit) {
        QTime time = timeEdit->minimumTime();
        if (hour) *hour = time.hour();
        if (minute) *minute = time.minute();
        if (second) *second = time.second();
    }
}

void SwiftQTimeEdit::setMaximumTime(int hour, int minute, int second) {
    if (timeEdit) {
        timeEdit->setMaximumTime(QTime(hour, minute, second));
    }
}

void SwiftQTimeEdit::getMaximumTime(int* hour, int* minute, int* second) const {
    if (timeEdit) {
        QTime time = timeEdit->maximumTime();
        if (hour) *hour = time.hour();
        if (minute) *minute = time.minute();
        if (second) *second = time.second();
    }
}

void SwiftQTimeEdit::setDisplayFormat(const std::string& format) {
    if (timeEdit) {
        timeEdit->setDisplayFormat(QString::fromStdString(format));
    }
}

std::string SwiftQTimeEdit::displayFormat() const {
    if (timeEdit) {
        return timeEdit->displayFormat().toStdString();
    }
    return "";
}

bool SwiftQTimeEdit::isReadOnly() const {
    return timeEdit ? timeEdit->isReadOnly() : false;
}

void SwiftQTimeEdit::setReadOnly(bool readOnly) {
    if (timeEdit) {
        timeEdit->setReadOnly(readOnly);
    }
}

// SwiftQDateTimeEdit implementation
SwiftQDateTimeEdit::SwiftQDateTimeEdit() : SwiftQWidget(), dateTimeEdit(nullptr) {
    ensureWidget();
}

SwiftQDateTimeEdit::SwiftQDateTimeEdit(SwiftQWidget* parent) : SwiftQWidget(parent), dateTimeEdit(nullptr) {
    ensureWidget();
}

SwiftQDateTimeEdit::~SwiftQDateTimeEdit() {
    // Widget cleanup handled by base class
}

void SwiftQDateTimeEdit::ensureWidget() {
    if (!widget) {
        dateTimeEdit = new QDateTimeEdit(parentWidget ? parentWidget->getQWidget() : nullptr);
        widget = dateTimeEdit;
        setupEventFilter();
    }
}

void SwiftQDateTimeEdit::setDateTime(int year, int month, int day, int hour, int minute, int second) {
    if (dateTimeEdit) {
        dateTimeEdit->setDateTime(QDateTime(QDate(year, month, day), QTime(hour, minute, second)));
    }
}

void SwiftQDateTimeEdit::getDateTime(int* year, int* month, int* day, int* hour, int* minute, int* second) const {
    if (dateTimeEdit) {
        QDateTime dt = dateTimeEdit->dateTime();
        QDate date = dt.date();
        QTime time = dt.time();
        if (year) *year = date.year();
        if (month) *month = date.month();
        if (day) *day = date.day();
        if (hour) *hour = time.hour();
        if (minute) *minute = time.minute();
        if (second) *second = time.second();
    }
}

void SwiftQDateTimeEdit::setMinimumDateTime(int year, int month, int day, int hour, int minute, int second) {
    if (dateTimeEdit) {
        dateTimeEdit->setMinimumDateTime(QDateTime(QDate(year, month, day), QTime(hour, minute, second)));
    }
}

void SwiftQDateTimeEdit::getMinimumDateTime(int* year, int* month, int* day, int* hour, int* minute, int* second) const {
    if (dateTimeEdit) {
        QDateTime dt = dateTimeEdit->minimumDateTime();
        QDate date = dt.date();
        QTime time = dt.time();
        if (year) *year = date.year();
        if (month) *month = date.month();
        if (day) *day = date.day();
        if (hour) *hour = time.hour();
        if (minute) *minute = time.minute();
        if (second) *second = time.second();
    }
}

void SwiftQDateTimeEdit::setMaximumDateTime(int year, int month, int day, int hour, int minute, int second) {
    if (dateTimeEdit) {
        dateTimeEdit->setMaximumDateTime(QDateTime(QDate(year, month, day), QTime(hour, minute, second)));
    }
}

void SwiftQDateTimeEdit::getMaximumDateTime(int* year, int* month, int* day, int* hour, int* minute, int* second) const {
    if (dateTimeEdit) {
        QDateTime dt = dateTimeEdit->maximumDateTime();
        QDate date = dt.date();
        QTime time = dt.time();
        if (year) *year = date.year();
        if (month) *month = date.month();
        if (day) *day = date.day();
        if (hour) *hour = time.hour();
        if (minute) *minute = time.minute();
        if (second) *second = time.second();
    }
}

void SwiftQDateTimeEdit::setDisplayFormat(const std::string& format) {
    if (dateTimeEdit) {
        dateTimeEdit->setDisplayFormat(QString::fromStdString(format));
    }
}

std::string SwiftQDateTimeEdit::displayFormat() const {
    if (dateTimeEdit) {
        return dateTimeEdit->displayFormat().toStdString();
    }
    return "";
}

void SwiftQDateTimeEdit::setCalendarPopup(bool enable) {
    if (dateTimeEdit) {
        dateTimeEdit->setCalendarPopup(enable);
    }
}

bool SwiftQDateTimeEdit::calendarPopup() const {
    return dateTimeEdit ? dateTimeEdit->calendarPopup() : false;
}

bool SwiftQDateTimeEdit::isReadOnly() const {
    return dateTimeEdit ? dateTimeEdit->isReadOnly() : false;
}

void SwiftQDateTimeEdit::setReadOnly(bool readOnly) {
    if (dateTimeEdit) {
        dateTimeEdit->setReadOnly(readOnly);
    }
}

// SwiftQDial implementation
SwiftQDial::SwiftQDial() : SwiftQWidget(), dial(nullptr) {
    ensureWidget();
}

SwiftQDial::SwiftQDial(SwiftQWidget* parent) : SwiftQWidget(parent), dial(nullptr) {
    ensureWidget();
}

SwiftQDial::~SwiftQDial() {
    // Widget cleanup handled by base class
}

void SwiftQDial::ensureWidget() {
    if (!widget) {
        dial = new QDial(parentWidget ? parentWidget->getQWidget() : nullptr);
        widget = dial;
        setupEventFilter();
    }
}

int SwiftQDial::value() const {
    return dial ? dial->value() : 0;
}

void SwiftQDial::setValue(int value) {
    if (dial) {
        dial->setValue(value);
    }
}

int SwiftQDial::minimum() const {
    return dial ? dial->minimum() : 0;
}

void SwiftQDial::setMinimum(int min) {
    if (dial) {
        dial->setMinimum(min);
    }
}

int SwiftQDial::maximum() const {
    return dial ? dial->maximum() : 99;
}

void SwiftQDial::setMaximum(int max) {
    if (dial) {
        dial->setMaximum(max);
    }
}

void SwiftQDial::setRange(int min, int max) {
    if (dial) {
        dial->setRange(min, max);
    }
}

int SwiftQDial::singleStep() const {
    return dial ? dial->singleStep() : 1;
}

void SwiftQDial::setSingleStep(int step) {
    if (dial) {
        dial->setSingleStep(step);
    }
}

int SwiftQDial::pageStep() const {
    return dial ? dial->pageStep() : 10;
}

void SwiftQDial::setPageStep(int step) {
    if (dial) {
        dial->setPageStep(step);
    }
}

bool SwiftQDial::notchesVisible() const {
    return dial ? dial->notchesVisible() : false;
}

void SwiftQDial::setNotchesVisible(bool visible) {
    if (dial) {
        dial->setNotchesVisible(visible);
    }
}

int SwiftQDial::notchSize() const {
    return dial ? dial->notchSize() : 1;
}

void SwiftQDial::setNotchTarget(double target) {
    if (dial) {
        dial->setNotchTarget(target);
    }
}

double SwiftQDial::notchTarget() const {
    return dial ? dial->notchTarget() : 3.7;
}

bool SwiftQDial::wrapping() const {
    return dial ? dial->wrapping() : false;
}

void SwiftQDial::setWrapping(bool wrap) {
    if (dial) {
        dial->setWrapping(wrap);
    }
}

// SwiftQLCDNumber implementation
SwiftQLCDNumber::SwiftQLCDNumber() : SwiftQWidget(), lcdNumber(nullptr) {
    ensureWidget();
}

SwiftQLCDNumber::SwiftQLCDNumber(SwiftQWidget* parent) : SwiftQWidget(parent), lcdNumber(nullptr) {
    ensureWidget();
}

SwiftQLCDNumber::SwiftQLCDNumber(int numDigits, SwiftQWidget* parent) : SwiftQWidget(parent), lcdNumber(nullptr) {
    ensureWidget();
    if (lcdNumber) {
        lcdNumber->setDigitCount(numDigits);
    }
}

SwiftQLCDNumber::~SwiftQLCDNumber() {
    // Widget cleanup handled by base class
}

void SwiftQLCDNumber::ensureWidget() {
    if (!widget) {
        lcdNumber = new QLCDNumber(parentWidget ? parentWidget->getQWidget() : nullptr);
        widget = lcdNumber;
        setupEventFilter();
    }
}

void SwiftQLCDNumber::display(int value) {
    if (lcdNumber) {
        lcdNumber->display(value);
    }
}

void SwiftQLCDNumber::display(double value) {
    if (lcdNumber) {
        lcdNumber->display(value);
    }
}

void SwiftQLCDNumber::display(const std::string& text) {
    if (lcdNumber) {
        lcdNumber->display(QString::fromStdString(text));
    }
}

int SwiftQLCDNumber::intValue() const {
    return lcdNumber ? lcdNumber->intValue() : 0;
}

double SwiftQLCDNumber::value() const {
    return lcdNumber ? lcdNumber->value() : 0.0;
}

int SwiftQLCDNumber::digitCount() const {
    return lcdNumber ? lcdNumber->digitCount() : 5;
}

void SwiftQLCDNumber::setDigitCount(int count) {
    if (lcdNumber) {
        lcdNumber->setDigitCount(count);
    }
}

void SwiftQLCDNumber::setMode(int mode) {
    if (lcdNumber) {
        lcdNumber->setMode(static_cast<QLCDNumber::Mode>(mode));
    }
}

int SwiftQLCDNumber::mode() const {
    return lcdNumber ? static_cast<int>(lcdNumber->mode()) : 1;
}

void SwiftQLCDNumber::setSegmentStyle(int style) {
    if (lcdNumber) {
        lcdNumber->setSegmentStyle(static_cast<QLCDNumber::SegmentStyle>(style));
    }
}

int SwiftQLCDNumber::segmentStyle() const {
    return lcdNumber ? static_cast<int>(lcdNumber->segmentStyle()) : 1;
}

bool SwiftQLCDNumber::smallDecimalPoint() const {
    return lcdNumber ? lcdNumber->smallDecimalPoint() : false;
}

void SwiftQLCDNumber::setSmallDecimalPoint(bool small) {
    if (lcdNumber) {
        lcdNumber->setSmallDecimalPoint(small);
    }
}

// SwiftQCalendarWidget implementation
SwiftQCalendarWidget::SwiftQCalendarWidget() : SwiftQWidget(), calendarWidget(nullptr) {
    ensureWidget();
}

SwiftQCalendarWidget::SwiftQCalendarWidget(SwiftQWidget* parent) : SwiftQWidget(parent), calendarWidget(nullptr) {
    ensureWidget();
}

SwiftQCalendarWidget::~SwiftQCalendarWidget() {
    // Widget cleanup handled by base class
}

void SwiftQCalendarWidget::ensureWidget() {
    if (!widget) {
        calendarWidget = new QCalendarWidget(parentWidget ? parentWidget->getQWidget() : nullptr);
        widget = calendarWidget;
        setupEventFilter();
    }
}

void SwiftQCalendarWidget::setSelectedDate(int year, int month, int day) {
    if (calendarWidget) {
        calendarWidget->setSelectedDate(QDate(year, month, day));
    }
}

void SwiftQCalendarWidget::getSelectedDate(int* year, int* month, int* day) const {
    if (calendarWidget) {
        QDate date = calendarWidget->selectedDate();
        if (year) *year = date.year();
        if (month) *month = date.month();
        if (day) *day = date.day();
    }
}

void SwiftQCalendarWidget::setMinimumDate(int year, int month, int day) {
    if (calendarWidget) {
        calendarWidget->setMinimumDate(QDate(year, month, day));
    }
}

void SwiftQCalendarWidget::getMinimumDate(int* year, int* month, int* day) const {
    if (calendarWidget) {
        QDate date = calendarWidget->minimumDate();
        if (year) *year = date.year();
        if (month) *month = date.month();
        if (day) *day = date.day();
    }
}

void SwiftQCalendarWidget::setMaximumDate(int year, int month, int day) {
    if (calendarWidget) {
        calendarWidget->setMaximumDate(QDate(year, month, day));
    }
}

void SwiftQCalendarWidget::getMaximumDate(int* year, int* month, int* day) const {
    if (calendarWidget) {
        QDate date = calendarWidget->maximumDate();
        if (year) *year = date.year();
        if (month) *month = date.month();
        if (day) *day = date.day();
    }
}

void SwiftQCalendarWidget::setFirstDayOfWeek(int dayOfWeek) {
    if (calendarWidget) {
        calendarWidget->setFirstDayOfWeek(static_cast<Qt::DayOfWeek>(dayOfWeek));
    }
}

int SwiftQCalendarWidget::firstDayOfWeek() const {
    return calendarWidget ? static_cast<int>(calendarWidget->firstDayOfWeek()) : 1;
}

void SwiftQCalendarWidget::setGridVisible(bool show) {
    if (calendarWidget) {
        calendarWidget->setGridVisible(show);
    }
}

bool SwiftQCalendarWidget::isGridVisible() const {
    return calendarWidget ? calendarWidget->isGridVisible() : false;
}

void SwiftQCalendarWidget::setNavigationBarVisible(bool visible) {
    if (calendarWidget) {
        calendarWidget->setNavigationBarVisible(visible);
    }
}

bool SwiftQCalendarWidget::isNavigationBarVisible() const {
    return calendarWidget ? calendarWidget->isNavigationBarVisible() : true;
}

void SwiftQCalendarWidget::setSelectionMode(int mode) {
    if (calendarWidget) {
        calendarWidget->setSelectionMode(static_cast<QCalendarWidget::SelectionMode>(mode));
    }
}

int SwiftQCalendarWidget::selectionMode() const {
    return calendarWidget ? static_cast<int>(calendarWidget->selectionMode()) : 1;
}

// SwiftQMessageBox implementation
void SwiftQMessageBox::showInformation(SwiftQWidget* parent, const std::string& title, const std::string& text) {
    QWidget* parentWidget = parent ? parent->getQWidget() : nullptr;
    QMessageBox::information(parentWidget, QString::fromStdString(title), QString::fromStdString(text));
}

void SwiftQMessageBox::showWarning(SwiftQWidget* parent, const std::string& title, const std::string& text) {
    QWidget* parentWidget = parent ? parent->getQWidget() : nullptr;
    QMessageBox::warning(parentWidget, QString::fromStdString(title), QString::fromStdString(text));
}

void SwiftQMessageBox::showCritical(SwiftQWidget* parent, const std::string& title, const std::string& text) {
    QWidget* parentWidget = parent ? parent->getQWidget() : nullptr;
    QMessageBox::critical(parentWidget, QString::fromStdString(title), QString::fromStdString(text));
}

bool SwiftQMessageBox::showQuestion(SwiftQWidget* parent, const std::string& title, const std::string& text) {
    QWidget* parentWidget = parent ? parent->getQWidget() : nullptr;
    QMessageBox::StandardButton reply = QMessageBox::question(parentWidget, 
        QString::fromStdString(title), 
        QString::fromStdString(text),
        QMessageBox::Yes | QMessageBox::No);
    return reply == QMessageBox::Yes;
}

void SwiftQMessageBox::showAbout(SwiftQWidget* parent, const std::string& title, const std::string& text) {
    QWidget* parentWidget = parent ? parent->getQWidget() : nullptr;
    QMessageBox::about(parentWidget, QString::fromStdString(title), QString::fromStdString(text));
}