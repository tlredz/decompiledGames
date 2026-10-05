local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://95591270480228",
	Description = "Damascus grain runs through the twin sickles, letting a demon carve Blood Manipulation into hooked arcs.",
	Rarity = 6,
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	NoSell = true,
	DemonArt = "Blood Manipulation",
	EquipRequirements = {
		Race = { "Demon", "Hybrid" }
	},
	HasCombat = true,
	CombatPreset = "Sickles",
	Mastery = "Sickles",
	SkillCategory = "Sickles",
	ActiveToolStats = {
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.08,
		["Block Points"] = 5.1,
		["Block Regen"] = 0.9
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Execution Scyther",
			SkillStats = {
				additional_damage_scale = 0.4
			},
			CoolDown = 18,
			icon = "rbxassetid://74114109530745",
			Max_Hold = 5,
			Stamina = 28
		},
		{
			Name = "Scyther Vortex",
			SkillStats = {
				additional_damage_scale = 0.28
			},
			CoolDown = 15,
			icon = "rbxassetid://85996996726779",
			Max_Hold = 5,
			Boss = "Hoyuzo",
			Stamina = 24
		}
	}
}