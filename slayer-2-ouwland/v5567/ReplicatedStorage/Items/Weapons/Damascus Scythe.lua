local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://92028275393089",
	Description = "A reaper's blade edged in violet, made for sweeping slashes and blood drunk lunges.",
	Rarity = 6,
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	NoSell = true,
	EquipRequirements = {
		Race = { "Demon", "Hybrid" }
	},
	HasCombat = true,
	CombatPreset = "Scythe",
	Mastery = "Scythe",
	SkillCategory = "Scythe",
	ActiveToolStats = {
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.077,
		["Block Points"] = 4.65,
		["Block Regen"] = 0.75
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Reaper Slash",
			CoolDown = 13,
			icon = "rbxassetid://78137253102226",
			Max_Hold = 5,
			Stamina = 20
		},
		{
			Name = "Blood Lust",
			CoolDown = 20,
			icon = "rbxassetid://105328220601414",
			Max_Hold = 2.5,
			Stamina = 30
		}
	}
}