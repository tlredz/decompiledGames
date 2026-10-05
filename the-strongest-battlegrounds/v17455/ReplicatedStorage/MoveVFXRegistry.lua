local list = {
	{
		Id = "ufw_punch",
		Name = "UFW Punch",
		ReplicationType = "UfwFinalPunch",
		EventCategory = "Effects",
		Duration = 0.3,
		Tags = "move vfx ufw punch repfire"
	}
}
local byId = {}

for _, v3 in ipairs(list) do
	if not (type(v3) == "table" and type(v3.Id) == "string" and v3.Id ~= "") then
		continue
	end

	byId[v3.Id] = v3
end

local function shallowCopy(items)
	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	return result
end

local MoveVFXRegistry = {
	List = list,
	ById = byId,
	getById = function(value: string)
		if type(value) == "string" then
			return byId[value]
		end

		return nil
	end,
	list = function()
		return list
	end
}

function MoveVFXRegistry.buildPayload(p: string, char)
	local v3 = MoveVFXRegistry.getById(p)

	if not v3 then
		return nil
	end

	local result = {
		Type = v3.ReplicationType,
		Char = char,
		Already = {}
	}

	if type(v3.Payload) == "table" then
		for k, v4 in pairs(v3.Payload) do
			if type(v4) == "table" then
				local v5 = {}

				for k2, v6 in pairs(v4) do
					v5[k2] = v6
				end

				result[k] = v5
			else
				result[k] = v4
			end
		end
	end

	if result.Already == nil then
		result.Already = {}
	end

	return result
end

return MoveVFXRegistry