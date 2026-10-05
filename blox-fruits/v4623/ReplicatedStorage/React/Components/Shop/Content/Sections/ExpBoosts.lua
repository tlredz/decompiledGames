local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ProductSection = require(script.Parent.Parent.ProductSection)
local products = {
	{
		ItemId = IdMap.Redeemable["2x EXP (15 mins.)"],
		Title = "15 mins.",
		IconSize = UDim2.fromScale(0.6, 0.6),
		IconBackgroundColor3 = Color3.fromRGB(184, 233, 255)
	},
	{
		ItemId = IdMap.Redeemable["2x EXP (1 hour)"],
		Title = "1 hour",
		IconSize = UDim2.fromScale(0.6, 0.6),
		IconBackgroundColor3 = Color3.fromRGB(184, 233, 255)
	},
	{
		ItemId = IdMap.Redeemable["2x EXP (6 hours)"],
		Title = "6 hours",
		IconSize = UDim2.fromScale(0.6, 0.6),
		IconBackgroundColor3 = Color3.fromRGB(184, 233, 255)
	},
	{
		ItemId = IdMap.Redeemable["2x EXP (12 hours)"],
		Title = "12 hours",
		HypeText = "POPULAR",
		HypeTextStrokeColor3 = Color3.fromRGB(231, 0, 3),
		IconBackgroundColor3 = Color3.fromRGB(184, 233, 255),
		IconSize = UDim2.fromScale(0.6, 0.6)
	},
	{
		ItemId = IdMap.Redeemable["2x EXP (24 hours)"],
		Title = "24 hours",
		HypeText = "BEST VALUE!",
		HypeTextStrokeColor3 = Color3.fromRGB(255, 0, 255),
		IconBackgroundColor3 = Color3.fromRGB(184, 233, 255),
		IconSize = UDim2.fromScale(0.6, 0.6)
	}
}
local createElement = React.createElement
return function(p)
	return createElement(ProductSection, {
		Title = "(2x) EXP BOOSTS  - SAVES ON EXIT",
		Products = products,
		LayoutOrder = p.LayoutOrder,
		OnClick = p.OnClick
	})
end