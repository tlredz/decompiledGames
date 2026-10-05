local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://138231871121567",
	Description = "Silver crescents pinned with a four point star, made for hands that never quite leave a fight idle.",
	Rarity = 5,
	Class = "Technician",
	EquipType = Menum.ItemEquipType.Accessory,
	Price = {
		["Silk Thread"] = 6,
		["Refinement Ore"] = 4
	},
	Stats = {
		["Max Health"] = 70,
		["Max Stamina"] = 35,
		["Additional Damage Factor"] = 0.05
	}
}