local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://94755662391877",
	Description = "Lacquered black and gilded with cranes, slung on red cords. Ornate for a bandit's hat, and still shade enough to keep the sun off.",
	Rarity = 1,
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		Wen = 10000
	},
	Stats = {
		["Sun Immunity"] = true
	}
}