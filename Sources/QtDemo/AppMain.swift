// ABOUTME: Main entry point for the demo application with MainActor context
// ABOUTME: Wraps demo logic in MainActor to satisfy Swift concurrency requirements

import Foundation
import QwiftUI

@MainActor
struct AppMain {
    // Keep references to widgets at struct level to prevent deallocation
    static var app: SimpleApp?
    static var mainWindow: Widget?
    static var statusLabel: Label?
    static var navigationCombo: ComboBox?
    static var currentDemo: ComponentDemo?
    static var demoContainer: Widget?

    static func main() {
        print("Starting QwiftUI Component Gallery...")

        // Create app and store reference
        app = SimpleApp()
        guard let app = app else { return }

        // Main window
        mainWindow = Widget()
        guard let mainWindow = mainWindow else { return }
        mainWindow.setWindowTitle("QwiftUI Component Gallery 🎨")
        mainWindow.resize(width: 640, height: 500)

        // Title
        let titleLabel = Label("QwiftUI Component Gallery", parent: mainWindow)
        titleLabel.alignment = Qt.Alignment.center
        titleLabel.resize(width: 600, height: 40)
        titleLabel.move(x: 20, y: 10)

        // Navigation section
        let navLabel = Label("Select Demo:", parent: mainWindow)
        navLabel.resize(width: 100, height: 30)
        navLabel.move(x: 20, y: 60)

        navigationCombo = ComboBox(parent: mainWindow)
        guard let navigationCombo = navigationCombo else { return }
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

        // Info button with click handler
        let infoButton = Button("ℹ️ About", parent: mainWindow)
        infoButton.resize(width: 100, height: 30)
        infoButton.move(x: 390, y: 60)
        infoButton.onClicked {
            MessageBox.showAbout(
                title: "About QwiftUI",
                text: """
                    QwiftUI Component Gallery
                    Version 1.0.0

                    A Qt6 wrapper for Swift using Swift 6.2's C++ interoperability.

                    Features:
                    • Direct C++ interop (no C wrappers!)
                    • Beautiful Swift APIs
                    • Cross-platform GUI development
                    • Event handling via closures

                    Built with ❤️ using Swift and Qt6
                    """,
                parent: mainWindow
            )
        }

        // Status label
        statusLabel = Label(
            "Event handling is working! Try clicking the About button.", parent: mainWindow)
        guard let statusLabel = statusLabel else { return }
        statusLabel.alignment = Qt.Alignment.center
        statusLabel.resize(width: 600, height: 30)
        statusLabel.move(x: 20, y: 100)

        // Demo container
        demoContainer = Widget(parent: mainWindow)
        guard let demoContainer = demoContainer else { return }
        demoContainer.resize(width: 600, height: 350)
        demoContainer.move(x: 20, y: 140)

        // Wire up combo box selection change
        // Use the safer onSelectionChanged that provides both index and text
        // This avoids accessing currentText during Qt signal emission which can crash
        navigationCombo.onSelectionChanged { [weak statusLabel] index, text in
            print("ComboBox selection changed to index: \(index), text: \(text)")
            guard let statusLabel = statusLabel else {
                print("Warning: Status label reference no longer valid")
                return
            }

            // Clean up current demo
            currentDemo?.cleanup()
            currentDemo = nil

            // Demo container is cleared by individual demo cleanup
            guard let demoContainer = self.demoContainer else { return }

            // Switch to new demo
            switch index {
            case 0:
                statusLabel.text = "Welcome to QwiftUI Component Gallery!"
                showWelcomeScreen(in: demoContainer)
            case 1:
                statusLabel.text = "Labels & Alignment Demo"
                currentDemo = LabelDemo()
                currentDemo?.setupDemo(in: demoContainer)
            case 2:
                statusLabel.text = "Button Demo - Try clicking buttons!"
                currentDemo = ButtonDemo()
                currentDemo?.setupDemo(in: demoContainer)
            case 3:
                statusLabel.text = "Text Input Demo"
                currentDemo = TextInputDemo()
                currentDemo?.setupDemo(in: demoContainer)
            case 4:
                statusLabel.text = "Checkboxes & Radio Buttons Demo"
                currentDemo = CheckableDemo()
                currentDemo?.setupDemo(in: demoContainer)
            case 5:
                statusLabel.text = "ComboBox Demo - Selection events work!"
                currentDemo = ComboBoxDemo()
                currentDemo?.setupDemo(in: demoContainer)
            case 6:
                statusLabel.text =
                    "Advanced Widgets - Sliders, Progress, ScrollView, Dial, LCD, Images"
                currentDemo = AdvancedWidgetsDemo()
                currentDemo?.setupDemo(in: demoContainer)
            case 7:
                statusLabel.text = "Date & Time Widgets Demo"
                currentDemo = DateTimeDemo()
                currentDemo?.setupDemo(in: demoContainer)
            case 8:
                statusLabel.text = "Mixed Components Demo"
                currentDemo = MixedWidgetsDemo()
                currentDemo?.setupDemo(in: demoContainer)
            default:
                statusLabel.text = "Selected: \(text)"
            }
        }

        // Show welcome screen initially
        showWelcomeScreen(in: demoContainer)

        // Footer
        let footerLabel = Label(
            "QwiftUI mini Demo",
            parent: mainWindow
        )
        footerLabel.alignment = Qt.Alignment.center
        footerLabel.resize(width: 600, height: 20)
        footerLabel.move(x: 20, y: 470)

        // Show window
        mainWindow.show()

        // Run the event loop
        print("Running Qt application with event handling...")
        _ = app.exec()
        print("Demo app terminated.")
    }

    static func showWelcomeScreen(in container: Widget) {
        // Create a WelcomeDemo instance to handle cleanup properly
        let demo = WelcomeDemo()
        currentDemo = demo
        demo.setupDemo(in: container)
    }
}
