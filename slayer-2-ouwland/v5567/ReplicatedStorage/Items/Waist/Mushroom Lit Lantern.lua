local Menum = require(game.ReplicatedStorage:WaitForChild("CAM"):WaitForChild("Global"):WaitForChild("Menum"))
require(game.ReplicatedStorage.CAM.Global.Types.ItemTypes)
return {
	Icon = "rbxassetid://72486367491595",
	Description = "Blue cave mushrooms light this case from inside. Their own glow keeps hidden caps visible where other lamps drive them under.",
	Rarity = 5,
	Class = "Phantom",
	EquipType = Menum.ItemEquipType.Accessory,
	Unique = true,
	NoSell = true,
	NoDelete = true,
	Stats = {
		["Max Health"] = 30,
		["Max Stamina"] = 35,
		["Stamina Regen Speed"] = 0.07,
		["Movement Speed Factor"] = 0.05,
		Illumination = 0.65
	}
}