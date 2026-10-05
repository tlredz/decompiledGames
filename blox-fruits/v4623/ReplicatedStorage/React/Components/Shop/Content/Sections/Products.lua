local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ProductSection = require(script.Parent.Parent.ProductSection)
local useCurrentSea = require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
local v = { IdMap.Redeemable["5x Legendary Scrolls"], IdMap.Redeemable["3x Mythical Scrolls"] }
local v2 = {
	{
		ItemId = IdMap.Redeemable["Respawn Bosses"],
		IconSize = UDim2.fromScale(0.6, 0.6),
		IconBackgroundTransparency = 0.7,
		TitleFontFace = Font.new("Montserrat"),
		IconSizeConstraint = Enum.SizeConstraint.RelativeXX
	},
	{
		ItemId = IdMap.Redeemable["Refund Points"],
		IconSize = UDim2.fromScale(0.6, 0.6),
		IconBackgroundTransparency = 0.7,
		TitleFontFace = Font.new("Montserrat"),
		Title = "Refund Stats",
		IconSizeConstraint = Enum.SizeConstraint.RelativeXX
	},
	{
		ItemId = IdMap.Redeemable["Change Race"],
		IconSize = UDim2.fromScale(0.6, 0.6),
		IconBackgroundTransparency = 0.7,
		IconSizeConstraint = Enum.SizeConstraint.RelativeXX,
		TitleFontFace = Font.new("Montserrat"),
		HypeText = "1/3 CHANCE PER RACE (RANDOM)",
		UpperHypeText = "HUMAN, SHARK, ANGEL, RABBIT",
		HypeTextSize = UDim2.fromScale(1, 0.2),
		HypeTextStrokeTransparency = 1,
		HypeTextColor3 = Color3.fromRGB(231, 0, 3)
	},
	{
		ItemId = IdMap.Redeemable["+1 Fruit Storage"],
		IconSize = UDim2.fromScale(0.6, 0.6),
		IconBackgroundTransparency = 0.7,
		IconSizeConstraint = Enum.SizeConstraint.RelativeXX,
		TitleFontFace = Font.new("Montserrat")
	},
	{
		ItemId = IdMap.Redeemable["5x Legendary Scrolls"],
		IconSize = UDim2.fromScale(0.6, 0.6),
		IconBackgroundTransparency = 0.7,
		IconSizeConstraint = Enum.SizeConstraint.RelativeXX,
		TitleFontFace = Font.new("Montserrat"),
		Title = "5x LEGENDARY SCROLLS"
	},
	{
		ItemId = IdMap.Redeemable["3x Mythical Scrolls"],
		IconSize = UDim2.fromScale(0.6, 0.6),
		IconBackgroundTransparency = 0.7,
		IconSizeConstraint = Enum.SizeConstraint.RelativeXX,
		TitleFontFace = Font.new("Montserrat"),
		Title = "3x MYTHICAL SCROLLS"
	}
}
local createElement = React.createElement
return function(p)
	local v3 = useCurrentSea()
	return createElement(ProductSection, {
		Title = "PRODUCTS",
		Products = React.useMemo(function()
			local v5 = v3 == "Sea3"
			local result = {}

			for _, v6 in v2 do
				if v5 then
					table.insert(result, v6)
				elseif table.find(v, v6.ItemId) then
					table.insert(result, false)
				else
					table.insert(result, v6)
				end
			end

			table.freeze(result)
			return result
		end, { v3 }),
		LayoutOrder = p.LayoutOrder,
		OnClick = function(p2: number)
			local unwrapped = ItemConfig.match(p2):unwrap()
			local onClick = p.OnClick
			local v5

			if unwrapped.Economy then
				v5 = unwrapped.Economy.IsGiftable == true
			else
				v5 = false
			end

			onClick(p2, v5)
		end,
		Size = UDim2.fromScale(1, 0.8),
		CellPadding = UDim2.fromScale(0.03, 0.015),
		CellSize = UDim2.fromScale(0.31, 0.49)
	})
end