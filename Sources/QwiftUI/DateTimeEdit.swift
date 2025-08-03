// ABOUTME: DateTimeEdit provides a combined date and time input field
// ABOUTME: This wraps Qt's QDateTimeEdit for use in Swift applications

import Foundation
import QtBridge

/// A widget for editing date and time values together.
///
/// DateTimeEdit provides a convenient way for users to input both date and time,
/// with format validation, range constraints, and optional calendar popup.
///
/// ## Example Usage
///
/// ```swift
/// let dateTimeEdit = DateTimeEdit()
/// dateTimeEdit.dateTime = Date()
/// dateTimeEdit.displayFormat = "yyyy-MM-dd HH:mm:ss"
/// dateTimeEdit.calendarPopup = true
/// dateTimeEdit.onDateTimeChanged { dateTime in
///     print("DateTime changed to: \(dateTime)")
/// }
/// ```
@MainActor
public class DateTimeEdit: SafeEventWidget, QtWidget {
    /// The underlying Qt datetime edit stored as a pointer
    nonisolated(unsafe) internal var qtDateTimeEdit: UnsafeMutablePointer<SwiftQDateTimeEdit>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQDateTimeEdit* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtDateTimeEdit).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The current date and time value
    public var dateTime: Date {
        get {
            var year: Int32 = 0
            var month: Int32 = 0
            var day: Int32 = 0
            var hour: Int32 = 0
            var minute: Int32 = 0
            var second: Int32 = 0
            qtDateTimeEdit.pointee.getDateTime(&year, &month, &day, &hour, &minute, &second)
            
            var components = DateComponents()
            components.year = Int(year)
            components.month = Int(month)
            components.day = Int(day)
            components.hour = Int(hour)
            components.minute = Int(minute)
            components.second = Int(second)
            
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newValue)
            if let year = components.year,
               let month = components.month,
               let day = components.day,
               let hour = components.hour,
               let minute = components.minute,
               let second = components.second {
                qtDateTimeEdit.pointee.setDateTime(Int32(year), Int32(month), Int32(day),
                                                   Int32(hour), Int32(minute), Int32(second))
            }
        }
    }
    
    /// The minimum allowed date and time
    public var minimumDateTime: Date {
        get {
            var year: Int32 = 0
            var month: Int32 = 0
            var day: Int32 = 0
            var hour: Int32 = 0
            var minute: Int32 = 0
            var second: Int32 = 0
            qtDateTimeEdit.pointee.getMinimumDateTime(&year, &month, &day, &hour, &minute, &second)
            
            var components = DateComponents()
            components.year = Int(year)
            components.month = Int(month)
            components.day = Int(day)
            components.hour = Int(hour)
            components.minute = Int(minute)
            components.second = Int(second)
            
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newValue)
            if let year = components.year,
               let month = components.month,
               let day = components.day,
               let hour = components.hour,
               let minute = components.minute,
               let second = components.second {
                qtDateTimeEdit.pointee.setMinimumDateTime(Int32(year), Int32(month), Int32(day),
                                                          Int32(hour), Int32(minute), Int32(second))
            }
        }
    }
    
    /// The maximum allowed date and time
    public var maximumDateTime: Date {
        get {
            var year: Int32 = 0
            var month: Int32 = 0
            var day: Int32 = 0
            var hour: Int32 = 0
            var minute: Int32 = 0
            var second: Int32 = 0
            qtDateTimeEdit.pointee.getMaximumDateTime(&year, &month, &day, &hour, &minute, &second)
            
            var components = DateComponents()
            components.year = Int(year)
            components.month = Int(month)
            components.day = Int(day)
            components.hour = Int(hour)
            components.minute = Int(minute)
            components.second = Int(second)
            
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newValue)
            if let year = components.year,
               let month = components.month,
               let day = components.day,
               let hour = components.hour,
               let minute = components.minute,
               let second = components.second {
                qtDateTimeEdit.pointee.setMaximumDateTime(Int32(year), Int32(month), Int32(day),
                                                          Int32(hour), Int32(minute), Int32(second))
            }
        }
    }
    
    /// The display format for the date and time
    /// Uses Qt datetime format strings (e.g., "yyyy-MM-dd HH:mm:ss", "dd/MM/yyyy h:mm AP")
    public var displayFormat: String {
        get {
            return String(qtDateTimeEdit.pointee.displayFormat())
        }
        set {
            qtDateTimeEdit.pointee.setDisplayFormat(std.string(newValue))
        }
    }
    
    /// Whether to show a calendar popup for date selection
    public var calendarPopup: Bool {
        get {
            return qtDateTimeEdit.pointee.calendarPopup()
        }
        set {
            qtDateTimeEdit.pointee.setCalendarPopup(newValue)
        }
    }
    
    /// Whether the datetime edit is read-only
    public var isReadOnly: Bool {
        get {
            return qtDateTimeEdit.pointee.isReadOnly()
        }
        set {
            qtDateTimeEdit.pointee.setReadOnly(newValue)
        }
    }
    
    /// Creates a new datetime edit widget
    ///
    /// - Parameter parent: The parent widget. If nil, creates a top-level datetime edit.
    public init(parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtDateTimeEdit = UnsafeMutablePointer<SwiftQDateTimeEdit>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtDateTimeEdit.initialize(to: SwiftQDateTimeEdit(parent.getBridgeWidget()))
        } else {
            qtDateTimeEdit.initialize(to: SwiftQDateTimeEdit())
        }
        
        super.init()
    }
    
    deinit {
        // Clean up the C++ object
        let ptr = qtDateTimeEdit
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    /// Sets the date time range
    ///
    /// - Parameters:
    ///   - min: The minimum date time
    ///   - max: The maximum date time
    public func setDateTimeRange(min: Date, max: Date) {
        minimumDateTime = min
        maximumDateTime = max
    }
    
    /// Sets a handler for datetime change events
    /// - Parameter handler: Closure called when the datetime changes
    public func onDateTimeChanged(_ handler: @escaping (Date) -> Void) {
        // TODO: Connect to dateTimeChanged signal
        // This would require signal/slot connection implementation
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtDateTimeEdit.pointee.show()
    }
    
    public func hide() {
        qtDateTimeEdit.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtDateTimeEdit.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtDateTimeEdit.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtDateTimeEdit.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtDateTimeEdit.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtDateTimeEdit.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtDateTimeEdit.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtDateTimeEdit.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtDateTimeEdit.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtDateTimeEdit.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtDateTimeEdit.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtDateTimeEdit.pointee.setParent(nil)
        }
    }
}