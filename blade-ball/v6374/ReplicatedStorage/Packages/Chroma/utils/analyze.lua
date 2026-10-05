local collections = require(script.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("collections"))
local number = require(script.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("number"))
local object = collections.Object
local log = math.log
local pow = math.pow
local floor = math.floor
local abs = math.abs
local limits

local function analyze(items, p: string?)
	local result = {
		min = 1.7976931348623157e308,
		max = -1.7976931348623157e308,
		sum = 0,
		values = {},
		count = 0
	}

	if type((next(items))) == "string" then
		items = object.values(items)
	end

	for _, item in items do
		if p ~= nil and p ~= "" and type(item) == "table" and type((next(item))) == "string" then
			item = item[p]
		end

		if item == nil or number.isNaN(item) then
			continue
		end

		table.insert(result.values, item)
		result.sum += item

		if item < result.min then
			result.min = item
		end

		if result.max < item then
			result.max = item
		end

		result.count += 1
	end

	result.domain = { result.min, result.max }

	function result.limits(p2, p3)
		return limits(result, p2, p3)
	end

	return result
end

limits = function(result, p: string?, p2: number?)
	local v = p == nil and "equal" or p
	local v2 = p2 == nil and 7 or p2

	if result.count == nil then
		result = analyze(result)
	end

	local min = result.min
	local max = result.max
	table.sort(result.values)
	local values = result.values

	if v2 == 1 then
		return { min, max }
	end

	local result2 = {}
	local v3 = string.sub(v, 1, 1)

	if v3 == "c" then
		table.insert(result2, min)
		table.insert(result2, max)
	end

	if v3 == "e" then
		table.insert(result2, min)
		local v4 = 1

		while v4 < v2 do
			table.insert(result2, min + v4 / v2 * (max - min))
			v4 += 1
		end

		table.insert(result2, max)
		return result2
	elseif v3 == "l" then
		if min <= 0 then
			error("Logarithmic scales are only possible for values > 0")
		end

		local v4 = log(min) * 0.4342944819032518
		local v5 = log(max) * 0.4342944819032518
		table.insert(result2, min)
		local v6 = 1

		while v6 < v2 do
			local v7 = v4 + v6 / v2 * (v5 - v4)
			table.insert(result2, (pow(10, v7)))
			v6 += 1
		end

		table.insert(result2, max)
		return result2
	else
		if v3 == "q" then
			table.insert(result2, min)

			for i = 1, v2 - 1 do
				local v4 = (#values - 1) * i / v2
				local v5 = floor(v4)

				if v5 == v4 then
					table.insert(result2, values[v5 + 1])
				else
					local v6 = v4 - v5
					table.insert(result2, values[v5 + 1] * (1 - v6) + values[v5 + 1 + 1] * v6)
				end
			end

			table.insert(result2, max)
		elseif v3 == "k" then
			local count = #values
			local v4 = table.create(count)
			local v5 = table.create(v2)
			local v6 = {}
			table.insert(v6, min)
			local flag = true
			local count2 = 0

			for i = 1, v2 - 1 do
				table.insert(v6, min + i / v2 * (max - min))
			end

			table.insert(v6, max)

			while flag do
				for i = 1, v2 do
					v5[i] = 0
				end

				for i = 1, count do
					local value = values[i]
					local v7 = 1.7976931348623157e308
					local v8 = nil

					for i2 = 1, v2 do
						local v10 = abs(v6[i2] - value)

						if v10 < v7 then
							v7 = v10
							v8 = i2
						end

						v5[v8] += 1
						v4[i] = v8
					end
				end

				local v7 = table.create(v2)

				for i = 1, count do
					local v8 = v4[i]

					if v7[v8] == nil then
						v7[v8] = values[i]
					else
						v7[v8] += values[i]
					end
				end

				for i = 1, v2 do
					v7[i] *= 1 / v5[i]
				end

				flag = false

				for i = 1, v2 do
					if v7[i] == v6[i] then
						continue
					end

					flag = true
					break
				end

				count2 += 1

				if count2 > 200 then
					flag = false
				end

				v6 = v7
			end

			local v7 = {}

			for i = 1, v2 do
				v7[i] = {}
			end

			for i = 1, count do
				table.insert(v7[v4[i]], values[i])
			end

			local v8 = {}

			for i = 1, v2 do
				table.insert(v8, v7[i][1])
				table.insert(v8, v7[i][#v7[i]])
			end

			table.sort(v8)
			table.insert(result2, v8[1])

			for i = 1, #v8, 2 do
				local v9 = v8[i]

				if number.isNaN(v9) or table.find(result2, v9) ~= nil then
					continue
				end

				table.insert(result2, v9)
			end
		end

		return result2
	end
end

return {
	analyze = analyze,
	limits = limits
}