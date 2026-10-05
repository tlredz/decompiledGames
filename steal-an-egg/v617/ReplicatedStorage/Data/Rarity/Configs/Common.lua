local ReplicatedStorage = game:GetService("ReplicatedStorage")
local child = ReplicatedStorage.Assets.UI.RarityGradients:FindFirstChild(script.Name)
assert(child, (`RarityGradients has no "{script.Name}" folder`))
return table.freeze({
	_id = script.Name,
	DisplayName = "Common",
	Rank = 1,
	Color = Color3.fromRGB(151, 151, 151),
	RarityGradient = child.RarityGradient,
	ItemTemplate = child.ItemTemplate
})