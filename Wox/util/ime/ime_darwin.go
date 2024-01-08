package ime

/*
#cgo CFLAGS: -x objective-c
#cgo LDFLAGS: -framework Cocoa
#include <stdlib.h>

char* getCurrentInputMethod();
void switchInputMethod(const char *inputMethodID);
*/
import "C"
import (
	"unsafe"
)

func SwitchInputMethodABC() {
	abcInputMethodID := "com.apple.keylayout.ABC"

	inputMethod := C.GoString(C.getCurrentInputMethod())
	if inputMethod == abcInputMethodID {
		return
	}

	inputMethodIDStr := C.CString(abcInputMethodID)
	defer C.free(unsafe.Pointer(inputMethodIDStr))
	C.switchInputMethod(inputMethodIDStr)
}
