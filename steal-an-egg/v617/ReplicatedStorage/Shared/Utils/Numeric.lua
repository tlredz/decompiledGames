local v = {}

-- equivalent calls inferred from this helper; original call sites unknown
local function isFinite(p: number)
	return math.abs(p) < 1e999
end

-- equivalent calls inferred from this helper; original call sites unknown
local function isFiniteVector(vector: Vector3)
	return isFinite(math.abs(vector.X) + math.abs(vector.Y) + math.abs(vector.Z))
end

local function weightAt(p, p2: number)
	local v2 = p[p2][2]

	if type(v2) ~= "number" then
		error((`weighted entry #{p2} carries a {typeof(v2)} where a numeric weight belongs`))
	end

	if v2 > 0 and v2 < 1e999 then
		return v2
	end

	return 0
end

local function cumulativeWeights(list)
	local result = table.create(#list)
	local total = 0

	for i = 1, #list do
		local v2 = list[i][2]

		if type(v2) ~= "number" then
			error((`weighted entry #{i} carries a {typeof(v2)} where a numeric weight belongs`))
		end

		total += not (v2 > 0 and v2 < 1e999) and 0 or v2
		result[i] = total
	end

	return result, total
end

local function positionAbove(list, p: number)
	local count = #list
	local v2 = 1

	while v2 < count do
		local v3 = (v2 + count) // 2

		if p < list[v3] then
			count = v3
		else
			v2 = v3 + 1
		end
	end

	return v2
end

function v.IsFiniteCFrame(cframe: CFrame)
	local v2 = isFiniteVector(cframe.Position)

	if not v2 then
		return v2
	end

	v2 = isFiniteVector(cframe.XVector)

	if v2 then
		v2 = isFiniteVector(cframe.YVector)

		if v2 then
			return (isFiniteVector(cframe.ZVector))
		end
	end

	return v2
end

function v.DrawWeighted(p, p2)
	local v2, v3 = cumulativeWeights(p)

	if v3 <= 0 then
		return nil
	end

	local v5 = positionAbove(v2, (p2 or Random.new()):NextNumber() * v3)
	local v6 = {
		Value = p[v5][1],
		Index = v5,
		Weight = 0
	}
	local v7 = p[v5][2]

	if type(v7) ~= "number" then
		error((`weighted entry #{v5} carries a {typeof(v7)} where a numeric weight belongs`))
	end

	v6.Weight = not (v7 > 0 and v7 < 1e999) and 0 or v7
	return v6
end

function v.RollWeighted(p, p2)
	local v2 = v.DrawWeighted(p, p2)

	if v2 == nil then
		return nil
	end

	return v2.Value
end

function v:Shuffle(p2)
	(p2 or Random.new()):Shuffle(self)
	return self
end

return table.freeze(v)