#pragma once

#include <memory>
#include <string>
#include <vector>
#include <functional>
#include <map>

// Forward declarations
class QApplication;
class QWidget;
class QLabel;
class QMessageBox;
class QEvent;
class QTabWidget;
class QSplitter;
class QSpinBox;
class QDoubleSpinBox;
class QDateEdit;
class QTimeEdit;
class QDateTimeEdit;
class QDial;
class QLCDNumber;
class QCalendarWidget;

// Event types enum for comprehensive event handling
enum class QtEventType {
    // Mouse events
    MousePress = 0,
    MouseRelease,
    MouseMove,
    MouseDoubleClick,
    MouseEnter,
    MouseLeave,
    
    // Keyboard events
    KeyPress,
    KeyRelease,
    
    // Focus events
    FocusIn,
    FocusOut,
    
    // Widget events
    Show,
    Hide,
    Close,
    Resize,
    Move,
    Paint,
    
    // Button specific
    Clicked,
    Pressed,
    Released,
    Toggled,
    
    // Input events
    TextChanged,
    TextEdited,
    ReturnPressed,
    
    // Selection events
    SelectionChanged,
    CurrentIndexChanged,
    CurrentTextChanged,
    Activated,
    
    // Check/Radio events
    StateChanged,
    
    // Custom
    Custom
};

// Generic event info structure
struct QtEventInfo {
    QtEventType type;
    int intValue;
    int intValue2;
    const char* stringValue;
    bool boolValue;
    void* customData;
};

// Universal event callback for Swift
struct SwiftEventCallback {
    void* context;
    void (*handler)(void* context, const QtEventInfo* info);
};

// Legacy callback types (kept for compatibility but will be migrated)
struct SwiftCallback {
    void* context;
    void (*handler)(void* context);
};

struct SwiftCallbackInt {
    void* context;
    void (*handler)(void* context, int value);
};

struct SwiftCallbackString {
    void* context;
    void (*handler)(void* context, const char* value);
};

// Simple QApplication wrapper
class SwiftQApplication {
private:
    std::vector<std::string> storedArgs;
    std::vector<char*> argv;
    int* argc;
    QApplication* app;
    static SwiftQApplication* g_appInstance;
    static int exitReturnCode;
    
    void buildArgv();
    void ensureInitialized();
    
public:
    SwiftQApplication();
    ~SwiftQApplication();
    
    int exec();
    void quit();
    void exit(int returnCode);
    void scheduleExit(int returnCode, int delayMs = 1);
    void forceQuit();
    static SwiftQApplication* instance();
    static void staticScheduleExit(int returnCode, int delayMs = 1);
    static void staticQuit();
    static void staticForceExit(int returnCode = 0);
    void processEvents();
    
    // Schedule a callback to run after a delay (in milliseconds)
    // This is essential for running tests after the event loop starts
    void scheduleCallback(int delayMs, void (*callback)(void*), void* context);
};

// Forward declaration
class SwiftEventFilter;

// Base widget wrapper with comprehensive event support
class SwiftQWidget {
    friend class SwiftEventFilter;
    
protected:
    QWidget* widget;
    SwiftQWidget* parentWidget;
    bool ownsWidget;
    SwiftEventFilter* eventFilter;  // Track our event filter for safe cleanup
    
    // Event handling map - stores callbacks by event type
    std::map<QtEventType, SwiftEventCallback> eventCallbacks;
    
    virtual void ensureWidget();
    virtual void setupEventFilter();
    virtual bool handleEvent(QEvent* event);
    
public:
    SwiftQWidget();
    explicit SwiftQWidget(SwiftQWidget* parent);
    SwiftQWidget(QWidget* existingWidget);
    virtual ~SwiftQWidget();
    
    // Custom copy constructor to handle widget pointer
    // Note: This creates a shallow copy - both objects will share the same QWidget
    SwiftQWidget(const SwiftQWidget& other);
    SwiftQWidget& operator=(const SwiftQWidget& other);
    
    // Get the underlying QWidget (for internal use)
    QWidget* getQWidget() const { return widget; }
    
    // Basic widget operations
    void show();
    void hide();
    void setEnabled(bool enabled);
    bool isVisible() const;
    
    // Geometry
    void resize(int width, int height);
    void move(int x, int y);
    void setGeometry(int x, int y, int width, int height);
    
    // Properties
    void setWindowTitle(const std::string& title);
    std::string windowTitle() const;
    void setObjectName(const std::string& name);
    std::string objectName() const;
    
    // Parent-child relationship
    void setParent(SwiftQWidget* parent);
    QWidget* getQWidget();
    std::vector<SwiftQWidget*> getChildren() const;
    
    // Window attributes
    void setAttribute(int attribute, bool on = true);
    void setMinimumSize(int width, int height);
    void setMaximumSize(int width, int height);
    void setFixedSize(int width, int height);
    void raise();
    void lower();
    void activateWindow();
    void showMaximized();
    void showMinimized();
    void showFullScreen();
    void showNormal();
    bool close();
    void update();
    int width() const;
    int height() const;
    int x() const;
    int y() const;
    void centerOnScreen();
    
    // Generic event handling
    void setEventHandler(QtEventType type, SwiftEventCallback callback);
    void removeEventHandler(QtEventType type);
    void clearEventHandlers();
};

// Label widget wrapper
class SwiftQLabel : public SwiftQWidget {
private:
    std::string labelText;
    int labelAlignment;
    
protected:
    void ensureWidget() override;
    
public:
    SwiftQLabel();
    explicit SwiftQLabel(const std::string& text);
    SwiftQLabel(const std::string& text, SwiftQWidget* parent);
    
    void setText(const std::string& text);
    std::string text() const;
    void setAlignment(int alignment);
    
    // Image support
    bool setPixmap(const std::string& imagePath);
    void setScaledContents(bool scaled);
    void clearPixmap();
};

// Button widget wrapper with comprehensive event support
class SwiftQPushButton : public SwiftQWidget {
private:
    std::string buttonText;
    
    // Store callbacks safely using std::function
    std::function<void()> clickedFunc;
    std::function<void()> pressedFunc;
    std::function<void()> releasedFunc;
    std::function<void(bool)> toggledFunc;
    
protected:
    void ensureWidget() override;
    void setupConnections();
    
public:
    SwiftQPushButton();
    explicit SwiftQPushButton(const std::string& text);
    SwiftQPushButton(const std::string& text, SwiftQWidget* parent);
    virtual ~SwiftQPushButton();
    
    void setText(const std::string& text);
    std::string text() const;
    void setDefault(bool isDefault);
    void setFlat(bool flat);
    void setCheckable(bool checkable);
    bool isChecked() const;
    void setChecked(bool checked);
    
    // Legacy event handling (for compatibility)
    void setClickHandler(SwiftCallback callback);
    
    // New comprehensive event handling
    void setClickedHandler(SwiftEventCallback callback);
    void setPressedHandler(SwiftEventCallback callback);
    void setReleasedHandler(SwiftEventCallback callback);
    void setToggledHandler(SwiftEventCallback callback);
};

// Line edit widget wrapper
class SwiftQLineEdit : public SwiftQWidget {
private:
    std::string lineText;
    std::string placeholderText;
    
protected:
    void ensureWidget() override;
    
public:
    SwiftQLineEdit();
    explicit SwiftQLineEdit(const std::string& text);
    SwiftQLineEdit(const std::string& text, SwiftQWidget* parent);
    
    void setText(const std::string& text);
    std::string text() const;
    void setPlaceholderText(const std::string& text);
    std::string getPlaceholderText() const;
    void setMaxLength(int length);
    void setReadOnly(bool readOnly);
    void clear();
    void selectAll();
};

// Text edit widget wrapper  
class SwiftQTextEdit : public SwiftQWidget {
private:
    std::string textContent;
    
protected:
    void ensureWidget() override;
    
public:
    SwiftQTextEdit();
    explicit SwiftQTextEdit(const std::string& text);
    SwiftQTextEdit(SwiftQWidget* parent);
    
    void setText(const std::string& text);
    std::string toPlainText() const;
    void setPlainText(const std::string& text);
    void setHtml(const std::string& html);
    std::string toHtml() const;
    void clear();
    void setReadOnly(bool readOnly);
    void setPlaceholderText(const std::string& text);
    std::string placeholderText() const;
};

// Check box widget wrapper
class SwiftQCheckBox : public SwiftQWidget {
private:
    std::string checkText;
    int checkState;
    
protected:
    void ensureWidget() override;
    
public:
    SwiftQCheckBox();
    explicit SwiftQCheckBox(const std::string& text);
    SwiftQCheckBox(const std::string& text, SwiftQWidget* parent);
    
    void setText(const std::string& text);
    std::string text() const;
    void setChecked(bool checked);
    bool isChecked() const;
    void setTristate(bool tristate);
    void setCheckState(int state); // 0=unchecked, 1=partially, 2=checked
    int getCheckState() const;
};

// Radio button widget wrapper
class SwiftQRadioButton : public SwiftQWidget {
private:
    std::string radioText;
    bool checked;
    
protected:
    void ensureWidget() override;
    
public:
    SwiftQRadioButton();
    explicit SwiftQRadioButton(const std::string& text);
    SwiftQRadioButton(const std::string& text, SwiftQWidget* parent);
    
    void setText(const std::string& text);
    std::string text() const;
    void setChecked(bool checked);
    bool isChecked() const;
};

// Combo box widget wrapper with safe event handling
class SwiftQComboBox : public SwiftQWidget {
private:
    std::vector<std::string> items;
    int currentIdx;
    
    // Store callbacks safely using std::function
    std::function<void(int)> indexChangedFunc;
    std::function<void(const std::string&)> textChangedFunc;
    std::function<void(int)> activatedFunc;
    std::function<void(const std::string&)> editTextChangedFunc;
    
protected:
    void ensureWidget() override;
    void setupConnections();
    
public:
    SwiftQComboBox();
    explicit SwiftQComboBox(SwiftQWidget* parent);
    virtual ~SwiftQComboBox();
    
    void addItem(const std::string& text);
    void insertItem(int index, const std::string& text);
    void removeItem(int index);
    void clear();
    int count() const;
    int currentIndex() const;
    void setCurrentIndex(int index);
    std::string currentText() const;
    std::string itemText(int index) const;
    void setEditable(bool editable);
    bool isEditable() const;
    
    // Legacy event handling (for compatibility)
    void setIndexChangedHandler(SwiftCallbackInt callback);
    void setTextChangedHandler(SwiftCallbackString callback);
    
    // New comprehensive event handling
    void setCurrentIndexChangedHandler(SwiftEventCallback callback);
    void setCurrentTextChangedHandler(SwiftEventCallback callback);
    void setActivatedHandler(SwiftEventCallback callback);
    void setEditTextChangedHandler(SwiftEventCallback callback);
};

// Group box widget wrapper
class SwiftQGroupBox : public SwiftQWidget {
private:
    std::string title;
    
protected:
    void ensureWidget() override;
    
public:
    SwiftQGroupBox();
    explicit SwiftQGroupBox(const std::string& title);
    SwiftQGroupBox(const std::string& title, SwiftQWidget* parent);
    
    void setTitle(const std::string& title);
    std::string getTitle() const;
    void setCheckable(bool checkable);
    void setChecked(bool checked);
    bool isChecked() const;
};

// Slider widget wrapper with comprehensive event support
class SwiftQSlider : public SwiftQWidget {
private:
    int sliderValue;
    int sliderMin;
    int sliderMax;
    int sliderOrientation;
    
    // Store callbacks safely using std::function
    std::function<void(int)> valueChangedFunc;
    std::function<void()> sliderPressedFunc;
    std::function<void()> sliderReleasedFunc;
    std::function<void(int)> sliderMovedFunc;
    
protected:
    void ensureWidget() override;
    void setupConnections();
    
public:
    SwiftQSlider();
    explicit SwiftQSlider(int orientation); // Qt::Horizontal=1, Qt::Vertical=2
    SwiftQSlider(int orientation, SwiftQWidget* parent);
    virtual ~SwiftQSlider();
    
    void setValue(int value);
    int value() const;
    void setMinimum(int min);
    int minimum() const;
    void setMaximum(int max);
    int maximum() const;
    void setRange(int min, int max);
    
    void setOrientation(int orientation);
    int orientation() const;
    
    void setTickPosition(int position); // QSlider::TickPosition
    void setTickInterval(int interval);
    int tickInterval() const;
    
    void setSingleStep(int step);
    int singleStep() const;
    void setPageStep(int step);
    int pageStep() const;
    
    // Event handlers
    void setValueChangedHandler(SwiftEventCallback callback);
    void setSliderPressedHandler(SwiftEventCallback callback);
    void setSliderReleasedHandler(SwiftEventCallback callback);
    void setSliderMovedHandler(SwiftEventCallback callback);
};

// Progress bar widget wrapper
class SwiftQProgressBar : public SwiftQWidget {
private:
    int progressValue;
    int progressMin;
    int progressMax;
    std::string progressFormat;
    
protected:
    void ensureWidget() override;
    
public:
    SwiftQProgressBar();
    explicit SwiftQProgressBar(SwiftQWidget* parent);
    
    void setValue(int value);
    int value() const;
    void setMinimum(int min);
    int minimum() const;
    void setMaximum(int max);
    int maximum() const;
    void setRange(int min, int max);
    
    void setTextVisible(bool visible);
    bool isTextVisible() const;
    void setFormat(const std::string& format);
    std::string format() const;
    
    void setOrientation(int orientation); // Qt::Horizontal=1, Qt::Vertical=2
    int orientation() const;
    
    void reset();
};

// Scroll area widget wrapper
class SwiftQScrollArea : public SwiftQWidget {
private:
    SwiftQWidget* contentWidget;
    
protected:
    void ensureWidget() override;
    
public:
    SwiftQScrollArea();
    explicit SwiftQScrollArea(SwiftQWidget* parent);
    virtual ~SwiftQScrollArea();
    
    void setWidget(SwiftQWidget* widget);
    SwiftQWidget* getWidget() const;
    
    void setWidgetResizable(bool resizable);
    bool widgetResizable() const;
    
    void setHorizontalScrollBarPolicy(int policy); // Qt::ScrollBarPolicy
    void setVerticalScrollBarPolicy(int policy);
    int horizontalScrollBarPolicy() const;
    int verticalScrollBarPolicy() const;
    
    void ensureVisible(int x, int y, int xmargin = 50, int ymargin = 50);
    void ensureWidgetVisible(SwiftQWidget* childWidget, int xmargin = 50, int ymargin = 50);
    
    // Scroll position access
    int horizontalScrollValue() const;
    void setHorizontalScrollValue(int value);
    int verticalScrollValue() const;
    void setVerticalScrollValue(int value);
    int horizontalScrollMaximum() const;
    int verticalScrollMaximum() const;
};

// Tab widget wrapper
class SwiftQTabWidget : public SwiftQWidget {
private:
    QTabWidget* tabWidget;
    void ensureWidget();
    
public:
    SwiftQTabWidget();
    explicit SwiftQTabWidget(SwiftQWidget* parent);
    virtual ~SwiftQTabWidget();
    
    // Tab management
    int addTab(SwiftQWidget* widget, const std::string& label);
    int insertTab(int index, SwiftQWidget* widget, const std::string& label);
    void removeTab(int index);
    void setTabText(int index, const std::string& text);
    std::string tabText(int index) const;
    void setTabEnabled(int index, bool enabled);
    bool isTabEnabled(int index) const;
    
    // Current tab
    int currentIndex() const;
    void setCurrentIndex(int index);
    SwiftQWidget* currentWidget() const;
    void setCurrentWidget(SwiftQWidget* widget);
    
    // Tab count
    int count() const;
    void clear();
    
    // Tab position
    void setTabPosition(int position); // 0=North, 1=South, 2=West, 3=East
    int tabPosition() const;
    
    // Movable tabs
    void setMovable(bool movable);
    bool isMovable() const;
    
    // Tab bar visibility
    void setTabBarAutoHide(bool hide);
    bool tabBarAutoHide() const;
};

// Splitter widget wrapper
class SwiftQSplitter : public SwiftQWidget {
private:
    QSplitter* splitter;
    void ensureWidget();
    
public:
    SwiftQSplitter(); // Default horizontal
    SwiftQSplitter(int orientation); // 1=Horizontal, 2=Vertical
    explicit SwiftQSplitter(SwiftQWidget* parent);
    SwiftQSplitter(int orientation, SwiftQWidget* parent);
    virtual ~SwiftQSplitter();
    
    // Widget management
    void addWidget(SwiftQWidget* widget);
    void insertWidget(int index, SwiftQWidget* widget);
    int count() const;
    SwiftQWidget* widget(int index) const;
    int indexOf(SwiftQWidget* widget) const;
    
    // Orientation
    void setOrientation(int orientation); // 1=Horizontal, 2=Vertical
    int orientation() const;
    
    // Sizes
    void setSizes(const std::vector<int>& sizes);
    void setSizesArray(const int* sizes, int count);
    std::vector<int> sizes() const;
    int getSizeAt(int index) const;
    int sizesCount() const;
    void setStretchFactor(int index, int stretch);
    
    // Collapsing
    void setCollapsible(int index, bool collapsible);
    bool isCollapsible(int index) const;
    void setChildrenCollapsible(bool collapsible);
    bool childrenCollapsible() const;
    
    // Handle width
    void setHandleWidth(int width);
    int handleWidth() const;
};

// Spin box widget wrapper
class SwiftQSpinBox : public SwiftQWidget {
private:
    QSpinBox* spinBox;
    void ensureWidget();
    
public:
    SwiftQSpinBox();
    explicit SwiftQSpinBox(SwiftQWidget* parent);
    virtual ~SwiftQSpinBox();
    
    // Value
    int value() const;
    void setValue(int value);
    
    // Range
    int minimum() const;
    void setMinimum(int min);
    int maximum() const;
    void setMaximum(int max);
    void setRange(int min, int max);
    
    // Step
    int singleStep() const;
    void setSingleStep(int step);
    
    // Prefix and suffix
    std::string prefix() const;
    void setPrefix(const std::string& prefix);
    std::string suffix() const;
    void setSuffix(const std::string& suffix);
    
    // Special value text
    std::string specialValueText() const;
    void setSpecialValueText(const std::string& text);
    
    // Wrapping
    bool wrapping() const;
    void setWrapping(bool wrap);
    
    // Button symbols
    void setButtonSymbols(int symbols); // 0=UpDown, 1=PlusMinus, 2=NoButtons
    int buttonSymbols() const;
    
    // Alignment
    void setAlignment(int alignment);
    int alignment() const;
    
    // Read-only
    bool isReadOnly() const;
    void setReadOnly(bool readOnly);
};

// Double spin box widget wrapper
class SwiftQDoubleSpinBox : public SwiftQWidget {
private:
    QDoubleSpinBox* spinBox;
    void ensureWidget();
    
public:
    SwiftQDoubleSpinBox();
    explicit SwiftQDoubleSpinBox(SwiftQWidget* parent);
    virtual ~SwiftQDoubleSpinBox();
    
    // Value
    double value() const;
    void setValue(double value);
    
    // Range
    double minimum() const;
    void setMinimum(double min);
    double maximum() const;
    void setMaximum(double max);
    void setRange(double min, double max);
    
    // Step
    double singleStep() const;
    void setSingleStep(double step);
    
    // Decimals
    int decimals() const;
    void setDecimals(int prec);
    
    // Prefix and suffix
    std::string prefix() const;
    void setPrefix(const std::string& prefix);
    std::string suffix() const;
    void setSuffix(const std::string& suffix);
    
    // Special value text
    std::string specialValueText() const;
    void setSpecialValueText(const std::string& text);
    
    // Wrapping
    bool wrapping() const;
    void setWrapping(bool wrap);
    
    // Button symbols
    void setButtonSymbols(int symbols); // 0=UpDown, 1=PlusMinus, 2=NoButtons
    int buttonSymbols() const;
    
    // Alignment
    void setAlignment(int alignment);
    int alignment() const;
    
    // Read-only
    bool isReadOnly() const;
    void setReadOnly(bool readOnly);
};

// Date edit widget wrapper
class SwiftQDateEdit : public SwiftQWidget {
private:
    QDateEdit* dateEdit;
    void ensureWidget();
    
public:
    SwiftQDateEdit();
    explicit SwiftQDateEdit(SwiftQWidget* parent);
    virtual ~SwiftQDateEdit();
    
    // Date value
    void setDate(int year, int month, int day);
    void getDate(int* year, int* month, int* day) const;
    
    // Range
    void setMinimumDate(int year, int month, int day);
    void getMinimumDate(int* year, int* month, int* day) const;
    void setMaximumDate(int year, int month, int day);
    void getMaximumDate(int* year, int* month, int* day) const;
    
    // Display format
    void setDisplayFormat(const std::string& format);
    std::string displayFormat() const;
    
    // Calendar popup
    void setCalendarPopup(bool enable);
    bool calendarPopup() const;
    
    // Read-only
    bool isReadOnly() const;
    void setReadOnly(bool readOnly);
};

// Time edit widget wrapper
class SwiftQTimeEdit : public SwiftQWidget {
private:
    QTimeEdit* timeEdit;
    void ensureWidget();
    
public:
    SwiftQTimeEdit();
    explicit SwiftQTimeEdit(SwiftQWidget* parent);
    virtual ~SwiftQTimeEdit();
    
    // Time value
    void setTime(int hour, int minute, int second);
    void getTime(int* hour, int* minute, int* second) const;
    
    // Range
    void setMinimumTime(int hour, int minute, int second);
    void getMinimumTime(int* hour, int* minute, int* second) const;
    void setMaximumTime(int hour, int minute, int second);
    void getMaximumTime(int* hour, int* minute, int* second) const;
    
    // Display format
    void setDisplayFormat(const std::string& format);
    std::string displayFormat() const;
    
    // Read-only
    bool isReadOnly() const;
    void setReadOnly(bool readOnly);
};

// DateTime edit widget wrapper
class SwiftQDateTimeEdit : public SwiftQWidget {
private:
    QDateTimeEdit* dateTimeEdit;
    void ensureWidget();
    
public:
    SwiftQDateTimeEdit();
    explicit SwiftQDateTimeEdit(SwiftQWidget* parent);
    virtual ~SwiftQDateTimeEdit();
    
    // DateTime value
    void setDateTime(int year, int month, int day, int hour, int minute, int second);
    void getDateTime(int* year, int* month, int* day, int* hour, int* minute, int* second) const;
    
    // Range
    void setMinimumDateTime(int year, int month, int day, int hour, int minute, int second);
    void getMinimumDateTime(int* year, int* month, int* day, int* hour, int* minute, int* second) const;
    void setMaximumDateTime(int year, int month, int day, int hour, int minute, int second);
    void getMaximumDateTime(int* year, int* month, int* day, int* hour, int* minute, int* second) const;
    
    // Display format
    void setDisplayFormat(const std::string& format);
    std::string displayFormat() const;
    
    // Calendar popup
    void setCalendarPopup(bool enable);
    bool calendarPopup() const;
    
    // Read-only
    bool isReadOnly() const;
    void setReadOnly(bool readOnly);
};

// Dial widget wrapper
class SwiftQDial : public SwiftQWidget {
private:
    QDial* dial;
    void ensureWidget();
    
public:
    SwiftQDial();
    explicit SwiftQDial(SwiftQWidget* parent);
    virtual ~SwiftQDial();
    
    // Value
    int value() const;
    void setValue(int value);
    
    // Range
    int minimum() const;
    void setMinimum(int min);
    int maximum() const;
    void setMaximum(int max);
    void setRange(int min, int max);
    
    // Step
    int singleStep() const;
    void setSingleStep(int step);
    int pageStep() const;
    void setPageStep(int step);
    
    // Notches
    bool notchesVisible() const;
    void setNotchesVisible(bool visible);
    int notchSize() const;
    void setNotchTarget(double target);
    double notchTarget() const;
    
    // Wrapping
    bool wrapping() const;
    void setWrapping(bool wrap);
};

// LCD Number widget wrapper
class SwiftQLCDNumber : public SwiftQWidget {
private:
    QLCDNumber* lcdNumber;
    void ensureWidget();
    
public:
    SwiftQLCDNumber();
    explicit SwiftQLCDNumber(SwiftQWidget* parent);
    SwiftQLCDNumber(int numDigits, SwiftQWidget* parent);
    virtual ~SwiftQLCDNumber();
    
    // Display value
    void display(int value);
    void display(double value);
    void display(const std::string& text);
    int intValue() const;
    double value() const;
    
    // Digit count
    int digitCount() const;
    void setDigitCount(int count);
    
    // Display mode
    void setMode(int mode); // 0=Hex, 1=Dec, 2=Oct, 3=Bin
    int mode() const;
    
    // Segment style
    void setSegmentStyle(int style); // 0=Outline, 1=Filled, 2=Flat
    int segmentStyle() const;
    
    // Small decimal point
    bool smallDecimalPoint() const;
    void setSmallDecimalPoint(bool small);
};

// Calendar widget wrapper
class SwiftQCalendarWidget : public SwiftQWidget {
private:
    QCalendarWidget* calendarWidget;
    void ensureWidget();
    
public:
    SwiftQCalendarWidget();
    explicit SwiftQCalendarWidget(SwiftQWidget* parent);
    virtual ~SwiftQCalendarWidget();
    
    // Selected date
    void setSelectedDate(int year, int month, int day);
    void getSelectedDate(int* year, int* month, int* day) const;
    
    // Range
    void setMinimumDate(int year, int month, int day);
    void getMinimumDate(int* year, int* month, int* day) const;
    void setMaximumDate(int year, int month, int day);
    void getMaximumDate(int* year, int* month, int* day) const;
    
    // First day of week
    void setFirstDayOfWeek(int dayOfWeek); // 1=Monday, 7=Sunday
    int firstDayOfWeek() const;
    
    // Grid visibility
    void setGridVisible(bool show);
    bool isGridVisible() const;
    
    // Navigation bar visibility
    void setNavigationBarVisible(bool visible);
    bool isNavigationBarVisible() const;
    
    // Selection mode
    void setSelectionMode(int mode); // 0=NoSelection, 1=SingleSelection
    int selectionMode() const;
};

// Message box wrapper
class SwiftQMessageBox {
public:
    enum Icon {
        NoIcon = 0,
        Information = 1,
        Warning = 2,
        Critical = 3,
        Question = 4
    };
    
    enum StandardButton {
        Ok = 0x00000400,
        Cancel = 0x00400000,
        Yes = 0x00004000,
        No = 0x00010000,
        Close = 0x00200000
    };
    
    static void showInformation(SwiftQWidget* parent, const std::string& title, const std::string& text);
    static void showWarning(SwiftQWidget* parent, const std::string& title, const std::string& text);
    static void showCritical(SwiftQWidget* parent, const std::string& title, const std::string& text);
    static bool showQuestion(SwiftQWidget* parent, const std::string& title, const std::string& text);
    static void showAbout(SwiftQWidget* parent, const std::string& title, const std::string& text);
};

// Factory functions for Swift
SwiftQWidget* createWidget(SwiftQWidget* parent = nullptr);
SwiftQLabel* createLabel(const std::string& text, SwiftQWidget* parent = nullptr);
SwiftQPushButton* createButton(const std::string& text, SwiftQWidget* parent = nullptr);
SwiftQLineEdit* createLineEdit(const std::string& text, SwiftQWidget* parent = nullptr);
SwiftQTextEdit* createTextEdit(SwiftQWidget* parent = nullptr);
SwiftQCheckBox* createCheckBox(const std::string& text, SwiftQWidget* parent = nullptr);
SwiftQRadioButton* createRadioButton(const std::string& text, SwiftQWidget* parent = nullptr);
SwiftQComboBox* createComboBox(SwiftQWidget* parent = nullptr);
SwiftQGroupBox* createGroupBox(const std::string& title, SwiftQWidget* parent = nullptr);
SwiftQSlider* createSlider(int orientation = 1, SwiftQWidget* parent = nullptr); // 1=Horizontal
SwiftQProgressBar* createProgressBar(SwiftQWidget* parent = nullptr);
SwiftQScrollArea* createScrollArea(SwiftQWidget* parent = nullptr);

// Delete function for proper cleanup (generic, works for all widget types)
void deleteQWidget(SwiftQWidget* widget);

// Include test bridge header for testing support
// This is included at the end to avoid circular dependencies
#include "QtTestBridge.h"