#include <QApplication>
#include <QCheckBox>
#include <QHBoxLayout>
#include <QLabel>
#include <QLineEdit>
#include <QPushButton>
#include <QVBoxLayout>
#include <QVariant>
#include <QWidget>
#include <cstring>
extern "C" {
using QtAppRef = void *;
using QtWindowRef = void *;
using QtLabelRef = void *;
using QtLayoutRef = void *;
using QtButtonRef = void *;
using QtLineEditRef = void *;
using QtCheckBoxRef = void *;
QtAppRef qtAppCreate(int argc, char **argv) {
  return new QApplication(argc, argv);
}
int qtAppRun(QtAppRef app) { return static_cast<QApplication *>(app)->exec(); }
void qtAppDelete(QtAppRef app) { delete static_cast<QApplication *>(app); }
QtWindowRef qtWindowCreate() { return new QWidget(); }
void qtWindowShow(QtWindowRef w) { static_cast<QWidget *>(w)->show(); }
void qtWindowHide(QtWindowRef w) { static_cast<QWidget *>(w)->hide(); }
void qtWindowSetTitle(QtWindowRef w, const char *title) {
  static_cast<QWidget *>(w)->setWindowTitle(title);
}
void qtWindowSetGeometry(QtWindowRef w, int x, int y, int width, int height) {
  static_cast<QWidget *>(w)->setGeometry(x, y, width, height);
}
void qtWindowDelete(QtWindowRef w) { delete static_cast<QWidget *>(w); }
QtLabelRef qtLabelCreate(const char *text, QtWindowRef parent) {
  return new QLabel(text, static_cast<QWidget *>(parent));
}
void qtLabelSetText(QtLabelRef label, const char *text) {
  static_cast<QLabel *>(label)->setText(text);
}
void qtLabelSetGeometry(QtLabelRef label, int x, int y, int w, int h) {
  static_cast<QLabel *>(label)->setGeometry(x, y, w, h);
}
void qtLabelDelete(QtLabelRef label) { delete static_cast<QLabel *>(label); }
QtButtonRef qtButtonCreate(const char *text, QtWindowRef parent) {
  return new QPushButton(text, static_cast<QWidget *>(parent));
}
void qtButtonSetText(QtButtonRef button, const char *text) {
  static_cast<QPushButton *>(button)->setText(text);
}
void qtButtonSetGeometry(QtButtonRef button, int x, int y, int w, int h) {
  static_cast<QPushButton *>(button)->setGeometry(x, y, w, h);
}
void qtButtonDelete(QtButtonRef button) {
  delete static_cast<QPushButton *>(button);
}
QtLayoutRef qtVBoxLayoutCreate(QtWindowRef parent) {
  return new QVBoxLayout(static_cast<QWidget *>(parent));
}
QtLayoutRef qtHBoxLayoutCreate(QtWindowRef parent) {
  return new QHBoxLayout(static_cast<QWidget *>(parent));
}
void qtLayoutAddWidget(QtLayoutRef layout, void *widget) {
  static_cast<QBoxLayout *>(layout)->addWidget(static_cast<QWidget *>(widget));
}
void qtLayoutAddLayout(QtLayoutRef parent, QtLayoutRef child) {
  static_cast<QBoxLayout *>(parent)->addLayout(static_cast<QLayout *>(child));
}
void qtWindowSetLayout(QtWindowRef window, QtLayoutRef layout) {
  static_cast<QWidget *>(window)->setLayout(static_cast<QLayout *>(layout));
}
void qtLayoutDelete(QtLayoutRef layout) {
  delete static_cast<QLayout *>(layout);
}
int qtLayoutCount(QtLayoutRef layout) {
  return static_cast<QLayout *>(layout)->count();
}
void *qtLayoutTakeAt(QtLayoutRef layout, int index) {
  QLayoutItem *item = static_cast<QLayout *>(layout)->takeAt(index);
  if (!item)
    return nullptr;
  QWidget *widget = item->widget();
  if (widget)
    widget->setParent(nullptr);
  delete item;
  return widget;
}
using ButtonCallback = void (*)(void *context);
class SwiftButtonHandler : public QObject {
public:
  SwiftButtonHandler(ButtonCallback cb, void *ctx)
      : callback_(cb), context_(ctx) {}
  void onClicked() {
    if (callback_)
      callback_(context_);
  }
  ButtonCallback callback_;
  void *context_;
};
QtButtonRef qtButtonCreateWithCallback(const char *text, QtWindowRef parent,
                                       ButtonCallback callback, void *context) {
  QPushButton *button = new QPushButton(text, static_cast<QWidget *>(parent));
  SwiftButtonHandler *handler = new SwiftButtonHandler(callback, context);
  QObject::connect(button, &QPushButton::clicked, handler,
                   [handler]() { handler->onClicked(); });
  button->setProperty("swiftHandler", QVariant::fromValue((void *)handler));
  return button;
}
void qtButtonRemoveCallback(QtButtonRef button) {
  QVariant handlerVar =
      static_cast<QPushButton *>(button)->property("swiftHandler");
  if (handlerVar.isValid()) {
    SwiftButtonHandler *handler =
        static_cast<SwiftButtonHandler *>(handlerVar.value<void *>());
    delete handler;
    static_cast<QPushButton *>(button)->setProperty("swiftHandler", {});
  }
}
using WindowCloseCallback = void (*)(void *context);
class SwiftWindowHandler : public QWidget {
public:
  SwiftWindowHandler(WindowCloseCallback cb, void *ctx)
      : callback_(cb), context_(ctx) {}

protected:
  void closeEvent(QCloseEvent *event) override {
    if (callback_)
      callback_(context_);
    QWidget::closeEvent(event);
  }

private:
  WindowCloseCallback callback_;
  void *context_;
};
QtWindowRef qtWindowCreateWithCloseCallback(WindowCloseCallback callback,
                                            void *context) {
  return new SwiftWindowHandler(callback, context);
}
QtLineEditRef qtLineEditCreate(const char *placeholder, QtWindowRef parent) {
  QLineEdit *edit = new QLineEdit(static_cast<QWidget *>(parent));
  if (placeholder)
    edit->setPlaceholderText(placeholder);
  return edit;
}
void qtLineEditSetText(QtLineEditRef lineEdit, const char *text) {
  static_cast<QLineEdit *>(lineEdit)->setText(text);
}
const char *qtLineEditGetText(QtLineEditRef lineEdit) {
  static thread_local std::string result;
  result = static_cast<QLineEdit *>(lineEdit)->text().toStdString();
  return result.c_str();
}
class SwiftLineEditHandler : public QObject {
public:
  SwiftLineEditHandler(ButtonCallback cb, void *ctx)
      : callback_(cb), context_(ctx) {}
  void onEditingFinished() {
    if (callback_)
      callback_(context_);
  }
  ButtonCallback callback_;
  void *context_;
};
void qtLineEditSetEditingFinishedCallback(QtLineEditRef lineEdit,
                                          ButtonCallback callback,
                                          void *context) {
  SwiftLineEditHandler *handler = new SwiftLineEditHandler(callback, context);
  QObject::connect(static_cast<QLineEdit *>(lineEdit),
                   &QLineEdit::editingFinished, handler,
                   [handler]() { handler->onEditingFinished(); });
  static_cast<QLineEdit *>(lineEdit)->setProperty(
      "swiftHandler", QVariant::fromValue((void *)handler));
}
QtCheckBoxRef qtCheckBoxCreate(const char *text, QtWindowRef parent) {
  return new QCheckBox(text, static_cast<QWidget *>(parent));
}
void qtCheckBoxSetChecked(QtCheckBoxRef checkBox, int checked) {
  static_cast<QCheckBox *>(checkBox)->setChecked(checked);
}
int qtCheckBoxIsChecked(QtCheckBoxRef checkBox) {
  return static_cast<QCheckBox *>(checkBox)->isChecked();
}
void qtCheckBoxSetText(QtCheckBoxRef checkBox, const char *text) {
  static_cast<QCheckBox *>(checkBox)->setText(text);
}
class SwiftCheckBoxHandler : public QObject {
public:
  SwiftCheckBoxHandler(ButtonCallback cb, void *ctx)
      : callback_(cb), context_(ctx) {}
  void onToggled(bool) {
    if (callback_)
      callback_(context_);
  }
  ButtonCallback callback_;
  void *context_;
};
void qtCheckBoxSetToggledCallback(QtCheckBoxRef checkBox,
                                  ButtonCallback callback, void *context) {
  SwiftCheckBoxHandler *handler = new SwiftCheckBoxHandler(callback, context);
  QObject::connect(static_cast<QCheckBox *>(checkBox), &QCheckBox::toggled,
                   handler,
                   [handler](bool checked) { handler->onToggled(checked); });
  static_cast<QCheckBox *>(checkBox)->setProperty(
      "swiftHandler", QVariant::fromValue((void *)handler));
}
}
