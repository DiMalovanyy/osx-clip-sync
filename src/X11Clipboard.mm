#include "X11Clipboard.hpp"
#include <X11/Xlib.h>
#include <X11/Xatom.h>
#include <X11/extensions/Xfixes.h>

X11Clipboard::X11Clipboard(boost::asio::io_context::strand& strand): strand_(strand) {

}

void X11Clipboard::AsyncPoll() {

}

void X11Clipboard::SetData(const std::string& newData) {

}
