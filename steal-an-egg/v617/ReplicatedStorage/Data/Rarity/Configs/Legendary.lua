local ReplicatedStorage = game:GetService("ReplicatedStorage")
local child = ReplicatedStorage.Assets.UI.RarityGradients:FindFirstChild(script.Name)
assert(child, (`RarityGradients has no "{script.Name}" folder`))
return table.freeze({
	_id = script.Name,
	DisplayName = "Legendary",
	Rank = 5,
	Color = Color3.fromRGB(254, 132, 36),
	RarityGradient = child.RarityGradient,
	ItemTemplate = child.ItemTemplate
})