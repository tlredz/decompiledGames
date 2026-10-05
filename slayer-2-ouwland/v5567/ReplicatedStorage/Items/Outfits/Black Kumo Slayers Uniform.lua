local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://109506236104989",
	Description = "A dark navy uniform under gold braid, cut with a guarded sleeve for Slayers who expect to meet claws at close range.",
	Rarity = 6,
	Class = "Sentinel",
	EquipType = Menum.ItemEquipType.Costume,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	Stats = {
		["Max Health"] = 195,
		["Health Regen Speed"] = 0.1,
		["Max Stamina"] = 90,
		["Damage Reduction"] = 1,
		["Block Points"] = 6,
		["Block Regen"] = 0.15
	}
}