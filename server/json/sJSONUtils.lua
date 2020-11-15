JsonUtils = class()

function JsonUtils:LoadJSON(path)
    return json.decode(LoadResourceFile(GetCurrentResourceName(), path))
end

function JsonUtils:SaveJSON(data, path)
    SaveResourceFile(GetCurrentResourceName(), path, json.encode(data, {indent = true}), -1)
    return true
end

JsonUtils = JsonUtils()