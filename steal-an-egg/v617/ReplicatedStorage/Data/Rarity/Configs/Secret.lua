local ReplicatedStorage = game:GetService("ReplicatedStorage")
local child = ReplicatedStorage.Assets.UI.RarityGradients:FindFirstChild(script.Name)
assert(child, (`RarityGradients has no "{script.Name}" folder`))
return table.freeze({
	_id = script.Name,
	DisplayName = "Secret",
	Rank = 8,
	Color = Color3.fromRGB(46, 46, 46),
	RarityGradient = child.RarityGradient,
	ItemTemplate = child.ItemTemplate
})