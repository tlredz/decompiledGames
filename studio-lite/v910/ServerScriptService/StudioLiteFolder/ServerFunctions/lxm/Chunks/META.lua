require(script.Parent.Parent.Types)
local BasicTypes = require(script.Parent.Parent.BasicTypes)

local function META(p, p2)
	local data = p.Data

	for _ = 1, data:readNumber("<I4") do
		local string = BasicTypes.String(data)
		local string2 = BasicTypes.String(data)
		p2.Metadata[string] = string2
	end
end

return META