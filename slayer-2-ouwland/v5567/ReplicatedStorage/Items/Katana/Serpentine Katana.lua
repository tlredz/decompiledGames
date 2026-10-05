local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://112939167874892",
	Description = "Violet and green light coils the length of the spine, a blade made to change line without warning and punish a missed guard.",
	Rarity = 6,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Toolbar,
	Price = {
		["Mythic Refinement Ore"] = 4
	},
	NoSell = true,
	HasCombat = true,
	Breathing = "All",
	Mastery = "Sword",
	RefineStats = { "Additional Damage", "Additional Damage Factor" },
	ActiveToolStats = {
		["Additional Damage"] = 2.5,
		["Additional Damage Factor"] = 0.1,
		["Block Points"] = 2.9,
		["Block Regen"] = 0.45
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