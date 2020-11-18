local OgMathRandomseed = math.randomseed

local function string_to_number(str)
    local insert = table.insert
    if str:len() < 6 then
        local numeric_representations = {}
        local digits = 0
        for c in str:gmatch('.') do
            insert(numeric_representations, c:byte())
        end
        return tonumber(table.concat(numeric_representations))
    else
        local numeric_representation = 0
        for c in str:gmatch('.') do
            numeric_representation = numeric_representation + c:byte()
        end
        return numeric_representation
    end
end

function math.randomseed(x)
    local number_form = x
    if type(x) == 'string' then
        number_form = string_to_number(x)
    end

    OgMathRandomseed(number_form)
end
