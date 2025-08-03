// ABOUTME: Test runner for automated QwiftUI testing with proper exit codes
// ABOUTME: Provides infrastructure for running tests and reporting results

import Foundation
import QwiftUI
import QtBridge

/// Test result tracking
public struct TestResult {
    public let name: String
    public let passed: Bool
    public let message: String?
    public let duration: TimeInterval
}

/// Simple test runner for automated QwiftUI tests
public class TestRunner {
    private var results: [TestResult] = []
    private var currentTestName: String = ""
    private var currentTestStartTime: Date = Date()
    private var failureMessages: [String] = []
    
    /// Singleton instance for global access
    public static let shared = TestRunner()
    
    private init() {}
    
    /// Start a new test
    public func startTest(_ name: String) {
        currentTestName = name
        currentTestStartTime = Date()
        failureMessages.removeAll()
        print("\n▶️ Running test: \(name)")
    }
    
    /// Record a test assertion
    public func assert(
        _ condition: Bool,
        _ message: String,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        if !condition {
            let failureMessage = "\(file):\(line) - \(message)"
            failureMessages.append(failureMessage)
            print("   ❌ Assertion failed: \(message)")
        }
    }
    
    /// Assert text equality with detailed output
    public func assertEqual<T: Equatable>(
        _ actual: T,
        _ expected: T,
        _ message: String = "",
        file: StaticString = #file,
        line: UInt = #line
    ) {
        if actual != expected {
            let failureMessage = message.isEmpty 
                ? "Expected '\(expected)' but got '\(actual)'"
                : message
            let fullMessage = "\(file):\(line) - \(failureMessage)"
            failureMessages.append(fullMessage)
            print("   ❌ \(failureMessage)")
        }
    }
    
    /// End the current test
    public func endTest() {
        let duration = Date().timeIntervalSince(currentTestStartTime)
        let passed = failureMessages.isEmpty
        
        let result = TestResult(
            name: currentTestName,
            passed: passed,
            message: failureMessages.isEmpty ? nil : failureMessages.joined(separator: "\n"),
            duration: duration
        )
        
        results.append(result)
        
        if passed {
            print(String(format: "   ✅ Test passed (%.3f seconds)", duration))
        } else {
            print(String(format: "   ❌ Test failed (%.3f seconds)", duration))
            for message in failureMessages {
                print("      • \(message)")
            }
        }
    }
    
    /// Run a test with automatic tracking
    public func test(_ name: String, _ testBlock: () throws -> Void) {
        startTest(name)
        
        do {
            try testBlock()
        } catch {
            failureMessages.append("Test threw error: \(error)")
        }
        
        endTest()
    }
    
    /// Run a test with async support
    public func testAsync(_ name: String, timeout: TimeInterval = 5.0, _ testBlock: @escaping (@escaping () -> Void) -> Void) {
        startTest(name)
        
        var completed = false
        let expectation = {
            completed = true
        }
        
        testBlock(expectation)
        
        // Wait for completion with timeout
        let timeoutMs = Int(timeout * 1000)
        var elapsed = 0
        let interval = 100
        
        while elapsed < timeoutMs && !completed {
            // Process Qt events
            if let simulator = EventSimulator() as EventSimulator? {
                simulator.processEvents(interval)
            }
            elapsed += interval
        }
        
        if !completed {
            failureMessages.append("Test timed out after \(timeout) seconds")
        }
        
        endTest()
    }
    
    /// Check if all tests passed
    public func allTestsPassed() -> Bool {
        return results.allSatisfy { $0.passed }
    }
    
    /// Print test summary without exiting
    public func printSummary() {
        let passedCount = results.filter { $0.passed }.count
        let failedCount = results.filter { !$0.passed }.count
        let totalDuration = results.reduce(0.0) { $0 + $1.duration }
        
        print("\nResults:")
        for result in results {
            let status = result.passed ? "✅ PASS" : "❌ FAIL"
            print(String(format: "  \(status): \(result.name) (%.3f s)", result.duration))
            if !result.passed, let message = result.message {
                for line in message.split(separator: "\n") {
                    print("      • \(line)")
                }
            }
        }
        
        print("\nTotal: \(results.count) tests")
        print("  Passed: \(passedCount)")
        print("  Failed: \(failedCount)")
        print(String(format: "  Duration: %.3f seconds", totalDuration))
        
        if failedCount > 0 {
            print("\n❌ TEST SUITE FAILED")
        } else {
            print("\n✅ ALL TESTS PASSED")
        }
    }
    
    /// Print final test summary and exit with appropriate code
    public func finish() -> Never {
        print("\n" + String(repeating: "=", count: 60))
        print("TEST SUMMARY")
        print(String(repeating: "=", count: 60))
        
        let passedCount = results.filter { $0.passed }.count
        let failedCount = results.filter { !$0.passed }.count
        let totalDuration = results.reduce(0.0) { $0 + $1.duration }
        
        print("\nResults:")
        for result in results {
            let status = result.passed ? "✅ PASS" : "❌ FAIL"
            print(String(format: "  \(status): \(result.name) (%.3f s)", result.duration))
        }
        
        print("\nTotal: \(results.count) tests")
        print("  Passed: \(passedCount)")
        print("  Failed: \(failedCount)")
        print(String(format: "  Duration: %.3f seconds", totalDuration))
        
        if failedCount > 0 {
            print("\n❌ TEST SUITE FAILED")
            Application.forceExit(returnCode: 1)
        } else {
            print("\n✅ ALL TESTS PASSED")
            Application.forceExit(returnCode: 0)
        }
    }
}

// MARK: - Convenience Functions

/// Run a test with automatic tracking
public func test(_ name: String, _ testBlock: () throws -> Void) {
    TestRunner.shared.test(name, testBlock)
}

/// Run an async test with automatic tracking
public func testAsync(_ name: String, timeout: TimeInterval = 5.0, _ testBlock: @escaping (@escaping () -> Void) -> Void) {
    TestRunner.shared.testAsync(name, timeout: timeout, testBlock)
}

/// Assert a condition with message
public func testAssert(_ condition: Bool, _ message: String, file: StaticString = #file, line: UInt = #line) {
    TestRunner.shared.assert(condition, message, file: file, line: line)
}

/// Assert equality with detailed output
public func testAssertEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String = "", file: StaticString = #file, line: UInt = #line) {
    TestRunner.shared.assertEqual(actual, expected, message, file: file, line: line)
}

/// Finish testing and exit with appropriate code
public func finishTesting() -> Never {
    TestRunner.shared.finish()
}