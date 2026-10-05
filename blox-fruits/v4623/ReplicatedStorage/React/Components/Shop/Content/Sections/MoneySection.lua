local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ProductSection = require(script.Parent.Parent.ProductSection)
local useCurrentSea = require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	Sea1 = {
		{
			ItemId = IdMap.Redeemable["10K Money"],
			Title = "+$10K",
			IconSize = UDim2.fromScale(1.1, 1),
			HeaderColor3 = Color3.fromRGB(239, 193, 75)
		},
		{
			ItemId = IdMap.Redeemable["50K Money"],
			Title = "+$50K",
			HypeText = "+25% MORE",
			IconSize = UDim2.fromScale(1.1, 1),
			HypeTextColor3 = Color3.fromRGB(231, 0, 3),
			HypeTextStrokeColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			HypeTextStrokeTransparency = 0.5,
			HeaderColor3 = Color3.fromRGB(239, 193, 75)
		},
		{
			ItemId = IdMap.Redeemable["135K Money"],
			Title = "+$135K",
			HypeText = "+35% MORE",
			IconSize = UDim2.fromScale(1.1, 1),
			HypeTextColor3 = Color3.fromRGB(231, 0, 3),
			HypeTextStrokeColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			HeaderColor3 = Color3.fromRGB(239, 193, 75)
		},
		{
			ItemId = IdMap.Redeemable["300K Money"],
			Title = "+$300K",
			HypeText = "+50% MORE",
			IconSize = UDim2.fromScale(1.1, 1),
			HypeTextStrokeColor3 = Color3.fromRGB(231, 0, 3),
			HeaderColor3 = Color3.fromRGB(239, 193, 75)
		},
		{
			ItemId = IdMap.Redeemable["500K Money"],
			Title = "+$500K",
			HypeText = "BEST VALUE!",
			IconSize = UDim2.fromScale(1.1, 1),
			HypeTextStrokeColor3 = Color3.fromRGB(255, 0, 255),
			HeaderColor3 = Color3.fromRGB(239, 193, 75)
		}
	},
	Sea2 = {
		{
			ItemId = IdMap.Redeemable["30K Money"],
			Title = "+$30K",
			IconSize = UDim2.fromScale(1.1, 1),
			HeaderColor3 = Color3.fromRGB(239, 193, 75)
		},
		{
			ItemId = IdMap.Redeemable["150K Money"],
			Title = "+$150K",
			HypeText = "+25% MORE",
			IconSize = UDim2.fromScale(1.1, 1),
			HypeTextColor3 = Color3.fromRGB(231, 0, 3),
			HypeTextStrokeColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			HypeTextStrokeTransparency = 0.5,
			HeaderColor3 = Color3.fromRGB(239, 193, 75)
		},
		{
			ItemId = IdMap.Redeemable["405K Money"],
			Title = "+$405K",
			HypeText = "+35% MORE",
			IconSize = UDim2.fromScale(1.1, 1),
			HypeTextColor3 = Color3.fromRGB(231, 0, 3),
			HypeTextStrokeColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			HeaderColor3 = Color3.fromRGB(239, 193, 75)
		},
		{
			ItemId = IdMap.Redeemable["900K Money"],
			Title = "+$900K",
			HypeText = "+50% MORE",
			IconSize = UDim2.fromScale(1.1, 1),
			HypeTextStrokeColor3 = Color3.fromRGB(231, 0, 3),
			HeaderColor3 = Color3.fromRGB(239, 193, 75)
		},
		{
			ItemId = IdMap.Redeemable["1.5M Money"],
			Title = "+$1.5M",
			HypeText = "BEST VALUE!",
			IconSize = UDim2.fromScale(1.1, 1),
			HypeTextStrokeColor3 = Color3.fromRGB(255, 0, 255),
			HeaderColor3 = Color3.fromRGB(239, 193, 75)
		}
	},
	Sea3 = {
		{
			ItemId = IdMap.Redeemable["60K Money"],
			Title = "+$60K",
			IconSize = UDim2.fromScale(1.1, 1),
			HeaderColor3 = Color3.fromRGB(239, 193, 75)
		},
		{
			ItemId = IdMap.Redeemable["305K Money"],
			Title = "+$305K",
			HypeText = "+25% MORE",
			IconSize = UDim2.fromScale(1.1, 1),
			HypeTextColor3 = Color3.fromRGB(231, 0, 3),
			HypeTextStrokeColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			HypeTextStrokeTransparency = 0.5,
			HeaderColor3 = Color3.fromRGB(239, 193, 75)
		},
		{
			ItemId = IdMap.Redeemable["810K Money"],
			Title = "+$810K",
			HypeText = "+35% MORE",
			IconSize = UDim2.fromScale(1.1, 1),
			HypeTextColor3 = Color3.fromRGB(231, 0, 3),
			HypeTextStrokeColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			HeaderColor3 = Color3.fromRGB(239, 193, 75)
		},
		{
			ItemId = IdMap.Redeemable["1.8M Money"],
			Title = "+$1.8M",
			HypeText = "+50% MORE",
			IconSize = UDim2.fromScale(1.1, 1),
			HypeTextStrokeColor3 = Color3.fromRGB(231, 0, 3),
			HeaderColor3 = Color3.fromRGB(239, 193, 75)
		},
		{
			ItemId = IdMap.Redeemable["3M Money"],
			Title = "+$3M",
			HypeText = "BEST VALUE!",
			IconSize = UDim2.fromScale(1.1, 1),
			HypeTextStrokeColor3 = Color3.fromRGB(255, 0, 255),
			HeaderColor3 = Color3.fromRGB(239, 193, 75)
		}
	}
}
local createElement = React.createElement
return function(p)
	local v2 = useCurrentSea()

	if v2 then
		return createElement(ProductSection, {
			Title = "($) MONEY",
			Products = v[v2],
			LayoutOrder = p.LayoutOrder,
			OnClick = p.OnClick
		})
	end
end