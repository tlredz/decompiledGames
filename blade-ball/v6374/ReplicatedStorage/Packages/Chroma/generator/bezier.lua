local collections = require(script.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("collections"))
local array = collections.Array
local Color = require(script.Parent.Parent:WaitForChild("Color"))
require(script.Parent.Parent:WaitForChild("io"):WaitForChild("lab"))
local scale = require(script.Parent:WaitForChild("scale"))

local function binom_row(p: number)
	local v = { 1, 1 }

	for _ = 1, p - 1 do
		local v2 = { 1 }

		for i = 1, #v do
			v2[i + 1] = (v[i + 1] or 0) + v[i]
		end

		v = v2
	end

	return v
end

local function bezier(p)
	local I
	local mapped = array.map(p, function(p2)
		return Color.new(p2)
	end)
	local count = #mapped

	if count == 2 then
		local mapped2 = array.map(mapped, function(object)
			return object:lab()
		end)
		local v = mapped2[1]
		local v2 = mapped2[2]

		I = function(p2: number)
			local mapped3 = array.map({ 1, 2, 3 }, function(p3)
				return v[p3] + p2 * (v2[p3] - v[p3])
			end)
			return Color.new(mapped3, "lab")
		end
	elseif count == 3 then
		local mapped2 = array.map(mapped, function(object)
			return object:lab()
		end)
		local v = mapped2[1]
		local v2 = mapped2[2]
		local v3 = mapped2[3]

		I = function(p2: number)
			local mapped3 = array.map({ 1, 2, 3 }, function(p3)
				return (1 - p2) * (1 - p2) * v[p3] + (1 - p2) * 2 * p2 * v2[p3] + p2 * p2 * v3[p3]
			end)
			return Color.new(mapped3, "lab")
		end
	elseif count == 4 then
		local mapped2 = array.map(mapped, function(object)
			return object:lab()
		end)
		local v = mapped2[4]
		local v2 = mapped2[1]
		local v3 = mapped2[2]
		local v4 = mapped2[3]

		I = function(p2: number)
			local mapped3 = array.map({ 1, 2, 3 }, function(p3)
				return (1 - p2) * (1 - p2) * (1 - p2) * v2[p3] + (1 - p2) * 3 * (1 - p2) * p2 * v3[p3] + (1 - p2) * 3 * p2 * p2 * v4[p3] + p2 * p2 * p2 * v[p3]
			end)
			return Color.new(mapped3, "lab")
		end
	elseif count >= 5 then
		local mapped2 = array.map(mapped, function(object)
			return object:lab()
		end)
		local v = count - 1
		local v2 = binom_row(v)

		I = function(p2: number)
			local v3 = 1 - p2
			local mapped3 = array.map({ 1, 2, 3 }, function(p3)
				return array.reduce(mapped2, function(p4: number, p5, p6: number)
					return p4 + v2[p6] * v3 ^ (v - (p6 - 1)) * p2 ^ (p6 - 1) * p5[p3]
				end, 0)
			end)
			return Color.new(mapped3, "lab")
		end
	else
		error("No point in running bezier with only one color.")
	end

	return I
end

return function(p)
	local v = bezier(p)
	local object = setmetatable({}, {
		__call = function(_, p2: number)
			return v(p2)
		end
	})

	function object.scale()
		return scale(object)
	end

	return object
end