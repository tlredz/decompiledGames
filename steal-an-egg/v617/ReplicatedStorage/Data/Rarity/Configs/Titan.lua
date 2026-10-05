local ReplicatedStorage = game:GetService("ReplicatedStorage")
local child = ReplicatedStorage.Assets.UI.RarityGradients:FindFirstChild(script.Name)
assert(child, (`RarityGradients has no "{script.Name}" folder`))
return table.freeze({
	_id = script.Name,
	DisplayName = "Titan",
	Rank = 11,
	Color = Color3.fromRGB(255, 64, 64),
	RarityGradient = child.RarityGradient,
	ItemTemplate = child.ItemTemplate
})