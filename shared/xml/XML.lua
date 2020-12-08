XML = class()

function XML:__init()

end

-- From https://github.com/blattersturm/cfx-object-loader
local function parseMapEditorXml(xml)
	local a = {}

	for _,obj in ipairs(xml.Objects[1].MapObject) do
		if obj.Type[1] == 'Prop' then
			table.insert(a, {
				pos = vector3(tonumber(obj.Position[1].X[1]), tonumber(obj.Position[1].Y[1]), tonumber(obj.Position[1].Z[1])),
				rot = vector3(tonumber(obj.Rotation[1].X[1]), tonumber(obj.Rotation[1].Y[1]), tonumber(obj.Rotation[1].Z[1])),
				hash = tonumber(obj.Hash[1])
			})
		end
	end

	return a
end

-- From https://github.com/blattersturm/cfx-object-loader
local function processXml(el)
	local v = {}
	local text

	for _,kid in ipairs(el.kids) do
		if kid.type == 'text' then
			text = kid.value
		elseif kid.type == 'element' then
			if not v[kid.name] then
				v[kid.name] = {}
			end

			table.insert(v[kid.name], processXml(kid))
		end
	end

	v._ = el.attr

	if #el.attr == 0 and #el.el == 0 then
		v = text
	end

	return v
end

function XML:Parse(filename)
    
    local data = LoadResourceFile(GetCurrentResourceName(), filename)
	local xml = SLAXML:dom(data)

	if xml and xml.root then
		Citizen.Trace("parsed as xml\n")

		if xml.root.name == 'Map' then
			return parseMapEditorXml(processXml(xml.root))
		end
	else
		return {}
    end
    
end

XML = XML()