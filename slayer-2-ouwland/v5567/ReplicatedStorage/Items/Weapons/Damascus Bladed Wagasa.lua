local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://116324848027524",
	Description = "A violet canopy on hardened ribs, keeping sunlight off overhead while steel petals answer underneath.",
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
	CombatPreset = "Bladed Wagasa",
	Mastery = "Bladed Wagasa",
	SkillCategory = "Bladed Wagasa",
	ActiveToolStats = {
		["Additional Damage"] = 4,
		["Additional Damage Factor"] = 0.074,
		["Block Points"] = 4.2,
		["Block Regen"] = 0.6,
		["Sun Immunity"] = true
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		},
		{
			Name = "Floating Grace",
			SkillStats = {
				strict_stun = true,
				additional_damage_scale = 0.25
			},
			CoolDown = 15,
			icon = "rbxassetid://102274552092247",
			Max_Hold = 5,
			Stamina = 24
		},
		{
			Name = "Pale Petals",
			SkillStats = {
				additional_damage_scale = 0.32
			},
			CoolDown = 20,
			icon = "rbxassetid://113999716517705",
			Max_Hold = 0.75,
			Stamina = 30
		},
		{
			Name = "Shade Breaker",
			CoolDown = 14,
			icon = "rbxassetid://113921345706618",
			Max_Hold = 4,
			Stamina = 22
		}
	}
}