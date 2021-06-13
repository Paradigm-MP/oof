local _error = error
function error(...)
    return _error(debug.traceback(...))
end