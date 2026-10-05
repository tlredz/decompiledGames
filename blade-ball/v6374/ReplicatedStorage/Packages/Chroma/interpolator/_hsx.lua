local collections = require(script.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("collections"))
local number = require(script.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("number"))
local array = collections.Array
local Color = require(script.Parent.Parent:WaitForChild("Color"))

local function _hsx(object, object2, p: number, value: string)
	local reversed = nil
	local reversed2 = nil

	if value == "hsl" then
		reversed = object:hsl()
		reversed2 = object2:hsl()
	elseif value == "hsv" then
		reversed = object:hsv()
		reversed2 = object2:hsv()
	elseif value == "hcg" then
		reversed = object:hcg()
		reversed2 = object2:hcg()
	elseif value == "hsi" then
		reversed = object:hsi()
		reversed2 = object2:hsi()
	elseif value == "lch" or value == "hcl" then
		reversed = object:hcl()
		reversed2 = object2:hcl()
		value = "hcl"
	elseif value == "oklch" then
		reversed = array.reverse(object:oklch())
		reversed2 = array.reverse(object2:oklch())
	end

	local v, v2, v3, naN, v4, v5

	if string.sub(value, 1, 1) == "h" or value == "oklch" then
		v, v2, v3 = table.unpack(reversed, 1, 3)
		naN, v4, v5 = table.unpack(reversed2, 1, 3)
	end

	local v6 = nil

	if number.isNaN(v) or number.isNaN(naN) then
		if number.isNaN(v) then
			if number.isNaN(naN) then
				naN = number.NaN
			elseif (v3 == 1 or v3 == 0) and value ~= "hsv" then
				v6 = v4
			end
		elseif v5 == 1 or v5 == 0 then
			if value == "hsv" then
				naN = v
			else
				naN = v
				v6 = v2
			end
		else
			naN = v
		end
	else
		local v7

		if v < naN and naN - v > 180 then
			v7 = naN - (v + 360)
		elseif naN < v and v - naN > 180 then
			v7 = naN + 360 - v
		else
			v7 = naN - v
		end

		naN = v + p * v7
	end

	if v6 == nil then
		v6 = v2 + p * (v4 - v2)
	end

	local v7 = v3 + p * (v5 - v3)

	if value == "oklch" then
		return (Color.new({ v7, v6, naN }, "oklch"))
	end

	return (Color.new({ naN, v6, v7 }, value))
end

return _hsx