local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://114519461304565",
	Description = "Dark plated fist guards set with a single red stone, turning bare hand work into flash strikes, broken footing, and throws.",
	Rarity = 5,
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		Wen = 100000
	},
	DemonArt = "All,exceptBlood Manipulation",
	HasCombat = true,
	CombatPreset = "Gauntlet",
	Mastery = "Gauntlet",
	SkillCategory = "Gauntlet",
	ActiveToolStats = {
		["Additional Damage"] = 2,
		["Additional Damage Factor"] = 0.041,
		["Block Points"] = 2.55
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Flash Fist",
			SkillStats = {
				strict_stun = true,
				additional_damage_scale = 0.5
			},
			CoolDown = 14,
			icon = "rbxassetid://117576772610807",
			Max_Hold = 3,
			Stamina = 20
		},
		{
			Name = "Shatter Step",
			CoolDown = 15,
			icon = "rbxassetid://120836341224394",
			Max_Hold = 3,
			Stamina = 24
		},
		{
			Name = "Shoulder Throw",
			SkillStats = {
				cancel_bypass = true
			},
			CoolDown = 18,
			icon = "rbxassetid://128375584273842",
			Max_Hold = 5,
			Stamina = 22
		}
	}
}