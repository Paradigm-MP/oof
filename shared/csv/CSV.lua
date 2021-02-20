CSV = class()

--[[
    Parses a CSV file

    args:
        filename (string): name of the file, including the path starting after resource name
        wait_after (number, optional): after X number of lines, this will call Wait(1). Call CSV:Parse in a thread to use this
        progress_callback (function, optional): will callback with its lines processed and total lines as it processes. Good to use with wait_after


    Returns a list of entries, with each entry containing fields for each column
]]
function CSV:Parse(filename, wait_after, progress_callback)
    local data = LoadResourceFile(GetCurrentResourceName(), filename)

    local insert, remove = table.insert, table.remove

    if data then

        local parsed = {}
        local lines = split(data, "\n")
        local headers = {}
        local done = 0
        local count = count_table(lines) - 1

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
                done = done + 1
                insert(parsed, line_data)
            end

            if progress_callback then
                progress_callback(done, count)
            end
        end

        return parsed

    else
        error(string.format("File %s not found in CSV parse", tostring(filename)))
    end

end

CSV = CSV()