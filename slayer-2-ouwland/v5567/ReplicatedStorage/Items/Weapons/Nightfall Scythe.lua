local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://116069758742823",
	Description = "A green and gold set blade for demon hands, its long edge made to sweep wide and answer with bloodlust.",
	Rarity = 6,
	Series = "Nightfall",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	EquipRequirements = {
		Race = { "Demon", "Hybrid" }
	},
	HasCombat = true,
	CombatPreset = "Scythe",
	Mastery = "Scythe",
	SkillCategory = "Scythe",
	ActiveToolStats = {
		["Additional Damage"] = 5.75,
		["Additional Damage Factor"] = 0.148,
		["Block Points"] = 7.75,
		["Block Regen"] = 1.27,
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