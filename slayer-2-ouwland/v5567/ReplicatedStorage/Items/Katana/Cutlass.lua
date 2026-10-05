local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://136890296113836",
	Description = "Zuko's short curved blade favors close work, opening with a double cut and a quick-draw flurry when space runs out.",
	Rarity = 3,
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Metal Scraps"] = 10
	},
	HasCombat = true,
	CombatPreset = "Regular Katana",
	Mastery = "Sword",
	ActiveToolStats = {
		["Additional Damage"] = 1,
		["Additional Damage Factor"] = 0.009,
		["Block Points"] = 0.45
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Double Cut",
			CoolDown = 12,
			icon = "rbxassetid://17106414316",
			Max_Hold = 5,
			Stamina = 12
		},
		{
			Name = "Quick Draw",
			SkillStats = {
				additional_damage_scale = 0.41
			},
			CoolDown = 14,
			icon = "rbxassetid://17106414221",
			Max_Hold = 5,
			Boss = "Zuko",
			Stamina = 20
		}
	}
}