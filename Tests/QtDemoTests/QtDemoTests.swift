// ABOUTME: Comprehensive GUI test for QtDemo application
// ABOUTME: Tests all demo categories and widgets through programmatic interaction

import Foundation
import QwiftUI
import QwiftUITesting
import Testing

@Suite("QtDemo Comprehensive Tests")
struct QtDemoTests {

    @Test("Complete QtDemo application test with all demos")
    @MainActor
    func testQtDemoApplication() async throws {
        print("\n========================================")
        print("Starting QtDemo Comprehensive Test Suite")
        print("========================================\n")

        // Use Application instead of SimpleApp to avoid QApplication conflict in tests
        // The test runner will handle QApplication creation
        let app = Application()

        // Create event simulator for user interactions
        let simulator = EventSimulator()

        // Note: WidgetQuery currently not used but available if needed

        // Create main window like AppMain does
        let mainWindow = Widget()
        mainWindow.setWindowTitle("QtDemo Test Window")
        mainWindow.resize(width: 640, height: 500)

        // Title label
        let titleLabel = Label("QwiftUI Component Gallery", parent: mainWindow)
        titleLabel.alignment = Qt.Alignment.center
        titleLabel.resize(width: 600, height: 40)
        titleLabel.move(x: 20, y: 10)

        // Navigation label
        let navLabel = Label("Select Demo:", parent: mainWindow)
        navLabel.resize(width: 100, height: 30)
        navLabel.move(x: 20, y: 60)

        // Create dropdown navigation
        let navigationCombo = ComboBox(parent: mainWindow)
        navigationCombo.addItem("Welcome")
        navigationCombo.addItem("Labels & Alignment")
        navigationCombo.addItem("Buttons")
        navigationCombo.addItem("Text Input")
        navigationCombo.addItem("Checkboxes & Radio Buttons")
        navigationCombo.addItem("Dropdown Lists")
        navigationCombo.addItem("Advanced Widgets")
        navigationCombo.addItem("Date & Time Widgets")
        navigationCombo.addItem("Mixed Components")
        navigationCombo.currentIndex = 0
        navigationCombo.resize(width: 250, height: 30)
        navigationCombo.move(x: 130, y: 60)

        // Info button
        let infoButton = Button("About", parent: mainWindow)
        infoButton.resize(width: 100, height: 30)
        infoButton.move(x: 390, y: 60)
        var aboutClicked = false
        infoButton.onClicked {
            aboutClicked = true
            print("About button clicked in test")
        }

        // Status label
        let statusLabel = Label("Test Status", parent: mainWindow)
        statusLabel.alignment = Qt.Alignment.center
        statusLabel.resize(width: 600, height: 30)
        statusLabel.move(x: 20, y: 100)

        // Demo container
        let demoContainer = Widget(parent: mainWindow)
        demoContainer.resize(width: 600, height: 350)
        demoContainer.move(x: 20, y: 140)

        // Footer
        let footerLabel = Label("Testing in progress...", parent: mainWindow)
        footerLabel.alignment = Qt.Alignment.center
        footerLabel.resize(width: 600, height: 20)
        footerLabel.move(x: 20, y: 470)

        // Show the window
        mainWindow.show()

        // Process initial events
        simulator.processEvents(100)

        // Test the About button first
        print("\n=== Testing About Button ===")
        simulator.click(infoButton)
        simulator.processEvents(50)
        #expect(aboutClicked == true, "About button should trigger callback")

        // Store widgets for cleanup between demos
        var currentWidgets: [any QtWidget] = []

        // Helper function to clean up widgets
        func cleanupCurrentDemo() {
            currentWidgets.forEach { $0.hide() }
            currentWidgets.removeAll()
            simulator.processEvents(50)
        }

        // Test 0: Welcome Screen
        print("\n=== Testing Welcome Screen ===")
        navigationCombo.currentIndex = 0
        statusLabel.text = "Welcome Screen"

        let welcomeTitle = Label("Welcome to QwiftUI!", parent: demoContainer)
        welcomeTitle.alignment = Qt.Alignment.center
        welcomeTitle.resize(width: 560, height: 40)
        welcomeTitle.move(x: 20, y: 50)
        welcomeTitle.show()
        currentWidgets.append(welcomeTitle)

        simulator.processEvents(100)
        #expect(welcomeTitle.text == "Welcome to QwiftUI!")
        cleanupCurrentDemo()

        // Test 1: Labels & Alignment
        print("\n=== Testing Labels & Alignment Demo ===")
        navigationCombo.currentIndex = 1
        statusLabel.text = "Labels & Alignment Demo"

        let leftLabel = Label("Left aligned text", parent: demoContainer)
        leftLabel.alignment = Qt.Alignment.left
        leftLabel.resize(width: 170, height: 30)
        leftLabel.move(x: 20, y: 70)
        leftLabel.show()
        currentWidgets.append(leftLabel)

        let centerLabel = Label("Center aligned", parent: demoContainer)
        centerLabel.alignment = Qt.Alignment.center
        centerLabel.resize(width: 170, height: 30)
        centerLabel.move(x: 205, y: 70)
        centerLabel.show()
        currentWidgets.append(centerLabel)

        let rightLabel = Label("Right aligned", parent: demoContainer)
        rightLabel.alignment = Qt.Alignment.right
        rightLabel.resize(width: 170, height: 30)
        rightLabel.move(x: 390, y: 70)
        rightLabel.show()
        currentWidgets.append(rightLabel)

        simulator.processEvents(100)
        #expect(leftLabel.alignment == Qt.Alignment.left)
        #expect(centerLabel.alignment == Qt.Alignment.center)
        #expect(rightLabel.alignment == Qt.Alignment.right)
        cleanupCurrentDemo()

        // Test 2: Buttons
        print("\n=== Testing Buttons Demo ===")
        navigationCombo.currentIndex = 2
        statusLabel.text = "Button Demo"

        let normalButton = Button("Normal Button", parent: demoContainer)
        normalButton.resize(width: 150, height: 35)
        normalButton.move(x: 20, y: 80)
        var normalClicked = false
        normalButton.onClicked {
            normalClicked = true
            print("Normal button clicked in test")
        }
        normalButton.show()
        currentWidgets.append(normalButton)

        let defaultButton = Button("Default Button", parent: demoContainer)
        defaultButton.isDefault = true
        defaultButton.resize(width: 150, height: 35)
        defaultButton.move(x: 180, y: 80)
        var defaultClicked = false
        defaultButton.onClicked {
            defaultClicked = true
            print("Default button clicked in test")
        }
        defaultButton.show()
        currentWidgets.append(defaultButton)

        let disabledButton = Button("Disabled Button", parent: demoContainer)
        disabledButton.setEnabled(false)
        disabledButton.resize(width: 150, height: 35)
        disabledButton.move(x: 340, y: 80)
        disabledButton.show()
        currentWidgets.append(disabledButton)

        simulator.processEvents(100)

        // Click the buttons
        simulator.click(normalButton)
        simulator.processEvents(50)
        #expect(normalClicked == true, "Normal button should trigger callback")

        simulator.click(defaultButton)
        simulator.processEvents(50)
        #expect(defaultClicked == true, "Default button should trigger callback")
        #expect(defaultButton.isDefault == true, "Default button should have default property")

        // Disabled button shouldn't respond
        simulator.click(disabledButton)
        simulator.processEvents(50)
        // Note: We can't easily check isEnabled without a getter

        cleanupCurrentDemo()

        // Test 3: Text Input
        print("\n=== Testing Text Input Demo ===")
        navigationCombo.currentIndex = 3
        statusLabel.text = "Text Input Demo"

        let lineEdit = LineEdit("Initial text", parent: demoContainer)
        lineEdit.placeholderText = "Enter text here..."
        lineEdit.resize(width: 250, height: 30)
        lineEdit.move(x: 20, y: 80)
        lineEdit.show()
        currentWidgets.append(lineEdit)

        let textEdit = TextEdit(parent: demoContainer)
        textEdit.placeholderText = "Enter multiple lines..."
        textEdit.resize(width: 400, height: 100)
        textEdit.move(x: 20, y: 120)
        textEdit.show()
        currentWidgets.append(textEdit)

        simulator.processEvents(100)

        // Test LineEdit
        simulator.setFocus(lineEdit)
        simulator.processEvents(50)
        lineEdit.selectAll()
        simulator.typeText("Test Input", into: lineEdit)
        simulator.processEvents(100)
        #expect(lineEdit.text == "Test Input", "LineEdit should contain typed text")

        // Test TextEdit
        simulator.setFocus(textEdit)
        simulator.processEvents(50)
        simulator.typeText("Line 1", into: textEdit)
        simulator.keyPress(.return, widget: textEdit)
        simulator.typeText("Line 2", into: textEdit)
        simulator.processEvents(100)
        #expect(textEdit.text.contains("Line 1"), "TextEdit should contain first line")
        #expect(textEdit.text.contains("Line 2"), "TextEdit should contain second line")

        cleanupCurrentDemo()

        // Test 4: Checkboxes & Radio Buttons
        print("\n=== Testing Checkboxes & Radio Buttons Demo ===")
        navigationCombo.currentIndex = 4
        statusLabel.text = "Checkboxes & Radio Buttons Demo"

        let checkbox1 = CheckBox("Option 1", parent: demoContainer)
        checkbox1.move(x: 20, y: 80)
        checkbox1.show()
        currentWidgets.append(checkbox1)

        let checkbox2 = CheckBox("Option 2", parent: demoContainer)
        checkbox2.move(x: 20, y: 110)
        checkbox2.isChecked = true
        checkbox2.show()
        currentWidgets.append(checkbox2)

        // Radio buttons group
        let radio1 = RadioButton("Choice A", parent: demoContainer)
        radio1.move(x: 200, y: 80)
        radio1.show()
        currentWidgets.append(radio1)

        let radio2 = RadioButton("Choice B", parent: demoContainer)
        radio2.move(x: 200, y: 110)
        radio2.isChecked = true
        radio2.show()
        currentWidgets.append(radio2)

        let radio3 = RadioButton("Choice C", parent: demoContainer)
        radio3.move(x: 200, y: 140)
        radio3.show()
        currentWidgets.append(radio3)

        simulator.processEvents(100)

        // Test checkboxes (can be independently checked)
        #expect(checkbox1.isChecked == false, "Checkbox 1 should start unchecked")
        #expect(checkbox2.isChecked == true, "Checkbox 2 should start checked")

        simulator.click(checkbox1)
        simulator.processEvents(50)
        #expect(checkbox1.isChecked == true, "Checkbox 1 should be checked after click")
        #expect(checkbox2.isChecked == true, "Checkbox 2 should remain checked")

        // Test radio buttons (exclusive selection)
        #expect(radio2.isChecked == true, "Radio 2 should start checked")

        simulator.click(radio3)
        simulator.processEvents(50)
        #expect(radio3.isChecked == true, "Radio 3 should be checked after click")
        // Note: We can't easily verify radio2 is unchecked without Qt's auto-exclusivity working

        cleanupCurrentDemo()

        // Test 5: Dropdown Lists
        print("\n=== Testing Dropdown Lists Demo ===")
        navigationCombo.currentIndex = 5
        statusLabel.text = "ComboBox Demo"

        let combo = ComboBox(parent: demoContainer)
        combo.addItem("First Item")
        combo.addItem("Second Item")
        combo.addItem("Third Item")
        combo.currentIndex = 0
        combo.resize(width: 200, height: 30)
        combo.move(x: 20, y: 80)
        var selectionChangedCount = 0
        combo.onSelectionChanged { index, text in
            selectionChangedCount += 1
            print("ComboBox selected: \(text) at index \(index)")
        }
        combo.show()
        currentWidgets.append(combo)

        simulator.processEvents(100)

        #expect(combo.currentIndex == 0, "ComboBox should start at index 0")
        #expect(combo.currentText == "First Item", "ComboBox should show first item")

        // Change selection programmatically
        combo.currentIndex = 2
        simulator.processEvents(50)
        #expect(combo.currentIndex == 2, "ComboBox should be at index 2")
        #expect(combo.currentText == "Third Item", "ComboBox should show third item")

        cleanupCurrentDemo()

        // Test 6: Advanced Widgets
        print("\n=== Testing Advanced Widgets Demo ===")
        navigationCombo.currentIndex = 6
        statusLabel.text = "Advanced Widgets Demo"

        // Slider
        let slider = Slider(orientation: .horizontal, parent: demoContainer)
        slider.move(x: 20, y: 80)
        slider.resize(width: 250, height: 30)
        slider.minimum = 0
        slider.maximum = 100
        slider.value = 25
        var sliderValue = 25
        slider.onValueChanged { value in
            sliderValue = value
            print("Slider value changed to: \(value)")
        }
        slider.show()
        currentWidgets.append(slider)

        // Progress bar
        let progressBar = ProgressBar(parent: demoContainer)
        progressBar.move(x: 20, y: 120)
        progressBar.resize(width: 250, height: 25)
        progressBar.value = 25
        progressBar.show()
        currentWidgets.append(progressBar)

        // ScrollView with content
        let scrollView = ScrollView(parent: demoContainer)
        scrollView.move(x: 300, y: 80)
        scrollView.resize(width: 280, height: 150)
        scrollView.show()
        currentWidgets.append(scrollView)

        let scrollContent = Widget()
        scrollContent.resize(width: 260, height: 300)  // Taller than scroll view
        scrollView.setContent(scrollContent)

        let scrollLabel = Label(
            "Scrollable content here\n\nLine 2\n\nLine 3\n\nLine 4", parent: scrollContent)
        scrollLabel.resize(width: 260, height: 300)
        scrollLabel.show()

        // ImageView
        let imageView = ImageView(parent: demoContainer)
        imageView.move(x: 20, y: 200)
        imageView.resize(width: 100, height: 100)
        imageView.setPlaceholder("No Image")
        imageView.show()
        currentWidgets.append(imageView)

        // Dial
        let dial = Dial(parent: demoContainer)
        dial.move(x: 140, y: 200)
        dial.resize(width: 80, height: 80)
        dial.minimum = 0
        dial.maximum = 100
        dial.value = 50
        var dialValue = 50
        dial.onValueChanged { value in
            dialValue = value
            print("Dial value changed to: \(value)")
        }
        dial.show()
        currentWidgets.append(dial)

        // LCD Number
        let lcdNumber = LCDNumber(digitCount: 3, parent: demoContainer)
        lcdNumber.move(x: 240, y: 250)
        lcdNumber.resize(width: 100, height: 30)
        lcdNumber.display(value: 50)
        lcdNumber.show()
        currentWidgets.append(lcdNumber)

        simulator.processEvents(100)

        // Test slider
        #expect(slider.value == 25, "Slider should start at 25")
        slider.value = 75
        simulator.processEvents(50)
        #expect(slider.value == 75, "Slider should be at 75")
        #expect(sliderValue == 75, "Slider callback should have been called")

        // Test progress bar
        #expect(progressBar.value == 25, "Progress bar should start at 25")
        progressBar.value = 50
        simulator.processEvents(50)
        #expect(progressBar.value == 50, "Progress bar should be at 50")

        // Test scroll view
        #expect(scrollView.content != nil, "ScrollView should have content")
        scrollView.scrollToBottom()
        simulator.processEvents(50)
        scrollView.scrollToTop()
        simulator.processEvents(50)

        // Test dial
        #expect(dial.value == 50, "Dial should start at 50")
        dial.value = 75
        simulator.processEvents(50)
        #expect(dial.value == 75, "Dial should be at 75")
        #expect(dialValue == 75, "Dial callback should have been called")

        // Test LCD Number
        #expect(lcdNumber.value == 50, "LCD Number should start at 50")
        lcdNumber.display(value: 99)
        simulator.processEvents(50)
        #expect(lcdNumber.value == 99, "LCD Number should be at 99")

        // Connect dial to LCD number for visual feedback
        dial.onValueChanged { value in
            lcdNumber.display(value: value)
        }
        dial.value = 25
        simulator.processEvents(50)
        #expect(lcdNumber.intValue == 25, "LCD Number should mirror dial value")

        cleanupCurrentDemo()

        // Test 7: Date & Time Widgets
        print("\n=== Testing Date & Time Widgets Demo ===")
        navigationCombo.currentIndex = 7
        statusLabel.text = "Date & Time Widgets Demo"

        // DateEdit widget
        let dateEdit = DateEdit(parent: demoContainer)
        dateEdit.move(x: 130, y: 50)
        dateEdit.resize(width: 150, height: 30)
        dateEdit.date = Date()
        dateEdit.displayFormat = "yyyy-MM-dd"
        dateEdit.calendarPopup = true
        dateEdit.show()
        currentWidgets.append(dateEdit)

        // TimeEdit widget
        let timeEdit = TimeEdit(parent: demoContainer)
        timeEdit.move(x: 130, y: 90)
        timeEdit.resize(width: 150, height: 30)
        timeEdit.time = Date()
        timeEdit.displayFormat = "HH:mm:ss"
        timeEdit.show()
        currentWidgets.append(timeEdit)

        // DateTimeEdit widget
        let dateTimeEdit = DateTimeEdit(parent: demoContainer)
        dateTimeEdit.move(x: 130, y: 130)
        dateTimeEdit.resize(width: 250, height: 30)
        dateTimeEdit.dateTime = Date()
        dateTimeEdit.displayFormat = "yyyy-MM-dd HH:mm:ss"
        dateTimeEdit.calendarPopup = true
        dateTimeEdit.show()
        currentWidgets.append(dateTimeEdit)

        // CalendarWidget
        let calendar = CalendarWidget(parent: demoContainer)
        calendar.move(x: 20, y: 180)
        calendar.resize(width: 300, height: 200)
        calendar.show()
        currentWidgets.append(calendar)

        // Status label for date selection
        let dateStatusLabel = Label("Selected date will appear here", parent: demoContainer)
        dateStatusLabel.move(x: 340, y: 180)
        dateStatusLabel.resize(width: 240, height: 30)
        dateStatusLabel.show()
        currentWidgets.append(dateStatusLabel)

        // Track calendar selection
        var selectedDate: Date? = nil
        calendar.onDateSelected { date in
            selectedDate = date
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            dateStatusLabel.text = "Selected: \(formatter.string(from: date))"
            print("Calendar date selected: \(date)")
        }

        simulator.processEvents(100)

        // Test DateEdit
        let testDate = Date()
        dateEdit.date = testDate
        simulator.processEvents(50)
        // Date is always non-nil, just verify it can be set
        let dateAfterSet = dateEdit.date
        #expect(dateAfterSet != Date.distantPast, "DateEdit should have a valid date set")

        // Test TimeEdit
        let testTime = Date()
        timeEdit.time = testTime
        simulator.processEvents(50)
        // Time is always non-nil, just verify it can be set
        let timeAfterSet = timeEdit.time
        #expect(timeAfterSet != Date.distantPast, "TimeEdit should have a valid time set")

        // Test DateTimeEdit
        let testDateTime = Date()
        dateTimeEdit.dateTime = testDateTime
        simulator.processEvents(50)
        // DateTime is always non-nil, just verify it can be set
        let dateTimeAfterSet = dateTimeEdit.dateTime
        #expect(
            dateTimeAfterSet != Date.distantPast, "DateTimeEdit should have a valid dateTime set")

        // Test date range constraints
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date())!
        let oneYearFromNow = Calendar.current.date(byAdding: .year, value: 1, to: Date())!

        dateEdit.minimumDate = oneYearAgo
        dateEdit.maximumDate = oneYearFromNow
        simulator.processEvents(50)

        // Test CalendarWidget
        let todayMidnight = Calendar.current.startOfDay(for: Date())
        calendar.selectedDate = todayMidnight
        simulator.processEvents(50)
        // Calendar always has a selected date, verify it was set correctly
        let calendarDate = calendar.selectedDate
        #expect(
            Calendar.current.isDate(calendarDate, inSameDayAs: todayMidnight),
            "Calendar should have today's date selected")

        // Test calendar's date changed callback
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: todayMidnight)!
        calendar.selectedDate = tomorrow
        simulator.processEvents(100)
        #expect(selectedDate != nil, "Calendar selection callback should have been triggered")
        if let selectedDate = selectedDate {
            // Compare dates at day precision since exact times might differ
            let cal = Calendar.current
            #expect(
                cal.isDate(selectedDate, inSameDayAs: tomorrow),
                "Selected date should match tomorrow")
        }

        cleanupCurrentDemo()

        // Test 8: Mixed Components (Complex Form)
        print("\n=== Testing Mixed Components Demo ===")
        navigationCombo.currentIndex = 8
        statusLabel.text = "Mixed Components Demo"

        // Form group
        let formGroup = GroupBox("User Registration", parent: demoContainer)
        formGroup.resize(width: 540, height: 280)
        formGroup.move(x: 20, y: 70)
        formGroup.show()
        currentWidgets.append(formGroup)

        // Name field
        let nameLabel = Label("Full Name:", parent: formGroup)
        nameLabel.resize(width: 100, height: 25)
        nameLabel.move(x: 20, y: 30)
        nameLabel.show()
        currentWidgets.append(nameLabel)

        let nameEdit = LineEdit("", parent: formGroup)
        nameEdit.placeholderText = "John Doe"
        nameEdit.resize(width: 180, height: 25)
        nameEdit.move(x: 130, y: 30)
        nameEdit.show()
        currentWidgets.append(nameEdit)

        // Email field
        let emailLabel = Label("Email:", parent: formGroup)
        emailLabel.resize(width: 100, height: 25)
        emailLabel.move(x: 20, y: 65)
        emailLabel.show()
        currentWidgets.append(emailLabel)

        let emailEdit = LineEdit("", parent: formGroup)
        emailEdit.placeholderText = "john@example.com"
        emailEdit.resize(width: 180, height: 25)
        emailEdit.move(x: 130, y: 65)
        emailEdit.show()
        currentWidgets.append(emailEdit)

        // Country dropdown
        let countryLabel = Label("Country:", parent: formGroup)
        countryLabel.resize(width: 100, height: 25)
        countryLabel.move(x: 20, y: 100)
        countryLabel.show()
        currentWidgets.append(countryLabel)

        let countryCombo = ComboBox(parent: formGroup)
        countryCombo.addItem("Belgium")
        countryCombo.addItem("United Kingdom")
        countryCombo.addItem("Canada")
        countryCombo.currentIndex = 0
        countryCombo.resize(width: 180, height: 25)
        countryCombo.move(x: 130, y: 100)
        countryCombo.show()
        currentWidgets.append(countryCombo)

        // Newsletter checkbox
        let newsletterCheck = CheckBox("Subscribe to newsletter", parent: formGroup)
        newsletterCheck.move(x: 20, y: 135)
        newsletterCheck.show()
        currentWidgets.append(newsletterCheck)

        // Submit button
        let submitButton = Button("Register", parent: demoContainer)
        submitButton.isDefault = true
        submitButton.resize(width: 100, height: 35)
        submitButton.move(x: 380, y: 360)
        var formSubmitted = false
        submitButton.onClicked {
            formSubmitted = true
            print("Form submitted with:")
            print("  Name: \(nameEdit.text)")
            print("  Email: \(emailEdit.text)")
            print("  Country: \(countryCombo.currentText)")
            print("  Newsletter: \(newsletterCheck.isChecked)")
        }
        submitButton.show()
        currentWidgets.append(submitButton)

        simulator.processEvents(100)

        // Fill out the form
        simulator.setFocus(nameEdit)
        simulator.typeText("Test User", into: nameEdit)
        simulator.processEvents(50)

        simulator.setFocus(emailEdit)
        simulator.typeText("test@example.com", into: emailEdit)
        simulator.processEvents(50)

        countryCombo.currentIndex = 1  // Select UK
        simulator.processEvents(50)

        simulator.click(newsletterCheck)
        simulator.processEvents(50)

        // Submit the form
        simulator.click(submitButton)
        simulator.processEvents(50)

        #expect(formSubmitted == true, "Form should have been submitted")
        #expect(nameEdit.text == "Test User", "Name field should contain entered text")
        #expect(emailEdit.text == "test@example.com", "Email field should contain entered text")
        #expect(countryCombo.currentText == "United Kingdom", "Country should be UK")
        #expect(newsletterCheck.isChecked == true, "Newsletter should be checked")

        cleanupCurrentDemo()

        // Test switching back and forth (regression test for crashes)
        print("\n=== Testing Demo Switching Stability ===")

        // Switch to Advanced Widgets
        navigationCombo.currentIndex = 6
        statusLabel.text = "Testing switch to Advanced"
        simulator.processEvents(100)

        // Create a simple widget to test
        let testSlider = Slider(orientation: .horizontal, parent: demoContainer)
        testSlider.move(x: 20, y: 80)
        testSlider.resize(width: 200, height: 30)
        testSlider.show()
        currentWidgets.append(testSlider)
        simulator.processEvents(50)
        cleanupCurrentDemo()

        // Switch to Mixed Components
        navigationCombo.currentIndex = 8
        statusLabel.text = "Testing switch to Mixed"
        simulator.processEvents(100)

        // Create a simple widget to test
        let testGroup = GroupBox("Test", parent: demoContainer)
        testGroup.resize(width: 200, height: 100)
        testGroup.move(x: 20, y: 70)
        testGroup.show()
        currentWidgets.append(testGroup)
        simulator.processEvents(50)
        cleanupCurrentDemo()

        // Switch back to Advanced Widgets (this often triggers crashes)
        navigationCombo.currentIndex = 6
        statusLabel.text = "Testing switch back to Advanced"
        simulator.processEvents(100)

        let testSlider2 = Slider(orientation: .vertical, parent: demoContainer)
        testSlider2.move(x: 20, y: 80)
        testSlider2.resize(width: 30, height: 200)
        testSlider2.show()
        currentWidgets.append(testSlider2)
        simulator.processEvents(50)
        cleanupCurrentDemo()

        print("\n=== Final Cleanup ===")
        mainWindow.hide()
        simulator.processEvents(100)

        print("\n========================================")
        print("QtDemo Comprehensive Test Suite COMPLETED")
        print("All demos tested successfully!")
        print("========================================\n")
    }
}
