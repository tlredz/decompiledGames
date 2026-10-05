-- equivalent calls inferred from this helper; original call sites unknown
local function hash(p: number, p2: number, p3: number)
	return (bit32.band(p, 262143) * 262144 + bit32.band(p3, 262143)) * 131072 + bit32.band(p2, 131071)
end

local function quantize(vector: Vector3, p: number)
	return vector.X // p, vector.Y // p, vector.Z // p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function key(vector: Vector3, epsilon: number)
	return hash(vector.X // epsilon, vector.Y // epsilon, vector.Z // epsilon)
end

local v = {}
local frozen = table.freeze({
	__index = v
})

function v.Insert(p, pos, p3)
	assert(typeof(pos) == "Vector3")
	local v2 = key(pos, p.Epsilon) -- equivalent call inferred; original call site unknown
	local table2 = p.Table

	if not table2[v2] then
		table2[v2] = {}
	end

	table.insert(table2[v2], {
		Pos = pos,
		Value = p3
	})
end

function v.Remove(p, p2, p3)
	assert(typeof(p2) == "Vector3")
	local v2 = key(p2, p.Epsilon) -- equivalent call inferred; original call site unknown
	local v3 = p.Table[v2]

	if not v3 then
		return
	end

	for i = #v3, 1, -1 do
		if v3[i].Value == p3 then
			table.remove(v3, i)
		end
	end

	if #v3 == 0 then
		p.Table[v2] = nil
	end
end

function v.Collect(p, data, value)
	assert(typeof(data) == "Vector3")
	local v2

	if value == nil then
		v2 = true
	elseif type(value) == "number" and value > 0 then
		v2 = math.floor(value) == value
	else
		v2 = false
	end

	assert(v2)
	local epsilon = p.Epsilon
	local v3 = data.X // epsilon
	local v4 = data.Y // epsilon
	local v5 = data.Z // epsilon
	local table2 = p.Table
	local v6 = value or 1
	local count = 0
	local result = {}

	for i = -v6, v6 do
		for i2 = -v6, v6 do
			for i3 = -v6, v6 do
				local v10 = table2[hash(v3 + i, v4 + i2, v5 + i3)]

				if not v10 then
					continue
				end

				for _, v11 in ipairs(v10) do
					count += 1
					result[count] = v11.Value
				end
			end
		end
	end

	result.n = count
	return result
end

function v.Query(p, data, value)
	assert(typeof(data) == "Vector3")
	local v2

	if value == nil then
		v2 = true
	elseif type(value) == "number" and value > 0 then
		v2 = math.floor(value) == value
	else
		v2 = false
	end

	assert(v2)
	local epsilon = p.Epsilon
	local v3 = data.X // epsilon
	local v4 = data.Y // epsilon
	local v5 = data.Z // epsilon
	local table2 = p.Table
	local v6 = value or 1
	local v7 = nil
	local value2 = nil

	for i = -v6, v6 do
		for i2 = -v6, v6 do
			for i3 = -v6, v6 do
				local v11 = table2[hash(v3 + i, v4 + i2, v5 + i3)]

				if not v11 then
					continue
				end

				for _, v12 in ipairs(v11) do
					local magnitude = (v12.Pos - data).Magnitude

					if not (not v7 or magnitude < v7) then
						continue
					end

					value2 = v12.Value
					v7 = magnitude
				end
			end
		end
	end

	return value2
end

table.freeze(v)
return table.freeze({
	new = function(value: number?, _)
		local v2

		if value == nil then
			v2 = true
		elseif type(value) == "number" then
			v2 = value > 0
		else
			v2 = false
		end

		assert(v2)
		return (setmetatable({
			Table = {},
			Epsilon = value or 10
		}, frozen))
	end
})