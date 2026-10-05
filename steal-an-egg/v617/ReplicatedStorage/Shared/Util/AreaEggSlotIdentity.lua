local ReplicatedStorage = game:GetService("ReplicatedStorage")
local t = require(ReplicatedStorage.Packages.t)
local strict = t.strict(t.instanceIsA("Model"))
local strict2 = t.strict(t.string)
local v = {}

local function rankOf(model)
	local eggSpotBottom = model.EggSpotBottom
	assert(eggSpotBottom:IsA("BasePart"), (`{model:GetFullName()} is missing its EggSpotBottom marker`))
	local position = eggSpotBottom.Position
	return {
		model = model,
		grid = { math.round(position.X * 1000), math.round(position.Z * 1000), (math.round(position.Y * 1000)) },
		label = model.Name
	}
end

local function precedes(p, p2)
	for i = 1, 3 do
		if p.grid[i] ~= p2.grid[i] then
			return p.grid[i] < p2.grid[i]
		end
	end

	return p.label < p2.label
end

function v.SortedNests(instance)
	strict(instance)
	local nests = instance.Nests
	assert(
		nests:IsA("Folder") or nests:IsA("Model"),
		(`{instance:GetFullName()} must keep its nests in a Folder or a Model`)
	)
	local v2 = {}

	for _, model in nests:GetChildren() do
		if model:IsA("Model") then
			table.insert(v2, (rankOf(model)))
		end
	end

	table.sort(v2, precedes)
	local models = table.create(#v2)

	for k, v3 in v2 do
		models[k] = v3.model
	end

	return models
end

function v.NestIdFor(instance, instance2)
	strict(instance)
	strict(instance2)
	local index = table.find(v.SortedNests(instance), instance2)

	if index == nil then
		error((`{instance2:GetFullName()} does not sit under {instance:GetFullName()}`))
	end

	return string.format("Slot_%03d", index)
end

function v.NestFor(p, value: string)
	strict(p)
	strict2(value)
	local v2 = string.match(value, "^Slot_(%d+)$")
	assert(v2 ~= nil, (`{value} does not name a nest slot`))
	local v3 = tonumber(v2)
	assert(v3 ~= nil, (`{value} carries a slot number that will not parse`))
	local v4 = v.SortedNests(p)[v3]
	assert(v4 ~= nil, (`{p.Name} has nothing at slot {value}`))
	return v4
end

function v.SlotKey(p: string, p2: string)
	strict2(p)
	strict2(p2)
	return string.format("%s:%s", p, p2)
end

function v.LooksLikeFirstAreaUid(value: string)
	strict2(value)
	return string.find(value, "FirstAreaEgg_", 1, true) == 1
end

function v.FirstAreaOwnerUserId(value: string)
	strict2(value)
	local v2 = string.match(value, "^FirstAreaEgg_(-?%d+)_")

	if v2 == nil then
		return nil
	end

	return (tonumber(v2))
end

return table.freeze(v)