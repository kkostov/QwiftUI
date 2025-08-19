// ABOUTME: DateEdit provides a date input field with calendar popup support
// ABOUTME: This wraps Qt's QDateEdit for use in Swift applications

import Foundation
import QtBridge

/// A widget for editing dates with optional calendar popup.
///
/// DateEdit provides a convenient way for users to input dates,
/// with format validation, range constraints, and optional calendar popup.
///
/// ## Example Usage
///
/// ```swift
/// let dateEdit = DateEdit()
/// dateEdit.date = Date()
/// dateEdit.displayFormat = "yyyy-MM-dd"
/// dateEdit.calendarPopup = true
/// dateEdit.minimumDate = Date(timeIntervalSince1970: 0)
/// dateEdit.onDateChanged { date in
///     print("Date changed to: \(date)")
/// }
/// ```
@MainActor
public class DateEdit: SafeEventWidget, QtWidget {
    /// The underlying Qt date edit stored as a pointer
    nonisolated(unsafe) internal var qtDateEdit: UnsafeMutablePointer<SwiftQDateEdit>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQDateEdit* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtDateEdit).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The current date value
    public var date: Date {
        get {
            var year: Int32 = 0
            var month: Int32 = 0
            var day: Int32 = 0
            qtDateEdit.pointee.getDate(&year, &month, &day)
            
            var components = DateComponents()
            components.year = Int(year)
            components.month = Int(month)
            components.day = Int(day)
            
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: newValue)
            if let year = components.year,
               let month = components.month,
               let day = components.day {
                qtDateEdit.pointee.setDate(Int32(year), Int32(month), Int32(day))
            }
        }
    }
    
    /// The minimum allowed date
    public var minimumDate: Date {
        get {
            var year: Int32 = 0
            var month: Int32 = 0
            var day: Int32 = 0
            qtDateEdit.pointee.getMinimumDate(&year, &month, &day)
            
            var components = DateComponents()
            components.year = Int(year)
            components.month = Int(month)
            components.day = Int(day)
            
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: newValue)
            if let year = components.year,
               let month = components.month,
               let day = components.day {
                qtDateEdit.pointee.setMinimumDate(Int32(year), Int32(month), Int32(day))
            }
        }
    }
    
    /// The maximum allowed date
    public var maximumDate: Date {
        get {
            var year: Int32 = 0
            var month: Int32 = 0
            var day: Int32 = 0
            qtDateEdit.pointee.getMaximumDate(&year, &month, &day)
            
            var components = DateComponents()
            components.year = Int(year)
            components.month = Int(month)
            components.day = Int(day)
            
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.year, .month, .day], from: newValue)
            if let year = components.year,
               let month = components.month,
               let day = components.day {
                qtDateEdit.pointee.setMaximumDate(Int32(year), Int32(month), Int32(day))
            }
        }
    }
    
    /// The display format for the date
    /// Uses Qt date format strings (e.g., "yyyy-MM-dd", "dd/MM/yyyy")
    public var displayFormat: String {
        get {
            return String(qtDateEdit.pointee.displayFormat())
        }
        set {
            qtDateEdit.pointee.setDisplayFormat(std.string(newValue))
        }
    }
    
    /// Whether to show a calendar popup for date selection
    public var calendarPopup: Bool {
        get {
            return qtDateEdit.pointee.calendarPopup()
        }
        set {
            qtDateEdit.pointee.setCalendarPopup(newValue)
        }
    }
    
    /// Whether the date edit is read-only
    public var isReadOnly: Bool {
        get {
            return qtDateEdit.pointee.isReadOnly()
        }
        set {
            qtDateEdit.pointee.setReadOnly(newValue)
        }
    }
    
    /// Creates a new date edit widget
    ///
    /// - Parameter parent: The parent widget. If nil, creates a top-level date edit.
    public init(parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtDateEdit = UnsafeMutablePointer<SwiftQDateEdit>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtDateEdit.initialize(to: SwiftQDateEdit(parent.getBridgeWidget()))
        } else {
            qtDateEdit.initialize(to: SwiftQDateEdit())
        }
        
        super.init()
    }
    
    deinit {
        // Clean up the C++ object
        let ptr = qtDateEdit
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    /// Sets the date range
    ///
    /// - Parameters:
    ///   - min: The minimum date
    ///   - max: The maximum date
    public func setDateRange(min: Date, max: Date) {
        minimumDate = min
        maximumDate = max
    }
    
    /// Sets a handler for date change events
    /// - Parameter handler: Closure called when the date changes
    public func onDateChanged(_ handler: @escaping (Date) -> Void) {
        // TODO: Connect to dateChanged signal
        // This would require signal/slot connection implementation
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtDateEdit.pointee.show()
    }
    
    public func hide() {
        qtDateEdit.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtDateEdit.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtDateEdit.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtDateEdit.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtDateEdit.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtDateEdit.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtDateEdit.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtDateEdit.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtDateEdit.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtDateEdit.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtDateEdit.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtDateEdit.pointee.setParent(nil)
        }
    }
}