require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
local Sickles = require(script.Parent.Sickles)
return {
	Icon = "rbxassetid://17802518265",
	Description = "Gyutai's paired sickles draw Blood Manipulation through their own blades, sending the art where bare hands cannot.",
	Rarity = 5,
	EquipType = Sickles.EquipType,
	Price = {
		["Metal Scraps"] = 10,
		["Refinement Ore"] = 6
	},
	DemonArt = Sickles.DemonArt,
	EquipRequirements = Sickles.EquipRequirements,
	ActiveToolStats = {
		["Additional Damage"] = 2,
		["Additional Damage Factor"] = 0.038,
		["Block Points"] = 2.25
	},
	Skills = Sickles.Skills,
	Mastery = Sickles.Mastery,
	SkillCategory = Sickles.SkillCategory,
	HasCombat = Sickles.HasCombat,
	CombatPreset = "Sickles"
}