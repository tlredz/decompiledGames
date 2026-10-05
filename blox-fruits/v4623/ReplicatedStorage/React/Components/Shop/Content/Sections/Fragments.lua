local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ProductSection = require(script.Parent.Parent.ProductSection)
local useCurrentSea = require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local products = {
	{
		ItemId = IdMap.Redeemable["500 Fragments"],
		Title = "+ƒ500",
		IconSize = UDim2.fromScale(1.1, 1),
		HeaderColor3 = Color3.fromRGB(211, 79, 247)
	},
	{
		ItemId = IdMap.Redeemable["2.1K Fragments"],
		Title = "+ƒ2,100",
		HypeText = "+25% MORE",
		IconSize = UDim2.fromScale(1.1, 1),
		HypeTextColor3 = Color3.fromRGB(231, 0, 3),
		HypeTextStrokeColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		HypeTextStrokeTransparency = 0.5,
		HeaderColor3 = Color3.fromRGB(211, 79, 247)
	},
	{
		ItemId = IdMap.Redeemable["4.5K Fragments"],
		Title = "+ƒ4,500",
		HypeText = "+35% MORE",
		IconSize = UDim2.fromScale(1.1, 1),
		HypeTextColor3 = Color3.fromRGB(231, 0, 3),
		HypeTextStrokeColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
		HeaderColor3 = Color3.fromRGB(211, 79, 247)
	},
	{
		ItemId = IdMap.Redeemable["10K Fragments"],
		Title = "+ƒ10,000",
		HypeText = "+50% MORE",
		IconSize = UDim2.fromScale(1.1, 1),
		HypeTextStrokeColor3 = Color3.fromRGB(231, 0, 3),
		HeaderColor3 = Color3.fromRGB(211, 79, 247)
	},
	{
		ItemId = IdMap.Redeemable["16K Fragments"],
		Title = "+ƒ16,000",
		HypeText = "BEST VALUE!",
		HypeTextStrokeColor3 = Color3.fromRGB(255, 0, 255),
		HeaderColor3 = Color3.fromRGB(211, 79, 247),
		IconSize = UDim2.fromScale(1.1, 1)
	}
}
local createElement = React.createElement
return function(p)
	local v2 = useCurrentSea()

	if v2 == "Sea2" or v2 == "Sea3" then
		return createElement(ProductSection, {
			Title = "(ƒ) FRAGMENTS",
			Products = products,
			LayoutOrder = p.LayoutOrder,
			OnClick = p.OnClick
		})
	end

	return nil
end