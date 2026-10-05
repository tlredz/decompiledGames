local ReplicatedStorage = game:GetService("ReplicatedStorage")
local child = ReplicatedStorage.Assets.UI.RarityGradients:FindFirstChild(script.Name)
assert(child, (`RarityGradients has no "{script.Name}" folder`))
return table.freeze({
	_id = script.Name,
	DisplayName = "Epic",
	Rank = 4,
	Color = Color3.fromRGB(196, 2, 255),
	RarityGradient = child.RarityGradient,
	ItemTemplate = child.ItemTemplate
})