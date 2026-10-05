local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://73663076031850",
	Description = "Set steel that drinks lamplight instead of returning any. Plating goes into its edge the way a whetstone goes into lesser blades.",
	Rarity = 6,
	Series = "Nightfall",
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	HasCombat = true,
	Breathing = "All",
	Mastery = "Sword",
	ActiveToolStats = {
		["Additional Damage"] = 5.75,
		["Additional Damage Factor"] = 0.138,
		["Block Points"] = 6.2,
		["Block Regen"] = 1.06,
		["Max Stamina"] = 5
	},
	Skills = {
		{
			Name = "Blocking",
			Key = "F",
			CoolDown = 1,
			icon = "http://www.roblox.com/asset/?id=12529007524"
		}
	}
}