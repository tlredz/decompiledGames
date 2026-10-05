local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local lab2rgb = require(script.Parent.Parent:WaitForChild("lab"):WaitForChild("lab2rgb"))
local lch2lab = require(script.Parent:WaitForChild("lch2lab"))

local function lch2rgb(...)
	local v = unpack(table.pack(...), "lch")
	local v2, v3, v4 = table.unpack(v, 1, 3)
	local v5, v6, v7 = table.unpack(lch2lab(v2, v3, v4), 1, 3)
	local v8, v9, v10 = table.unpack(lab2rgb(v5, v6, v7), 1, 3)
	return {
		v8,
		v9,
		v10,
		not (#v > 3) and 1 or v[4]
	}
end

return lch2rgb