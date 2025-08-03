// ABOUTME: CalendarWidget provides a monthly calendar view for date selection
// ABOUTME: This wraps Qt's QCalendarWidget for use in Swift applications

import Foundation
import QtBridge

/// A monthly calendar widget for date selection.
///
/// CalendarWidget provides a full-featured calendar display with date selection,
/// navigation controls, and customizable appearance options.
///
/// ## Example Usage
///
/// ```swift
/// let calendar = CalendarWidget()
/// calendar.selectedDate = Date()
/// calendar.gridVisible = true
/// calendar.firstDayOfWeek = .monday
/// calendar.onDateSelected { date in
///     print("Selected date: \(date)")
/// }
/// ```
@MainActor
public class CalendarWidget: SafeEventWidget, QtWidget {
    /// Days of the week
    public enum DayOfWeek: Int {
        case monday = 1
        case tuesday = 2
        case wednesday = 3
        case thursday = 4
        case friday = 5
        case saturday = 6
        case sunday = 7
    }
    
    /// Selection modes for the calendar
    public enum SelectionMode: Int {
        case noSelection = 0      // No date can be selected
        case singleSelection = 1  // Single date selection (default)
    }
    
    /// The underlying Qt calendar widget stored as a pointer
    nonisolated(unsafe) internal var qtCalendarWidget: UnsafeMutablePointer<SwiftQCalendarWidget>
    
    /// Protocol conformance - provide mutable pointer
    public func getBridgeWidget() -> UnsafeMutablePointer<SwiftQWidget> {
        // Cast from SwiftQCalendarWidget* to SwiftQWidget* (base class pointer)
        return UnsafeMutableRawPointer(qtCalendarWidget).assumingMemoryBound(to: SwiftQWidget.self)
    }
    
    /// The currently selected date
    public var selectedDate: Date {
        get {
            var year: Int32 = 0
            var month: Int32 = 0
            var day: Int32 = 0
            qtCalendarWidget.pointee.getSelectedDate(&year, &month, &day)
            
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
                qtCalendarWidget.pointee.setSelectedDate(Int32(year), Int32(month), Int32(day))
            }
        }
    }
    
    /// The minimum selectable date
    public var minimumDate: Date {
        get {
            var year: Int32 = 0
            var month: Int32 = 0
            var day: Int32 = 0
            qtCalendarWidget.pointee.getMinimumDate(&year, &month, &day)
            
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
                qtCalendarWidget.pointee.setMinimumDate(Int32(year), Int32(month), Int32(day))
            }
        }
    }
    
    /// The maximum selectable date
    public var maximumDate: Date {
        get {
            var year: Int32 = 0
            var month: Int32 = 0
            var day: Int32 = 0
            qtCalendarWidget.pointee.getMaximumDate(&year, &month, &day)
            
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
                qtCalendarWidget.pointee.setMaximumDate(Int32(year), Int32(month), Int32(day))
            }
        }
    }
    
    /// The first day of the week
    public var firstDayOfWeek: DayOfWeek {
        get {
            return DayOfWeek(rawValue: Int(qtCalendarWidget.pointee.firstDayOfWeek())) ?? .monday
        }
        set {
            qtCalendarWidget.pointee.setFirstDayOfWeek(Int32(newValue.rawValue))
        }
    }
    
    /// Whether to show grid lines
    public var gridVisible: Bool {
        get {
            return qtCalendarWidget.pointee.isGridVisible()
        }
        set {
            qtCalendarWidget.pointee.setGridVisible(newValue)
        }
    }
    
    /// Whether to show the navigation bar
    public var navigationBarVisible: Bool {
        get {
            return qtCalendarWidget.pointee.isNavigationBarVisible()
        }
        set {
            qtCalendarWidget.pointee.setNavigationBarVisible(newValue)
        }
    }
    
    /// The selection mode
    public var selectionMode: SelectionMode {
        get {
            return SelectionMode(rawValue: Int(qtCalendarWidget.pointee.selectionMode())) ?? .singleSelection
        }
        set {
            qtCalendarWidget.pointee.setSelectionMode(Int32(newValue.rawValue))
        }
    }
    
    /// Creates a new calendar widget
    ///
    /// - Parameter parent: The parent widget. If nil, creates a top-level calendar widget.
    public init(parent: (any QtWidget)? = nil) {
        // Allocate the C++ object on the heap
        qtCalendarWidget = UnsafeMutablePointer<SwiftQCalendarWidget>.allocate(capacity: 1)
        
        // Initialize the C++ object
        if let parent = parent {
            qtCalendarWidget.initialize(to: SwiftQCalendarWidget(parent.getBridgeWidget()))
        } else {
            qtCalendarWidget.initialize(to: SwiftQCalendarWidget())
        }
        
        super.init()
    }
    
    deinit {
        // Clean up the C++ object
        let ptr = qtCalendarWidget
        ptr.deinitialize(count: 1)
        ptr.deallocate()
    }
    
    /// Sets the date range
    ///
    /// - Parameters:
    ///   - min: The minimum selectable date
    ///   - max: The maximum selectable date
    public func setDateRange(min: Date, max: Date) {
        minimumDate = min
        maximumDate = max
    }
    
    /// Sets a handler for date selection events
    /// - Parameter handler: Closure called when a date is selected
    public func onDateSelected(_ handler: @escaping (Date) -> Void) {
        // TODO: Connect to selectionChanged signal
        // This would require signal/slot connection implementation
    }
    
    // MARK: - QtWidget Protocol Implementation
    
    public func show() {
        qtCalendarWidget.pointee.show()
    }
    
    public func hide() {
        qtCalendarWidget.pointee.hide()
    }
    
    public func setEnabled(_ enabled: Bool) {
        qtCalendarWidget.pointee.setEnabled(enabled)
    }
    
    public var isVisible: Bool {
        qtCalendarWidget.pointee.isVisible()
    }
    
    public func resize(width: Int, height: Int) {
        qtCalendarWidget.pointee.resize(Int32(width), Int32(height))
    }
    
    public func move(x: Int, y: Int) {
        qtCalendarWidget.pointee.move(Int32(x), Int32(y))
    }
    
    public func setGeometry(x: Int, y: Int, width: Int, height: Int) {
        qtCalendarWidget.pointee.setGeometry(Int32(x), Int32(y), Int32(width), Int32(height))
    }
    
    public func setWindowTitle(_ title: String) {
        qtCalendarWidget.pointee.setWindowTitle(std.string(title))
    }
    
    public var windowTitle: String {
        String(qtCalendarWidget.pointee.windowTitle())
    }
    
    public func setObjectName(_ name: String) {
        qtCalendarWidget.pointee.setObjectName(std.string(name))
    }
    
    public var objectName: String {
        String(qtCalendarWidget.pointee.objectName())
    }
    
    public func setParent(_ parent: QtWidget?) {
        if let parent = parent {
            qtCalendarWidget.pointee.setParent(parent.getBridgeWidget())
        } else {
            qtCalendarWidget.pointee.setParent(nil)
        }
    }
}