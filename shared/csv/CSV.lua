CSV = class()

-- Parses a CSV file given a filename
-- Returns a list of entries, with each entry containing fields for each column
function CSV:Parse(filename)
    local data = LoadResourceFile(GetCurrentResourceName(), filename)

    local insert, remove = table.insert, table.remove

    if data then

        local parsed = {}
        local lines = split(data, "\n")
        local headers = {}

        for line_index, line in pairs(lines) do
            local line_split = split(line, ",")
            local line_data = {}

            for data_index, data_string in pairs(line_split) do
                data_string = trim(data_string)

                if line_index == 1 then
                    headers[data_index] = data_string
                else
                    line_data[headers[data_index]] = data_string
                end
            end

            if line_index > 1 then
                insert(parsed, line_data)
            end
        end

        return parsed

    else
        error(string.format("File %s not found in CSV parse", tostring(filename)))
    end

end

CSV = CSV()