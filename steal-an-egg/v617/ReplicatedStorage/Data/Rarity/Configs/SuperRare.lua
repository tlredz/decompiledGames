local ReplicatedStorage = game:GetService("ReplicatedStorage")
local child = ReplicatedStorage.Assets.UI.RarityGradients:FindFirstChild(script.Name)
assert(child, (`RarityGradients has no "{script.Name}" folder`))
return table.freeze({
	_id = script.Name,
	DisplayName = "SuperRare",
	Rank = 2,
	Color = Color3.fromRGB(25, 216, 250),
	RarityGradient = child.RarityGradient,
	ItemTemplate = child.ItemTemplate
})