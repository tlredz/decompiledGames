local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack

local function rgb2num(...)
	local v, v2, v3 = table.unpack(unpack(table.pack(...), "rgb"), 1, 3)
	return bit32.lshift(v, 16) + bit32.lshift(v2, 8) + v3
end

return rgb2num