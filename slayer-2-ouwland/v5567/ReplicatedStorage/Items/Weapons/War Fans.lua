local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://105471122563052",
	Description = "Domae's fans open gold and lotus painted, though what answers through them is Cryokinesis and a chant that hardens the gale.",
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
	DemonArt = "Cryokinesis",
	CombatPreset = "War Fans",
	Mastery = "War Fans",
	SkillCategory = "War Fans",
	ActiveToolStats = {
		["Additional Damage"] = 2,
		["Additional Damage Factor"] = 0.045,
		["Block Points"] = 3
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "War Gale Wind",
			State = true,
			[Menum.skillState.Default] = {
				Name = "War Gale Wind",
				SkillStats = {
					additional_damage_scale = 0.33
				},
				CoolDown = 14,
				icon = "rbxassetid://92733552852074",
				Max_Hold = 0.5,
				Stamina = 22
			},
			WarChantBuff = {
				Name = "Wintry Gale",
				CoolDown = 14,
				icon = "rbxassetid://89644185380844",
				Max_Hold = 0.3,
				Stamina = 22
			}
		},
		{
			Name = "War Chant",
			CoolDown = 20,
			CooldownGroup = "Counter",
			icon = "rbxassetid://72095384400313",
			Max_Hold = 1.5,
			Stamina = 16,
			SkillStats = {
				counter = Menum.CounterType.All
			}
		}
	}
}