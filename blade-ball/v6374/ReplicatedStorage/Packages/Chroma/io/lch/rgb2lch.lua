local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local lab2lch = require(script.Parent:WaitForChild("lab2lch"))
local rgb2lab = require(script.Parent.Parent:WaitForChild("lab"):WaitForChild("rgb2lab"))

local function rgb2lch(...)
	local v, v2, v3 = table.unpack(unpack(table.pack(...), "rgb"), 1, 3)
	local v4, v5, v6 = table.unpack(rgb2lab(v, v2, v3), 1, 3)
	return lab2lch(v4, v5, v6)
end

return rgb2lch