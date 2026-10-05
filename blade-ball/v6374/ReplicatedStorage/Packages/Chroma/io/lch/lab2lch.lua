local number = require(script.Parent.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("number"))
local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local RAD2DEG = utils.RAD2DEG
local sqrt = math.sqrt
local atan2 = math.atan2
local round = math.round

local function lab2lch(...)
	local v, v2, v3 = table.unpack(unpack(table.pack(...), "lab"), 1, 3)
	local v5 = sqrt(v2 * v2 + v3 * v3)
	local naN = (atan2(v3, v2) * RAD2DEG + 360) % 360

	if round(v5 * 10000) == 0 then
		naN = number.NaN
	end

	return { v, v5, naN }
end

return lab2lch