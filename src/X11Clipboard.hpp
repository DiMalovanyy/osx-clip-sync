#ifndef X11_CLIPBOARD_HPP
#define X11_CLIPBOARD_HPP

#include "IClipboard.hpp"
#include <boost/asio.hpp>

class X11Clipboard final: public IClipboard {
public:
    X11Clipboard(boost::asio::io_context::strand& strand);

    void AsyncPoll() override;
    void SetData(const std::string& newData) override;
private:
    boost::asio::io_context::strand& strand_;

    std::thread pollThread_;
};


#endif // X11_CLIPBOARD_HPP
