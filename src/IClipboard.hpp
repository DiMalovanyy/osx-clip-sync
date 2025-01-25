#ifndef ICLIPBOARD_H
#define ICLIPBOARD_H

#include <string>
#include <functional>

/*
class IClibpoardChangeHandler {
public:
    virtual ~IClibpoardChangeHandler() {}
    virtual void OnClipboardChanged(const std::string& newData) = 0;
};
*/

using DataChangeCbT = std::function<void(const std::string& data)>;

class IClipboard {
public:
    virtual ~IClipboard() {}
    
    virtual void AsyncPoll() = 0;
    virtual std::string GetData() const {
        if (data_.has_value()) {
            return data_.value();
        } else {
            throw std::runtime_error("Missed clipboard data");
        }
    }

    virtual void SetClipboardDataChangedCb(DataChangeCbT onDataChangedCb) {
        onDataChangedCb_ = onDataChangedCb;
    }
private:
    std::optional<std::string> data_;
protected:
    DataChangeCbT onDataChangedCb_;
};

#endif
