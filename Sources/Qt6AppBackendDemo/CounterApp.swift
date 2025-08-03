// ABOUTME: Demo application showcasing Qt6AppBackend with SwiftCrossUI
// ABOUTME: Implements a simple counter example using the Qt6 backend

import Qt6AppBackend
import SwiftCrossUI

@main
struct CounterApp: App {
    @State var count = 0
    
    typealias Backend = Qt6AppBackend.QtBackend
    
    var backend: Backend {
        print("CounterApp: Creating Qt6AppBackend...")
        let backend = Backend()
        print("CounterApp: Qt6AppBackend created successfully")
        return backend
    }
    
    var body: some Scene {
        print("CounterApp: Creating scene...")
        return WindowGroup("Qt6 Counter Example: \(count)") {
            HStack(spacing: 20) {
                Button("-") {
                    print("CounterApp: Decrement button clicked")
                    count -= 1
                }
                Text("Count: \(count)")
                    .font(.system(size: 18))
                Button("+") {
                    print("CounterApp: Increment button clicked")
                    count += 1
                }
            }
            .padding()
        }
        .defaultSize(width: 400, height: 200)
    }
}