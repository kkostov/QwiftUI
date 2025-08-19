// ABOUTME: Tests for new widgets: Slider, ProgressBar, ScrollView, ImageView
// ABOUTME: Verifies that the C++ bridge implementation works correctly

import Testing
@testable import QwiftUI
import Foundation

@Suite("New Widgets Tests")
struct NewWidgetsTests {
    
    @Test("Slider creation and value manipulation")
    func testSlider() {
        let slider = Slider()
        
        // Test default values
        #expect(slider.minimum == 0)
        #expect(slider.maximum == 100)
        #expect(slider.value == 0)
        
        // Test setting values
        slider.value = 50
        #expect(slider.value == 50)
        
        slider.minimum = -100
        slider.maximum = 200
        #expect(slider.minimum == -100)
        #expect(slider.maximum == 200)
        
        // Test orientation
        slider.orientation = .vertical
        #expect(slider.orientation == .vertical)
        
        // Test tick settings
        slider.tickPosition = .ticksBothSides
        slider.tickInterval = 10
        #expect(slider.tickInterval == 10)
        
        // Test step settings
        slider.singleStep = 5
        slider.pageStep = 20
        #expect(slider.singleStep == 5)
        #expect(slider.pageStep == 20)
    }
    
    @Test("ProgressBar creation and configuration")
    func testProgressBar() {
        let progressBar = ProgressBar()
        
        // Test default values
        #expect(progressBar.minimum == 0)
        #expect(progressBar.maximum == 100)
        #expect(progressBar.value == 0)
        
        // Test setting values
        progressBar.value = 75
        #expect(progressBar.value == 75)
        
        // Test text visibility
        progressBar.showText = false
        #expect(progressBar.showText == false)
        
        // Test format string
        progressBar.format = "Loading: %p%"
        #expect(progressBar.format == "Loading: %p%")
        
        // Test busy mode
        progressBar.isBusy = true
        #expect(progressBar.isBusy == true)
        #expect(progressBar.minimum == 0)
        #expect(progressBar.maximum == 0)
        
        // Reset from busy mode
        progressBar.isBusy = false
        #expect(progressBar.minimum == 0)
        #expect(progressBar.maximum == 100)
        
        // Test reset
        progressBar.value = 50
        progressBar.reset()
        #expect(progressBar.value == progressBar.minimum)
    }
    
    @Test("ScrollView creation and content management")
    func testScrollView() {
        let scrollView = ScrollView()
        
        // Test default policies
        #expect(scrollView.horizontalScrollBarPolicy == .asNeeded)
        #expect(scrollView.verticalScrollBarPolicy == .asNeeded)
        #expect(scrollView.widgetResizable == true)
        
        // Test scroll bar policies
        scrollView.horizontalScrollBarPolicy = .alwaysOn
        scrollView.verticalScrollBarPolicy = .alwaysOff
        #expect(scrollView.horizontalScrollBarPolicy == .alwaysOn)
        #expect(scrollView.verticalScrollBarPolicy == .alwaysOff)
        
        // Test content management
        let content = Widget()
        scrollView.setContent(content)
        #expect(scrollView.content != nil)
        
        // Test clearing content
        scrollView.clearContent()
        #expect(scrollView.content == nil)
        
        // Test scroll position methods
        scrollView.scrollToTop()
        scrollView.scrollToBottom()
        scrollView.scrollToLeft()
        scrollView.scrollToRight()
        
        // Test ensure visible
        scrollView.ensureVisible(x: 100, y: 100, width: 50, height: 50)
    }
    
    @Test("ImageView creation and image loading")
    func testImageView() {
        let imageView = ImageView()
        
        // Test that it's a subclass of Label
        #expect(imageView is Label)
        
        // Test scaled contents property
        imageView.scaledContents = true
        #expect(imageView.scaledContents == true)
        
        // Test scale mode
        imageView.scaleMode = .fitToWidget
        #expect(imageView.scaleMode == .fitToWidget)
        
        // Test placeholder
        imageView.setPlaceholder("No image")
        
        // Test clearing image
        imageView.clearImage()
        #expect(imageView.imagePath == nil)
        
        // Test setting maximum size
        imageView.setMaximumImageSize(width: 256, height: 256)
    }
    
    @Test("Widget event handlers")
    func testEventHandlers() {
        let slider = Slider()
        
        var valueChangedCalled = false
        var pressedCalled = false
        var releasedCalled = false
        var movedCalled = false
        
        // Set up event handlers
        slider.onValueChanged { value in
            valueChangedCalled = true
        }
        
        slider.onSliderPressed {
            pressedCalled = true
        }
        
        slider.onSliderReleased {
            releasedCalled = true
        }
        
        slider.onSliderMoved { value in
            movedCalled = true
        }
        
        // Note: We can't easily trigger these events in a unit test
        // without running the Qt event loop, but we can verify that
        // the handlers are set without crashing
        #expect(valueChangedCalled == false) // Not triggered without event loop
    }
}