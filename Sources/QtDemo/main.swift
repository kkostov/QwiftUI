import QtBridge
import QwiftUI

// Create Qt application
print("Creating Qt application...")
let app = SimpleApp()
print("Qt application created")

// Create main window using the beautiful Swift API
let window = Widget()
window.setWindowTitle("QwiftUI - Qt6 but safe 🚀")
window.resize(width: 600, height: 400)

// Create labels with different alignments to showcase the API
let titleLabel = Label("Welcome to QwiftUI", parent: window)
    .configure(text: "Welcome to QwiftUI", alignment: .center)
titleLabel.resize(width: 580, height: 60)
titleLabel.move(x: 10, y: 20)

// Create a multi-line centered label
let descriptionLabel = Label(
    """
    Experiments with Swift, Qt6 and Swift 6.2's C++ Interoperability.
    No manual C headers were written for this demo.
    """, parent: window)
descriptionLabel.alignment = .center
descriptionLabel.resize(width: 580, height: 80)
descriptionLabel.move(x: 10, y: 100)

// Create labels with different alignments
let leftLabel = Label("Left aligned text", parent: window)
leftLabel.alignment = .left
leftLabel.resize(width: 180, height: 40)
leftLabel.move(x: 10, y: 200)

// Use the convenient centered factory method
let centerLabel = Label.centered("Centered text", parent: window)
centerLabel.resize(width: 180, height: 40)
centerLabel.move(x: 210, y: 200)

// Right-aligned label
let rightLabel = Label("Right aligned text", parent: window)
rightLabel.alignment = .right
rightLabel.resize(width: 180, height: 40)
rightLabel.move(x: 410, y: 200)

// Bottom labels using convenience alignment properties
let bottomLeftLabel = Label("Bottom-Left", parent: window)
bottomLeftLabel.alignment = .bottomLeft  // Using convenience property
bottomLeftLabel.resize(width: 180, height: 60)
bottomLeftLabel.move(x: 10, y: 260)

let bottomCenterLabel = Label("Bottom-Center", parent: window)
bottomCenterLabel.alignment = .bottomCenter  // Using convenience property
bottomCenterLabel.resize(width: 180, height: 60)
bottomCenterLabel.move(x: 210, y: 260)

let bottomRightLabel = Label(42, parent: window)  // Using the generic initializer
bottomRightLabel.text = "Answer: 42"  // Update text after creation
bottomRightLabel.alignment = .bottomRight  // Using convenience property
bottomRightLabel.resize(width: 180, height: 60)
bottomRightLabel.move(x: 410, y: 260)

// Show the window
window.show()

// Run the application
print("Running Qt application...")
_ = app.exec()
