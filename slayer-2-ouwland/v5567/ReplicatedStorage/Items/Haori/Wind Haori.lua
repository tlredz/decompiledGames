local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://80657685925324",
	Description = "Saneri's haori, undyed and worn open at the front. The Wind school leaves nothing on the cloth that could slow a straight line through.",
	Rarity = 6,
	Class = "Duelist",
	EquipType = Menum.ItemEquipType.Clothing,
	Price = {
		["Mythic Refinement Ore"] = 2
	},
	DisableClothing = {
		EquippedShirt = true
	},
	ClothingTag = "Coat",
	Stats = {
		["Max Health"] = 150,
		["Max Stamina"] = 80,
		["Additional Damage"] = 1,
		["Additional Damage Factor"] = 0.015
	}
}