local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://88604236534027",
	Description = "A demon's reaping blade from sealed caches, built around wide slashes and a blood hungry follow-up.",
	Rarity = 5,
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Metal Scraps"] = 10,
		["Refinement Ore"] = 6
	},
	EquipRequirements = {
		Race = { "Demon", "Hybrid" }
	},
	HasCombat = true,
	CombatPreset = "Scythe",
	Mastery = "Scythe",
	SkillCategory = "Scythe",
	ActiveToolStats = {
		["Additional Damage"] = 2,
		["Additional Damage Factor"] = 0.042,
		["Block Points"] = 2.7
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