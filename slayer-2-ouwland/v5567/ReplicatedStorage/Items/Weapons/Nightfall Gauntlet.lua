local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://70883439417550",
	Description = "Gold cased set gauntlets over wrapped knuckles, favoring sudden fistwork and throws that end a quarrel early.",
	Rarity = 6,
	Series = "Nightfall",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	DemonArt = "All,exceptBlood Manipulation",
	HasCombat = true,
	CombatPreset = "Gauntlet",
	Mastery = "Gauntlet",
	SkillCategory = "Gauntlet",
	ActiveToolStats = {
		["Additional Damage"] = 5.75,
		["Additional Damage Factor"] = 0.147,
		["Block Points"] = 7.6,
		["Block Regen"] = 1.24,
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