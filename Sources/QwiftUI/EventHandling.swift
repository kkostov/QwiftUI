// ABOUTME: Safe event callback management system for Qt widget events
// ABOUTME: Provides heap-allocated callback storage to prevent crashes from stack deallocation

import Foundation
import QtBridge

/// Manager for safe event callback storage
/// Keeps callbacks alive on the heap to prevent crashes
/// Made thread-safe using an internal lock for access from deinit
public final class CallbackManager: Sendable {
    /// Singleton instance for global callback management
    public nonisolated static let shared: CallbackManager = CallbackManager()
    
    /// Storage for active callbacks indexed by object pointer
    nonisolated(unsafe) private let callbacks = NSMutableDictionary()
    
    /// Storage for allocated callback pointers indexed by object pointer
    nonisolated(unsafe) private let allocatedPointers = NSMutableDictionary()
    
    /// Lock for thread-safe access
    private let lock = NSLock()
    
    nonisolated init() {}
    
    /// Store a callback associated with an object
    public nonisolated func store<T>(_ callback: T, for object: AnyObject) {
        let pointer = Unmanaged.passUnretained(object).toOpaque()
        lock.lock()
        defer { lock.unlock() }
        callbacks[pointer] = callback
    }
    
    /// Store an allocated pointer for automatic cleanup
    public nonisolated func storeAllocatedPointer(_ ptr: UnsafeMutableRawPointer, for object: AnyObject) {
        let objPointer = Unmanaged.passUnretained(object).toOpaque()
        lock.lock()
        defer { lock.unlock() }
        if allocatedPointers[objPointer] == nil {
            allocatedPointers[objPointer] = NSMutableArray()
        }
        (allocatedPointers[objPointer] as? NSMutableArray)?.add(ptr)
    }
    
    /// Retrieve a callback for an object
    public nonisolated func retrieve<T>(_ type: T.Type, for object: AnyObject) -> T? {
        let pointer = Unmanaged.passUnretained(object).toOpaque()
        lock.lock()
        defer { lock.unlock() }
        return callbacks[pointer] as? T
    }
    
    /// Remove callbacks and deallocate pointers for an object
    public nonisolated func remove(for object: AnyObject) {
        let pointer = Unmanaged.passUnretained(object).toOpaque()
        lock.lock()
        defer { lock.unlock() }
        
        callbacks.removeObject(forKey: pointer)
        
        // Deallocate any stored pointers
        if let pointers = allocatedPointers[pointer] as? NSMutableArray {
            for ptr in pointers {
                if let rawPtr = ptr as? UnsafeMutableRawPointer {
                    rawPtr.deallocate()
                }
            }
            allocatedPointers.removeObject(forKey: pointer)
        }
    }
}

/// Helper to create heap-allocated callbacks
public struct CallbackHelper {
    /// Create a heap-allocated SwiftCallback
    public static func createCallback(
        context: AnyObject,
        handler: @escaping () -> Void
    ) -> UnsafeMutablePointer<SwiftCallback> {
        let callback = UnsafeMutablePointer<SwiftCallback>.allocate(capacity: 1)
        // Use passUnretained to avoid retain cycle - the widget already holds the callback
        callback.pointee.context = Unmanaged.passUnretained(context).toOpaque()
        callback.pointee.handler = { contextPtr in
            guard let contextPtr = contextPtr else { return }
            let object = Unmanaged<AnyObject>.fromOpaque(contextPtr).takeUnretainedValue()
            
            // Retrieve the stored handler
            if let storedHandler = CallbackManager.shared.retrieve((() -> Void).self, for: object) {
                storedHandler()
            }
        }
        
        // Store the handler to keep it alive
        CallbackManager.shared.store(handler, for: context)
        
        // Automatically store the allocated pointer for cleanup
        CallbackManager.shared.storeAllocatedPointer(UnsafeMutableRawPointer(callback), for: context)
        
        return callback
    }
    
    /// Create a heap-allocated SwiftCallbackInt
    public static func createCallbackInt(
        context: AnyObject,
        handler: @escaping (Int) -> Void
    ) -> UnsafeMutablePointer<SwiftCallbackInt> {
        let callback = UnsafeMutablePointer<SwiftCallbackInt>.allocate(capacity: 1)
        // Use passUnretained to avoid retain cycle - the widget already holds the callback
        callback.pointee.context = Unmanaged.passUnretained(context).toOpaque()
        callback.pointee.handler = { contextPtr, value in
            guard let contextPtr = contextPtr else { return }
            let object = Unmanaged<AnyObject>.fromOpaque(contextPtr).takeUnretainedValue()
            
            // Retrieve the stored handler
            if let storedHandler = CallbackManager.shared.retrieve(((Int) -> Void).self, for: object) {
                storedHandler(Int(value))
            }
        }
        
        // Store the handler to keep it alive
        CallbackManager.shared.store(handler, for: context)
        
        // Automatically store the allocated pointer for cleanup
        CallbackManager.shared.storeAllocatedPointer(UnsafeMutableRawPointer(callback), for: context)
        
        return callback
    }
    
    /// Create a heap-allocated SwiftCallbackString
    public static func createCallbackString(
        context: AnyObject,
        handler: @escaping (String) -> Void
    ) -> UnsafeMutablePointer<SwiftCallbackString> {
        let callback = UnsafeMutablePointer<SwiftCallbackString>.allocate(capacity: 1)
        // Use passUnretained to avoid retain cycle - the widget already holds the callback
        callback.pointee.context = Unmanaged.passUnretained(context).toOpaque()
        callback.pointee.handler = { contextPtr, textPtr in
            guard let contextPtr = contextPtr else { return }
            guard let textPtr = textPtr else { return }
            let object = Unmanaged<AnyObject>.fromOpaque(contextPtr).takeUnretainedValue()
            let text = String(cString: textPtr)
            
            // Retrieve the stored handler
            if let storedHandler = CallbackManager.shared.retrieve(((String) -> Void).self, for: object) {
                storedHandler(text)
            }
        }
        
        // Store the handler to keep it alive
        CallbackManager.shared.store(handler, for: context)
        
        // Automatically store the allocated pointer for cleanup
        CallbackManager.shared.storeAllocatedPointer(UnsafeMutableRawPointer(callback), for: context)
        
        return callback
    }
    
    /// Create a heap-allocated SwiftEventCallback
    public static func createEventCallback(
        context: AnyObject,
        handler: @escaping (QtEventInfo) -> Void
    ) -> UnsafeMutablePointer<SwiftEventCallback> {
        let callback = UnsafeMutablePointer<SwiftEventCallback>.allocate(capacity: 1)
        // Use passUnretained to avoid retain cycle - the widget already holds the callback
        callback.pointee.context = Unmanaged.passUnretained(context).toOpaque()
        callback.pointee.handler = { contextPtr, infoPtr in
            guard let contextPtr = contextPtr else { return }
            guard let infoPtr = infoPtr else { return }
            let object = Unmanaged<AnyObject>.fromOpaque(contextPtr).takeUnretainedValue()
            let info = infoPtr.pointee
            
            // Retrieve the stored handler
            if let storedHandler = CallbackManager.shared.retrieve(((QtEventInfo) -> Void).self, for: object) {
                storedHandler(info)
            }
        }
        
        // Store the handler to keep it alive
        CallbackManager.shared.store(handler, for: context)
        
        // Automatically store the allocated pointer for cleanup
        CallbackManager.shared.storeAllocatedPointer(UnsafeMutableRawPointer(callback), for: context)
        
        return callback
    }
    
    /// Free a heap-allocated callback
    public static func freeCallback<T>(_ callback: UnsafeMutablePointer<T>) {
        callback.deallocate()
    }
}

/// Base class for widgets with safe event handling
@MainActor
open class SafeEventWidget {
    public init() {
        // Required for MainActor
    }
    
    deinit {
        // CallbackManager automatically handles cleanup
        // Using Task to handle MainActor isolation from deinit
        // Note: This is safe because CallbackManager is not MainActor-isolated anymore
        CallbackManager.shared.remove(for: self)
    }
}