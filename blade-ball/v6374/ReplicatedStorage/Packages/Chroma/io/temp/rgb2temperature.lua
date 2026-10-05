local temperature2rgb = require(script.Parent:WaitForChild("temperature2rgb"))
local utils = require(script.Parent.Parent.Parent:WaitForChild("utils"))
local unpack = utils.unpack
local round = math.round

local function rgb2temperature(...)
	local v = unpack(table.pack(...), "rgb")
	local v2 = v[1]
	local v3 = v[3]
	local v4 = 40000
	local v5 = 1000
	local v6 = nil

	while v4 - v5 > 0.4 do
		v6 = (v4 + v5) * 0.5
		local v7 = temperature2rgb(v6)
		local v8 = v7[3] / v7[1]

		if v3 / v2 <= v8 then
			v4 = v6
		else
			v5 = v6
		end
	end

	return (round(v6))
end

return rgb2temperature