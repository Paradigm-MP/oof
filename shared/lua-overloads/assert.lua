local _assert = assert
function assert(condition, message)
    return _assert(condition, debug.traceback(tostring(message)))
end