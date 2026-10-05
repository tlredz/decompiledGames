local ReplicatedStorage = game:GetService("ReplicatedStorage")
local child = ReplicatedStorage.Assets.UI.RarityGradients:FindFirstChild(script.Name)
assert(child, (`RarityGradients has no "{script.Name}" folder`))
return table.freeze({
	_id = script.Name,
	DisplayName = "Light & Dark",
	Rank = 12,
	Color = Color3.fromRGB(196, 148, 255),
	RarityGradient = child.RarityGradient,
	ItemTemplate = child.ItemTemplate
})