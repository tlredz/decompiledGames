local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ItemConfig = require(ReplicatedStorage.ItemConfig)
local React = require(game.ReplicatedStorage.Packages.React)
local useInstantMasteryOptions = require(ReplicatedStorage.React.Hooks.Player.useInstantMasteryOptions)
local ProductSection = require(script.Parent.Parent.ProductSection)
local CONSTANTS = require(ReplicatedStorage.React.CONSTANTS)
local v = {
	50,
	100,
	150,
	200,
	250,
	300,
	350,
	400
}
local v2 = {
	FightingStyle = Color3.fromRGB(255, 123, 123),
	Gun = Color3.fromRGB(255, 217, 65),
	Sword = Color3.fromRGB(141, 255, 92),
	Fruit = Color3.fromRGB(205, 125, 255)
}
local createElement = React.createElement
return function(p)
	local v3 = useInstantMasteryOptions()
	local products = {}

	for _, v5 in v3 do
		local nullable = ItemConfig.match(v5.ItemId):asNullable()

		if nullable == nil then
			continue
		end

		local v6 = v[#v]

		for i = #v, 1, -1 do
			local v7 = v[i]

			if v5.LevelsToMaxSkills <= v7 then
				v6 = v7
			else
				break
			end
		end

		local nullable2 = ItemConfig.match(`+{v6} {v5.Moveset} Mastery`, "Redeemable"):asNullable()

		if nullable2 ~= nil and nullable2.Economy ~= nil then
			table.insert(products, {
				ItemId = v5.ItemId,
				ProductId = 4,
				HeaderColor3 = v2[v5.Moveset] or CONSTANTS.COLOR.PALETTE.WHITE,
				IconSize = UDim2.fromScale(0.6, 0.6),
				IconBackgroundTransparency = 0.7,
				TileFontFace = Font.new("rbxasset://fonts/families/HighwayGothic.json", Enum.FontWeight.Medium),
				Title = "Unlock All Skills",
				HypeText = nullable.Display.Name or nullable.Index.StorageKey,
				UpperHypeText = `+{v6} MASTERY⭐`,
				IconSizeConstraint = Enum.SizeConstraint.RelativeXX,
				ProductOverrideId = nullable2.Index.ItemId,
				Sunburst = true
			})
		end
	end

	local v5 = #products > 3

	if next(products) == nil then
		return nil
	end

	return (createElement(ProductSection, {
		Title = "Instant Mastery",
		Products = products,
		UseFinalPrice = true,
		LayoutOrder = p.LayoutOrder,
		OnClick = p.OnClick,
		Size = UDim2.fromScale(1, v5 and 0.8 or 0.4),
		CellPadding = UDim2.fromScale(0.03, 0.03 / (v5 and 2 or 1)),
		CellSize = UDim2.fromScale(0.31, 0.98 / (v5 and 2 or 1))
	}))
end