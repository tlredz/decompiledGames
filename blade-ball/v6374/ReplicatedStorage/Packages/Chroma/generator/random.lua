local Color = require(script.Parent.Parent:WaitForChild("Color"))
local v = string.split("0123456789abcdef", "")

local function random()
	local v2 = table.create(6, "")

	for i = 1, 6 do
		v2[i] = v[math.random(1, 16)]
	end

	return Color.new(`#{table.concat(v2, "")}`, "hex")
end

return random