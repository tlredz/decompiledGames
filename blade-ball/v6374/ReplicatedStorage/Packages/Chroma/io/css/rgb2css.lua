local hsl2css = require(script.Parent:WaitForChild("hsl2css"))
local roundroblox = require(script.Parent.Parent.Parent:WaitForChild("utils"):WaitForChild("round.roblox"))
local rgb2hsl = require(script.Parent.Parent:WaitForChild("hsl"):WaitForChild("rgb2hsl"))
local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local last = utils.last

local function rgb2css(...)
	local v = unpack(table.pack(...), "rgba")
	local v2 = last(...)
	local v3 = (v2 == nil or v2 == "") and "rgb" or v2

	if string.sub(v3, 1, 3) == "hsl" then
		return hsl2css(rgb2hsl(v), v3)
	end

	local v4 = { tostring(roundroblox(v[1])), tostring(roundroblox(v[2])), (tostring(roundroblox(v[3]))) }

	if v3 == "rgba" or #v > 3 and v[4] < 1 then
		v4[4] = tostring(not (#v > 3) and 1 or v[4])
		v3 = "rgba"
	end

	return (`{v3}({table.concat(v4, ",")})`)
end

return rgb2css