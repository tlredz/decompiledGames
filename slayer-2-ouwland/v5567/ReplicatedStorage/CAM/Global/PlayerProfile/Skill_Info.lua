local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.CAM.Global.Types.ItemTypes)
Cooldowns = {
	Blocking = 2
}
return {
	Blocking = {
		Cooldown = Cooldowns.Blocking,
		Icon = "rbxassetid://13735172949",
		Locked = false
	},
	Dash = {
		Cooldown = 1,
		Stamina = 10
	},
	["Double Jump"] = {
		Icon = "rbxassetid://76136876197533",
		Cooldown = 3,
		Stamina = 20,
		Category = "Innate Skills",
		Index = 1
	},
	["Wall Climb"] = {
		Icon = "rbxassetid://76503830534647",
		Cooldown = 2,
		Category = "Innate Skills",
		Index = 2
	}
}