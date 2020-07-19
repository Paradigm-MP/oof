JSONUtils = class()

function JSONUtils:__init()
end

function JSONUtils:LoadJSON(path)
    return json.decode(LoadResourceFile(GetCurrentResourceName(), path))
end

function JSONUtils:SaveJSON(data, path)
    SaveResourceFile(GetCurrentResourceName(), path, json.encode(data, {indent = true}), -1)
    return true
end

JSONUtils = JSONUtils()