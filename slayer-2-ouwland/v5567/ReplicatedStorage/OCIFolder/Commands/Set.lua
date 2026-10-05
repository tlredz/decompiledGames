local modulesByName = {}
local names = {}

for _, moduleScript in pairs(script:GetChildren()) do
	local name = moduleScript.Name:lower()
	local module = require(moduleScript)
	modulesByName[name] = module
	table.insert(names, moduleScript.Name)
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Clans = require(ReplicatedStorage.CAM:WaitForChild("Clans"))
local clan = { "None" }

for _, rarity in Clans.Rarities do
	for k in Clans.GetByRarity(rarity.rarity) or {} do
		table.insert(clan, k)
	end
end

local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local checklist = {}
local v3 = {
	race = {
		"Human",
		"Slayer",
		"Demon",
		"Hybrid"
	},
	clan = clan,
	progresslevel = { "Slayer", "Demon" },
	playtime = { "0", "15" },
	onboarding = {
		"0",
		"3",
		"4",
		"5",
		"6"
	},
	checklist = 0
}

for k in require(ReplicatedStorage2.CAM.Global.Checklists) do
	table.insert(checklist, k)
end

table.sort(checklist)
v3.checklist = checklist
return {
	Clearance = 1,
	Priority = 10,
	Keys = {
		{
			Type = "Players",
			Required = true
		},
		{
			Type = "Set Category",
			Required = true,
			Suggester = names
		},
		{
			Required = true,
			Suggester = function(list)
				return v3[(list[2] or ""):lower()]
			end
		},
		{
			Type = "Amount",
			Name = "Amount",
			Required = false,
			Completer = function(p: string)
				return (tonumber(p))
			end
		}
	},
	Server = function(_, p, value, ...)
		if modulesByName[value:lower()] then
			return modulesByName[value:lower()](p, ...)
		end
	end
}