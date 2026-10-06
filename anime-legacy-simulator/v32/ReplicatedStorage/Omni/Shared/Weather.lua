local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Mutations = require(script.Parent.Mutations)
local v = nil
local v2 = nil
local names = {}
local total = 0
local v3 = {
	List = {},
	Origin = 1789948800,
	Version = 1,
	AttributeName = "WeatherState"
}

local function IsFinite(value)
	return typeof(value) == "number" and math.isfinite(value)
end

local function SelectWeather(object)
	local v4 = object:NextNumber() * total
	local total2 = 0

	for _, v5 in names do
		total2 += v3.List[v5].Chance

		if v4 < total2 then
			return v5
		end
	end

	return names[#names]
end

function v3.Validate(p: string, data)
	assert(typeof(data) == "table", (`Invalid weather: {p}`))
	local chance = data.Chance
	local v4

	if typeof(chance) == "number" then
		v4 = math.isfinite(chance)
	else
		v4 = false
	end

	assert(v4 and data.Chance >= 0, (`Invalid chance: {p}`))
	local duration = data.Duration
	local v5

	if typeof(duration) == "number" then
		v5 = math.isfinite(duration)
	else
		v5 = false
	end

	if v5 then
		if data.Duration >= 1 then
			v5 = data.Duration % 1 == 0
		else
			v5 = false
		end
	end

	assert(v5, (`Invalid duration: {p}`))
	local v6

	if typeof(data.Perks) == "table" then
		v6 = typeof(data.Mutations) == "table"
	else
		v6 = false
	end

	assert(v6, (`Invalid weather rewards: {p}`))

	for _, perk in data.Perks do
		local v7

		if typeof(perk) == "table" then
			v7 = perk.Type == "Add" or perk.Type == "Multi"
		else
			v7 = false
		end

		assert(v7, (`Invalid perk: {p}`))
		local amount = perk.Amount
		local v8

		if typeof(amount) == "number" then
			v8 = math.isfinite(amount)
		else
			v8 = false
		end

		assert(v8 and perk.Amount >= (perk.Type == "Multi" and 1 or 0), (`Invalid perk amount: {p}`))
	end

	Mutations.Roll(data.Mutations, 99.999999)
end

function v3.CreateCursor()
	local random = Random.new(1789948801)
	local name = SelectWeather(random)
	return {
		Generator = random,
		Name = name,
		StartedAt = 1789948800,
		EndsAt = 1789948800 + v3.List[name].Duration
	}
end

function v3:AdvanceCursor(value: number, callback)
	local v4

	if typeof(value) == "number" then
		v4 = math.isfinite(value)
	else
		v4 = false
	end

	assert(v4 and value >= 1789948800, "Weather time precedes schedule origin")
	assert(self.StartedAt <= value, "Weather cursor cannot move backwards")
	local count = 0

	while self.EndsAt <= value do
		self.StartedAt = self.EndsAt
		self.Name = SelectWeather(self.Generator)
		self.EndsAt = self.StartedAt + v3.List[self.Name].Duration
		count += 1

		if callback and count % 2048 == 0 then
			callback()
		end
	end

	return {
		Name = self.Name,
		StartedAt = self.StartedAt,
		EndsAt = self.EndsAt,
		Mode = "Auto",
		Version = v3.Signature
	}
end

function v3.IsState(data)
	local v4

	if typeof(data) == "table" and typeof(data.Name) == "string" and v3.List[data.Name] ~= nil then
		local startedAt = data.StartedAt

		if typeof(startedAt) == "number" then
			v4 = math.isfinite(startedAt)
		else
			v4 = false
		end

		if v4 then
			local endsAt = data.EndsAt

			if typeof(endsAt) == "number" then
				v4 = math.isfinite(endsAt)
			else
				v4 = false
			end

			if v4 then
				if data.EndsAt > data.StartedAt and data.Version == v3.Signature then
					return data.Mode == "Auto" or data.Mode == "Local" or data.Mode == "Global"
				else
					return false
				end
			end
		end
	else
		return false
	end

	return v4
end

function v3.GetState()
	local weatherState = ReplicatedStorage:GetAttribute("WeatherState")

	if weatherState == v then
		return v2
	end

	v = weatherState
	v2 = nil

	if typeof(weatherState) == "string" then
		local success, result = pcall(HttpService.JSONDecode, HttpService, weatherState)

		if success and v3.IsState(result) then
			v2 = result
		end
	end

	return v2
end

function v3.SystemSolver(p: string)
	local state = v3.GetState()
	local v4 = state and v3.List[state.Name]
	local v5 = v4 and v4.Perks[p]
	return v5 and { v5 } or {}
end

local v4 = { tostring(1789948800), (tostring(1)) }

for _, moduleScript in script:GetChildren() do
	if not moduleScript:IsA("ModuleScript") then
		continue
	end

	local module = require(moduleScript)
	v3.Validate(moduleScript.Name, module)
	module.Name = moduleScript.Name
	v3.List[moduleScript.Name] = module
	table.insert(names, moduleScript.Name)
	total += module.Chance
end

table.sort(names)
assert(total > 0, "Weather catalog has no positive chances")

for _, v5 in names do
	local v6 = v3.List[v5]
	table.insert(v4, (`{v5}:{v6.Chance}:{v6.Duration}`))

	for _, v7 in { "Perks", "Mutations" } do
		local v8 = {}

		for k in v6[v7] do
			table.insert(v8, k)
		end

		table.sort(v8)

		for _, v9 in v8 do
			local v10 = v6[v7][v9]
			table.insert(v4, (`{v7}:{v9}:{v7 == "Perks" and `{v10.Type}:{v10.Amount}` or tostring(v10)}`))
		end
	end
end

local v5 = 5381

for _, v6 in { string.byte(table.concat(v4, "|"), 1, -1) } do
	v5 = (v5 * 33 + v6) % 4294967296
end

v3.Signature = `{1}:{v5}`
return table.freeze(v3)