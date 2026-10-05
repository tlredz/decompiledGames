local HttpService = game:GetService("HttpService")
local CONSTANTS = require(script.Parent.CONSTANTS)
local ENV = require(script.Parent.ENV)

function fallbackSerializer(value)
	if typeof(value) == "table" or typeof(value) == "number" or typeof(value) == "string" or typeof(value) == "boolean" or value == nil then
		return value
	end

	error((`Cannot serialize value of type "{typeof(value)}" for ChooseParameter without a custom serializeCallback`))
end

function solveArrayPermutations(p, callback)
	local clones = {}
	local recurse

	recurse = function(list, list2)
		if #list2 == 0 then
			if callback == nil or callback(list) then
				table.insert(clones, table.clone(list))
			end
		else
			for i = 1, #list2 do
				table.insert(list, list2[i])
				local clone = table.clone(list2)
				table.remove(clone, i)
				recurse(list, clone)
				table.remove(list)
			end
		end
	end

	recurse({}, p)
	return clones
end

function solveArrayCombinations(list, p: number, callback)
	local clones = {}
	local recurse

	recurse = function(p2: number, list2)
		if #list2 == p then
			if callback == nil or callback(list2) then
				table.insert(clones, table.clone(list2))
			end
		else
			local v = p - #list2

			for i = p2, #list - v + 1 do
				table.insert(list2, list[i])
				recurse(i + 1, list2)
				table.remove(list2)
			end
		end
	end

	recurse(1, {})
	return clones
end

function getArrayPermutationCount(p: number, p2: number, p3: number)
	if p2 == 1e999 or p3 == 1e999 then
		return 1e999
	end

	local function permCount(p4: number, p5: number)
		if p4 < p5 then
			return 0
		end

		local v = 1

		for i = 0, p5 - 1 do
			v *= p4 - i
		end

		return v
	end

	local total = 0

	for i = p2, p3 do
		local v

		if p < i then
			v = 0
		else
			v = 1

			for i2 = 0, i - 1 do
				v *= p - i2
			end
		end

		total += v
	end

	return total
end

function solveSetPermutationCount(p: number, p2: number, p3: number)
	if p2 == 1e999 or p3 == 1e999 then
		return 1e999
	end

	local function permCount(p4: number, p5: number)
		if p4 < p5 then
			return 0
		end

		local v = 1

		for i = 0, p5 - 1 do
			v *= p4 - i
		end

		return v
	end

	local total = 0

	for i = p2, p3 do
		local v

		if p < i then
			v = 0
		else
			v = 1

			for i2 = 0, i - 1 do
				v *= p - i2
			end
		end

		total += v
	end

	return total
end

function solveSetCombinations(p, p2: number, p3: number, callback)
	local clone = table.clone(p)
	table.sort(clone)

	local function permutations(p4)
		local clones = {}
		local recurse

		recurse = function(list, list2)
			if #list2 == 0 then
				if callback == nil or callback(list) then
					table.insert(clones, table.clone(list))
				end
			else
				local v = {}

				for i = 1, #list2 do
					local v2 = list2[i]
					local v3 = tostring(v2)

					if v[v3] then
						continue
					end

					v[v3] = true
					table.insert(list, v2)
					local clone2 = table.clone(list2)
					table.remove(clone2, i)
					recurse(list, clone2)
					table.remove(list)
				end
			end
		end

		recurse({}, p4)
		return clones
	end

	local function combinations(i: number)
		local clones = {}
		local recurse

		recurse = function(p4: number, list)
			if #list == i then
				table.insert(clones, table.clone(list))
				return
			end

			local v = i - #list

			for i2 = p4, #clone - v + 1 do
				if not (i2 == p4 or tostring(clone[i2]) ~= tostring(clone[i2 - 1])) then
					continue
				end

				table.insert(list, clone[i2])
				recurse(i2 + 1, list)
				table.remove(list)
			end
		end

		recurse(1, {})
		return clones
	end

	local result = {}

	for i = p2, p3 do
		for _, v in combinations(i) do
			for _, v2 in permutations(v) do
				table.insert(result, v2)
			end
		end
	end

	return result
end

local Parameter = {
	Custom = {
		new = function(p: string, method, callback2, permutations)
			return {
				Key = p,
				Type = "Custom",
				Method = method,
				SerializeCallback = callback2 or fallbackSerializer,
				Permutations = permutations
			}
		end,
		generate = function(p, p2)
			return p.Method(p2)
		end,
		serialize = function(p, p2)
			return p.SerializeCallback(p2)
		end,
		permute = function(p, p2: number, callback)
			local v

			if callback then
				v = ENV.MAX_UNCAPPED_PERMUTATIONS
			else
				v = p2
			end

			if p.Permutations and #p.Permutations <= v then
				if not callback then
					return table.clone(p.Permutations)
				end

				local permutations = {}

				for _, permutation in p.Permutations do
					if callback(permutation) then
						table.insert(permutations, permutation)
					end
				end

				if p2 < #permutations then
					return #p.Permutations
				end

				return permutations
			elseif p.Permutations then
				return #p.Permutations
			else
				return 1e999
			end
		end
	},
	Integer = {
		new = function(p: string, min: number?, max: number?, increment: number?)
			return {
				Key = p,
				Type = "Integer",
				Min = min,
				Max = max,
				Increment = increment
			}
		end,
		generate = function(data, object)
			local integer = object:NextInteger(
				data.Min or -CONSTANTS.BIGGEST_INTEGER,
				data.Max or CONSTANTS.BIGGEST_INTEGER
			)
			local increment = data.Increment

			if increment then
				integer -= integer % increment
			end

			return integer
		end,
		serialize = function(_, value)
			if typeof(value) == "number" and math.abs(value) == 1e999 then
				if value > 0 then
					return "INF"
				end

				return "-INF"
			elseif typeof(value) == "number" and value ~= value then
				return "NaN"
			else
				return value
			end
		end,
		permute = function(data, p: number, callback)
			if not data.Max then
				return 1e999
			end

			local min = data.Min or 0
			local increment = data.Increment or 1
			local v = math.floor((data.Max - min) / increment + 1)
			local v2

			if callback then
				v2 = ENV.MAX_UNCAPPED_PERMUTATIONS
			else
				v2 = p
			end

			if v2 < v then
				return v
			end

			local result = {}

			for i = min, data.Max, increment do
				if callback == nil or callback(i) then
					table.insert(result, i)
				end
			end

			if p < #result then
				return #result
			end

			return result
		end
	},
	Float = {
		new = function(p: string, min: number?, max: number?, increment: number?)
			return {
				Key = p,
				Type = "Float",
				Min = min,
				Max = max,
				Increment = increment
			}
		end,
		generate = function(data, object)
			local number = object:NextNumber(data.Min or -CONSTANTS.BIGGEST_FLOAT, data.Max or CONSTANTS.BIGGEST_FLOAT)
			local increment = data.Increment

			if increment then
				number -= number % increment
			end

			return number
		end,
		serialize = function(_, value)
			if typeof(value) == "number" and math.abs(value) == 1e999 then
				if value > 0 then
					return "INF"
				end

				return "-INF"
			elseif typeof(value) == "number" and value ~= value then
				return "NaN"
			else
				return value
			end
		end,
		permute = function(_, _: number, _)
			return 1e999
		end
	},
	Boolean = {
		new = function(p: string, chanceTrue: number?)
			return {
				Key = p,
				Type = "Boolean",
				ChanceTrue = chanceTrue
			}
		end,
		generate = function(p, object)
			return object:NextNumber() < (p.ChanceTrue or 0.5)
		end,
		permute = function(_, p: number, callback)
			local MAX_UNCAPPED_PERMUTATIONS

			if callback then
				MAX_UNCAPPED_PERMUTATIONS = ENV.MAX_UNCAPPED_PERMUTATIONS
			else
				MAX_UNCAPPED_PERMUTATIONS = p
			end

			local v = { true, false }

			if MAX_UNCAPPED_PERMUTATIONS < #v then
				return #v
			end

			local result = {}

			for _, v2 in v do
				if callback == nil or callback(v2) then
					table.insert(result, v2)
				end
			end

			if p < #result then
				return #result
			end

			return result
		end
	},
	Vector2 = {
		new = function(p: string, point: Vector2?, point2: Vector2?, point3: Vector2?)
			return {
				Key = p,
				Type = "Vector2",
				Min = point,
				Max = point2,
				Increment = point3
			}
		end,
		generate = function(data, object)
			local min = data.Min or Vector2.new(-CONSTANTS.BIGGEST_VEC_FLOAT, -CONSTANTS.BIGGEST_VEC_FLOAT)
			local max = data.Max or Vector2.new(CONSTANTS.BIGGEST_VEC_FLOAT, CONSTANTS.BIGGEST_VEC_FLOAT)
			local number = object:NextNumber(min.X, max.X)
			local number2 = object:NextNumber(min.Y, max.Y)
			local vector = Vector2.new(number, number2)
			local increment = data.Increment

			if increment then
				local v = vector.X % increment.X
				local v2 = vector.Y % increment.Y
				vector -= Vector2.new(v, v2)
			end

			return vector
		end,
		serialize = function(_, p)
			if typeof(p) ~= "Vector2" then
				return p
			end

			if p.X ~= p.X or p.Y ~= p.Y then
				return { p.X ~= p.X and "NaN" or tostring(p.X), p.Y ~= p.Y and "NaN" or tostring(p.Y) }
			end

			if math.abs(p.X) ~= 1e999 and math.abs(p.Y) ~= 1e999 then
				return { p.X, p.Y }
			end

			local v2

			if math.abs(p.X) == 1e999 then
				v2 = p.X > 0 and "INF" or "-INF"
			else
				v2 = p.X
			end

			local v3

			if math.abs(p.Y) == 1e999 then
				v3 = p.Y > 0 and "INF" or "-INF"
			else
				v3 = p.Y
			end

			return {
				X = v2,
				Y = v3
			}
		end,
		permute = function(_, _: number, _)
			return 1e999
		end
	},
	Vector3 = {
		new = function(p: string, vector: Vector3?, vector2: Vector3?, vector3: Vector3?)
			return {
				Key = p,
				Type = "Vector3",
				Min = vector,
				Max = vector2,
				Increment = vector3
			}
		end,
		generate = function(data, object)
			local min = data.Min or Vector3.new(
				-CONSTANTS.BIGGEST_VEC_FLOAT,
				-CONSTANTS.BIGGEST_VEC_FLOAT,
				-CONSTANTS.BIGGEST_VEC_FLOAT
			)
			local max = data.Max or Vector3.new(
				CONSTANTS.BIGGEST_VEC_FLOAT,
				CONSTANTS.BIGGEST_VEC_FLOAT,
				CONSTANTS.BIGGEST_VEC_FLOAT
			)
			local vector = Vector3.new(
				object:NextNumber(min.X, max.X),
				object:NextNumber(min.Y, max.Y),
				(object:NextNumber(min.Z, max.Z))
			)
			local increment = data.Increment

			if increment then
				vector -= Vector3.new(vector.X % increment.X, vector.Y % increment.Y, vector.Z % increment.Z)
			end

			return vector
		end,
		serialize = function(_, data)
			if typeof(data) ~= "Vector3" then
				return data
			end

			if data.X ~= data.X or data.Y ~= data.Y or data.Z ~= data.Z then
				return {
					data.X ~= data.X and "NaN" or tostring(data.X),
					data.Y ~= data.Y and "NaN" or tostring(data.Y),
					data.Z ~= data.Z and "NaN" or tostring(data.Z)
				}
			end

			if math.abs(data.X) ~= 1e999 and math.abs(data.Y) ~= 1e999 and math.abs(data.Z) ~= 1e999 then
				return { data.X, data.Y, data.Z }
			end

			local v2

			if math.abs(data.X) == 1e999 then
				v2 = data.X > 0 and "INF" or "-INF"
			else
				v2 = data.X
			end

			local v3

			if math.abs(data.Y) == 1e999 then
				v3 = data.Y > 0 and "INF" or "-INF"
			else
				v3 = data.Y
			end

			local v4

			if math.abs(data.Z) == 1e999 then
				v4 = data.Z > 0 and "INF" or "-INF"
			else
				v4 = data.Z
			end

			return {
				X = v2,
				Y = v3,
				Z = v4
			}
		end,
		permute = function(_, _: number, _)
			return 1e999
		end
	},
	Literal = {
		new = function(p: string, values)
			return {
				Key = p,
				Type = "Literal",
				Values = values
			}
		end,
		generate = function(p, object)
			local integer = object:NextInteger(1, #p.Values)
			return p.Values[integer]
		end,
		serialize = function(_, p)
			return p
		end,
		permute = function(p, p2: number, callback)
			local v

			if callback then
				v = ENV.MAX_UNCAPPED_PERMUTATIONS
			else
				v = p2
			end

			if v < #p.Values then
				return #p.Values
			end

			local result = {}

			for _, value in p.Values do
				if callback == nil or callback(value) then
					table.insert(result, value)
				end
			end

			if p2 < #result then
				return #result
			end

			return result
		end
	},
	Choose = {
		new = function(p: string, values, callback)
			assert(#values > 0, "need more than 0 values to choose from")
			return {
				Key = p,
				Type = "Choose",
				Values = values,
				SerializeCallback = callback or fallbackSerializer
			}
		end,
		generate = function(p, object)
			local integer = object:NextInteger(1, #p.Values)
			return p.Values[integer]
		end,
		serialize = function(p, p2)
			return p.SerializeCallback(p2)
		end,
		permute = function(p, p2: number, callback)
			local v

			if callback then
				v = ENV.MAX_UNCAPPED_PERMUTATIONS
			else
				v = p2
			end

			if v < #p.Values then
				return #p.Values
			end

			local result = {}

			for _, value in p.Values do
				if callback == nil or callback(value) then
					table.insert(result, value)
				end
			end

			if p2 < #result then
				return #result
			end

			return result
		end
	},
	Raffle = {
		new = function(p: string, items, callback)
			local total = 0
			local raffle = {}

			for k, item in pairs(items) do
				local v2 = {
					Value = k,
					Position = total
				}
				table.freeze(v2)
				table.insert(raffle, v2)
				total += item
			end

			table.freeze(raffle)
			return {
				Key = p,
				Type = "Raffle",
				Raffle = raffle,
				OddSum = total,
				SerializeCallback = callback or fallbackSerializer
			}
		end,
		generate = function(data, object)
			local v = math.clamp(object:NextNumber() * data.OddSum, 0, data.OddSum)

			for k, v2 in data.Raffle do
				if v < v2.Position or k == #data.Raffle then
					return v2.Value
				end
			end

			error((`Failed to generate value for RaffleParameter "{data.Key}". This should never happen.`))
		end,
		serialize = function(p, p2)
			return p.SerializeCallback(p2)
		end,
		permute = function(p, p2: number, callback)
			local v

			if callback then
				v = ENV.MAX_UNCAPPED_PERMUTATIONS
			else
				v = p2
			end

			if v < #p.Raffle then
				return #p.Raffle
			end

			local result = {}

			for _, v2 in p.Raffle do
				if callback == nil or callback(v2.Value) then
					table.insert(result, v2.Value)
				end
			end

			if p2 < #result then
				return #result
			end

			return result
		end
	}
}
Parameter.Array = {
	new = function(p: string, valueType, minLength: number?, maxLength: number?, isFrozen: boolean?)
		return {
			Key = p,
			Type = "Array",
			ValueType = valueType,
			IsFrozen = isFrozen,
			MinLength = minLength,
			MaxLength = maxLength
		}
	end,
	generate = function(data, object)
		local v = math.max(data.MinLength or 0, 0)
		local integer = object:NextInteger(v, (math.max(v, data.MaxLength or ENV.DEFAULT_TABLE_SIZE)))
		local result = {}

		if integer > 0 then
			for i = 1, integer do
				result[i] = Parameter.Any.generate(data.ValueType, object)
			end
		end

		if data.IsFrozen then
			return table.freeze(result)
		end

		return result
	end,
	serialize = function(p, items)
		if typeof(items) ~= "table" then
			return nil
		end

		local result = {}

		for k, item in items do
			result[k] = Parameter.Any.serialize(p.ValueType, item)
		end

		return result
	end,
	permute = function(data, p: number, callback)
		local v = math.max(data.MinLength or 0, 0)
		local v2 = math.max(v, data.MaxLength or ENV.DEFAULT_TABLE_SIZE)
		local permute = Parameter.Any.permute(data.ValueType, p, callback)
		local MAX_UNCAPPED_PERMUTATIONS

		if callback then
			MAX_UNCAPPED_PERMUTATIONS = ENV.MAX_UNCAPPED_PERMUTATIONS
		else
			MAX_UNCAPPED_PERMUTATIONS = p
		end

		local v3 = typeof(permute) ~= "number" and #permute or permute
		local arrayPermutationCount = getArrayPermutationCount(v3, v3, v3)

		if MAX_UNCAPPED_PERMUTATIONS < arrayPermutationCount then
			return arrayPermutationCount
		end

		assert(typeof(permute) == "table", "bad valueSet")
		local result = {}

		for i = v, v2 do
			for _, v4 in solveArrayCombinations(permute, i) do
				for _, v5 in solveArrayPermutations(v4) do
					table.insert(result, v5)
				end
			end
		end

		if p < #result then
			return #result
		end

		return result
	end
}
Parameter.Filter = {
	new = function(p: string, valueType, filterFunc)
		return {
			Key = p,
			Type = "Filter",
			ValueType = valueType,
			FilterFunc = filterFunc
		}
	end,
	generate = function(data, p)
		local count = 0
		local v

		repeat
			v = Parameter.Any.generate(data.ValueType, p)
			count += 1
			assert(
				count < ENV.MAX_RETRIES,
				(`Too many attempts to generate unique value for FilterParameter "{data.Key}".`)
			)
		until data.FilterFunc(v)

		return v
	end,
	serialize = function(p, p2)
		return Parameter.Any.serialize(p.ValueType, p2)
	end,
	permute = function(p, p2: number, callback)
		return Parameter.Any.permute(p.ValueType, p2, function(p3)
			return not not p.FilterFunc(p3) and not (callback and not callback(p3))
		end)
	end
}
Parameter.Computed = {
	new = function(p: string, inputs, computeFunc, callback2, permutations)
		return {
			Key = p,
			Type = "Computed",
			Inputs = inputs,
			ComputeFunc = computeFunc,
			SerializeCallback = callback2 or fallbackSerializer,
			Permutations = permutations
		}
	end,
	generate = function(p, p2)
		local v = {}

		for k, input in p.Inputs do
			v[k] = Parameter.Any.generate(input, p2)
		end

		return p.ComputeFunc(table.unpack(v, 1, #p.Inputs))
	end,
	serialize = function(p, p2)
		return p.SerializeCallback(p2)
	end,
	permute = function(p, MAX_UNCAPPED_PERMUTATIONS: number, callback)
		if callback then
			MAX_UNCAPPED_PERMUTATIONS = ENV.MAX_UNCAPPED_PERMUTATIONS
		end

		if p.Permutations and #p.Permutations < MAX_UNCAPPED_PERMUTATIONS then
			if not callback then
				return table.clone(p.Permutations)
			end

			local permutations = {}

			for _, permutation in p.Permutations do
				if callback(permutation) then
					table.insert(permutations, permutation)
				end
			end

			if MAX_UNCAPPED_PERMUTATIONS <= #permutations then
				return #permutations
			end

			return permutations
		elseif p.Permutations then
			return #p.Permutations
		else
			return 1e999
		end
	end
}
Parameter.Set = {
	new = function(p: string, valueType, minLength: number?, maxLength: number?, isFrozen: boolean?, callback)
		return {
			Key = p,
			Type = "Set",
			ValueType = valueType,
			IsFrozen = isFrozen,
			MinLength = minLength,
			MaxLength = maxLength,
			HashFunc = callback or tostring
		}
	end,
	generate = function(data, object)
		local v = math.max(data.MinLength or 0, 0)
		local v2 = math.max(v, data.MaxLength or ENV.DEFAULT_TABLE_SIZE)

		if v ~= v2 then
			v = object:NextInteger(v, v2)
		end

		local result = {}
		local v3 = {}

		if v > 0 then
			local permute = Parameter.Any.permute(data.ValueType, v2 + 1)

			if type(permute) == "number" then
				for i = 1, v do
					local count = 0
					local v4, v5

					repeat
						v4 = Parameter.Any.generate(data.ValueType, object)
						v5 = data.HashFunc(v4)
						count += 1
						assert(
							count < ENV.MAX_RETRIES,
							(`Too many attempts to generate unique value for SetParameter "{data.Key}".`)
						)
					until v3[v5] == nil

					v3[v5] = true
					result[i] = v4
				end
			else
				local v4 = {}

				for _, v5 in permute do
					v4[v5] = object:NextNumber()
				end

				table.sort(permute, function(a, b)
					return v4[a] < v4[b]
				end)

				for i = 1, #permute do
					table.insert(result, permute[i])
				end
			end
		end

		if data.IsFrozen then
			return table.freeze(result)
		end

		return result
	end,
	serialize = function(p, items)
		if typeof(items) ~= "table" then
			return nil
		end

		local result = {}

		for k, item in items do
			result[k] = Parameter.Any.serialize(p.ValueType, item)
		end

		return result
	end,
	permute = function(data, p: number, callback)
		local MAX_UNCAPPED_PERMUTATIONS

		if callback then
			MAX_UNCAPPED_PERMUTATIONS = ENV.MAX_UNCAPPED_PERMUTATIONS
		else
			MAX_UNCAPPED_PERMUTATIONS = p
		end

		local v = math.max(data.MinLength or 0, 0)
		local v2 = math.max(v, data.MaxLength or ENV.DEFAULT_TABLE_SIZE)
		local permute = Parameter.Any.permute(data.ValueType, p, callback)
		local v3 = typeof(permute) ~= "number" and #permute or permute
		local v4 = solveSetPermutationCount(v3, v3, v3)

		if MAX_UNCAPPED_PERMUTATIONS < v4 then
			return v4
		end

		assert(typeof(permute) == "table", "bad valueSet")
		local result = {}

		for _, v5 in solveSetCombinations(permute, v, v2, callback) do
			table.insert(result, v5)
		end

		if p < #result then
			return #result
		end

		return result
	end
}
Parameter.String = {
	new = function(p: string, minLength: number?, maxLength: number?)
		return {
			Key = p,
			Type = "String",
			MinLength = minLength,
			MaxLength = maxLength
		}
	end,
	generate = function(p, object)
		local v = math.max(p.MinLength or 0, 0)
		local integer = object:NextInteger(v, (math.max(v, p.MaxLength or ENV.DEFAULT_STRING_LENGTH)))

		if not (integer > 0) then
			return ""
		end

		local v2 = {}

		for i = 1, integer do
			v2[i] = string.char((object:NextInteger(32, 126)))
		end

		return table.concat(v2)
	end,
	permute = function(p, p2: number, callback)
		local MAX_UNCAPPED_PERMUTATIONS

		if callback then
			MAX_UNCAPPED_PERMUTATIONS = ENV.MAX_UNCAPPED_PERMUTATIONS
		else
			MAX_UNCAPPED_PERMUTATIONS = p2
		end

		local v = math.max(p.MinLength or 0, 0)
		local v2 = math.max(v, p.MaxLength or ENV.DEFAULT_STRING_LENGTH)
		local arrayPermutationCount = getArrayPermutationCount(95, 95, 95)

		if MAX_UNCAPPED_PERMUTATIONS < arrayPermutationCount then
			return arrayPermutationCount
		end

		local v3 = {}

		for i = 32, 126 do
			local v4 = string.char(i)

			if callback == nil or callback(v4) then
				table.insert(v3, v4)
			end
		end

		assert(typeof(v3) == "table", "bad valueSet")
		local result = {}

		for i = v, v2 do
			for _, v4 in solveArrayCombinations(v3, i) do
				for _, list in solveArrayPermutations(v4) do
					table.insert(result, table.concat(list))
				end
			end
		end

		if p2 < #result then
			return #result
		end

		return result
	end
}
Parameter.Color3 = {
	new = function(p: string)
		return {
			Key = p,
			Type = "Color3"
		}
	end,
	generate = function(_, object)
		return Color3.fromRGB(object:NextInteger(0, 255), object:NextInteger(0, 255), object:NextInteger(0, 255))
	end,
	serialize = function(_, data)
		if typeof(data) ~= "Color3" then
			return data
		end

		local v = data.R * 255
		local v2 = data.G * 255
		local v3 = data.B * 255
		return { math.round(v), math.round(v2), (math.round(v3)) }
	end,
	permute = function(_, p: number, callback)
		local v

		if callback then
			v = ENV.MAX_UNCAPPED_PERMUTATIONS
		else
			v = p
		end

		if v < 16777216 then
			return 16777216
		end

		local colors = {}

		for i = 0, 255 do
			for i2 = 0, 255 do
				for i3 = 0, 255 do
					local color = Color3.fromRGB(i, i2, i3)

					if callback == nil or callback(color) then
						table.insert(colors, color)
					end
				end
			end
		end

		if p < #colors then
			return #colors
		end

		return colors
	end
}
local v = {
	1,
	2,
	3,
	5,
	6,
	9,
	11,
	12,
	18,
	21,
	22,
	23,
	24,
	25,
	26,
	27,
	28,
	29,
	36,
	37,
	38,
	39,
	40,
	41,
	42,
	43,
	44,
	45,
	47,
	48,
	49,
	50,
	100,
	101,
	102,
	103,
	104,
	105,
	106,
	107,
	108,
	110,
	111,
	112,
	113,
	115,
	116,
	118,
	119,
	120,
	121,
	123,
	124,
	125,
	126,
	127,
	128,
	131,
	133,
	134,
	135,
	136,
	137,
	138,
	140,
	141,
	143,
	145,
	146,
	147,
	148,
	149,
	150,
	151,
	153,
	154,
	157,
	158,
	168,
	176,
	178,
	179,
	180,
	190,
	191,
	192,
	193,
	194,
	195,
	196,
	198,
	199,
	200,
	208,
	209,
	210,
	211,
	212,
	213,
	216,
	217,
	218,
	219,
	220,
	221,
	222,
	223,
	224,
	225,
	226,
	232,
	268,
	301,
	302,
	303,
	304,
	305,
	306,
	307,
	308,
	309,
	310,
	311,
	312,
	313,
	314,
	315,
	316,
	317,
	318,
	319,
	320,
	321,
	322,
	323,
	324,
	325,
	327,
	328,
	329,
	330,
	331,
	332,
	333,
	334,
	335,
	336,
	337,
	338,
	339,
	340,
	341,
	342,
	343,
	344,
	345,
	346,
	347,
	348,
	349,
	350,
	351,
	352,
	353,
	354,
	355,
	356,
	357,
	358,
	359,
	360,
	361,
	362,
	363,
	364,
	365,
	1001,
	1002,
	1003,
	1004,
	1005,
	1006,
	1007,
	1008,
	1009,
	1010,
	1011,
	1012,
	1013,
	1014,
	1015,
	1016,
	1017,
	1018,
	1019,
	1020,
	1021,
	1022,
	1023,
	1024,
	1025,
	1026,
	1027,
	1028,
	1029,
	1030,
	1031,
	1032
}
Parameter.BrickColor = {
	new = function(p: string)
		return {
			Key = p,
			Type = "BrickColor"
		}
	end,
	generate = function(_, object)
		return BrickColor.new(v[object:NextInteger(1, #v)])
	end,
	serialize = function(_, p)
		if typeof(p) == "BrickColor" then
			return (`BrickColor({p.Name})`)
		end

		return p
	end,
	permute = function(_, p: number, callback)
		local v2

		if callback then
			v2 = ENV.MAX_UNCAPPED_PERMUTATIONS
		else
			v2 = p
		end

		if v2 < #v then
			return #v
		end

		local brickColors = {}

		for _, v3 in v do
			local brickColor = BrickColor.new(v3)

			if callback == nil or callback(brickColor) then
				table.insert(brickColors, brickColor)
			end
		end

		if p < #brickColors then
			return #brickColors
		end

		return brickColors
	end
}
Parameter.Map = {
	new = function(p: string, keyType, valueType, minLength: number?, maxLength: number?)
		return {
			Key = p,
			Type = "Map",
			ValueType = valueType,
			KeyType = keyType,
			MinLength = minLength,
			MaxLength = maxLength
		}
	end,
	generate = function(data, object)
		local v2 = math.max(data.MinLength or 0, 0)
		local integer = object:NextInteger(v2, (math.max(v2, data.MaxLength or ENV.DEFAULT_TABLE_SIZE)))
		local result = {}

		if integer <= 0 then
			return result
		end

		for i = 1, integer do
			local v3 = math.max(10000, integer ^ 2)
			local count = 0
			local v4

			repeat
				count += 1
				v4 = Parameter.Any.generate(data.KeyType, object)
			until v4 ~= nil and result[v4] == nil and count < v3

			assert(v4 ~= nil, "Failed to generate unique key for MapParameter")
			assert(
				count <= v3,
				(`Exceeded maximum attempts to generate unique key for MapParameter: {count}/{v3} for map of length {integer} ({i})`)
			)
			result[v4] = Parameter.Any.generate(data.ValueType, object)
		end

		return result
	end,
	serialize = function(p, items)
		if typeof(items) ~= "table" then
			return nil
		end

		local result = {}

		for k, item in items do
			result[Parameter.Any.serialize(p.KeyType, k)] = Parameter.Any.serialize(p.ValueType, item)
		end

		return result
	end,
	permute = function(data, p: number, callback)
		local MAX_UNCAPPED_PERMUTATIONS

		if callback then
			MAX_UNCAPPED_PERMUTATIONS = ENV.MAX_UNCAPPED_PERMUTATIONS
		else
			MAX_UNCAPPED_PERMUTATIONS = p
		end

		local v2 = math.max(data.MinLength or 0, 0)
		local v3 = math.max(v2, data.MaxLength or ENV.DEFAULT_TABLE_SIZE)
		local permute = Parameter.Any.permute(data.KeyType, p)
		local permute2 = Parameter.Any.permute(data.ValueType, p)
		local v4 = typeof(permute) ~= "number" and #permute or permute
		local v5 = (1 + (typeof(permute2) ~= "number" and #permute2 or permute2)) ^ v4

		if MAX_UNCAPPED_PERMUTATIONS < v5 or typeof(permute) == "number" or typeof(permute2) == "number" then
			return v5
		end

		assert(typeof(permute) == "table", "bad keySet")
		assert(typeof(permute2) == "table", "bad valueSet")
		local v6 = solveSetCombinations(permute, v2, v3)

		if MAX_UNCAPPED_PERMUTATIONS < #v6 then
			return #v6
		end

		local v7 = {}

		for _, v8 in v6 do
			local recurse
			local v9 = v8
			local recurse2 = recurse

			recurse = function(p2: number, items)
				if #v9 < p2 then
					local v10 = {}

					for k, item in pairs(items) do
						v10[k] = item
					end

					table.insert(v7, v10)
				else
					local v10 = v9[p2]

					for i, item in ipairs(permute2) do
						items[v10] = item
						recurse2(p2 + 1, items)
					end

					items[v10] = nil
				end
			end

			recurse(1, {})
		end

		if p < #v7 then
			return #v7
		end

		return v7
	end
}
Parameter.Nullable = {
	new = function(p: string, valueType, chanceNull: number?)
		return {
			Key = p,
			Type = "Nullable",
			ChanceNull = chanceNull,
			ValueType = valueType
		}
	end,
	generate = function(p, object)
		if (p.ChanceNull or 0.5) > object:NextNumber() then
			return nil
		end

		return Parameter.Any.generate(p.ValueType, object)
	end,
	serialize = function(p, p2)
		if p2 == nil then
			return "null"
		end

		return Parameter.Any.serialize(p.ValueType, p2)
	end,
	permute = function(_, _: number, _)
		return 1e999
	end
}
Parameter.Fallback = {
	new = function(p: string, valueType, fallbackType)
		return {
			Key = p,
			Type = "Fallback",
			ValueType = valueType,
			FallbackType = fallbackType
		}
	end,
	generate = function(p, p2)
		local v2 = nil
		pcall(function(...)
			v2 = Parameter.Any.generate(p.ValueType, p2)
		end)

		if v2 == nil then
			return Parameter.Any.generate(p.FallbackType, p2)
		end

		return v2
	end,
	serialize = function(p, p2)
		local serialized = Parameter.Any.serialize(p.ValueType, p2)
		local serialized2 = Parameter.Any.serialize(p.FallbackType, p2)

		if serialized2 ~= serialized then
			if typeof(serialized) == "table" then
				serialized = HttpService:JSONEncode(serialized)
			end

			if typeof(serialized2) == "table" then
				serialized2 = HttpService:JSONEncode(serialized2)
			end
		end

		assert(
			serialized == serialized2,
			(`fallback and value serializers must produce the same output for the same input: "{serialized}" vs "{serialized2}"`)
		)
		return serialized
	end,
	permute = function(p, p2: number, callback)
		local MAX_UNCAPPED_PERMUTATIONS

		if callback then
			MAX_UNCAPPED_PERMUTATIONS = ENV.MAX_UNCAPPED_PERMUTATIONS
		else
			MAX_UNCAPPED_PERMUTATIONS = p2
		end

		local permute = Parameter.Any.permute(p.ValueType, p2, callback)
		local permute2 = Parameter.Any.permute(p.FallbackType, p2, callback)
		local v2 = (typeof(permute) ~= "number" and #permute or permute) + (typeof(permute2) ~= "number" and #permute2 or permute2)

		if MAX_UNCAPPED_PERMUTATIONS < v2 or typeof(permute) == "number" or typeof(permute2) == "number" then
			return v2
		end

		local result = {}

		for _, v3 in permute do
			table.insert(result, v3)
		end

		for _, v3 in permute2 do
			table.insert(result, v3)
		end

		if p2 < #result then
			return #result
		end

		return result
	end
}
Parameter.Static = {
	new = function(p: string, p2, callback)
		return {
			Key = p,
			Type = "Static",
			Value = p2,
			SerializeCallback = callback or fallbackSerializer
		}
	end,
	generate = function(p, _)
		return p.Value
	end,
	serialize = function(p, p2)
		return p.SerializeCallback(p2)
	end,
	permute = function(p, MAX_UNCAPPED_PERMUTATIONS: number, callback)
		if callback then
			MAX_UNCAPPED_PERMUTATIONS = ENV.MAX_UNCAPPED_PERMUTATIONS
		end

		if callback ~= nil and not callback(p.Value) then
			return {}
		end

		if MAX_UNCAPPED_PERMUTATIONS < 1 then
			return 1
		end

		return { p.Value }
	end
}
Parameter.Any = {}

function Parameter.Any.new()
	error("Parameter.Any cannot be instantiated directly")
end

function Parameter.Any.generate(p, p2)
	local v2 = Parameter[p.Type]
	assert(v2, (`bad solver: "{p.Type}"`))
	return v2.generate(p, p2)
end

function Parameter.Any.serialize(p, p2)
	local v2 = Parameter[p.Type]
	assert(v2, (`bad solver: "{p.Type}"`))

	if v2.serialize then
		return v2.serialize(p, p2)
	end

	return fallbackSerializer(p2)
end

function Parameter.Any.permute(p, p2: number, callback)
	local v2 = Parameter[p.Type]
	assert(v2, (`bad solver: "{p.Type}"`))

	if v2.permute then
		return v2.permute(p, p2, callback)
	end

	return 1e999
end

return Parameter