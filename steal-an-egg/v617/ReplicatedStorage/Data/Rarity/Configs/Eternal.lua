local ReplicatedStorage = game:GetService("ReplicatedStorage")
local child = ReplicatedStorage.Assets.UI.RarityGradients:FindFirstChild(script.Name)
assert(child, (`RarityGradients has no "{script.Name}" folder`))
return table.freeze({
	_id = script.Name,
	DisplayName = "Eternal",
	Rank = 9,
	Color = Color3.fromRGB(255, 30, 240),
	RarityGradient = child.RarityGradient,
	ItemTemplate = child.ItemTemplate
})