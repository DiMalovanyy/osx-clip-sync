#include "OsxClipboard.hpp"

namespace {
}

OsxClipboard::OsxClipboard(boost::asio::io_context::strand& strand): strand_(strand) {
    if (OSStatus status = PasteboardCreate(kPasteboardClipboard, pasteboard_.get()); status != noErr) {
        throw std::runtime_error(std::to_string(status));
    }
}

void OsxClipboard::AsyncPoll() {

}

OSStatus OsxClipboard::fetchFromClipboard() {
    OSStatus status = noErr;
    
    PasteboardSynchronize(*pasteboard_);
    
    ItemCount itemCount;
    if(status = PasteboardGetItemCount(*pasteboard_, &itemCount); status != noErr) {
        return status;
    }

    PasteboardItemID itemID;
    if (status = PasteboardGetItemIdentifier(*pasteboard_, 1, &itemID); status != noErr) {
        return status;
    }

    CFDataRef itemData = NULL;
    if (status = PasteboardCopyItemFlavorData(*pasteboard_, itemID, CFSTR("public.utf8-plain-text"), &itemData); status != noErr) {
        return status;
    }
    CFStringRef pasteboardString = NULL;
    pasteboardString = CFStringCreateWithBytes(NULL, CFDataGetBytePtr(itemData), CFDataGetLength(itemData), kCFStringEncodingUTF8, false);
    if (!pasteboardString) {
        return -1;
    }

    char buffer[256];
    CFStringGetCString(pasteboardString, buffer, sizeof(buffer), kCFStringEncodingUTF8);
    std::string data(buffer);
    CFRelease(pasteboardString);
    if (data_ != data) {
        data_ = data;
        if (onDataChangedCb_) {
            onDataChangedCb_(data_.value());
        }
    }
    return status;
}

