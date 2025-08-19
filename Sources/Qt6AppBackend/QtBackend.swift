// ABOUTME: QtBackend provides the SwiftCrossUI AppBackend implementation using Qt6
// ABOUTME: This bridges QwiftUI's Qt6 widgets to SwiftCrossUI's declarative API

import Foundation
@preconcurrency import SwiftCrossUI
import QwiftUI

/// Qt6 backend implementation for SwiftCrossUI
@MainActor
public final class QtBackend: AppBackend, @unchecked Sendable {
    // MARK: - Associated Types
    public typealias Window = QtWindow
    public typealias Widget = QtBackendWidget
    public typealias Menu = QtMenu
    public typealias Alert = QtAlert
    public typealias Path = QtPath
    
    // MARK: - Properties
    
    /// The default height of a table row excluding cell padding
    public let defaultTableRowContentHeight = 24
    
    /// The default vertical padding to apply to table cells
    public let defaultTableCellVerticalPadding = 4
    
    /// The default amount of padding used when a user uses the padding modifier
    public let defaultPaddingAmount = 8
    
    /// Gets the layout width of a backend's scroll bars
    public let scrollBarWidth = 15
    
    /// If true, a toggle in the switch style grows to fill its parent container
    public let requiresToggleSwitchSpacer = false
    
    /// If true, all images in a window will get updated when the window's scale factor changes
    public let requiresImageUpdateOnScaleFactorChange = false
    
    /// How the backend handles rendering of menu buttons
    public let menuImplementationStyle = MenuImplementationStyle.menuButton
    
    /// The class of device that the backend is currently running on
    public let deviceClass = DeviceClass.desktop
    
    /// Whether the backend can reveal files in the system file manager or not
    public let canRevealFiles = true
    
    // MARK: - Private Properties
    
    private let app: Application
    private var mainLoopCallback: (@MainActor () -> Void)?
    private var windows: [QtWindow] = []
    
    // MARK: - Initialization
    
    public init() {
        // Create the Qt application immediately - it must exist before any widgets
        app = Application()
    }
    
    // MARK: - Main Loop
    
    /// Runs the backend's main run loop
    public func runMainLoop(_ callback: @escaping @MainActor () -> Void) {
        // Store the callback
        mainLoopCallback = callback
        
        print("QtBackend: Starting main loop...")
        
        // Run the callback to create windows and setup the UI
        print("QtBackend: About to call callback...")
        callback()
        print("QtBackend: Callback completed successfully")
        
        print("QtBackend: \(windows.count) windows created after callback")
        
        // Ensure at least one window is visible
        for (index, window) in windows.enumerated() {
            print("QtBackend: Window \(index) visible: \(window.widget.isVisible)")
            if !window.widget.isVisible {
                print("QtBackend: Showing window \(index)...")
                window.widget.show()
            }
        }
        
        // Check if we have any windows to show
        if windows.isEmpty {
            print("QtBackend: WARNING - No windows created!")
        }
        
        // Start the Qt event loop
        print("QtBackend: Starting Qt event loop...")
        let exitCode = app.exec()
        print("QtBackend: Qt event loop exited with code: \(exitCode)")
    }
    
    // MARK: - Window Management
    
    /// Creates a new window
    public func createWindow(withDefaultSize defaultSize: SIMD2<Int>?) -> Window {
        print("QtBackend: createWindow called with defaultSize: \(String(describing: defaultSize))")
        let window = QtWindow(defaultSize: defaultSize)
        windows.append(window)
        return window
    }
    
    /// Sets the title of a window
    public func setTitle(ofWindow window: Window, to title: String) {
        window.setTitle(title)
    }
    
    /// Sets the resizability of a window
    public func setResizability(ofWindow window: Window, to resizable: Bool) {
        window.setResizable(resizable)
    }
    
    /// Sets the root child of a window
    public func setChild(ofWindow window: Window, to child: Widget) {
        window.setChild(child)
    }
    
    /// Gets the size of the given window in pixels
    public func size(ofWindow window: Window) -> SIMD2<Int> {
        window.size
    }
    
    /// Check whether a window is programmatically resizable
    public func isWindowProgrammaticallyResizable(_ window: Window) -> Bool {
        window.isResizable
    }
    
    /// Sets the size of the given window in pixels
    public func setSize(ofWindow window: Window, to newSize: SIMD2<Int>) {
        window.setSize(newSize)
    }
    
    /// Sets the minimum width and height of the window
    public func setMinimumSize(ofWindow window: Window, to minimumSize: SIMD2<Int>) {
        window.setMinimumSize(minimumSize)
    }
    
    /// Sets the handler for the window's resizing events
    public func setResizeHandler(
        ofWindow window: Window,
        to action: @escaping  (_ newSize: SIMD2<Int>) -> Void
    ) {
        window.setResizeHandler(action)
    }
    
    /// Shows a window after it has been created or updated
    public func show(window: Window) {
        print("QtBackend: show(window:) called - showing the main window")
        window.show()
        print("QtBackend: window.show() completed - window should be visible")
    }
    
    /// Brings a window to the front if possible
    public func activate(window: Window) {
        window.activate()
    }
    
    // MARK: - Environment
    
    /// Computes the root environment for an app
    public func computeRootEnvironment(defaultEnvironment: EnvironmentValues) -> EnvironmentValues {
        // For now, just return the default environment
        // TODO: Check system theme, scale factor, etc.
        return defaultEnvironment
    }
    
    /// Sets the handler to be notified when the root environment may have to get recomputed
    public func setRootEnvironmentChangeHandler(to action: @escaping  () -> Void) {
        // TODO: Monitor system theme changes
    }
    
    /// Computes a window's environment based off the root environment
    public func computeWindowEnvironment(
        window: Window,
        rootEnvironment: EnvironmentValues
    ) -> EnvironmentValues {
        // TODO: Add window-specific environment values like scale factor
        return rootEnvironment
    }
    
    /// Sets the handler to be notified when the window's contribution to the environment may have to be recomputed
    public func setWindowEnvironmentChangeHandler(
        of window: Window,
        to action: @escaping  () -> Void
    ) {
        window.setEnvironmentChangeHandler(action)
    }
    
    // MARK: - Thread Management
    
    /// Runs an action in the app's main thread if required to perform UI updates
    nonisolated public func runInMainThread(action: @escaping @MainActor () -> Void) {
        Task { @MainActor in
            action()
        }
    }
    
    // MARK: - Widget Management
    
    /// Shows a widget after it has been created or updated
    public func show(widget: Widget) {
        // Only show widgets that don't have a parent (i.e., top-level widgets)
        // Child widgets will be shown automatically when their parent is shown
        // This prevents child widgets from appearing as separate windows
        print("QtBackend: show(widget:) called - skipping (child widgets show automatically)")
    }
    
    /// Gets the natural size of a given widget
    public func naturalSize(of widget: Widget) -> SIMD2<Int> {
        widget.naturalSize()
    }
    
    /// Sets the size of a widget
    public func setSize(of widget: Widget, to size: SIMD2<Int>) {
        widget.setSize(size)
    }
    
    // MARK: - Container Management
    
    /// Creates a container in which children can be layed out by SwiftCrossUI using exact pixel positions
    public func createContainer() -> Widget {
        QtBackendWidget(QwiftUI.Container())
    }
    
    /// Removes all children of the given container
    public func removeAllChildren(of container: Widget) {
        container.removeAllChildren()
    }
    
    /// Adds a child to a given container at an exact position
    public func addChild(_ child: Widget, to container: Widget) {
        container.addChild(child)
    }
    
    /// Sets the position of the specified child in a container
    public func setPosition(ofChildAt index: Int, in container: Widget, to position: SIMD2<Int>) {
        container.setChildPosition(at: index, to: position)
    }
    
    /// Removes a child widget from a container
    public func removeChild(_ child: Widget, from container: Widget) {
        container.removeChild(child)
    }
    
    // MARK: - Text Management
    
    /// Creates a non-editable text view
    public func createTextView() -> Widget {
        QtBackendWidget(QwiftUI.Label())
    }
    
    /// Updates the content and wrapping mode of a non-editable text view
    public func updateTextView(_ textView: Widget, content: String, environment: EnvironmentValues) {
        if let label = textView.qtWidget as? QwiftUI.Label {
            label.text = content
            // TODO: Apply font from environment
        }
    }
    
    // MARK: - Input Widget Management
    
    /// Creates a text field for single-line text input
    public func createTextField() -> Widget {
        QtBackendWidget(QwiftUI.LineEdit())
    }
    
    /// Updates a text field with content and configuration
    public func updateTextField(
        _ textField: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping  (String) -> Void
    ) {
        if let lineEdit = textField.qtWidget as? QwiftUI.LineEdit {
            lineEdit.placeholderText = placeholder
            lineEdit.onTextChanged { text in
                onChange(text)
            }
        }
    }
    
    /// Creates a checkbox widget
    public func createCheckbox() -> Widget {
        QtBackendWidget(QwiftUI.CheckBox())
    }
    
    /// Updates a checkbox with label and state
    public func updateCheckbox(
        _ checkbox: Widget,
        label: String,
        environment: EnvironmentValues,
        onChange: @escaping  (Bool) -> Void
    ) {
        if let checkBox = checkbox.qtWidget as? QwiftUI.CheckBox {
            checkBox.text = label
            checkBox.onStateChanged { _ in
                onChange(checkBox.isChecked)
            }
        }
    }
    
    /// Sets the state of a checkbox
    public func setState(ofCheckbox checkbox: Widget, to state: Bool) {
        if let checkBox = checkbox.qtWidget as? QwiftUI.CheckBox {
            checkBox.isChecked = state
        }
    }
    
    /// Creates a slider widget
    public func createSlider() -> Widget {
        QtBackendWidget(QwiftUI.Slider())
    }
    
    /// Updates a slider with configuration
    public func updateSlider(
        _ slider: Widget,
        minimum: Double,
        maximum: Double,
        decimalPlaces: Int,
        environment: EnvironmentValues,
        onChange: @escaping  (Double) -> Void
    ) {
        if let sliderWidget = slider.qtWidget as? QwiftUI.Slider {
            sliderWidget.minimum = Int(minimum)
            sliderWidget.maximum = Int(maximum)
            sliderWidget.onValueChanged { value in
                onChange(Double(value))
            }
        }
    }
    
    /// Creates a progress bar widget
    public func createProgressBar() -> Widget {
        QtBackendWidget(QwiftUI.ProgressBar())
    }
    
    /// Updates a progress bar with value and range
    public func updateProgressBar(
        _ progressBar: Widget,
        minimum: Double,
        maximum: Double,
        value: Double,
        environment: EnvironmentValues
    ) {
        if let progress = progressBar.qtWidget as? QwiftUI.ProgressBar {
            progress.minimum = Int(minimum)
            progress.maximum = Int(maximum)
            progress.value = Int(value)
        }
    }
    
    /// Creates a scroll container for a child widget
    public func createScrollContainer(for child: Widget) -> Widget {
        let scrollView = QwiftUI.ScrollView()
        scrollView.setContent(child.qtWidget)
        return QtBackendWidget(scrollView)
    }
    
    /// Updates scroll container settings
    public func updateScrollContainer(
        _ scrollView: Widget,
        environment: EnvironmentValues
    ) {
        if scrollView.qtWidget is QwiftUI.ScrollView {
            // Apply any environment-based settings
        }
    }
    
    /// Creates an image view widget
    public func createImageView() -> Widget {
        QtBackendWidget(QwiftUI.ImageView())
    }
    
    /// Updates an image view with image data
    public func updateImageView(
        _ imageView: Widget,
        environment: EnvironmentValues,
        onTap: (() -> Void)?
    ) {
        // TODO: Implement image loading from environment
        if imageView.qtWidget is QwiftUI.ImageView {
            // Configure image settings
        }
    }
    
    // MARK: - Widget State Management
    
    /// Sets the visibility of a widget
    public func setIsHidden(of widget: Widget, to hidden: Bool) {
        if hidden {
            widget.qtWidget.hide()
        } else {
            widget.qtWidget.show()
        }
    }
    
    /// Sets whether a widget is enabled
    public func setIsEnabled(of widget: Widget, to enabled: Bool) {
        widget.qtWidget.setEnabled(enabled)
    }
    
    /// Sets the background color of a widget
    public func setBackgroundColor(of widget: Widget, to color: Color) {
        // TODO: Implement Qt stylesheet or palette color setting
    }
    
    /// Sets the foreground/text color of a widget
    public func setForegroundColor(of widget: Widget, to color: Color) {
        // TODO: Implement Qt stylesheet or palette color setting
    }
    
    // MARK: - Button Management
    
    /// Creates a labelled button with an action triggered on click
    public func createButton() -> Widget {
        QtBackendWidget(QwiftUI.Button())
    }
    
    /// Sets a button's label and action
    public func updateButton(
        _ button: Widget,
        label: String,
        environment: EnvironmentValues,
        action: @escaping  () -> Void
    ) {
        if let qtButton = button.qtWidget as? QwiftUI.Button {
            qtButton.text = label
            qtButton.onClicked(action)
        }
    }
    
    /// Updates a button with a child widget instead of text
    public func updateButton(
        _ button: Widget,
        body: Widget,
        environment: EnvironmentValues,
        action: @escaping  () -> Void
    ) {
        // TODO: Qt buttons don't directly support child widgets
        // Would need to create a custom button with layout
        if let qtButton = button.qtWidget as? QwiftUI.Button {
            qtButton.onClicked(action)
        }
    }
    
    // MARK: - Picker Management
    
    /// Creates a picker/dropdown widget
    public func createPicker() -> Widget {
        QtBackendWidget(QwiftUI.ComboBox())
    }
    
    /// Updates a picker with options
    public func updatePicker(
        _ picker: Widget,
        options: [String],
        environment: EnvironmentValues,
        onChange: @escaping  (Int?) -> Void
    ) {
        if let combo = picker.qtWidget as? QwiftUI.ComboBox {
            combo.clear()
            for option in options {
                combo.addItem(option)
            }
            combo.onCurrentIndexChanged { index in
                onChange(index >= 0 ? index : nil)
            }
        }
    }
    
    // MARK: - Text Editor Management
    
    /// Creates a multi-line text editor
    public func createTextEditor() -> Widget {
        QtBackendWidget(QwiftUI.TextEdit())
    }
    
    /// Updates a text editor with content and configuration
    public func updateTextEditor(
        _ textEditor: Widget,
        placeholder: String,
        environment: EnvironmentValues,
        onChange: @escaping  (String) -> Void
    ) {
        if let editor = textEditor.qtWidget as? QwiftUI.TextEdit {
            // QTextEdit doesn't have native placeholder support
            // Would need custom implementation
            editor.onTextChanged { text in
                onChange(text)
            }
        }
    }
    
    // MARK: - Colorable Rectangle (for backgrounds/borders)
    
    /// Creates a colorable rectangle widget
    public func createColorableRectangle() -> Widget {
        // Use a plain widget that can be styled
        QtBackendWidget(QwiftUI.Widget())
    }
    
    // MARK: - Progress Spinner
    
    /// Creates a progress spinner (indeterminate progress)
    public func createProgressSpinner() -> Widget {
        let progressBar = QwiftUI.ProgressBar()
        progressBar.isBusy = true
        return QtBackendWidget(progressBar)
    }
    
    // MARK: - Tab View
    
    /// Creates a tab view widget
    public func createTabView() -> Widget {
        QtBackendWidget(QwiftUI.TabWidget())
    }
    
    /// Updates a tab view with tabs
    public func updateTabView(
        _ tabView: Widget,
        tabs: [(label: String, body: Widget)],
        environment: EnvironmentValues,
        onChange: @escaping (Int) -> Void
    ) {
        if let tabWidget = tabView.qtWidget as? QwiftUI.TabWidget {
            tabWidget.clear()
            for (label, bodyWidget) in tabs {
                tabWidget.addTab(bodyWidget.qtWidget, label: label)
            }
            // TODO: Connect to currentChanged signal
        }
    }
    
    // MARK: - Split View
    
    /// Creates a split view widget
    public func createSplitView() -> Widget {
        QtBackendWidget(QwiftUI.Splitter())
    }
    
    /// Updates a split view with children
    public func updateSplitView(
        _ splitView: Widget,
        orientation: SwiftCrossUI.Orientation,
        children: [Widget],
        environment: EnvironmentValues
    ) {
        if let splitter = splitView.qtWidget as? QwiftUI.Splitter {
            splitter.orientation = orientation == .vertical ? .vertical : .horizontal
            // Clear existing children (would need tracking)
            for child in children {
                splitter.addWidget(child.qtWidget)
            }
        }
    }
    
    // MARK: - Spin Box
    
    /// Creates a spin box widget for integer input
    public func createSpinBox() -> Widget {
        QtBackendWidget(QwiftUI.SpinBox())
    }
    
    /// Updates a spin box with configuration
    public func updateSpinBox(
        _ spinBox: Widget,
        value: Int,
        minimum: Int,
        maximum: Int,
        step: Int,
        environment: EnvironmentValues,
        onChange: @escaping (Int) -> Void
    ) {
        if let spin = spinBox.qtWidget as? QwiftUI.SpinBox {
            spin.value = value
            spin.minimum = minimum
            spin.maximum = maximum
            spin.singleStep = step
            spin.onValueChanged { newValue in
                onChange(newValue)
            }
        }
    }
    
    // MARK: - Group Box
    
    /// Creates a group box widget
    public func createGroupBox() -> Widget {
        QtBackendWidget(QwiftUI.GroupBox())
    }
    
    /// Updates a group box with title and content
    public func updateGroupBox(
        _ groupBox: Widget,
        title: String,
        child: Widget?,
        environment: EnvironmentValues
    ) {
        if let group = groupBox.qtWidget as? QwiftUI.GroupBox {
            group.title = title
            if let child = child {
                // GroupBox can contain a single child widget
                // Would need to set layout and add child
            }
        }
    }
    
    // MARK: - Menu and Alert Support
    
    /// Shows an alert dialog
    public func showAlert(
        _ alert: Alert,
        on window: Window,
        completion: @escaping (Int) -> Void
    ) {
        // Use QwiftUI.MessageBox for alerts
        let parent = window.widget
        
        switch alert.style {
        case .information:
            QwiftUI.MessageBox.showInformation(
                title: alert.title,
                text: alert.message,
                parent: parent
            )
            completion(0)
        case .warning:
            QwiftUI.MessageBox.showWarning(
                title: alert.title,
                text: alert.message,
                parent: parent
            )
            completion(0)
        case .critical:
            QwiftUI.MessageBox.showCritical(
                title: alert.title,
                text: alert.message,
                parent: parent
            )
            completion(0)
        case .question:
            let result = QwiftUI.MessageBox.showQuestion(
                title: alert.title,
                text: alert.message,
                parent: parent
            )
            completion(result ? 1 : 0)
        }
    }
    
    /// Opens a file dialog
    public func openFileDialog(
        on window: Window,
        mode: FileDialogMode,
        completion: @escaping (String?) -> Void
    ) {
        // TODO: Implement using QFileDialog
        completion(nil)
    }
    
    /// Opens an input dialog
    public func openInputDialog(
        on window: Window,
        title: String,
        message: String,
        defaultValue: String,
        completion: @escaping (String?) -> Void
    ) {
        // TODO: Implement using QInputDialog
        completion(nil)
    }
    
    /// Sets the application's global menu
    public func setApplicationMenu(_ submenus: [SwiftCrossUI.ResolvedMenu.Submenu]) {
        // TODO: Implement using QMenuBar, QMenu, and QAction
        // For now, just log that it was called
        print("QtBackend: setApplicationMenu with \(submenus.count) submenus (not yet implemented)")
    }
    
    /// Gets the size that text would have if laid out
    public func size(
        of text: String,
        whenDisplayedIn widget: Widget,
        proposedFrame: SIMD2<Int>?,
        environment: SwiftCrossUI.EnvironmentValues
    ) -> SIMD2<Int> {
        // For now, return a reasonable default size based on text length
        // TODO: Implement proper text measurement using QFontMetrics
        let width = proposedFrame?.x ?? (text.count * 8)
        let height = 20 // Default single line height
        return SIMD2(x: width, y: height)
    }
    
    /// Sets the handler for incoming URLs
    public func setIncomingURLHandler(to action: @escaping (URL) -> Void) {
        // TODO: Implement URL handling
        print("QtBackend: setIncomingURLHandler called")
    }
}

// MARK: - Type Definitions

/// Qt-specific window type for SwiftCrossUI
@MainActor
public final class QtWindow {
    internal let widget: QwiftUI.Widget
    private var resizeHandler: ( (SIMD2<Int>) -> Void)?
    private var environmentChangeHandler: ( () -> Void)?
    private(set) var isResizable: Bool = true
    
    var size: SIMD2<Int> {
        SIMD2(x: widget.width, y: widget.height)
    }
    
    init(defaultSize: SIMD2<Int>?) {
        widget = QwiftUI.Widget()
        widget.setAttribute(.window)
        
        if let size = defaultSize {
            widget.resize(width: size.x, height: size.y)
        }
    }
    
    func setTitle(_ title: String) {
        widget.setWindowTitle(title)
    }
    
    func setResizable(_ resizable: Bool) {
        isResizable = resizable
        // TODO: Implement window resizability control in Qt
    }
    
    func setChild(_ child: QtBackendWidget) {
        // Clear existing children
        for existingChild in widget.children {
            existingChild.setParent(nil)
        }
        
        // Set the child directly as a child of the window
        // SwiftCrossUI already provides a container if needed
        child.qtWidget.setParent(widget)
        child.qtWidget.resize(width: widget.width, height: widget.height)
        
        // Setup resize handler to resize the child
        widget.onResize { [weak self] width, height in
            child.qtWidget.resize(width: width, height: height)
            self?.resizeHandler?(SIMD2(x: width, y: height))
        }
    }
    
    func setSize(_ size: SIMD2<Int>) {
        widget.resize(width: size.x, height: size.y)
    }
    
    func setMinimumSize(_ size: SIMD2<Int>) {
        widget.setMinimumSize(width: size.x, height: size.y)
    }
    
    func setResizeHandler(_ handler: @escaping  (SIMD2<Int>) -> Void) {
        resizeHandler = handler
        // TODO: Connect to Qt resize events
    }
    
    func setEnvironmentChangeHandler(_ handler: @escaping  () -> Void) {
        environmentChangeHandler = handler
    }
    
    func show() {
        widget.show()
    }
    
    func activate() {
        widget.raise()
        widget.activateWindow()
    }
}

/// Qt-specific widget wrapper for SwiftCrossUI
@MainActor
public final class QtBackendWidget {
    internal let qtWidget: any QtWidget
    
    init(_ widget: any QtWidget) {
        self.qtWidget = widget
    }
    
    func show() {
        // Don't show individual widgets - they should only be shown
        // as part of their parent window to avoid multiple windows
        // qtWidget.show()
    }
    
    func naturalSize() -> SIMD2<Int> {
        // TODO: Implement natural size calculation
        SIMD2(x: 100, y: 30)
    }
    
    func setSize(_ size: SIMD2<Int>) {
        qtWidget.resize(width: size.x, height: size.y)
    }
    
    func removeAllChildren() {
        if let container = qtWidget as? QwiftUI.Container {
            container.removeAllChildren()
        } else if let widget = qtWidget as? QwiftUI.Widget {
            for child in widget.children {
                child.setParent(nil)
            }
        }
    }
    
    func addChild(_ child: QtBackendWidget) {
        if let container = qtWidget as? QwiftUI.Container {
            container.addChild(child.qtWidget)
        } else {
            child.qtWidget.setParent(qtWidget)
        }
    }
    
    func setChildPosition(at index: Int, to position: SIMD2<Int>) {
        if let container = qtWidget as? QwiftUI.Container {
            container.setChildPosition(at: index, x: position.x, y: position.y)
        } else if let widget = qtWidget as? QwiftUI.Widget {
            let children = widget.children
            if index < children.count {
                children[index].move(x: position.x, y: position.y)
            }
        }
    }
    
    func removeChild(_ child: QtBackendWidget) {
        if let container = qtWidget as? QwiftUI.Container {
            container.removeChild(child.qtWidget)
        } else {
            child.qtWidget.setParent(nil)
        }
    }
}

/// Qt-specific menu type for SwiftCrossUI
public struct QtMenu {
    // TODO: Implement Qt menu wrapper
}

/// Qt-specific alert type for SwiftCrossUI
public struct QtAlert {
    public enum Style {
        case information
        case warning
        case critical
        case question
    }
    
    public let title: String
    public let message: String
    public let style: Style
    public let buttons: [String]
    
    public init(title: String, message: String, style: Style = .information, buttons: [String] = ["OK"]) {
        self.title = title
        self.message = message
        self.style = style
        self.buttons = buttons
    }
}

/// File dialog mode enumeration
public enum FileDialogMode {
    case open
    case save
    case selectFolder
    case openMultiple
}

/// Qt-specific path type for SwiftCrossUI
public struct QtPath {
    public let path: String
    
    public init(_ path: String) {
        self.path = path
    }
}