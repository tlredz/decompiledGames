local number = require(script.Parent.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("number"))
local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local last = utils.last

-- equivalent calls inferred from this helper; original call sites unknown
local function rnd(p: number)
	return math.round(p * 100) / 100
end

local function hsl2css(...)
	local v = unpack(table.pack(...), "hsla")
	local v2 = last(...)
	local v3 = (v2 == nil or v2 == "") and "lsa" or v2
	local v4 = {
		tostring(rnd(number.isNaN(v[1]) and 0 or v[1])),
		tostring(rnd(v[2] * 100)) .. "%",
		tostring(rnd(v[3] * 100)) .. "%"
	}

	if v3 == "hsla" or #v > 3 and v[4] < 1 then
		v4[4] = tostring(not (#v > 3) and 1 or v[4])
		v3 = "hsla"
	end

	return (`{v3}({table.concat(v4, ",")})`)
end

return hsl2css