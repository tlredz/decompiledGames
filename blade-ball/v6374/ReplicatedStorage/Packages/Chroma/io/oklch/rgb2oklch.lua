local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local lab2lch = require(script.Parent.Parent:WaitForChild("lch"):WaitForChild("lab2lch"))
local rgb2oklab = require(script.Parent.Parent:WaitForChild("oklab"):WaitForChild("rgb2oklab"))

local function rgb2oklch(...)
	local v = unpack(table.pack(...), "rgb")
	local v5 = rgb2oklab(v[1], v[2], v[3])
	return lab2lch(v5[1], v5[2], v5[3])
end

return rgb2oklch