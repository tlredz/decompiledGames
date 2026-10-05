local luauregexp = require(script.Parent.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("luau-regexp"))
local v = luauregexp("^#?([A-Fa-f0-9]{6}|[A-Fa-f0-9]{3})$")
local v2 = luauregexp("^#?([A-Fa-f0-9]{8}|[A-Fa-f0-9]{4})$")

local function hex2rgb(value: string)
	local count = #value

	if v:test(value) then
		if count == 4 or count == 7 then
			value = string.sub(value, 2)
			count = #value
		end

		if count == 3 then
			local v3 = string.split(value, "")
			value = v3[1] .. v3[1] .. v3[2] .. v3[2] .. v3[3] .. v3[3]
		end

		local v3 = tonumber(value, 16)
		return {
			bit32.arshift(v3, 16),
			bit32.band(bit32.arshift(v3, 8), 255),
			bit32.band(v3, 255),
			1
		}
	else
		if not v2:test(value) then
			error((`unknown hex color: {value}`))
			return
		end

		if count == 5 or count == 9 then
			value = string.sub(value, 2)
			count = #value
		end

		if count == 4 then
			local v3 = string.split(value, "")
			value = v3[1] .. v3[1] .. v3[2] .. v3[2] .. v3[3] .. v3[3] .. v3[4] .. v3[4]
		end

		local v3 = tonumber(value, 16)
		return {
			bit32.band(bit32.arshift(v3, 24), 255),
			bit32.band(bit32.arshift(v3, 16), 255),
			bit32.band(bit32.arshift(v3, 8), 255),
			math.round(bit32.band(v3, 255) / 255 * 100) / 100
		}
	end
end

return hex2rgb