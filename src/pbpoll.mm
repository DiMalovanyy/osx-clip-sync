#include <ApplicationServices/ApplicationServices.h>
#include <CoreFoundation/CoreFoundation.h>
#include <iostream>


class OsxClipboard final {
public:

private:
    char buffer[256];
};

OSStatus clipboardGet() {
    CFStringRef pasteboardString = NULL;
    OSStatus status = noErr;
    
    // Open the pasteboard
    PasteboardRef pasteboard;
    if (status = PasteboardCreate(kPasteboardClipboard, &pasteboard); status != noErr) {
        return status;
    }
    PasteboardSynchronize(pasteboard);
    
    ItemCount itemCount;
    if(status = PasteboardGetItemCount(pasteboard, &itemCount); status != noErr) {
        return status;
    }
    std::cout << "Item count: " << itemCount << std::endl;

    PasteboardItemID itemID;
    if (status = PasteboardGetItemIdentifier(pasteboard, 1, &itemID); status != noErr) {
        return status;
    }

    CFDataRef itemData = NULL;
    if (status = PasteboardCopyItemFlavorData(pasteboard, itemID, CFSTR("public.utf8-plain-text"), &itemData); status != noErr) {
        return status;
    }
    pasteboardString = CFStringCreateWithBytes(NULL, CFDataGetBytePtr(itemData), CFDataGetLength(itemData), kCFStringEncodingUTF8, false);
    if (!pasteboardString) {
        return -1;
    }

    char buffer[256];
    CFStringGetCString(pasteboardString, buffer, sizeof(buffer), kCFStringEncodingUTF8);
    printf("Clipboard Data: %s\n", buffer);
    CFRelease(pasteboardString);

    CFRelease(pasteboard);
    return status;
}

int main() {
    OSStatus status = clipboardGet();
    std::cout << status << std::endl;

    // Set up a timer to poll for clipboard changes
    /*
    CFRunLoopTimerContext context = {0};
    CFRunLoopTimerRef timer = CFRunLoopTimerCreate(NULL, CFAbsoluteTimeGetCurrent() + 1.0, 1.0, 0, 0, clipboardChanged, &context);

    // Add the timer to the run loop to check periodically
    CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, kCFRunLoopCommonModes);
    
    // Start the run loop
    CFRunLoopRun();
    */
    
    return 0;
}
