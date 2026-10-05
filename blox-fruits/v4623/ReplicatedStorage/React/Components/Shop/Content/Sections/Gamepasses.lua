local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ProductSection = require(script.Parent.Parent.ProductSection)
local products = {
	{
		ItemId = IdMap.Redeemable["2x Boss Drops"],
		HeaderColor3 = Color3.fromRGB(255, 226, 0),
		IconSize = UDim2.fromScale(0.6, 0.6),
		IconBackgroundTransparency = 0.7,
		TitleFontFace = Font.new("Montserrat"),
		IconSizeConstraint = Enum.SizeConstraint.RelativeXX
	},
	{
		ItemId = IdMap.Redeemable["Fast Boats"],
		HeaderColor3 = Color3.fromRGB(255, 226, 0),
		IconSize = UDim2.fromScale(0.6, 0.6),
		IconBackgroundTransparency = 0.7,
		TitleFontFace = Font.new("Montserrat"),
		HypeTextColor3 = Color3.fromRGB(255, 0, 255),
		HypeText = "THE FASTEST!",
		HypeTextSize = UDim2.fromScale(1, 0.2),
		HypeTextStrokeTransparency = 1,
		IconSizeConstraint = Enum.SizeConstraint.RelativeXX
	},
	{
		ItemId = IdMap.Redeemable["2x Money"],
		HeaderColor3 = Color3.fromRGB(255, 226, 0),
		IconSize = UDim2.fromScale(0.6, 0.6),
		IconBackgroundTransparency = 0.7,
		TitleFontFace = Font.new("Montserrat"),
		Title = "2x Money",
		IconSizeConstraint = Enum.SizeConstraint.RelativeXX
	},
	{
		ItemId = IdMap.Redeemable["2x Mastery"],
		HeaderColor3 = Color3.fromRGB(255, 226, 0),
		IconSize = UDim2.fromScale(0.6, 0.6),
		IconBackgroundTransparency = 0.7,
		TitleFontFace = Font.new("Montserrat"),
		Title = "2x Mastery",
		IconSizeConstraint = Enum.SizeConstraint.RelativeXX
	},
	{
		ItemId = IdMap.Redeemable["Dark Blade"],
		HeaderColor3 = Color3.fromRGB(255, 226, 0),
		IconSize = UDim2.fromScale(0.6, 0.6),
		IconBackgroundTransparency = 0.7,
		TitleFontFace = Font.new("Montserrat"),
		IconSizeConstraint = Enum.SizeConstraint.RelativeXX
	},
	{
		ItemId = IdMap.Redeemable["Fruit Notifier"],
		HeaderColor3 = Color3.fromRGB(255, 226, 0),
		IconSize = UDim2.fromScale(0.6, 0.6),
		IconBackgroundTransparency = 0.7,
		TitleFontFace = Font.new("Montserrat"),
		IconSizeConstraint = Enum.SizeConstraint.RelativeXX
	}
}
local createElement = React.createElement
return function(p)
	return createElement(ProductSection, {
		Title = "GAME PASSES - PERMANENT",
		Products = products,
		LayoutOrder = p.LayoutOrder,
		OnClick = p.OnClick,
		Size = UDim2.fromScale(1, 0.8),
		CellPadding = UDim2.fromScale(0.03, 0.015),
		CellSize = UDim2.fromScale(0.31, 0.49)
	})
end