local createVector = vector.create
local module = require("../../utils/interpolate")
local module2 = require("../../../../../tests/test")
local v = {
	{ 0, 1, 0.5 },
	{ createVector(0, 0, 0), createVector(1, 1, 1), createVector(0.5, 0.5, 0.5) },
	{
		{ 0, 0, 0 },
		{ 1, 1, 1 },
		{ 0.5, 0.5, 0.5 }
	}
}

if game then
	table.insert(v, { Color3.new(), Color3.new(1, 1, 1) })
	table.insert(v, { UDim2.new(0, 0, 0, 0), UDim2.new(1, 100, 1, 100), UDim2.new(0.5, 50, 0.5, 50) })
	table.insert(v, { UDim.new(0, 0), UDim.new(1, 100), UDim.new(0.5, 50) })
	table.insert(v, { Rect.new(0, 0, 0, 0), Rect.new(100, 100, 200, 200), Rect.new(50, 50, 100, 100) })
	table.insert(v, { CFrame.new(0, 0, 0), CFrame.new(10, 10, 10), CFrame.new(5, 5, 5) })
end

for _, list in v do
	local v2, v3, v4 = unpack(list)
	module2(`should return correct type for {typeof(v2)}`, function()
		local v7 = module(v2, v3, 0.5)
		assert(typeof(v7) == typeof(v2), (`Expected type {typeof(v2)}, got {typeof(v7)}`))
	end)

	if not v4 then
		continue
	end

	local v7 = v2
	local v8 = v3
	local v9 = v4
	module2(`should return correct midpoint for {typeof(v2)}`, function()
		local v10 = module(v7, v8, 0.5)

		if type(v10) ~= "table" then
			assert(v10 == v9, (`Expected {v9}, got {v10}`))
			return
		end

		for k, v11 in v9 do
			assert(v10[k] == v11, (`Expected {v11} at index {k}, got {v10[k]}`))
		end
	end)
end

module2("should return original table if nothing changed", function()
	local v2 = { 1 }
	assert(module(v2, { 2 }, 0) == v2, "Expected the same table for step 0")
	assert(module(v2, { 1 }, 1) == v2, "Expected the same table for step to same value")
end)
return {}