#pragma once

#ifdef __cplusplus
extern "C" {
#endif

typedef void *QtAppRef;
typedef void *QtWindowRef;
typedef void *QtLabelRef;
typedef void *QtLayoutRef;
typedef void *QtButtonRef;
typedef void *QtLineEditRef;
typedef void *QtCheckBoxRef;

typedef void (*ButtonCallback)(void *context);
typedef void (*WindowCloseCallback)(void *context);

QtAppRef qtAppCreate(int argc, char **argv);
int qtAppRun(QtAppRef app);
void qtAppDelete(QtAppRef app);

QtWindowRef qtWindowCreate(void);
void qtWindowShow(QtWindowRef w);
void qtWindowHide(QtWindowRef w);
void qtWindowSetTitle(QtWindowRef w, const char *title);
void qtWindowSetGeometry(QtWindowRef w, int x, int y, int width, int height);
void qtWindowDelete(QtWindowRef w);
QtWindowRef qtWindowCreateWithCloseCallback(WindowCloseCallback callback,
                                            void *context);

QtLabelRef qtLabelCreate(const char *text, QtWindowRef parent);
void qtLabelSetText(QtLabelRef label, const char *text);
void qtLabelSetGeometry(QtLabelRef label, int x, int y, int w, int h);
void qtLabelDelete(QtLabelRef label);

QtButtonRef qtButtonCreate(const char *text, QtWindowRef parent);
void qtButtonSetText(QtButtonRef button, const char *text);
void qtButtonSetGeometry(QtButtonRef button, int x, int y, int w, int h);
void qtButtonDelete(QtButtonRef button);
QtButtonRef qtButtonCreateWithCallback(const char *text, QtWindowRef parent,
                                       ButtonCallback callback, void *context);
void qtButtonRemoveCallback(QtButtonRef button);

QtLayoutRef qtVBoxLayoutCreate(QtWindowRef parent);
QtLayoutRef qtHBoxLayoutCreate(QtWindowRef parent);
void qtLayoutAddWidget(QtLayoutRef layout, void *widget);
void qtLayoutAddLayout(QtLayoutRef parent, QtLayoutRef child);
void qtWindowSetLayout(QtWindowRef window, QtLayoutRef layout);
void qtLayoutDelete(QtLayoutRef layout);
int qtLayoutCount(QtLayoutRef layout);
void *qtLayoutTakeAt(QtLayoutRef layout, int index);

QtLineEditRef qtLineEditCreate(const char *placeholder, QtWindowRef parent);
void qtLineEditSetText(QtLineEditRef lineEdit, const char *text);
const char *qtLineEditGetText(QtLineEditRef lineEdit);
void qtLineEditSetEditingFinishedCallback(QtLineEditRef lineEdit,
                                          ButtonCallback callback,
                                          void *context);

QtCheckBoxRef qtCheckBoxCreate(const char *text, QtWindowRef parent);
void qtCheckBoxSetChecked(QtCheckBoxRef checkBox, int checked);
int qtCheckBoxIsChecked(QtCheckBoxRef checkBox);
void qtCheckBoxSetText(QtCheckBoxRef checkBox, const char *text);
void qtCheckBoxSetToggledCallback(QtCheckBoxRef checkBox,
                                  ButtonCallback callback, void *context);

#ifdef __cplusplus
}
#endif
