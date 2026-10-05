local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.ClanTypes)
local Shared = require(script.Parent.Shared)
local Rare = require(script.Parent.Rare)
local Legendary = require(script.Parent.Legendary)
local Mythic = require(script.Parent.Mythic)
local v = {
	Rare,
	Legendary,
	Mythic,
	require(script.Parent.Supreme)
}

local function from(p: string, p2: string)
	for _, v2 in v do
		local v3 = v2[p]

		if v3 == nil then
			continue
		end

		for _, skill in v3.skills do
			if skill.name == p2 then
				return skill
			end
		end
	end

	error((`Test bench: {p} has no skill named "{p2}"`))
end

local stats = {
	["Max Health"] = 200,
	["Health Regen Speed"] = 0.1,
	["Max Stamina"] = 150,
	["Stamina Regen Speed"] = 0.1,
	["Movement Speed Factor"] = 0.1,
	["Additional Damage"] = 10,
	["Additional Damage Factor"] = 0.25,
	["Damage Reduction"] = 5,
	["Damage Reduction Factor"] = 0.1,
	["Block Points"] = 10,
	["Block Regen"] = 0.5
}
local passives = {
	Shared.PainResistance,
	Shared.EnhancedSpeed,
	Shared.TacticalIntellect,
	Shared.MasterSwordsman,
	Shared.IndomitableWillImmunity
}
return {
	Test = {
		name = "Test",
		rarity = 7,
		archetype = "Ascendant",
		flavour = "Not a real bloodline. A bench for testing the clan pipeline end to end.",
		stats = stats,
		skills = {
			from("Shabana", "Core Detachment"),
			from("Shabana", "Poison Generation"),
			from("Shinazugawa", "Marechi's Blade"),
			from("Tamayo", "Pharmaceutical Skills"),
			Shared.IndomitableWill,
			from("Agatsuma", "Enhanced Hearing"),
			from("Iguro", "Kaburamaru"),
			from("Iguro", "Flash Step"),
			from("Douma", "Extrasensory Perception"),
			from("Ubuyashiki", "Demon Slayer Summon"),
			from("Douma", "Speed & Reflex")
		},
		passives = passives
	},
	["Test Clan2"] = {
		name = "Test Clan2",
		rarity = 7,
		archetype = "Ascendant",
		flavour = "The second half of the bench. Not a real bloodline.",
		stats = stats,
		skills = {
			from("Rengoku", "Heart Ablaze Mode"),
			from("Uzui", "Musical Score"),
			from("Yahaba", "Disruption Pulse"),
			from("Ubuyashiki", "Self-Destruct"),
			from("Ubuyashiki", "Soothing Voice"),
			from("Tamayo", "Demon Coagulant"),
			from("Soyama", "Bell Splitter"),
			from("Kamado", "Headbutt"),
			from("Uzui", "Vital Draw")
		},
		passives = passives
	}
}