import CQtWrapper
import Foundation
fileprivate typealias QtAppRef = UnsafeMutableRawPointer?
fileprivate typealias QtWindowRef = UnsafeMutableRawPointer?
fileprivate typealias QtLabelRef = UnsafeMutableRawPointer?
fileprivate typealias QtLayoutRef = UnsafeMutableRawPointer?
fileprivate typealias QtButtonRef = UnsafeMutableRawPointer?
fileprivate typealias QtLineEditRef = UnsafeMutableRawPointer?
fileprivate typealias QtCheckBoxRef = UnsafeMutableRawPointer?
fileprivate typealias CButtonCallback = @convention(c) (UnsafeMutableRawPointer?) -> Void
@_silgen_name("qtLineEditCreate")
fileprivate func qtLineEditCreate(_ placeholder: UnsafePointer<CChar>?, _ parent: QtWindowRef) -> QtLineEditRef
@_silgen_name("qtLineEditSetText")
fileprivate func qtLineEditSetText(_ lineEdit: QtLineEditRef, _ text: UnsafePointer<CChar>?)
@_silgen_name("qtLineEditGetText")
fileprivate func qtLineEditGetText(_ lineEdit: QtLineEditRef) -> UnsafePointer<CChar>?
@_silgen_name("qtLineEditSetEditingFinishedCallback")
fileprivate func qtLineEditSetEditingFinishedCallback(_ lineEdit: QtLineEditRef, _ callback: CButtonCallback?, _ context: UnsafeMutableRawPointer?)
@_silgen_name("qtCheckBoxCreate")
fileprivate func qtCheckBoxCreate(_ text: UnsafePointer<CChar>?, _ parent: QtWindowRef) -> QtCheckBoxRef
@_silgen_name("qtCheckBoxSetChecked")
fileprivate func qtCheckBoxSetChecked(_ checkBox: QtCheckBoxRef, _ checked: Int32)
@_silgen_name("qtCheckBoxIsChecked")
fileprivate func qtCheckBoxIsChecked(_ checkBox: QtCheckBoxRef) -> Int32
@_silgen_name("qtCheckBoxSetText")
fileprivate func qtCheckBoxSetText(_ checkBox: QtCheckBoxRef, _ text: UnsafePointer<CChar>?)
@_silgen_name("qtCheckBoxSetToggledCallback")
fileprivate func qtCheckBoxSetToggledCallback(_ checkBox: QtCheckBoxRef, _ callback: CButtonCallback?, _ context: UnsafeMutableRawPointer?)
struct Todo {
    var text: String
    var completed: Bool
}
@MainActor
final class TodoList {
    private(set) var items: [Todo] = []
    func add(_ item: String) { items.append(Todo(text: item, completed: false)) }
    func toggleCompleted(at index: Int) {
        guard items.indices.contains(index) else { return }
        items[index].completed.toggle()
    }
    func setCompleted(_ completed: Bool, at index: Int) {
        guard items.indices.contains(index) else { return }
        items[index].completed = completed
    }
    func remove(at index: Int) { items.remove(at: index) }
}
@MainActor
final class TodoDemoApp {
    private var argc = Int32(CommandLine.argc)
    private let argv = UnsafeMutablePointer(mutating: CommandLine.unsafeArgv)
    private let qtApp: QtAppRef
    private let mainWindow: QtWindowRef
    private let mainLayout: QtLayoutRef
    private let todoList = TodoList()
    private let inputLabel: QtLabelRef
    private var inputField: QtLineEditRef!
    private var todosLayout: QtLayoutRef!
    private var addButton: QtButtonRef!
    private var simulateButton: QtButtonRef!
    private let demoInputs = ["Buy milk", "Read book", "Write Swift Qt wrapper"]
    private var demoInputIndex = 0
    private lazy var selfPtr: UnsafeMutableRawPointer = {
        Unmanaged.passUnretained(self).toOpaque()
    }()
    private var todoCheckBoxes: [QtCheckBoxRef] = []
    init() {
        qtApp = qtAppCreate(argc, argv)
        mainWindow = qtWindowCreate()
        qtWindowSetTitle(mainWindow, "Swift Qt6 Todo App")
        qtWindowSetGeometry(mainWindow, 100, 100, 400, 500)
        mainLayout = qtVBoxLayoutCreate(mainWindow)
        qtWindowSetLayout(mainWindow, mainLayout)
        inputLabel = qtLabelCreate("Things to do today:", mainWindow)
        qtLayoutAddWidget(mainLayout, inputLabel)
        todosLayout = qtVBoxLayoutCreate(nil)
        qtLayoutAddLayout(mainLayout, todosLayout)
        inputField = qtLineEditCreate("Enter a todo...", mainWindow)
        addButton = qtButtonCreateWithCallback("Add", mainWindow, TodoDemoApp.addButtonThunk, selfPtr)
        simulateButton = qtButtonCreateWithCallback("Simulate Input", mainWindow, TodoDemoApp.simulateButtonThunk, selfPtr)
        qtLineEditSetEditingFinishedCallback(inputField, TodoDemoApp.inputEditingFinishedThunk, selfPtr)
        qtLayoutAddWidget(mainLayout, inputField)
        qtLayoutAddWidget(mainLayout, addButton)
        qtLayoutAddWidget(mainLayout, simulateButton)
        updateTodosUI()
    }
    private static let addButtonThunk: CButtonCallback = { context in
        guard let context else { return }
        let app = Unmanaged<TodoDemoApp>.fromOpaque(context).takeUnretainedValue()
        Task { @MainActor in app.handleAddButton() }
    }
    private static let simulateButtonThunk: CButtonCallback = { context in
        guard let context else { return }
        let app = Unmanaged<TodoDemoApp>.fromOpaque(context).takeUnretainedValue()
        Task { @MainActor in app.simulateInput() }
    }
    private static let inputEditingFinishedThunk: CButtonCallback = { context in
        guard let context else { return }
        let app = Unmanaged<TodoDemoApp>.fromOpaque(context).takeUnretainedValue()
        Task { @MainActor in app.handleAddButton() }
    }
    private static let checkBoxToggledThunk: CButtonCallback = { context in
        guard let context else { return }
        let boxInfoPtr = context.assumingMemoryBound(to: CheckBoxContext.self)
        let boxInfo = boxInfoPtr.pointee
        let index = boxInfo.index
        let app = Unmanaged<TodoDemoApp>.fromOpaque(boxInfo.appPtr).takeUnretainedValue()
        Task { @MainActor in app.handleCheckBoxToggled(index: index) }
    }
    private struct CheckBoxContext {
        let appPtr: UnsafeMutableRawPointer
        let index: Int
    }
    private func handleAddButton() {
        guard let cstr = qtLineEditGetText(inputField), let text = String(validatingCString: cstr), !text.isEmpty else { return }
        todoList.add(text)
        qtLineEditSetText(inputField, "")
        updateTodosUI()
    }
    private func simulateInput() {
        if demoInputIndex < demoInputs.count {
            let text = demoInputs[demoInputIndex]
            qtLineEditSetText(inputField, text)
            demoInputIndex += 1
        }
    }
    private func handleCheckBoxToggled(index: Int) {
        guard index < todoList.items.count, index < todoCheckBoxes.count else { return }
        let checked = qtCheckBoxIsChecked(todoCheckBoxes[index]) != 0
        todoList.setCompleted(checked, at: index)
    }
    private func updateTodosUI() {
        while let layout = todosLayout, let itemCount = getLayoutCount(layout), itemCount > 0 {
            removeFirstLayoutItem(layout)
        }
        todoCheckBoxes.removeAll()
        for (i, todo) in todoList.items.enumerated() {
            let checkBox = qtCheckBoxCreate(todo.text, mainWindow)
            qtCheckBoxSetChecked(checkBox, todo.completed ? 1 : 0)
            let ctx = UnsafeMutablePointer<CheckBoxContext>.allocate(capacity: 1)
            ctx.initialize(to: CheckBoxContext(appPtr: selfPtr, index: i))
            qtCheckBoxSetToggledCallback(checkBox, TodoDemoApp.checkBoxToggledThunk, UnsafeMutableRawPointer(ctx))
            qtLayoutAddWidget(todosLayout, checkBox)
            todoCheckBoxes.append(checkBox)
        }
    }
    func run() {
        qtWindowShow(mainWindow)
        _ = qtAppRun(qtApp)
    }
}
@_silgen_name("qtLayoutCount")
fileprivate func qtLayoutCount(_ layout: QtLayoutRef) -> Int32
@_silgen_name("qtLayoutTakeAt")
fileprivate func qtLayoutTakeAt(_ layout: QtLayoutRef, _ index: Int32) -> UnsafeMutableRawPointer?
fileprivate func getLayoutCount(_ layout: QtLayoutRef) -> Int32? {
    qtLayoutCount(layout)
}
fileprivate func removeFirstLayoutItem(_ layout: QtLayoutRef) {
    _ = qtLayoutTakeAt(layout, 0)
}
let app = TodoDemoApp()
app.run()
