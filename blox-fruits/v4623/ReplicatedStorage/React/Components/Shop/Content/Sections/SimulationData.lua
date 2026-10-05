local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ProductSection = require(script.Parent.Parent.ProductSection)
local useCurrentSea = require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local products = {
	{
		ItemId = IdMap.Redeemable["200 Simulation Data"],
		Title = "+200",
		IconSize = UDim2.fromScale(0.6, 1),
		HeaderColor3 = Color3.fromRGB(121, 200, 241)
	},
	{
		ItemId = IdMap.Redeemable["1000 Simulation Data"],
		Title = "+1,000",
		HypeText = "+25% MORE",
		IconSize = UDim2.fromScale(0.6, 1),
		HypeTextColor3 = Color3.fromRGB(231, 0, 3),
		HypeTextStrokeColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		HypeTextStrokeTransparency = 0.5,
		HeaderColor3 = Color3.fromRGB(121, 200, 241)
	},
	{
		ItemId = IdMap.Redeemable["2700 Simulation Data"],
		Title = "+2,700",
		HypeText = "+35% MORE",
		IconSize = UDim2.fromScale(0.6, 1),
		HypeTextColor3 = Color3.fromRGB(231, 0, 3),
		HypeTextStrokeColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		HeaderColor3 = Color3.fromRGB(121, 200, 241)
	},
	{
		ItemId = IdMap.Redeemable["6000 Simulation Data"],
		Title = "+6,000",
		HypeText = "+50% MORE",
		IconSize = UDim2.fromScale(0.6, 1),
		HypeTextStrokeColor3 = Color3.fromRGB(231, 0, 3),
		HeaderColor3 = Color3.fromRGB(121, 200, 241)
	},
	{
		ItemId = IdMap.Redeemable["10000 Simulation Data"],
		Title = "+10,000",
		HypeText = "BEST VALUE!",
		HypeTextStrokeColor3 = Color3.fromRGB(255, 0, 255),
		HeaderColor3 = Color3.fromRGB(121, 200, 241),
		IconSize = UDim2.fromScale(0.6, 1)
	}
}
local createElement = React.createElement
return function(p)
	if useCurrentSea() == "Sea1" then
		return nil
	end

	return createElement(ProductSection, {
		Title = "SIMULATION DATA",
		TitleColor3 = Color3.fromHex("#B7DBFF"),
		Products = products,
		LayoutOrder = p.LayoutOrder,
		OnClick = p.OnClick
	})
end