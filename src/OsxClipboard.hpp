#ifndef OSX_CLIPBOARD_HPP
#define OSX_CLIPBOARD_HPP

#include "IClipboard.hpp"

#include <boost/asio.hpp>
#include <CoreFoundation/CoreFoundation.h>
#include <ApplicationServices/ApplicationServices.h>

struct CFDeleter {
    void operator()(CFTypeRef obj) const {
        if (obj) {
            CFRelease(obj);
        }
    }
};

class OsxClipboard final: public IClipboard {
public:
    OsxClipboard(boost::asio::io_context::strand& strand, std::chrono::duration<long long> pollTime = std::chrono::seconds(1));

    void SetData(const std::string& newData) override;
    void AsyncPoll() override;

private:
    OSStatus fetchFromClipboard();

    boost::asio::io_context::strand& strand_;
    std::optional<std::string> data_;
    
    std::unique_ptr<PasteboardRef, CFDeleter> pasteboard_;
    boost::asio::steady_timer pollTimer_;
};


#endif
