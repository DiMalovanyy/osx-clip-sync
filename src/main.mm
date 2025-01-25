#include "OsxClipboard.hpp"

#include <iostream>

int main() {
    boost::asio::io_context ctx;
    boost::asio::io_context::strand strand(ctx);

    OsxClipboard osxClipboard(strand);
    osxClipboard.AsyncPoll();

    ctx.run();
    std::cout << "IO context suddenly stopped" << std::endl;
    return 1;
}
