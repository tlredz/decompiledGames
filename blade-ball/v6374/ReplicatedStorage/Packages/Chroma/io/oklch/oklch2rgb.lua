local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local lch2lab = require(script.Parent.Parent:WaitForChild("lch"):WaitForChild("lch2lab"))
local oklab2rgb = require(script.Parent.Parent:WaitForChild("oklab"):WaitForChild("oklab2rgb"))

local function oklch2rgb(...)
	local v = unpack(table.pack(...), "lch")
	local v5 = lch2lab(v[1], v[2], v[3])
	local v9 = oklab2rgb(v5[1], v5[2], v5[3])
	return {
		v9[1],
		v9[2],
		v9[3],
		not (#v > 3) and 1 or v[4]
	}
end

return oklch2rgb