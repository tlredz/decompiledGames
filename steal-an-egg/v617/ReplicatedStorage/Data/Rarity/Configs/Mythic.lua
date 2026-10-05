local ReplicatedStorage = game:GetService("ReplicatedStorage")
local child = ReplicatedStorage.Assets.UI.RarityGradients:FindFirstChild(script.Name)
assert(child, (`RarityGradients has no "{script.Name}" folder`))
return table.freeze({
	_id = script.Name,
	DisplayName = "Mythic",
	Rank = 6,
	Color = Color3.fromRGB(254, 44, 102),
	RarityGradient = child.RarityGradient,
	ItemTemplate = child.ItemTemplate
})