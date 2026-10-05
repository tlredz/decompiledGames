local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://109428456454495",
	Description = "Giyen's blade throws white water along the cut, passing through and leaving very little argument behind.",
	Rarity = 5,
	Class = "Sentinel",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Metal Scraps"] = 10,
		["Refinement Ore"] = 6
	},
	HasCombat = true,
	Breathing = "All",
	Mastery = "Sword",
	RefineStats = { "Additional Damage", "Block Points" },
	ActiveToolStats = {
		["Additional Damage"] = 1.5,
		["Additional Damage Factor"] = 0.04,
		["Block Points"] = 3.5,
		["Block Regen"] = 0.15
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