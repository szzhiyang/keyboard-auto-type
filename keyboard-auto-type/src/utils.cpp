#include "utils.h"

#include <stdexcept>

namespace keyboard_auto_type {

AutoTypeResult throw_or_return(AutoTypeResult result, [[maybe_unused]] const std::string &message) {
    if (result == AutoTypeResult::Ok) {
        return result;
    }
#if __cpp_exceptions && !defined(KEYBOARD_AUTO_TYPE_NO_EXCEPTIONS)
    switch (result) {
    case AutoTypeResult::BadArg:
        throw std::invalid_argument(message);
    default:
        throw std::runtime_error(message);
    }
#else
    return result;
#endif
}

} // namespace keyboard_auto_type
