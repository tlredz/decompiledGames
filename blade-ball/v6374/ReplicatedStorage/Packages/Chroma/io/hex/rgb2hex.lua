local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local last = utils.last
local round = math.round

local function rgb2hex(...)
	local v, v2, v3, v4 = table.unpack(unpack(table.pack(...), "rgba"), 1, 4)
	local v5 = last(...)
	local v6 = (v5 == nil or v5 == "") and "auto" or v5
	local v7 = v4 == nil and 1 or v4

	if v6 == "auto" then
		v6 = v7 < 1 and "rgba" or "rgb"
	end

	local v8 = round(v)
	local v9 = round(v2)
	local v10 = round(v3)
	local v11 = bit32.bor(bit32.bor(bit32.lshift(v8, 16), (bit32.lshift(v9, 8))), v10)
	local v12 = "000000" .. string.format("%x", v11)
	local v13 = string.sub(v12, #v12 + 1 - 6)
	local v15 = "0" .. string.format("%x", (round(v7 * 255)))
	local v16 = string.sub(v15, #v15 + 1 - 2)
	local v17 = string.lower(v6)

	if v17 == "rgba" then
		return (`#{v13}{v16}`)
	elseif v17 == "argb" then
		return (`#{v16}{v13}`)
	end

	return (`#{v13}`)
end

return rgb2hex