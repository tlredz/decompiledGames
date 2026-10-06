require("@game/ReplicatedStorage/Omni/DataTemplate")
local random = Random.new()
local v = {
	List = {}
}

local function IsPositive(value)
	return typeof(value) == "number" and value > 0 and value < 1e999
end

function v.Register(name: string, state)
	if typeof(name) ~= "string" or name == "" or v.List[name] or typeof(state) ~= "table" then
		return false
	end

	if typeof(state.MapName) ~= "string" or state.MapName == "" or (typeof(state.Folder) ~= "string" or state.Folder == "") then
		return false
	end

	local interval = state.Interval
	local v2

	if typeof(interval) == "number" and interval > 0 then
		v2 = interval < 1e999
	else
		v2 = false
	end

	if not v2 then
		return false
	end

	local lifetime = state.Lifetime
	local v3

	if typeof(lifetime) == "number" and lifetime > 0 then
		v3 = lifetime < 1e999
	else
		v3 = false
	end

	if not v3 then
		return false
	end

	local collectDistance = state.CollectDistance
	local v4

	if typeof(collectDistance) == "number" and collectDistance > 0 then
		v4 = collectDistance < 1e999
	else
		v4 = false
	end

	if not v4 or (typeof(state.Fruits) ~= "table" or #state.Fruits == 0) then
		return false
	end

	local v5 = {}
	local total = 0

	for _, fruit in state.Fruits do
		if typeof(fruit) ~= "table" or (typeof(fruit.Name) ~= "string" or fruit.Name == "") then
			return false
		end

		if typeof(fruit.Model) ~= "string" or fruit.Model == "" or v5[fruit.Name] then
			return false
		end

		local chance = fruit.Chance
		local v6

		if typeof(chance) == "number" and chance > 0 then
			v6 = chance < 1e999
		else
			v6 = false
		end

		if v6 then
			v5[fruit.Name] = true
			total += fruit.Chance
			continue
		end

		return false
	end

	local v6

	if typeof(total) == "number" and total > 0 then
		v6 = total < 1e999
	else
		v6 = false
	end

	if not v6 then
		return false
	end

	state.Name = name
	v.List[name] = state
	return true
end

function v.GetFruit(p, p2: string)
	for _, fruit in p.Fruits do
		if fruit.Name == p2 then
			return fruit
		end
	end

	return nil
end

function v.Roll(p, value: number?)
	if value == nil then
		value = random:NextNumber()
	end

	if typeof(value) ~= "number" or not (value >= 0 and value < 1) then
		return nil
	end

	local total = 0

	for _, fruit in p.Fruits do
		total += fruit.Chance
	end

	local v2 = value * total
	local total2 = 0

	for _, fruit in p.Fruits do
		total2 += fruit.Chance

		if v2 < total2 then
			return fruit
		end
	end

	return nil
end

function v.OwnsFruit(p, p2: string)
	for _, v2 in p.Weapons.List do
		if v2.Name == p2 then
			return true
		end
	end

	return false
end

return table.freeze(v)