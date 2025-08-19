// ABOUTME: Slider provides a widget for selecting a value from a range
// ABOUTME: This wraps Qt's QSlider for use in Swift applications

import Foundation
import QtBridge

/// A slider widget for selecting values from a continuous range.
///
/// Slider provides a widget that lets users select a value by moving
/// a handle along a horizontal or vertical track.
///
/// ## Example Usage
///
/// ```swift
/// let slider = Slider()
/// slider.minimum = 0
/// slider.maximum = 100
/// slider.value = 50
/// slider.onValueChanged { value in
///     print("Slider value: \(value)")
/// }
/// ```
@MainActor
public class Slider: SafeEventWidget, QtWidget {
    /// The orientation of the slider
    public enum Orientation: Int {
        case horizontal = 1  // Qt::Horizontal
        case vertical = 2    // Qt::Vertical
    }
    
    /// The underlying Qt slider stored as a pointer
    nonisolated(unsafe) internal var qtSlider: UnsafeMutablePointer<SwiftQSlider>
    
    // Store event handlers
    private var valueChangedHandler: ((Int) -> Void)?
    private var sliderPressedHandler: (() -> Void)?
    private var sliderReleasedHandler: (() -> Void)?
    private var sliderMovedHandler: ((Int) -> Void)?
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQSlider* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtSlider).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The current value of the slider
    public var value: Int {
        get {
            return Int(qtSlider.pointee.value())
        }
        set {
            qtSlider.pointee.setValue(Int32(newValue))
        }
    }
    
    /// The minimum value of the slider
    public var minimum: Int {
        get {
            return Int(qtSlider.pointee.minimum())
        }
        set {
            qtSlider.pointee.setMinimum(Int32(newValue))
        }
    }
    
    /// The maximum value of the slider
    public var maximum: Int {
        get {
            return Int(qtSlider.pointee.maximum())
        }
        set {
            qtSlider.pointee.setMaximum(Int32(newValue))
        }
    }
    
    /// The orientation of the slider
    public var orientation: Orientation = .horizontal {
        didSet {
            qtSlider.pointee.setOrientation(Int32(orientation.rawValue))
        }
    }
    
    /// The page step size (amount to move when Page Up/Down is pressed)
    public var pageStep: Int {
        get {
            return Int(qtSlider.pointee.pageStep())
        }
        set {
            qtSlider.pointee.setPageStep(Int32(newValue))
        }
    }
    
    /// The single step size (amount to move when arrow keys are pressed)
    public var singleStep: Int {
        get {
            return Int(qtSlider.pointee.singleStep())
        }
        set {
            qtSlider.pointee.setSingleStep(Int32(newValue))
        }
    }
    
    /// Whether to show tick marks
    public var tickPosition: TickPosition = .noTicks {
        didSet {
            qtSlider.pointee.setTickPosition(Int32(tickPosition.rawValue))
        }
    }
    
    /// Tick mark positions
    public enum TickPosition: Int {
        case noTicks = 0        // QSlider::NoTicks
        case ticksAbove = 1     // QSlider::TicksAbove
        case ticksBelow = 2     // QSlider::TicksBelow
        case ticksBothSides = 3 // QSlider::TicksBothSides
    }
    
    /// The interval between tick marks
    public var tickInterval: Int {
        get {
            return Int(qtSlider.pointee.tickInterval())
        }
        set {
            qtSlider.pointee.setTickInterval(Int32(newValue))
        }
    }
    
    /// Creates a new slider with the specified orientation
    ///
    /// - Parameters:
    ///   - orientation: The orientation of the slider (horizontal or vertical)
    ///   - parent: The parent widget. If nil, creates a top-level slider.
    public init(orientation: Orientation = .horizontal, parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtSlider = UnsafeMutablePointer<SwiftQSlider>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtSlider.initialize(to: SwiftQSlider(Int32(orientation.rawValue), parent.getBridgeWidget()))
        } else {
            qtSlider.initialize(to: SwiftQSlider(Int32(orientation.rawValue)))
        }
        
        self.orientation = orientation
        super.init()
    }
    
    deinit {
        // CallbackManager automatically handles callback cleanup via SafeEventWidget
        // Clean up the C++ object
        let ptr = qtSlider
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    /// Sets a handler for value change events
    /// - Parameter handler: Closure called when the slider value changes
    public func onValueChanged(_ handler: @escaping (Int) -> Void) {
        valueChangedHandler = handler
        
        // Store the handler in CallbackManager to keep it alive
        CallbackManager.shared.store(handler, for: self)
        
        // Create the callback on the heap using CallbackHelper
        let eventCallback = CallbackHelper.createEventCallback(context: self) { [weak self] info in
            guard let self = self else { return }
            self.valueChangedHandler?(Int(info.intValue))
        }
        
        // Pass the dereferenced callback struct to the C++ side
        qtSlider.pointee.setValueChangedHandler(eventCallback.pointee)
    }
    
    /// Sets a handler for when the user starts dragging the slider
    /// - Parameter handler: Closure called when slider dragging starts
    public func onSliderPressed(_ handler: @escaping () -> Void) {
        sliderPressedHandler = handler
        
        // Store the handler in CallbackManager to keep it alive
        CallbackManager.shared.store(handler, for: self)
        
        // Create the callback on the heap using CallbackHelper
        let eventCallback = CallbackHelper.createEventCallback(context: self) { [weak self] _ in
            guard let self = self else { return }
            self.sliderPressedHandler?()
        }
        
        // Pass the dereferenced callback struct to the C++ side
        qtSlider.pointee.setSliderPressedHandler(eventCallback.pointee)
    }
    
    /// Sets a handler for when the user stops dragging the slider
    /// - Parameter handler: Closure called when slider dragging stops
    public func onSliderReleased(_ handler: @escaping () -> Void) {
        sliderReleasedHandler = handler
        
        // Store the handler in CallbackManager to keep it alive
        CallbackManager.shared.store(handler, for: self)
        
        // Create the callback on the heap using CallbackHelper
        let eventCallback = CallbackHelper.createEventCallback(context: self) { [weak self] _ in
            guard let self = self else { return }
            self.sliderReleasedHandler?()
        }
        
        // Pass the dereferenced callback struct to the C++ side
        qtSlider.pointee.setSliderReleasedHandler(eventCallback.pointee)
    }
    
    /// Sets a handler for when the slider is moved (during dragging)
    /// - Parameter handler: Closure called while the slider is being dragged
    public func onSliderMoved(_ handler: @escaping (Int) -> Void) {
        sliderMovedHandler = handler
        
        // Store the handler in CallbackManager to keep it alive
        CallbackManager.shared.store(handler, for: self)
        
        // Create the callback on the heap using CallbackHelper
        let eventCallback = CallbackHelper.createEventCallback(context: self) { [weak self] info in
            guard let self = self else { return }
            self.sliderMovedHandler?(Int(info.intValue))
        }
        
        // Pass the dereferenced callback struct to the C++ side
        qtSlider.pointee.setSliderMovedHandler(eventCallback.pointee)
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtSlider.pointee.show()
    }
    
    public func hide() {
        qtSlider.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtSlider.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtSlider.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtSlider.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtSlider.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtSlider.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtSlider.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtSlider.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtSlider.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtSlider.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtSlider.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtSlider.pointee.setParent(nil)
        }
    }
}