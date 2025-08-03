// ABOUTME: Individual demo screens for each QwiftUI component
// ABOUTME: Provides focused demonstrations of widget functionality

import Foundation
import QwiftUI

/// Base protocol for component demos
@MainActor
protocol ComponentDemo {
    var title: String { get }
    func setupDemo(in container: Widget)
    func cleanup()
}

/// Welcome screen demonstration
@MainActor
class WelcomeDemo: ComponentDemo {
    var title: String { "Welcome" }
    private var widgets: [any QtWidget] = []

    func setupDemo(in container: Widget) {
        let welcomeTitle = Label("Welcome to QwiftUI!", parent: container)
        welcomeTitle.alignment = Qt.Alignment.center
        welcomeTitle.resize(width: 560, height: 40)
        welcomeTitle.move(x: 20, y: 50)
        widgets.append(welcomeTitle)

        let welcomeText = Label(
            """
            This gallery showcases Qt6 widgets wrapped in Swift using
            Swift 6.2's C++ interoperability - no manual "C" bindings (but there is C++ glue code 😅)!
            """,
            parent: container
        )
        welcomeText.alignment = Qt.Alignment.left
        welcomeText.resize(width: 560, height: 250)
        welcomeText.move(x: 20, y: 100)
        widgets.append(welcomeText)

        widgets.forEach { $0.show() }
    }

    func cleanup() {
        widgets.forEach { $0.hide() }
        widgets.removeAll()
    }
}

/// Label and alignment demonstration
@MainActor
class LabelDemo: ComponentDemo {
    var title: String { "Labels & Alignment" }
    private var widgets: [any QtWidget] = []

    func setupDemo(in container: Widget) {
        // Title
        let title = Label("Label & Alignment Demo", parent: container)
        title.alignment = Qt.Alignment.center
        title.resize(width: 560, height: 40)
        title.move(x: 20, y: 20)
        widgets.append(title)

        // Different alignment examples
        let leftLabel = Label("Left aligned text", parent: container)
        leftLabel.alignment = Qt.Alignment.left
        leftLabel.resize(width: 170, height: 30)
        leftLabel.move(x: 20, y: 70)
        widgets.append(leftLabel)

        let centerLabel = Label("Center aligned", parent: container)
        centerLabel.alignment = Qt.Alignment.center
        centerLabel.resize(width: 170, height: 30)
        centerLabel.move(x: 205, y: 70)
        widgets.append(centerLabel)

        let rightLabel = Label("Right aligned", parent: container)
        rightLabel.alignment = Qt.Alignment.right
        rightLabel.resize(width: 170, height: 30)
        rightLabel.move(x: 390, y: 70)
        widgets.append(rightLabel)

        // Multi-line with different vertical alignments
        let topLabel = Label("Top\nAligned\nText", parent: container)
        topLabel.alignment = [Qt.Alignment.hCenter, Qt.Alignment.top]
        topLabel.resize(width: 170, height: 80)
        topLabel.move(x: 20, y: 120)
        widgets.append(topLabel)

        let vCenterLabel = Label("Vertically\nCentered\nText", parent: container)
        vCenterLabel.alignment = Qt.Alignment.center
        vCenterLabel.resize(width: 170, height: 80)
        vCenterLabel.move(x: 205, y: 120)
        widgets.append(vCenterLabel)

        let bottomLabel = Label("Bottom\nAligned\nText", parent: container)
        bottomLabel.alignment = [Qt.Alignment.hCenter, Qt.Alignment.bottom]
        bottomLabel.resize(width: 170, height: 80)
        bottomLabel.move(x: 390, y: 120)
        widgets.append(bottomLabel)

        // Show all widgets
        widgets.forEach { $0.show() }
    }

    func cleanup() {
        widgets.forEach { $0.hide() }
        widgets.removeAll()
    }
}

/// Button demonstration
@MainActor
class ButtonDemo: ComponentDemo {
    var title: String { "Buttons" }
    private var widgets: [any QtWidget] = []

    func setupDemo(in container: Widget) {
        let title = Label("Button Demo", parent: container)
        title.alignment = Qt.Alignment.center
        title.resize(width: 560, height: 40)
        title.move(x: 20, y: 20)
        widgets.append(title)

        // Regular button
        let normalButton = Button("Normal Button", parent: container)
        normalButton.resize(width: 150, height: 35)
        normalButton.move(x: 20, y: 80)
        widgets.append(normalButton)

        // Default button (responds to Enter)
        let defaultButton = Button("Default Button", parent: container)
        defaultButton.isDefault = true
        defaultButton.resize(width: 150, height: 35)
        defaultButton.move(x: 180, y: 80)
        widgets.append(defaultButton)

        // Flat button
        let flatButton = Button("Flat Button", parent: container)
        flatButton.isFlat = true
        flatButton.resize(width: 150, height: 35)
        flatButton.move(x: 340, y: 80)
        widgets.append(flatButton)

        // Disabled button
        let disabledButton = Button("Disabled Button", parent: container)
        disabledButton.setEnabled(false)
        disabledButton.resize(width: 150, height: 35)
        disabledButton.move(x: 20, y: 130)
        widgets.append(disabledButton)

        // Button with emoji
        let emojiButton = Button("Click Me! 🚀", parent: container)
        emojiButton.resize(width: 150, height: 35)
        emojiButton.move(x: 180, y: 130)
        widgets.append(emojiButton)

        widgets.forEach { $0.show() }
    }

    func cleanup() {
        widgets.forEach { $0.hide() }
        widgets.removeAll()
    }
}

/// Text input demonstration
@MainActor
class TextInputDemo: ComponentDemo {
    var title: String { "Text Input" }
    private var widgets: [any QtWidget] = []

    func setupDemo(in container: Widget) {
        let title = Label("Text Input Demo", parent: container)
        title.alignment = Qt.Alignment.center
        title.resize(width: 560, height: 40)
        title.move(x: 20, y: 20)
        widgets.append(title)

        // Line edits
        let nameLabel = Label("Name:", parent: container)
        nameLabel.resize(width: 80, height: 30)
        nameLabel.move(x: 20, y: 80)
        widgets.append(nameLabel)

        let nameEdit = LineEdit("", parent: container)
        nameEdit.placeholderText = "Enter your name"
        nameEdit.resize(width: 200, height: 30)
        nameEdit.move(x: 110, y: 80)
        widgets.append(nameEdit)

        let emailLabel = Label("Email:", parent: container)
        emailLabel.resize(width: 80, height: 30)
        emailLabel.move(x: 20, y: 120)
        widgets.append(emailLabel)

        let emailEdit = LineEdit("", parent: container)
        emailEdit.placeholderText = "user@example.com"
        emailEdit.resize(width: 200, height: 30)
        emailEdit.move(x: 110, y: 120)
        widgets.append(emailEdit)

        let passwordLabel = Label("Password:", parent: container)
        passwordLabel.resize(width: 80, height: 30)
        passwordLabel.move(x: 20, y: 160)
        widgets.append(passwordLabel)

        let passwordEdit = LineEdit("", parent: container)
        passwordEdit.placeholderText = "••••••••"
        passwordEdit.maxLength = 20
        passwordEdit.resize(width: 200, height: 30)
        passwordEdit.move(x: 110, y: 160)
        widgets.append(passwordEdit)

        // Read-only field
        let readOnlyLabel = Label("Read-only:", parent: container)
        readOnlyLabel.resize(width: 80, height: 30)
        readOnlyLabel.move(x: 20, y: 200)
        widgets.append(readOnlyLabel)

        let readOnlyEdit = LineEdit("This field is read-only", parent: container)
        readOnlyEdit.readOnly = true
        readOnlyEdit.resize(width: 200, height: 30)
        readOnlyEdit.move(x: 110, y: 200)
        widgets.append(readOnlyEdit)

        // Multi-line text edit
        let notesLabel = Label("Notes:", parent: container)
        notesLabel.resize(width: 80, height: 30)
        notesLabel.move(x: 340, y: 80)
        widgets.append(notesLabel)

        let notesEdit = TextEdit(
            "Enter your notes here...\n\nSupports multiple lines!", parent: container)
        notesEdit.resize(width: 220, height: 150)
        notesEdit.move(x: 340, y: 110)
        widgets.append(notesEdit)

        widgets.forEach { $0.show() }
    }

    func cleanup() {
        widgets.forEach { $0.hide() }
        widgets.removeAll()
    }
}

/// Checkable widgets demonstration
@MainActor
class CheckableDemo: ComponentDemo {
    var title: String { "Checkboxes & Radio Buttons" }
    private var widgets: [any QtWidget] = []

    func setupDemo(in container: Widget) {
        let title = Label("Checkboxes & Radio Buttons", parent: container)
        title.alignment = Qt.Alignment.center
        title.resize(width: 560, height: 40)
        title.move(x: 20, y: 20)
        widgets.append(title)

        // Checkboxes group
        let checkGroup = GroupBox("Options", parent: container)
        checkGroup.resize(width: 250, height: 180)
        checkGroup.move(x: 20, y: 70)
        widgets.append(checkGroup)

        let check1 = CheckBox("Enable notifications", parent: checkGroup)
        check1.isChecked = true
        check1.resize(width: 200, height: 25)
        check1.move(x: 15, y: 30)
        widgets.append(check1)

        let check2 = CheckBox("Auto-save", parent: checkGroup)
        check2.resize(width: 200, height: 25)
        check2.move(x: 15, y: 60)
        widgets.append(check2)

        let check3 = CheckBox("Dark mode", parent: checkGroup)
        check3.isChecked = true
        check3.resize(width: 200, height: 25)
        check3.move(x: 15, y: 90)
        widgets.append(check3)

        // Tri-state checkbox
        let triCheck = CheckBox("Select all", parent: checkGroup)
        triCheck.isTristate = true
        triCheck.checkState = .partiallyChecked
        triCheck.resize(width: 200, height: 25)
        triCheck.move(x: 15, y: 130)
        widgets.append(triCheck)

        // Radio buttons group
        let radioGroup = GroupBox("Choose one", parent: container)
        radioGroup.resize(width: 250, height: 180)
        radioGroup.move(x: 290, y: 70)
        widgets.append(radioGroup)

        let radio1 = RadioButton("Small", parent: radioGroup)
        radio1.resize(width: 200, height: 25)
        radio1.move(x: 15, y: 30)
        widgets.append(radio1)

        let radio2 = RadioButton("Medium", parent: radioGroup)
        radio2.isChecked = true
        radio2.resize(width: 200, height: 25)
        radio2.move(x: 15, y: 60)
        widgets.append(radio2)

        let radio3 = RadioButton("Large", parent: radioGroup)
        radio3.resize(width: 200, height: 25)
        radio3.move(x: 15, y: 90)
        widgets.append(radio3)

        let radio4 = RadioButton("Extra Large", parent: radioGroup)
        radio4.resize(width: 200, height: 25)
        radio4.move(x: 15, y: 120)
        widgets.append(radio4)

        // Checkable group box
        let checkableGroup = GroupBox("Enable advanced options", parent: container)
        checkableGroup.isCheckable = true
        checkableGroup.isChecked = false
        checkableGroup.resize(width: 520, height: 80)
        checkableGroup.move(x: 20, y: 260)
        widgets.append(checkableGroup)

        let advancedLabel = Label(
            "Advanced options would appear here when enabled", parent: checkableGroup)
        advancedLabel.alignment = Qt.Alignment.center
        advancedLabel.resize(width: 480, height: 30)
        advancedLabel.move(x: 20, y: 30)
        widgets.append(advancedLabel)

        widgets.forEach { $0.show() }
    }

    func cleanup() {
        widgets.forEach { $0.hide() }
        widgets.removeAll()
    }
}

/// ComboBox demonstration
@MainActor
class ComboBoxDemo: ComponentDemo {
    var title: String { "Dropdown Lists (ComboBox)" }
    private var widgets: [any QtWidget] = []

    func setupDemo(in container: Widget) {
        let title = Label("ComboBox Demo", parent: container)
        title.alignment = Qt.Alignment.center
        title.resize(width: 560, height: 40)
        title.move(x: 20, y: 20)
        widgets.append(title)

        // Country selector
        let countryLabel = Label("Country:", parent: container)
        countryLabel.resize(width: 100, height: 30)
        countryLabel.move(x: 20, y: 80)
        widgets.append(countryLabel)

        let countryCombo = ComboBox(
            items: [
                "Belgium",
                "Canada",
                "United Kingdom",
                "Germany",
                "France",
                "Japan",
                "Australia",
            ], parent: container)
        countryCombo.currentIndex = 0
        countryCombo.resize(width: 200, height: 30)
        countryCombo.move(x: 130, y: 80)
        widgets.append(countryCombo)

        // Language selector
        let langLabel = Label("Language:", parent: container)
        langLabel.resize(width: 100, height: 30)
        langLabel.move(x: 20, y: 120)
        widgets.append(langLabel)

        let langCombo = ComboBox(parent: container)
        langCombo.addItem("English")
        langCombo.addItem("Spanish")
        langCombo.addItem("French")
        langCombo.addItem("German")
        langCombo.addItem("Chinese")
        langCombo.addItem("Japanese")
        langCombo.currentIndex = 0
        langCombo.resize(width: 200, height: 30)
        langCombo.move(x: 130, y: 120)
        widgets.append(langCombo)

        // Theme selector
        let themeLabel = Label("Theme:", parent: container)
        themeLabel.resize(width: 100, height: 30)
        themeLabel.move(x: 20, y: 160)
        widgets.append(themeLabel)

        let themeCombo = ComboBox(items: ["Light", "Dark", "Auto"], parent: container)
        themeCombo.currentIndex = 1
        themeCombo.resize(width: 200, height: 30)
        themeCombo.move(x: 130, y: 160)
        widgets.append(themeCombo)

        // Font size selector
        let fontLabel = Label("Font Size:", parent: container)
        fontLabel.resize(width: 100, height: 30)
        fontLabel.move(x: 20, y: 200)
        widgets.append(fontLabel)

        let fontCombo = ComboBox(parent: container)
        for size in [8, 9, 10, 11, 12, 14, 16, 18, 20, 24, 28, 32] {
            fontCombo.addItem("\(size) pt")
        }
        fontCombo.currentIndex = 4  // 12pt
        fontCombo.resize(width: 200, height: 30)
        fontCombo.move(x: 130, y: 200)
        widgets.append(fontCombo)

        // Info display
        let infoLabel = Label(
            "ComboBoxes provide dropdown selection.\nCurrent selections are shown above.",
            parent: container
        )
        infoLabel.alignment = Qt.Alignment.center
        infoLabel.resize(width: 200, height: 60)
        infoLabel.move(x: 360, y: 100)
        widgets.append(infoLabel)

        widgets.forEach { $0.show() }
    }

    func cleanup() {
        widgets.forEach { $0.hide() }
        widgets.removeAll()
    }
}

/// Advanced widgets demonstration - Slider, ProgressBar, ScrollView, ImageView
@MainActor
class AdvancedWidgetsDemo: ComponentDemo {
    var title: String { "Advanced Widgets" }
    private var widgets: [any QtWidget] = []

    func setupDemo(in container: Widget) {
        let title = Label("Advanced Widgets Demo", parent: container)
        title.alignment = Qt.Alignment.center
        title.resize(width: 560, height: 40)
        title.move(x: 20, y: 10)
        widgets.append(title)

        // Horizontal slider with progress bar
        let sliderLabel = Label("Slider value: 25", parent: container)
        sliderLabel.resize(width: 150, height: 25)
        sliderLabel.move(x: 20, y: 50)
        widgets.append(sliderLabel)

        let hSlider = Slider(orientation: .horizontal, parent: container)
        hSlider.move(x: 20, y: 80)
        hSlider.resize(width: 250, height: 30)
        hSlider.minimum = 0
        hSlider.maximum = 100
        hSlider.value = 25
        hSlider.tickPosition = .ticksBelow
        hSlider.tickInterval = 10
        widgets.append(hSlider)

        let progressBar = ProgressBar(parent: container)
        progressBar.move(x: 20, y: 120)
        progressBar.resize(width: 250, height: 25)
        progressBar.minimum = 0
        progressBar.maximum = 100
        progressBar.value = 25
        progressBar.showText = true
        progressBar.format = "Progress: %p%"
        widgets.append(progressBar)

        // Connect slider to progress bar and label
        hSlider.onValueChanged { value in
            progressBar.value = value
            sliderLabel.text = "Slider value: \(value)"
        }

        // Vertical slider
        let vSliderLabel = Label("Volume", parent: container)
        vSliderLabel.resize(width: 60, height: 25)
        vSliderLabel.move(x: 300, y: 50)
        widgets.append(vSliderLabel)

        let vSlider = Slider(orientation: .vertical, parent: container)
        vSlider.move(x: 310, y: 80)
        vSlider.resize(width: 30, height: 150)
        vSlider.minimum = 0
        vSlider.maximum = 10
        vSlider.value = 5
        vSlider.tickPosition = .ticksBothSides
        vSlider.tickInterval = 1
        widgets.append(vSlider)

        // ScrollView with content
        let scrollLabel = Label("Scrollable Area:", parent: container)
        scrollLabel.resize(width: 150, height: 25)
        scrollLabel.move(x: 370, y: 50)
        widgets.append(scrollLabel)

        let scrollView = ScrollView(parent: container)
        scrollView.move(x: 370, y: 80)
        scrollView.resize(width: 200, height: 150)
        scrollView.horizontalScrollBarPolicy = .asNeeded
        scrollView.verticalScrollBarPolicy = .asNeeded
        widgets.append(scrollView)

        // Create content for scroll view
        let scrollContent = Widget()
        scrollContent.resize(width: 300, height: 300)

        // Track the scroll content widget for cleanup
        widgets.append(scrollContent)

        for i in 0..<8 {
            let label = Label("Scrollable line \(i + 1)", parent: scrollContent)
            label.move(x: 10, y: i * 35)
            label.resize(width: 250, height: 25)
            // Track each label for cleanup
            widgets.append(label)
        }

        scrollView.setContent(scrollContent)

        // SpinBox (integer input)
        let spinBoxLabel = Label("Integer SpinBox:", parent: container)
        spinBoxLabel.resize(width: 120, height: 25)
        spinBoxLabel.move(x: 380, y: 50)
        widgets.append(spinBoxLabel)

        let spinBox = SpinBox(parent: container)
        spinBox.move(x: 380, y: 80)
        spinBox.resize(width: 120, height: 30)
        spinBox.minimum = 0
        spinBox.maximum = 100
        spinBox.value = 42
        spinBox.singleStep = 5
        spinBox.suffix = " items"
        widgets.append(spinBox)

        // DoubleSpinBox (floating-point input)
        let doubleSpinBoxLabel = Label("Double SpinBox:", parent: container)
        doubleSpinBoxLabel.resize(width: 120, height: 25)
        doubleSpinBoxLabel.move(x: 380, y: 120)
        widgets.append(doubleSpinBoxLabel)

        let doubleSpinBox = DoubleSpinBox(parent: container)
        doubleSpinBox.move(x: 380, y: 150)
        doubleSpinBox.resize(width: 120, height: 30)
        doubleSpinBox.setRange(0.0, 100.0)
        doubleSpinBox.setValue(3.14159)
        doubleSpinBox.setSingleStep(0.1)
        doubleSpinBox.setDecimals(2)
        doubleSpinBox.setPrefix("$")
        widgets.append(doubleSpinBox)

        // Dial widget
        let dialLabel = Label("Dial Control:", parent: container)
        dialLabel.resize(width: 100, height: 25)
        dialLabel.move(x: 20, y: 160)
        widgets.append(dialLabel)

        let dial = Dial(parent: container)
        dial.move(x: 20, y: 190)
        dial.resize(width: 80, height: 80)
        dial.minimum = 0
        dial.maximum = 100
        dial.value = 50
        dial.notchesVisible = true
        dial.wrapping = false
        widgets.append(dial)

        // LCD Number display
        let lcdLabel = Label("LCD Display:", parent: container)
        lcdLabel.resize(width: 100, height: 25)
        lcdLabel.move(x: 120, y: 160)
        widgets.append(lcdLabel)

        let lcdNumber = LCDNumber(digitCount: 3, parent: container)
        lcdNumber.move(x: 120, y: 190)
        lcdNumber.resize(width: 100, height: 60)
        lcdNumber.mode = .decimal
        lcdNumber.segmentStyle = .filled
        lcdNumber.display(value: 50)
        widgets.append(lcdNumber)

        // Connect dial to LCD display
        dial.onValueChanged { value in
            lcdNumber.display(value: value)
        }

        // Image view (if available)
        let imageLabel = Label("Image:", parent: container)
        imageLabel.resize(width: 60, height: 25)
        imageLabel.move(x: 240, y: 160)
        widgets.append(imageLabel)

        let imageView = ImageView(parent: container)
        imageView.move(x: 240, y: 190)
        imageView.resize(width: 64, height: 64)
        imageView.scaledContents = true
        widgets.append(imageView)

        // For now, just show a placeholder text since Qt may not support .icns files
        // TODO: In the future, we could generate a simple PNG image or use a cross-platform image format
        imageView.text = "📁"
        imageView.alignment = Qt.Alignment.center

        // Reset button
        let resetButton = Button("Reset All Values", parent: container)
        resetButton.move(x: 20, y: 290)
        resetButton.resize(width: 120, height: 30)
        resetButton.onClicked {
            hSlider.value = 50
            progressBar.value = 50
            vSlider.value = 5
            dial.value = 50
            lcdNumber.display(value: 50)
            scrollView.scrollToTop()
        }
        widgets.append(resetButton)

        widgets.forEach { $0.show() }
    }

    func cleanup() {
        widgets.forEach { $0.hide() }
        widgets.removeAll()
    }
}

/// Mixed widgets demonstration
@MainActor
class MixedWidgetsDemo: ComponentDemo {
    var title: String { "Mixed Components" }
    private var widgets: [any QtWidget] = []

    func setupDemo(in container: Widget) {
        let title = Label("Mixed Components Demo", parent: container)
        title.alignment = Qt.Alignment.center
        title.resize(width: 560, height: 40)
        title.move(x: 20, y: 20)
        widgets.append(title)

        // User registration form
        let formGroup = GroupBox("User Registration", parent: container)
        formGroup.resize(width: 540, height: 280)
        formGroup.move(x: 20, y: 70)
        widgets.append(formGroup)

        // Name field
        let nameLabel = Label("Full Name:", parent: formGroup)
        nameLabel.resize(width: 100, height: 25)
        nameLabel.move(x: 20, y: 30)
        widgets.append(nameLabel)

        let nameEdit = LineEdit("", parent: formGroup)
        nameEdit.placeholderText = "John Doe"
        nameEdit.resize(width: 180, height: 25)
        nameEdit.move(x: 130, y: 30)
        widgets.append(nameEdit)

        // Email field
        let emailLabel = Label("Email:", parent: formGroup)
        emailLabel.resize(width: 100, height: 25)
        emailLabel.move(x: 20, y: 65)
        widgets.append(emailLabel)

        let emailEdit = LineEdit("", parent: formGroup)
        emailEdit.placeholderText = "john@example.com"
        emailEdit.resize(width: 180, height: 25)
        emailEdit.move(x: 130, y: 65)
        widgets.append(emailEdit)

        // Account type
        let typeLabel = Label("Account Type:", parent: formGroup)
        typeLabel.resize(width: 100, height: 25)
        typeLabel.move(x: 20, y: 100)
        widgets.append(typeLabel)

        let typeCombo = ComboBox(items: ["Free", "Premium", "Business"], parent: formGroup)
        typeCombo.resize(width: 180, height: 25)
        typeCombo.move(x: 130, y: 100)
        widgets.append(typeCombo)

        // Preferences
        let newsCheck = CheckBox("Subscribe to newsletter", parent: formGroup)
        newsCheck.resize(width: 200, height: 25)
        newsCheck.move(x: 20, y: 140)
        widgets.append(newsCheck)

        let termsCheck = CheckBox("I agree to terms and conditions", parent: formGroup)
        termsCheck.resize(width: 250, height: 25)
        termsCheck.move(x: 20, y: 170)
        widgets.append(termsCheck)

        // Gender selection
        let genderLabel = Label("Gender:", parent: formGroup)
        genderLabel.resize(width: 100, height: 25)
        genderLabel.move(x: 340, y: 30)
        widgets.append(genderLabel)

        let maleRadio = RadioButton("Male", parent: formGroup)
        maleRadio.resize(width: 100, height: 25)
        maleRadio.move(x: 340, y: 60)
        widgets.append(maleRadio)

        let femaleRadio = RadioButton("Female", parent: formGroup)
        femaleRadio.resize(width: 100, height: 25)
        femaleRadio.move(x: 340, y: 85)
        widgets.append(femaleRadio)

        let otherRadio = RadioButton("Other", parent: formGroup)
        otherRadio.resize(width: 100, height: 25)
        otherRadio.move(x: 340, y: 110)
        widgets.append(otherRadio)

        // Bio text area
        let bioLabel = Label("Bio:", parent: formGroup)
        bioLabel.resize(width: 100, height: 25)
        bioLabel.move(x: 20, y: 210)
        widgets.append(bioLabel)

        let bioEdit = TextEdit("Tell us about yourself...", parent: formGroup)
        bioEdit.resize(width: 400, height: 50)
        bioEdit.move(x: 130, y: 210)
        widgets.append(bioEdit)

        // Submit button
        let submitButton = Button("Register", parent: container)
        submitButton.isDefault = true
        submitButton.resize(width: 100, height: 35)
        submitButton.move(x: 380, y: 360)
        widgets.append(submitButton)

        let cancelButton = Button("Cancel", parent: container)
        cancelButton.resize(width: 100, height: 35)
        cancelButton.move(x: 270, y: 360)
        widgets.append(cancelButton)

        widgets.forEach { $0.show() }
    }

    func cleanup() {
        widgets.forEach { $0.hide() }
        widgets.removeAll()
    }
}

/// Date and Time widgets demonstration
@MainActor
class DateTimeDemo: ComponentDemo {
    var title: String { "Date & Time Widgets" }
    private var widgets: [any QtWidget] = []

    func setupDemo(in container: Widget) {
        let title = Label("Date & Time Widgets Demo", parent: container)
        title.alignment = Qt.Alignment.center
        title.resize(width: 560, height: 40)
        title.move(x: 20, y: 10)
        widgets.append(title)

        // DateEdit widget
        let dateEditLabel = Label("Date Edit:", parent: container)
        dateEditLabel.resize(width: 100, height: 25)
        dateEditLabel.move(x: 20, y: 60)
        widgets.append(dateEditLabel)

        let dateEdit = DateEdit(parent: container)
        dateEdit.move(x: 130, y: 60)
        dateEdit.resize(width: 150, height: 30)
        dateEdit.date = Date()
        dateEdit.displayFormat = "yyyy-MM-dd"
        dateEdit.calendarPopup = true
        widgets.append(dateEdit)

        // TimeEdit widget
        let timeEditLabel = Label("Time Edit:", parent: container)
        timeEditLabel.resize(width: 100, height: 25)
        timeEditLabel.move(x: 300, y: 60)
        widgets.append(timeEditLabel)

        let timeEdit = TimeEdit(parent: container)
        timeEdit.move(x: 410, y: 60)
        timeEdit.resize(width: 150, height: 30)
        timeEdit.time = Date()
        timeEdit.displayFormat = "HH:mm:ss"
        widgets.append(timeEdit)

        // DateTimeEdit widget
        let dateTimeEditLabel = Label("DateTime Edit:", parent: container)
        dateTimeEditLabel.resize(width: 100, height: 25)
        dateTimeEditLabel.move(x: 20, y: 110)
        widgets.append(dateTimeEditLabel)

        let dateTimeEdit = DateTimeEdit(parent: container)
        dateTimeEdit.move(x: 130, y: 110)
        dateTimeEdit.resize(width: 250, height: 30)
        dateTimeEdit.dateTime = Date()
        dateTimeEdit.displayFormat = "yyyy-MM-dd HH:mm:ss"
        dateTimeEdit.calendarPopup = true
        widgets.append(dateTimeEdit)

        // Calendar widget
        let calendarLabel = Label("Calendar Widget:", parent: container)
        calendarLabel.resize(width: 150, height: 25)
        calendarLabel.move(x: 20, y: 160)
        widgets.append(calendarLabel)

        let calendar = CalendarWidget(parent: container)
        calendar.move(x: 20, y: 190)
        calendar.resize(width: 300, height: 200)
        calendar.selectedDate = Date()
        calendar.gridVisible = true
        calendar.firstDayOfWeek = .monday
        widgets.append(calendar)

        // Selection display label
        let selectionLabel = Label(
            "Selected: "
                + DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none),
            parent: container)
        selectionLabel.resize(width: 220, height: 25)
        selectionLabel.move(x: 340, y: 190)
        widgets.append(selectionLabel)

        // Connect calendar to selection label
        calendar.onDateSelected { date in
            selectionLabel.text =
                "Selected: "
                + DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        }

        // Date range configuration
        let rangeLabel = Label("Date Range Settings:", parent: container)
        rangeLabel.resize(width: 150, height: 25)
        rangeLabel.move(x: 340, y: 230)
        widgets.append(rangeLabel)

        // Set minimum date to one year ago
        let oneYearAgo = Calendar.current.date(byAdding: .year, value: -1, to: Date()) ?? Date()
        dateEdit.minimumDate = oneYearAgo
        dateTimeEdit.minimumDateTime = oneYearAgo
        calendar.minimumDate = oneYearAgo

        // Set maximum date to one year from now
        let oneYearFromNow = Calendar.current.date(byAdding: .year, value: 1, to: Date()) ?? Date()
        dateEdit.maximumDate = oneYearFromNow
        dateTimeEdit.maximumDateTime = oneYearFromNow
        calendar.maximumDate = oneYearFromNow

        let minDateLabel = Label(
            "Min: "
                + DateFormatter.localizedString(
                    from: oneYearAgo, dateStyle: .short, timeStyle: .none), parent: container)
        minDateLabel.resize(width: 220, height: 25)
        minDateLabel.move(x: 340, y: 260)
        widgets.append(minDateLabel)

        let maxDateLabel = Label(
            "Max: "
                + DateFormatter.localizedString(
                    from: oneYearFromNow, dateStyle: .short, timeStyle: .none), parent: container)
        maxDateLabel.resize(width: 220, height: 25)
        maxDateLabel.move(x: 340, y: 290)
        widgets.append(maxDateLabel)

        // Reset button
        let resetButton = Button("Reset to Today", parent: container)
        resetButton.move(x: 340, y: 330)
        resetButton.resize(width: 120, height: 30)
        resetButton.onClicked {
            let now = Date()
            dateEdit.date = now
            timeEdit.time = now
            dateTimeEdit.dateTime = now
            calendar.selectedDate = now
        }
        widgets.append(resetButton)

        widgets.forEach { $0.show() }
    }

    func cleanup() {
        widgets.forEach { $0.hide() }
        widgets.removeAll()
    }
}
