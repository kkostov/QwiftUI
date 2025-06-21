import CQtWrapper
import Foundation

// MARK: - Todo Model
@MainActor
final class TodoListModel {
    private(set) var items: [String] = []
    func add(_ item: String) { items.append(item) }
    func remove(at index: Int) { items.remove(at: index) }
}

// MARK: - Qt UI Abstractions
@MainActor
final class QtTextField {
    let widget: QtLabelRef // Simulate with label for now
    var text: String = "" {
        didSet { qtLabelSetText(widget, text) }
    }
    init(parent: QtWindowRef) {
        widget = qtLabelCreate("", parent)
    }
}

@MainActor
final class QtButton {
    let widget: QtButtonRef
    init(title: String, parent: QtWindowRef, action: @escaping () -> Void) {
        let callback: @convention(c) (UnsafeMutableRawPointer?) -> Void = { context in
            guard let context else { return }
            let box = Unmanaged<CallbackBox>.fromOpaque(context).takeUnretainedValue()
            box.action()
        }
        let box = CallbackBox(action)
        widget = qtButtonCreateWithCallback(title, parent, callback, Unmanaged.passUnretained(box).toOpaque())
    }
    private final class CallbackBox {
        let action: () -> Void
        init(_ action: @escaping () -> Void) { self.action = action }
    }
}

@MainActor
final class QtTodoListView {
    let layout: QtLayoutRef
    private var rowLayouts: [QtLayoutRef] = []
    private var itemLabels: [QtLabelRef] = []
    private var removeButtons: [QtButtonRef] = []
    private let parent: QtWindowRef
    private let onRemove: (Int) -> Void
    init(parent: QtWindowRef, onRemove: @escaping (Int) -> Void) {
        self.parent = parent
        self.onRemove = onRemove
        layout = qtVBoxLayoutCreate(parent)
    }
    func update(items: [String]) {
        // Remove old widgets from layout
        for row in rowLayouts {
            qtLayoutDelete(row)
        }
        rowLayouts.removeAll()
        itemLabels.removeAll()
        removeButtons.removeAll()
        // Add new widgets
        for (i, item) in items.enumerated() {
            guard let rowLayout = qtHBoxLayoutCreate(parent),
                  let label = qtLabelCreate(item, parent) else { continue }
            qtLayoutAddWidget(rowLayout, label)
            let removeBtn = QtButton(title: "Remove", parent: parent) { [weak self] in self?.onRemove(i) }.widget
            qtLayoutAddWidget(rowLayout, removeBtn)
            qtLayoutAddWidget(layout, rowLayout)
            rowLayouts.append(rowLayout)
            itemLabels.append(label)
            removeButtons.append(removeBtn)
        }
    }
}

// MARK: - App Backend Implementation
@MainActor
final class QtTodoApp {
    private var argc = Int32(CommandLine.argc)
    private let argv = UnsafeMutablePointer(mutating: CommandLine.unsafeArgv)
    private let qtApp: QtAppRef
    private let mainWindow: QtWindowRef
    private let mainLayout: QtLayoutRef
    private let todoList = TodoListModel()
    private let inputField: QtTextField
    private lazy var addButton: QtButton = {
        QtButton(title: "Add", parent: mainWindow) { [weak self] in self?.addTodo() }
    }()
    private lazy var todoListView: QtTodoListView = {
        QtTodoListView(parent: mainWindow) { [weak self] index in self?.removeTodo(at: index) }
    }()

    init() {
        qtApp = qtAppCreate(argc, argv)
        mainWindow = qtWindowCreate()
        qtWindowSetTitle(mainWindow, "Swift Qt Todo App")
        qtWindowSetGeometry(mainWindow, 100, 100, 400, 400)
        mainLayout = qtVBoxLayoutCreate(mainWindow)
        qtWindowSetLayout(mainWindow, mainLayout)
        inputField = QtTextField(parent: mainWindow)
        qtLayoutAddWidget(mainLayout, inputField.widget)
        qtLayoutAddWidget(mainLayout, addButton.widget)
        qtLayoutAddWidget(mainLayout, todoListView.layout)
        updateListView()
    }
    private func addTodo() {
        let text = inputField.text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        todoList.add(text)
        inputField.text = ""
        updateListView()
    }
    private func removeTodo(at index: Int) {
        todoList.remove(at: index)
        updateListView()
    }
    private func updateListView() {
        todoListView.update(items: todoList.items)
    }
    func run() {
        qtWindowShow(mainWindow)
        _ = qtAppRun(qtApp)
    }
}
