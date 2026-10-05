local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Common.RewardInfo)
local v2 = require3(ReplicatedStorage2.ServerInfo)
return {
	["Righteous Blade"] = {
		Regular = v.createSwordReward("Righteous Blade"),
		Awakened = v.createSwordReward("Awakened Righteous Blade")
	},
	["Emperor's Axe"] = {
		Regular = v.createSwordReward("Emperor's Axe"),
		Awakened = v.createSwordReward("Awakened Emperor's Axe")
	},
	["Void Hammer"] = {
		Regular = v.createSwordReward("Void Hammer"),
		Awakened = v.createSwordReward("Awakened Void Hammer")
	},
	["Anchored Crusher"] = {
		Regular = v.createSwordReward("Anchored Crusher"),
		Awakened = v.createSwordReward("Awakened Anchored Crusher")
	},
	["Crystal Staff"] = {
		Regular = v.createSwordReward("Crystal Staff"),
		Awakened = v.createSwordReward("Awakened Crystal Staff")
	},
	["Lunar Protector"] = {
		Regular = v.createSwordReward("Lunar Protector"),
		Awakened = v.createSwordReward("Awakened Lunar Protector")
	},
	["Winter's Touch"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Winter's Touch"),
		Awakened = v.createSwordReward("Awakened Winter's Touch")
	},
	Venomweaver = {
		CustomSlash = true,
		Regular = v.createSwordReward("Venomweaver"),
		Awakened = v.createSwordReward("Awakened Venomweaver")
	},
	["Medusa's Wraith"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Medusa's Wraith"),
		Awakened = v.createSwordReward("Awakened Medusa's Wraith")
	},
	["Trinity Axe"] = {
		Regular = v.createSwordReward("Trinity Axe"),
		Awakened = v.createSwordReward("Awakened Trinity Axe")
	},
	["Fabled Sword"] = {
		Regular = v.createSwordReward("Fabled Sword"),
		Awakened = v.createSwordReward("Awakened Fabled Sword")
	},
	["Forgotten Scythe"] = {
		Regular = v.createSwordReward("Forgotten Scythe"),
		Awakened = v.createSwordReward("Awakened Forgotten Scythe")
	},
	["Dragon's Wraith"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Dragon's Wraith"),
		Awakened = v.createSwordReward("Awakened Dragon's Wraith")
	},
	["Frozen Eternity"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Frozen Eternity"),
		Awakened = v.createSwordReward("Awakened Frozen Eternity")
	},
	["Phoenix Rebirth"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Phoenix Rebirth"),
		Awakened = v.createSwordReward("Awakened Phoenix Rebirth")
	},
	["Emerald Katana"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Emerald Katana"),
		Awakened = v.createSwordReward("Awakened Emerald Katana")
	},
	["Sky Axe"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Sky Axe"),
		Awakened = v.createSwordReward("Awakened Sky Axe")
	},
	["Blazing Darkblade"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Blazing Darkblade"),
		Awakened = v.createSwordReward("Awakened Blazing Darkblade")
	},
	["Empyreal Blade"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Empyreal Blade"),
		Awakened = v.createSwordReward("Awakened Empyreal Blade")
	},
	["Bane of Ferocity"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Bane of Ferocity"),
		Awakened = v.createSwordReward("Awakened Bane of Ferocity")
	},
	Ashblade = {
		CustomSlash = true,
		Regular = v.createSwordReward("Ashblade"),
		Awakened = v.createSwordReward("Awakened Ashblade")
	},
	["Kraken's Wraith"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Kraken's Wraith"),
		Awakened = v.createSwordReward("Awakened Kraken's Wraith")
	},
	["Megatooth Relic"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Megatooth Relic"),
		Awakened = v.createSwordReward("Awakened Megatooth Relic")
	},
	["Void Engine Blade"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Void Engine Blade"),
		Awakened = v.createSwordReward("Awakened Void Engine Blade")
	},
	["Oblivion Scythe"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Oblivion Scythe"),
		Awakened = v.createSwordReward("Awakened Oblivion Scythe")
	},
	["Titan's Gleam"] = {
		Regular = v.createSwordReward("Titan's Gleam"),
		Awakened = v.createSwordReward("Awakened Titan's Gleam")
	},
	["Sunburst Axe"] = {
		Regular = v.createSwordReward("Sunburst Axe"),
		Awakened = v.createSwordReward("Awakened Sunburst Axe")
	},
	["Lunar Hammer"] = {
		Regular = v.createSwordReward("Lunar Hammer"),
		Awakened = v.createSwordReward("Awakened Lunar Hammer")
	},
	["Eggquinox Blade"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Eggquinox Blade"),
		Awakened = v.createSwordReward("Awakened Eggquinox Blade")
	},
	["Moral Duality"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Moral Duality"),
		Awakened = v.createSwordReward("Awakened Moral Duality")
	},
	Architect = {
		CustomSlash = true,
		Regular = v.createSwordReward("Architect"),
		Awakened = v.createSwordReward("Awakened Architect")
	},
	Subversion = {
		CustomSlash = true,
		Regular = v.createSwordReward("Subversion"),
		Awakened = v.createSwordReward("Awakened Subversion")
	},
	["Everbloom Fang"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Everbloom Fang"),
		Awakened = v.createSwordReward("Awakened Everbloom Fang")
	},
	["Staff of Despair"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Staff of Despair"),
		Awakened = v.createSwordReward("Awakened Staff of Despair")
	},
	["Hydra's Bane"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Hydra's Bane"),
		Awakened = v.createSwordReward("Awakened Hydra's Bane")
	},
	["Ancient Defender"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Ancient Defender"),
		Awakened = v.createSwordReward("Awakened Ancient Defender")
	},
	["Cybotic Scythe"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Cybotic Scythe"),
		Awakened = v.createSwordReward("Awakened Cybotic Scythe")
	},
	Netherfang = {
		CustomSlash = true,
		Regular = v.createSwordReward("Netherfang"),
		Awakened = v.createSwordReward("Awakened Netherfang")
	},
	["Aurora's Wrath"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Aurora's Wrath"),
		Awakened = v.createSwordReward("Awakened Aurora's Wrath")
	},
	["Frost Reaper"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Frost Reaper"),
		Awakened = v.createSwordReward("Awakened Frost Reaper")
	},
	["Eclipse Desire"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Eclipse Desire"),
		Awakened = v.createSwordReward("Awakened Eclipse Desire")
	},
	["Exo-Godslayer"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Exo-Godslayer"),
		Awakened = v.createSwordReward("Awakened Exo-Godslayer")
	},
	["Mythic Eggclipse"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Mythic Eggclipse"),
		Awakened = v.createSwordReward("Awakened Mythic Eggclipse")
	},
	["Oni's Pact"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Oni's Pact"),
		Awakened = v.createSwordReward("Awakened Oni's Pact")
	},
	["Voltage Edge"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Voltage Edge"),
		Awakened = v.createSwordReward("Awakened Voltage Edge")
	},
	Oniwake = {
		CustomSlash = true,
		Regular = v.createSwordReward("Oniwake"),
		Awakened = v.createSwordReward("Awakened Oniwake")
	},
	["Abyssal Slicer"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Abyssal Slicer"),
		Awakened = v.createSwordReward("Awakened Abyssal Slicer")
	},
	["Everfrost Scythe"] = {
		CustomSlash = false,
		Regular = v.createSwordReward("Everfrost Scythe"),
		Awakened = v.createSwordReward("Awakened Everfrost Scythe")
	},
	["Cosmic Keystone"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Cosmic Keystone"),
		Awakened = v.createSwordReward("Awakened Cosmic Keystone")
	},
	["Celestial Aegis"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Celestial Aegis"),
		Awakened = v.createSwordReward("Awakened Celestial Aegis")
	},
	["Periastron's Glory"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Periastron's Glory"),
		Awakened = v.createSwordReward("Awakened Periastron's Glory")
	},
	Nightfall = {
		CustomSlash = true,
		Regular = v.createSwordReward("Nightfall"),
		Awakened = v.createSwordReward("Awakened Nightfall")
	},
	["Cursed Abyss"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Cursed Abyss"),
		Awakened = v.createSwordReward("Awakened Cursed Abyss")
	},
	["Kraken's Fury"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Kraken's Fury"),
		Awakened = v.createSwordReward("Awakened Kraken's Fury")
	},
	["Ethereal Scythe"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Ethereal Scythe"),
		Awakened = v.createSwordReward("Awakened Ethereal Scythe")
	},
	["Chrono Fang"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Chrono Fang"),
		Awakened = v.createSwordReward("Awakened Chrono Fang")
	},
	["Onyx Katana"] = {
		CustomSlash = true,
		Regular = v.createSwordReward("Onyx Katana"),
		Awakened = v.createSwordReward("Awakened Onyx Katana")
	},
	["Enchanted Blade"] = {
		Regular = v.createSwordReward("Enchanted Blade"),
		Awakened = v.createSwordReward("Awakened Enchanted Blade")
	},
	Requirement = 1500,
	GetSecretRate = function(value)
		if v2.isTestGame() then
			return 0.2
		end

		if value == "DungeonSwordCrate" then
			return 0.0015
		end

		if string.find(value, "Premium") then
			return 0.008
		end

		return 0.0002
	end,
	NormalOdds = 0.0002,
	PremiumOdds = 0.008
}