local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://86745583744655",
	Description = "Firstlight work at the head of a long shaft, made to order and made to be taken back to the forge again.",
	Rarity = 6,
	Series = "Firstlight",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	EquipRequirements = {
		Race = { "Human", "Slayer", "Hybrid" }
	},
	HasCombat = true,
	CombatPreset = "Spear",
	Mastery = "Spear",
	SkillCategory = "Spear",
	ActiveToolStats = {
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.148,
		["Block Points"] = 8.8,
		["Block Regen"] = 1.93,
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
			Name = "Storm Rush",
			SkillStats = {
				additional_damage_scale = 0.78,
				cancel_bypass = true
			},
			CoolDown = 18,
			icon = "rbxassetid://71270513349797",
			Max_Hold = 6,
			Stamina = 28
		},
		{
			Name = "Storm Piercer",
			SkillStats = {
				strict_stun = true,
				cancel_bypass = true
			},
			CoolDown = 14,
			icon = "rbxassetid://73641228099685",
			Max_Hold = 2,
			Stamina = 22
		}
	}
}