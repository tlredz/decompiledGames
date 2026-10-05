local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Rarities = require(ReplicatedStorage.CAM.Global.Rarities)
local Config = require(ReplicatedStorage.CAM.Global.SeasonRewards.Config)
local SettingsLive = require(ReplicatedStorage.CAM.Global.SettingsLive)
require(ReplicatedStorage.CAM.Global.Types.TitleTypes)
local Utility = require(ReplicatedStorage.CAM.Global.Utility)
local Titles = {
	BoostSlots = 3,
	Definitions = require(script.DefaultConfigs)
}
Titles.Live = SettingsLive.new("Titles", Titles.Definitions, Titles.Definitions)
local v = {}

function Titles.SeasonId(p: string, p2: string, p3: string)
	return (`Season:{p}:{p2}:{p3}`)
end

local function masteryOf(p: string)
	for _, definition in Titles.Definitions do
		local requirement = definition.requirements[1]

		if requirement ~= nil and requirement.counter == `mastered_{p}` then
			return definition
		end
	end

	return nil
end

local function seasonTitle(value: string)
	if type(value) ~= "string" then
		return nil
	end

	local v2, v3, displayName = string.match(value, "^Season:([^:]+):([^:]+):(.+)$")
	local v5

	if v3 ~= nil then
		v5 = Config.Groups[v3]
	end

	local v6

	if not (v5 == nil or v5.TitleGrades == nil) then
		v6 = v5.TitleGrades[v2]
	end

	local v7

	if v2 ~= nil then
		v7 = v6 or Config.TitleGrades[v2]
	end

	if v7 == nil then
		return nil
	end

	local v8 = v[value]

	if v8 ~= nil then
		return v8
	end

	local v9 = masteryOf(v3)
	v8 = {
		displayName = displayName,
		season = string.match(displayName, "^(Season %d+) "),
		description = "A ranked season reward.",
		category = "Ranked",
		rarity = v7.rarity,
		color = 0,
		particle = 0,
		requirements = 0,
		buffs = 0,
		collection = 0,
		disabled = false
	}
	local color

	if v9 == nil then
		color = Config.TitleColors[v3]
	else
		color = v9.color
	end

	v8.color = color
	local particle

	if v9 == nil then
		particle = Config.TitleParticles[v3] or string.match(
			string.gsub(displayName, " #%d+$", ""),
			"^Season %d+ (.+)$"
		)
	else
		particle = v9.displayName
	end

	v8.particle = particle
	v8.requirements = {}
	v8.buffs = v7.buffs
	v8.collection = v7.collection
	v[value] = v8
	return v8
end

function Titles.Get(p: string)
	local selected = Titles.Definitions[p] or seasonTitle(p)

	if selected == nil or selected.disabled == true then
		return nil
	end

	return selected
end

function Titles.GetAll()
	local definitions = {}

	for k, definition in Titles.Definitions do
		if definition.disabled ~= true then
			definitions[k] = definition
		end
	end

	return definitions
end

function Titles.GetColor(p: string)
	local v2 = Titles.Definitions[p] or seasonTitle(p)

	if v2 ~= nil and v2.color ~= nil then
		return v2.color
	end

	local v3

	if v2 ~= nil then
		v3 = table.find(Rarities.Order, v2.rarity)
	end

	return ColorSequence.new(Rarities.Colors[v3 or 1])
end

function Titles.GetStatBonus(p, p2: string)
	local data, v2 = Utility.GetData(p)

	if data == nil then
		return 0
	end

	local total = 0

	for _, child in data.EquippedTitles.Boost:GetChildren() do
		local v3 = Titles.Get(child.Value)

		if not (v3 ~= nil and v3.buffs ~= nil) then
			continue
		end

		for _, buff in v3.buffs do
			if buff.stat == p2 and type(buff.amount) == "number" then
				total += buff.amount
			end
		end
	end

	for _, child in v2.PlayerTitles.Unlocked:GetChildren() do
		local v3 = Titles.Get(child.Name)

		if not (v3 ~= nil and v3.collection ~= nil) then
			continue
		end

		for _, v4 in v3.collection do
			if v4.stat == p2 and type(v4.amount) == "number" then
				total += v4.amount
			end
		end
	end

	return total
end

return Titles