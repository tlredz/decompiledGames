local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://91396072601592",
	Description = "Rengu's Nichirin runs red along its length and takes open fire the moment it clears the sheath.",
	Rarity = 5,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Metal Scraps"] = 10,
		["Refinement Ore"] = 6
	},
	Breathing = "All",
	HasCombat = true,
	Mastery = "Sword",
	ActiveToolStats = {
		["Additional Damage"] = 2,
		["Additional Damage Factor"] = 0.037,
		["Block Points"] = 1.95
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