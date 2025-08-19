// ABOUTME: TimeEdit provides a time input field for editing time values
// ABOUTME: This wraps Qt's QTimeEdit for use in Swift applications

import Foundation
import QtBridge

/// A widget for editing time values.
///
/// TimeEdit provides a convenient way for users to input time values,
/// with format validation and range constraints.
///
/// ## Example Usage
///
/// ```swift
/// let timeEdit = TimeEdit()
/// timeEdit.time = Date()
/// timeEdit.displayFormat = "HH:mm:ss"
/// timeEdit.minimumTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
/// timeEdit.maximumTime = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!
/// timeEdit.onTimeChanged { time in
///     print("Time changed to: \(time)")
/// }
/// ```
@MainActor
public class TimeEdit: SafeEventWidget, QtWidget {
    /// The underlying Qt time edit stored as a pointer
    nonisolated(unsafe) internal var qtTimeEdit: UnsafeMutablePointer<SwiftQTimeEdit>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQTimeEdit* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtTimeEdit).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The current time value (only time components are used)
    public var time: Date {
        get {
            var hour: Int32 = 0
            var minute: Int32 = 0
            var second: Int32 = 0
            qtTimeEdit.pointee.getTime(&hour, &minute, &second)
            
            var components = DateComponents()
            components.hour = Int(hour)
            components.minute = Int(minute)
            components.second = Int(second)
            
            // Create a date with today's date but the specified time
            let calendar = Calendar.current
            let today = Date()
            let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
            components.year = todayComponents.year
            components.month = todayComponents.month
            components.day = todayComponents.day
            
            return calendar.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute, .second], from: newValue)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            let second = components.second ?? 0
            qtTimeEdit.pointee.setTime(Int32(hour), Int32(minute), Int32(second))
        }
    }
    
    /// The minimum allowed time (only time components are used)
    public var minimumTime: Date {
        get {
            var hour: Int32 = 0
            var minute: Int32 = 0
            var second: Int32 = 0
            qtTimeEdit.pointee.getMinimumTime(&hour, &minute, &second)
            
            var components = DateComponents()
            components.hour = Int(hour)
            components.minute = Int(minute)
            components.second = Int(second)
            
            // Create a date with today's date but the specified time
            let calendar = Calendar.current
            let today = Date()
            let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
            components.year = todayComponents.year
            components.month = todayComponents.month
            components.day = todayComponents.day
            
            return calendar.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute, .second], from: newValue)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            let second = components.second ?? 0
            qtTimeEdit.pointee.setMinimumTime(Int32(hour), Int32(minute), Int32(second))
        }
    }
    
    /// The maximum allowed time (only time components are used)
    public var maximumTime: Date {
        get {
            var hour: Int32 = 0
            var minute: Int32 = 0
            var second: Int32 = 0
            qtTimeEdit.pointee.getMaximumTime(&hour, &minute, &second)
            
            var components = DateComponents()
            components.hour = Int(hour)
            components.minute = Int(minute)
            components.second = Int(second)
            
            // Create a date with today's date but the specified time
            let calendar = Calendar.current
            let today = Date()
            let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
            components.year = todayComponents.year
            components.month = todayComponents.month
            components.day = todayComponents.day
            
            return calendar.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute, .second], from: newValue)
            let hour = components.hour ?? 0
            let minute = components.minute ?? 0
            let second = components.second ?? 0
            qtTimeEdit.pointee.setMaximumTime(Int32(hour), Int32(minute), Int32(second))
        }
    }
    
    /// The display format for the time
    /// Uses Qt time format strings (e.g., "HH:mm:ss", "h:mm AP")
    public var displayFormat: String {
        get {
            return String(qtTimeEdit.pointee.displayFormat())
        }
        set {
            qtTimeEdit.pointee.setDisplayFormat(std.string(newValue))
        }
    }
    
    /// Whether the time edit is read-only
    public var isReadOnly: Bool {
        get {
            return qtTimeEdit.pointee.isReadOnly()
        }
        set {
            qtTimeEdit.pointee.setReadOnly(newValue)
        }
    }
    
    /// Creates a new time edit widget
    ///
    /// - Parameter parent: The parent widget. If nil, creates a top-level time edit.
    public init(parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtTimeEdit = UnsafeMutablePointer<SwiftQTimeEdit>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtTimeEdit.initialize(to: SwiftQTimeEdit(parent.getBridgeWidget()))
        } else {
            qtTimeEdit.initialize(to: SwiftQTimeEdit())
        }
        
        super.init()
    }
    
    deinit {
        // Clean up the C++ object
        let ptr = qtTimeEdit
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    /// Sets the time using hour, minute, and second components
    ///
    /// - Parameters:
    ///   - hour: The hour (0-23)
    ///   - minute: The minute (0-59)
    ///   - second: The second (0-59)
    public func setTime(hour: Int, minute: Int, second: Int) {
        qtTimeEdit.pointee.setTime(Int32(hour), Int32(minute), Int32(second))
    }
    
    /// Sets the time range
    ///
    /// - Parameters:
    ///   - min: The minimum time
    ///   - max: The maximum time
    public func setTimeRange(min: Date, max: Date) {
        minimumTime = min
        maximumTime = max
    }
    
    /// Sets a handler for time change events
    /// - Parameter handler: Closure called when the time changes
    public func onTimeChanged(_ handler: @escaping (Date) -> Void) {
        // TODO: Connect to timeChanged signal
        // This would require signal/slot connection implementation
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtTimeEdit.pointee.show()
    }
    
    public func hide() {
        qtTimeEdit.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtTimeEdit.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtTimeEdit.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtTimeEdit.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtTimeEdit.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtTimeEdit.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtTimeEdit.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtTimeEdit.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtTimeEdit.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtTimeEdit.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtTimeEdit.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtTimeEdit.pointee.setParent(nil)
        }
    }
}