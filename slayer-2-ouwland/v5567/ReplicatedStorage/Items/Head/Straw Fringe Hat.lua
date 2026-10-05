local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://133339303331856",
	Description = "A wide straw hat with dark cords hanging past the jaw, hiding a face from recognition and a demon from the sun. Iceveil marauders favor it.",
	Rarity = 5,
	Class = "Titan",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	Stats = {
		["Max Health"] = 130,
		["Max Stamina"] = 45,
		["Sun Immunity"] = true
	}
}