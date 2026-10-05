local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://110963307315061",
	Description = "Violet plated claws with a hungry curve, sharpened for the brutal reversal and the pursuit that follows.",
	Rarity = 6,
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	NoSell = true,
	EquipRequirements = {
		Race = { "Demon", "Hybrid" }
	},
	DemonArt = "All,exceptBlood Manipulation",
	HasCombat = true,
	CombatPreset = "Claws",
	Mastery = "Claws",
	SkillCategory = "Claws",
	ActiveToolStats = {
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.075,
		["Block Points"] = 4.35,
		["Block Regen"] = 0.65
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