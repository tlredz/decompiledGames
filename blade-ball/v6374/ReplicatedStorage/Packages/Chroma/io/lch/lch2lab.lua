local number = require(script.Parent.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("number"))
local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local DEG2RAD = utils.DEG2RAD
local sin = math.sin
local cos = math.cos

local function lch2lab(...)
	local v, v2, v3 = table.unpack(unpack(table.pack(...), "lch"), 1, 3)
	local v4 = (number.isNaN(v3) and 0 or v3) * DEG2RAD
	return { v, cos(v4) * v2, sin(v4) * v2 }
end

return lch2lab