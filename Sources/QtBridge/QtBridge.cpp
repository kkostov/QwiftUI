#include "include/QtBridge.h"
#include <QtWidgets/QApplication>
#include <QtWidgets/QWidget>
#include <QtWidgets/QLabel>
#include <QtCore/QString>

// Global QApplication instance management
static SwiftQApplication* g_appInstance = nullptr;

// SwiftQApplication implementation
void SwiftQApplication::buildArgv() {
    if (!argc) {
        argc = new int;
    }
    *argc = static_cast<int>(storedArgs.size());
    argv.clear();
    argv.reserve(*argc);
    for (auto& arg : storedArgs) {
        argv.push_back(const_cast<char*>(arg.c_str()));
    }
}

void SwiftQApplication::ensureInitialized() {
    if (!app && !QApplication::instance()) {
        // Create QApplication with reference to argc
        app = new QApplication(*argc, argv.data());
    } else if (!app && QApplication::instance()) {
        // QApplication was created elsewhere, just use it
        app = qobject_cast<QApplication*>(QApplication::instance());
    }
}

QApplication* SwiftQApplication::instance() {
    return qobject_cast<QApplication*>(QApplication::instance());
}

SwiftQApplication::SwiftQApplication() : argc(nullptr), app(nullptr) {
    // Store as global instance
    g_appInstance = this;
    
    // Default app name
    storedArgs.push_back("qt-app");
    buildArgv();
    ensureInitialized();
}

SwiftQApplication::SwiftQApplication(const ArgumentsBuilder& builder) : argc(nullptr), app(nullptr) {
    // Store as global instance
    g_appInstance = this;
    
    storedArgs = builder.getArgs();
    if (storedArgs.empty()) {
        storedArgs.push_back("qt-app");
    }
    buildArgv();
    ensureInitialized();
}

SwiftQApplication::~SwiftQApplication() {
    if (g_appInstance == this) {
        g_appInstance = nullptr;
    }
    // Don't delete the QApplication - Qt manages it as a singleton
    delete argc;
}

int SwiftQApplication::exec() {
    ensureInitialized();
    if (app) {
        return app->exec();
    } else if (QApplication::instance()) {
        return QApplication::instance()->exec();
    }
    return -1;
}

void SwiftQApplication::processEvents() {
    QApplication::processEvents();
}

// SwiftQWidget implementation
SwiftQWidget::SwiftQWidget() : widget(nullptr), ownsWidget(true), parentWidget(nullptr) {
    // Defer widget creation until QApplication exists
}

SwiftQWidget::SwiftQWidget(SwiftQWidget* parent) : widget(nullptr), ownsWidget(true), parentWidget(parent) {
    // Defer widget creation until QApplication exists
}

SwiftQWidget::SwiftQWidget(QWidget* existingWidget, bool takeOwnership)
    : widget(existingWidget), ownsWidget(takeOwnership) {
}

void SwiftQWidget::ensureWidget() {
    if (!widget && QApplication::instance()) {
        if (parentWidget) {
            widget = new QWidget(parentWidget->getQWidget());
        } else {
            widget = new QWidget(nullptr);
        }
    }
}

SwiftQWidget::~SwiftQWidget() {
    if (ownsWidget && widget && !widget->parent()) {
        delete widget;
    }
}

void SwiftQWidget::show() {
    ensureWidget();
    if (widget) {
        widget->show();
    }
}

void SwiftQWidget::hide() {
    ensureWidget();
    if (widget) {
        widget->hide();
    }
}

void SwiftQWidget::setWindowTitle(const std::string& title) {
    ensureWidget();
    if (widget) {
        widget->setWindowTitle(QString::fromStdString(title));
    }
}

void SwiftQWidget::resize(int width, int height) {
    ensureWidget();
    if (widget) {
        widget->resize(width, height);
    }
}

void SwiftQWidget::move(int x, int y) {
    ensureWidget();
    if (widget) {
        widget->move(x, y);
    }
}

QWidget* SwiftQWidget::getQWidget() {
    ensureWidget();
    return widget;
}

// SwiftQLabel implementation
void SwiftQLabel::ensureWidget() {
    if (!widget && QApplication::instance()) {
        QWidget* parentW = parentWidget ? parentWidget->getQWidget() : nullptr;
        QLabel* label = new QLabel(QString::fromStdString(labelText), parentW);
        if (labelAlignment != 0) {
            label->setAlignment(static_cast<Qt::Alignment>(labelAlignment));
        }
        // Enable word wrap for multi-line text
        label->setWordWrap(true);
        widget = label;
    }
}

SwiftQLabel::SwiftQLabel(const std::string& text) : labelText(text) {
    ownsWidget = true;
    // Defer label creation until QApplication exists
}

SwiftQLabel::SwiftQLabel(const std::string& text, SwiftQWidget* parent) : labelText(text) {
    parentWidget = parent;
    ownsWidget = true;
    // Defer label creation until QApplication exists
}

void SwiftQLabel::setText(const std::string& text) {
    labelText = text;
    ensureWidget();
    if (QLabel* label = qobject_cast<QLabel*>(widget)) {
        label->setText(QString::fromStdString(text));
    }
}

void SwiftQLabel::setAlignment(int alignment) {
    labelAlignment = alignment;
    ensureWidget();
    if (QLabel* label = qobject_cast<QLabel*>(widget)) {
        label->setAlignment(static_cast<Qt::Alignment>(alignment));
    }
}

void SwiftQLabel::setWordWrap(bool wrap) {
    ensureWidget();
    if (QLabel* label = qobject_cast<QLabel*>(widget)) {
        label->setWordWrap(wrap);
    }
}

// Factory function implementation
SwiftQWidget* createWidget(SwiftQWidget* parent) {
    return new SwiftQWidget(parent);
}

SwiftQLabel* createLabel(const std::string& text, SwiftQWidget* parent) {
    return new SwiftQLabel(text, parent);
}