// ABOUTME: ImageView provides a widget for displaying images
// ABOUTME: This wraps Qt's QLabel with pixmap support for image display

import Foundation
import QtBridge

/// An image view widget for displaying images.
///
/// ImageView provides a widget that can display images from files or data.
/// It supports various image formats including PNG, JPEG, GIF, BMP, and more.
///
/// ## Example Usage
///
/// ```swift
/// let imageView = ImageView()
/// imageView.loadImage(from: "/path/to/image.png")
/// imageView.scaledContents = true
/// ```
@MainActor
public class ImageView: Label {
    /// How the image should be scaled
    public enum ScaleMode {
        case none           // No scaling
        case fitToWidget    // Scale to fit widget size
        case keepAspectRatio // Scale keeping aspect ratio
        case keepAspectRatioExpanding // Scale keeping aspect ratio, may expand beyond widget
    }
    
    /// Whether the image should be scaled to fill the widget
    public var scaledContents: Bool = false {
        didSet {
            qtLabel.pointee.setScaledContents(scaledContents)
        }
    }
    
    /// The current scale mode
    public var scaleMode: ScaleMode = .none {
        didSet {
            updateScaling()
        }
    }
    
    /// The path to the currently loaded image
    private(set) public var imagePath: String?
    
    /// Creates a new image view
    ///
    /// - Parameter parent: The parent widget. If nil, creates a top-level image view.
    public init(parent: (any QtWidget)? = nil) {
        super.init("", parent: parent)
        setupImageView()
    }
    
    /// Creates an image view with an initial image
    ///
    /// - Parameters:
    ///   - imagePath: Path to the image file to load
    ///   - parent: The parent widget
    public init(imagePath: String, parent: (any QtWidget)? = nil) {
        super.init(parent: parent)
        setupImageView()
        loadImage(from: imagePath)
    }
    
    private func setupImageView() {
        // Configure the label for image display
        // In Qt, images are displayed using QLabel with QPixmap
        alignment = Qt.Alignment.center
    }
    
    /// Loads an image from a file path
    ///
    /// - Parameter path: The path to the image file
    /// - Returns: True if the image was loaded successfully
    @discardableResult
    public func loadImage(from path: String) -> Bool {
        imagePath = path
        let success = qtLabel.pointee.setPixmap(std.string(path))
        if success {
            updateScaling()
        } else {
            // If loading failed, set placeholder text if any
            if !text.isEmpty {
                qtLabel.pointee.setText(std.string(text))
            }
        }
        return success
    }
    
    /// Loads an image from data
    ///
    /// - Parameter data: The image data
    /// - Returns: True if the image was loaded successfully
    @discardableResult
    public func loadImage(from data: Data) -> Bool {
        // TODO: Implement QPixmap loading from data in QtBridge
        // This would involve:
        // 1. Creating QPixmap from QByteArray
        // 2. Setting it on the QLabel
        return false
    }
    
    /// Clears the displayed image
    public func clearImage() {
        imagePath = nil
        qtLabel.pointee.clearPixmap()
    }
    
    /// Sets a placeholder text to show when no image is loaded
    ///
    /// - Parameter placeholder: The placeholder text
    public func setPlaceholder(_ placeholder: String) {
        if imagePath == nil {
            text = placeholder
        }
    }
    
    private func updateScaling() {
        switch scaleMode {
        case .none:
            scaledContents = false
        case .fitToWidget:
            scaledContents = true
        case .keepAspectRatio:
            // Qt's setScaledContents doesn't preserve aspect ratio
            // Would need custom implementation
            scaledContents = true
        case .keepAspectRatioExpanding:
            // Would need custom implementation
            scaledContents = true
        }
    }
    
    /// Gets the original size of the loaded image
    ///
    /// - Returns: The original image size, or nil if no image is loaded
    public var imageSize: (width: Int, height: Int)? {
        // TODO: Get QPixmap size from QtBridge
        return nil
    }
    
    /// Sets the maximum size for the displayed image
    ///
    /// - Parameters:
    ///   - width: Maximum width in pixels
    ///   - height: Maximum height in pixels
    public func setMaximumImageSize(width: Int, height: Int) {
        // TODO: Implement maximum size constraint for pixmap
    }
}