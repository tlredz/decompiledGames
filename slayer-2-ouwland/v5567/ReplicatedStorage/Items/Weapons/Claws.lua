local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://85714640127883",
	Description = "Hooked demon claws built for close reversals, turning a staggered moment into a savage counter and chase.",
	Rarity = 4,
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Metal Scraps"] = 10,
		["Refinement Ore"] = 2
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
		["Additional Damage"] = 1,
		["Additional Damage Factor"] = 0.02,
		["Block Points"] = 1.2
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