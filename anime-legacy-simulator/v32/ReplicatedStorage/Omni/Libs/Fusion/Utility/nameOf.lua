local parent = script.Parent.Parent
local nicknames = require(parent.Utility.nicknames)

local function nameOf(data, p: string)
	local nickname = nicknames[data]

	if typeof(nickname) == "string" then
		return nickname
	end

	if typeof(data) ~= "table" then
		return p
	end

	if typeof(data.name) == "string" then
		return data.name
	end

	if typeof(data.kind) == "string" then
		return data.kind
	end

	if typeof(data.type) == "string" then
		return data.type
	end

	return p
end

return nameOf