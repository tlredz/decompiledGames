local ReplicatedStorage = game:GetService("ReplicatedStorage")
local child = ReplicatedStorage.Assets.UI.RarityGradients:FindFirstChild(script.Name)
assert(child, (`RarityGradients has no "{script.Name}" folder`))
return table.freeze({
	_id = script.Name,
	DisplayName = "Cosmic",
	Rank = 7,
	Color = Color3.fromRGB(65, 0, 170),
	RarityGradient = child.RarityGradient,
	ItemTemplate = child.ItemTemplate
})