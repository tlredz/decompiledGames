local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://76799487746233",
	Description = "Deep green set claws banded in gold over old bandages, for the moment a demon turns a hit taken into a hit returned.",
	Rarity = 6,
	Series = "Nightfall",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	EquipRequirements = {
		Race = { "Demon", "Hybrid" }
	},
	DemonArt = "All,exceptBlood Manipulation",
	HasCombat = true,
	CombatPreset = "Claws",
	Mastery = "Claws",
	SkillCategory = "Claws",
	ActiveToolStats = {
		["Additional Damage"] = 5.75,
		["Additional Damage Factor"] = 0.146,
		["Block Points"] = 7.4,
		["Block Regen"] = 1.22,
		["Max Stamina"] = 5
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "TriClaw Reversal",
			SkillStats = {
				cancel_bypass = true
			},
			CoolDown = 12,
			icon = "rbxassetid://129904287008684",
			Max_Hold = 5,
			Stamina = 18
		},
		{
			Name = "Predator Claws",
			CoolDown = 14,
			icon = "rbxassetid://115960609606998",
			Max_Hold = 1.9,
			Boss = "Kaiden",
			Stamina = 22
		}
	}
}