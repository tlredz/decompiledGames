local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://130808328524942",
	Description = "A straw hat hung all round with pale paper streamers and one red tassel, woven close enough to keep the sun off a demon.",
	Rarity = 6,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 65000
	},
	Stats = {
		["Max Health"] = 160,
		["Max Stamina"] = 55,
		["Movement Speed Factor"] = 0.07,
		["Sun Immunity"] = true
	}
}