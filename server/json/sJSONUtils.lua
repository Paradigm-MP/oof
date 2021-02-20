JsonUtils = class()

function JsonUtils:LoadJSON(path)
    local contents = LoadResourceFile(GetCurrentResourceName(), path)
    if not contents then return end
    return json.decode(contents)
end

function JsonUtils:SaveJSON(data, path)
    SaveResourceFile(GetCurrentResourceName(), path, json.encode(data, {indent = true}), -1)
    return true
end

JsonUtils = JsonUtils()