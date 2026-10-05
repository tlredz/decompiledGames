local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Data.Rarity)
local t = require(ReplicatedStorage.Packages.t)
local interface = t.interface({
	Single = t.interface({
		Ids = t.array(t.string),
		Data = t.interface({
			Speed = t.array(t.number),
			Volume = t.number
		})
	})
})
local interface2 = t.interface({
	DisplayName = t.string,
	Rarity = t.optional(t.table),
	Desc = t.optional(t.string),
	Icon = t.optional(t.string),
	Sounds = t.optional(interface),
	CollectDistanceOverride = t.optional(t.numberPositive),
	PickupDistanceOverride = t.optional(t.numberPositive),
	_id = t.string
})

local function byName(p, p2)
	return p.Name < p2.Name
end

local function collectCurrencies(configs)
	local children = configs:GetChildren()
	table.sort(children, byName)
	local modulesByName = {}

	for _, moduleScript in children do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local module = require(moduleScript)
		local v, v2 = interface2(module)

		if not v then
			error((`currency config {moduleScript.Name} is malformed: {v2}`))
		end

		if module._id ~= moduleScript.Name then
			error((`currency config {moduleScript.Name} declares _id "{module._id}"`))
		end

		modulesByName[moduleScript.Name] = module
	end

	return table.freeze(modulesByName)
end

local directory = collectCurrencies(script.Configs)
return table.freeze({
	Directory = directory,
	Get = function(p: string)
		local v2 = directory[p]

		if v2 == nil then
			error(`no currency is registered under "{p}"`, 2)
		end

		return v2
	end,
	CurrencyNameExists = function(p: string)
		if directory[p] == nil then
			return false, (`no currency is registered under "{p}"`)
		end

		return true
	end
})