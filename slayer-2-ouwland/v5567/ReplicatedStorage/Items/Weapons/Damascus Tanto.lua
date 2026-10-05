local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://133207752168261",
	Description = "A short blade sunk in violet, suited to phantom rushes, spiral cuts, and drops from above.",
	Rarity = 6,
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	NoSell = true,
	EquipRequirements = {
		Race = { "Human", "Slayer", "Hybrid" }
	},
	HasCombat = true,
	CombatPreset = "Tanto",
	Mastery = "Tanto",
	SkillCategory = "Tanto",
	ActiveToolStats = {
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.082,
		["Block Points"] = 5.4,
		["Block Regen"] = 1
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Phantom Barrage",
			SkillStats = {
				skills_to_play_over = {
					Blocking = true
				},
				additional_damage_scale = 0.6
			},
			CoolDown = 14,
			icon = "rbxassetid://116755335274578",
			Max_Hold = 4,
			Stamina = 22
		},
		{
			Name = "Spiral Fang",
			SkillStats = {
				additional_damage_scale = 0.32,
				cancel_bypass = true
			},
			CoolDown = 12,
			icon = "rbxassetid://102490463926612",
			Max_Hold = 3,
			Stamina = 14
		},
		{
			Name = "Tanto Descent",
			CoolDown = 14,
			icon = "rbxassetid://105261161007701",
			Max_Hold = 5,
			Stamina = 22
		}
	}
}