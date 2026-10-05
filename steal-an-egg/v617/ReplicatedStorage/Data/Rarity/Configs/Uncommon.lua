local ReplicatedStorage = game:GetService("ReplicatedStorage")
local child = ReplicatedStorage.Assets.UI.RarityGradients:FindFirstChild(script.Name)
assert(child, (`RarityGradients has no "{script.Name}" folder`))
return table.freeze({
	_id = script.Name,
	DisplayName = "Uncommon",
	Rank = 2,
	Color = Color3.fromRGB(0, 255, 0),
	RarityGradient = child.RarityGradient,
	ItemTemplate = child.ItemTemplate
})