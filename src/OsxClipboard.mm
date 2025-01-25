#include "OsxClipboard.hpp"
#include <iostream>

OsxClipboard::OsxClipboard(boost::asio::io_context::strand& strand, std::chrono::duration<long long> pollTime):
    strand_(strand), 
    pasteboard_(new PasteboardRef),
    pollTimer_(strand.context(), pollTime) {
    if (OSStatus status = PasteboardCreate(kPasteboardClipboard, pasteboard_.get()); status != noErr) {
        throw std::runtime_error(std::to_string(status));
    }
}

void OsxClipboard::AsyncPoll() {
    pollTimer_.async_wait([this](const boost::system::error_code& error) {
        if (error) {
            std::cout << "OSX clipboard poll timer error: " << error.to_string() << std::endl;
            return;
        }
        if (OSStatus status = fetchFromClipboard(); status != noErr) {
            std::cout << "OSX clipboard failed to fetch data: " << std::to_string(status) << std::endl;
            return;
        }
        AsyncPoll();
    });
}

void OsxClipboard::SetData(const std::string& newData) {


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
        std::cout << "OSX clipboard data changed: " << data_.value() << std::endl;
        if (onDataChangedCb_) {
            onDataChangedCb_(data_.value());
        }
    }
    return status;
}

