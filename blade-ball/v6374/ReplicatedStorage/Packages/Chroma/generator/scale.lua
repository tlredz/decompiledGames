local collections = require(script.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("collections"))
local number = require(script.Parent.Parent:WaitForChild("node_modules"):WaitForChild(".luau-aliases"):WaitForChild("@jsdotlua"):WaitForChild("number"))
local array = collections.Array
require(script.Parent.Parent:WaitForChild("types"):WaitForChild("brewer-types"))
require(script.Parent.Parent:WaitForChild("types"):WaitForChild("scale-types"))
local chroma = require(script.Parent.Parent:WaitForChild("chroma"))
local pow = math.pow

local function isCallable(p)
	local typeName = type(p)

	if typeName ~= "table" then
		return typeName == "function"
	end

	local metatable = getmetatable(p)
	return metatable ~= nil and type(metatable.__call) == "function"
end

local __range__

local function scale(p)
	local v = "rgb"
	local v2 = chroma("#ccc")
	local v3 = 0
	local v4 = {}
	v4[1], v4[2] = 0, 1
	local v5 = {}
	local v6 = {}
	v6[1], v6[2] = 0, 0
	local v7 = false
	local v8 = {}
	local v9 = false
	local v10 = 0
	local v11 = 1
	local v12 = false
	local values = {}
	local v13 = true
	local v14 = 1
	local resetCache

	local function setColors(p2)
		local clone = (p2 == nil or p2 == "") and { "#fff", "#000" } or p2

		if clone ~= nil and type(clone) == "string" and clone ~= "" and chroma.brewer[string.lower(clone)] ~= nil then
			clone = chroma.brewer[string.lower(clone)]
		end

		if type(clone) == "table" then
			local v15 = #clone == 1 and { clone[1], clone[1] } or clone
			clone = table.clone(v15)

			for i = 1, #clone do
				clone[i] = chroma(clone[i])
			end

			v5 = {}

			for i = 0, #clone - 1 do
				table.insert(v5, i / (#clone - 1))
			end
		end

		resetCache()
		v8 = clone
		return v8
	end

	local function getClass(p2)
		if not v7 then
			return 0
		end

		local v15 = #v7 - 1
		local count = 0

		while count < v15 and v7[count + 1] <= p2 do
			count += 1
		end

		return count - 1
	end

	local function tMapLightness(p2: number)
		return p2
	end

	local function tMapDomain(p2: number)
		return p2
	end

	local function getColor(p2: number?, flag: boolean?)
		local interpolated = nil

		if flag == nil then
			flag = false
		end

		if number.isNaN(p2) or p2 == nil then
			return v2
		end

		if not flag then
			if v7 and #v7 > 2 then
				local v15

				if v7 then
					local v16 = #v7 - 1
					local count = 0

					while count < v16 and v7[count + 1] <= p2 do
						count += 1
					end

					v15 = count - 1
				else
					v15 = 0
				end

				p2 = v15 / (#v7 - 2)
			elseif v11 == v10 then
				p2 = 1
			else
				p2 = (p2 - v10) / (v11 - v10)
			end
		end

		local v15 = tMapDomain(p2)

		if not flag then
			v15 = tMapLightness(v15)
		end

		if v14 ~= 1 then
			v15 = pow(v15, v14)
		end

		local v16 = math.min(1, (math.max(0, v6[1] + v15 * (1 - v6[1] - v6[2]))))
		local v17 = math.floor(v16 * 10000)

		if v13 and values[v17 + 1] then
			return values[v17 + 1]
		end

		local v18 = v8
		local typeName = type(v18)
		local v19

		if typeName == "table" then
			local metatable = getmetatable(v18)

			if metatable == nil then
				v19 = false
			else
				v19 = type(metatable.__call) == "function"
			end
		else
			v19 = typeName == "function"
		end

		if v19 then
			interpolated = v8(v16)
		elseif type(v8) == "table" then
			for k, v21 in v5 do
				if v16 <= v21 then
					interpolated = v8[k]
					break
				elseif v21 <= v16 and k == #v5 then
					interpolated = v8[k]
					break
				elseif v21 < v16 and v16 < v5[k + 1] then
					local v22 = (v16 - v21) / (v5[k + 1] - v21)
					interpolated = chroma.interpolate(v8[k], v8[k + 1], v22, v)
					break
				end
			end
		end

		if v13 then
			values[v17 + 1] = interpolated
		end

		return interpolated
	end

	resetCache = function()
		values = {}
	end

	setColors(p)

	local function callF(_, p2: number?)
		local v15 = chroma((getColor(p2)))

		if v9 and v9 ~= "" and v15[v9] then
			return v15[v9](v15)
		end

		return v15
	end

	local object = setmetatable({}, {
		__call = callF
	})

	function object.classes(list)
		if list == nil then
			return v7
		end

		if type(list) == "table" then
			v7 = list
			v4 = { list[1], list[#list - 1] }
		else
			local analyze = chroma.analyze(v4)

			if list == 0 then
				v7 = { analyze.min, analyze.max }
			else
				v7 = chroma.limits(analyze, "e", list)
			end
		end

		return object
	end

	function object.domain(list)
		if list == nil then
			return v4
		end

		v10 = list[1]
		local count = #list
		v11 = list[count]
		v5 = {}
		local count2 = #v8

		if count == count2 and v10 ~= v11 then
			for _, v15 in list do
				table.insert(v5, (v15 - v10) / (v11 - v10))
			end
		else
			for i = 0, count2 - 1 do
				table.insert(v5, i / (count2 - 1))
			end

			if count > 2 then
				local mapped = array.map(list, function(_: number, p2: number)
					return (p2 - 1) / (count - 1)
				end)
				local mapped2 = array.map(list, function(p2: number)
					return (p2 - v10) / (v11 - v10)
				end)

				if not array.every(mapped2, function(p2, p3)
					return mapped[p3] == p2
				end) then
					tMapDomain = function(p2: number)
						if p2 <= 0 or p2 >= 1 then
							return p2
						end

						local v15 = 1

						while mapped2[v15 + 1] <= p2 do
							v15 += 1
						end

						local v16 = (p2 - mapped2[v15]) / (mapped2[v15 + 1] - mapped2[v15])
						return mapped[v15] + v16 * (mapped[v15 + 1] - mapped[v15])
					end
				end
			end
		end

		v4 = { v10, v11 }
		return object
	end

	function object.mode(p2)
		if p2 == nil then
			return v
		end

		v = p2
		resetCache()
		return object
	end

	function object.range(p2)
		setColors(p2)
		return object
	end

	function object.out(p2)
		v9 = p2
		return object
	end

	function object.spread(p2: number?)
		if p2 == nil then
			return v3
		end

		v3 = p2
		return object
	end

	function object.correctLightness(flag: boolean?)
		v12 = flag == nil or flag
		resetCache()

		if v12 then
			tMapLightness = function(p2: number)
				local v15 = getColor(0, true):lab()[1]
				local v16 = getColor(1, true):lab()[1]
				local v17 = v16 < v15
				local v18 = getColor(p2, true):lab()[1]
				local v19 = v15 + (v16 - v15) * p2
				local v20 = v18 - v19
				local v21 = 20
				local v22 = 1
				local v23 = 0

				while math.abs(v20) > 0.01 and v21 > 0 do
					v21 -= 1

					if v17 then
						v20 *= -1
					end

					local v24

					if v20 < 0 then
						v24 = p2 + (v22 - p2) * 0.5
						v23 = p2
					else
						v24 = p2 + (v23 - p2) * 0.5
						v22 = p2
					end

					v20 = getColor(v24, true):lab()[1] - v19
					p2 = v24
				end

				return p2
			end
		else
			tMapLightness = function(p2: number)
				return p2
			end
		end

		return object
	end

	function object.padding(value)
		if value == nil then
			return v6
		end

		v6 = type(value) == "number" and { value, value } or value
		return object
	end

	function object.colors(...)
		local v15, v16 = ...
		local v17 = select("#", ...)
		local v18 = v17 < 2 and "hex" or v16
		local clone

		if v17 == 0 then
			clone = table.clone(v8)
		elseif v15 == 1 then
			clone = { object(0.5) }
		elseif v15 > 1 then
			local v19 = v4[1]
			local v20 = v4[2] - v19
			clone = array.map(__range__(0, v15, false), function(p2: number)
				return object(v19 + p2 / (v15 - 1) * v20)
			end)
		else
			p = {}
			local v19 = {}

			if v7 and #v7 > 2 then
				local count = #v7

				for i = 2, count, count >= 1 and 1 or -1 do
					table.insert(v19, (v7[i - 1] + v7[i]) * 0.5)
				end
			else
				v19 = v4
			end

			clone = array.map(v19, function(p2)
				return object(p2)
			end)
		end

		if v18 and chroma[v18] then
			clone = array.map(clone, function(p2)
				return p2[v18](p2)
			end)
		end

		return clone
	end

	function object.cache(flag: boolean?)
		if flag == nil then
			return v13
		end

		v13 = flag
		return object
	end

	function object.gamma(p2: number?)
		if p2 == nil then
			return v14
		end

		v14 = p2
		return object
	end

	function object.nodata(p2)
		if p2 == nil then
			return v2
		end

		v2 = chroma(p2)
		return object
	end

	return object
end

__range__ = function(p: number, p2: number, flag: boolean)
	local result = {}
	local v = p < p2

	if flag then
		if v then
			p2 += 1
		else
			p2 -= 1
		end
	end

	local v2 = v and 1 or -1

	for i = p, p2 - v2, v2 do
		table.insert(result, i)
	end

	return result
end

return scale