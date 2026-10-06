require(script.Parent.Parent.Types)
local BasicTypes = require(script.Parent.Parent.BasicTypes)

local function SSTR(object, p)
	local data = object.Data

	if data:readNumber("<I4") ~= 0 then
		object:Error("Invalid SSTR version")
	end

	for i = 1, data:readNumber("<I4") do
		data:read(16)
		p.Strings[i] = BasicTypes.String(data)
	end
end

return SSTR