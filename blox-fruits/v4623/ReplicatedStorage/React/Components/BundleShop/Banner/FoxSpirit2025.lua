local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Textures = require(game.ReplicatedStorage.Textures)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local Card = require(game.ReplicatedStorage.React.Components.Shop.Card)
local useSale = require(game.ReplicatedStorage.React.Hooks.useSale)
local useCurrentSea = require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local foxSpiritBundle = IdMap.Redeemable["Fox Spirit Bundle"]
local unwrapped = ItemConfig.match(foxSpiritBundle):unwrap()
local createElement = React.createElement
return function(props)
	local v = useSale("FoxSpiritBundle2025")
	local v2 = useCurrentSea()
	local price = useRobuxPrice(foxSpiritBundle)
	local v4 = v2 == "Sea1" and 60000 or v2 == "Sea2" and 150000 or 305000
	local v5 = v2 == "Sea1" and "" or " + <font color=\"rgb(255,0,255)\">ƒ2,100</font>"
	return createElement(Card, {
		ZIndex = props.ZIndex,
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		SizeConstraint = props.SizeConstraint,
		AutomaticSize = props.AutomaticSize,
		Title = unwrapped.Display.Name or unwrapped.Index.StorageKey,
		TitleColor = Color3.fromRGB(230, 73, 11),
		ProductImage = Textures.banner.shop["FoxSpiritBundle.png"],
		Description = `<stroke thickness="1.5">Get <font color="#ed2000">Crimson</font> &lt;Empyrean (Kitsune)&gt;, <font color="rgb(255,200,90)">Permanent </font>&lt;Kitsune&gt; <font color="#00bfff">in storage</font>! + <font color="rgb(102,255,102)">${FormatUtil.commaInteger(v4)}</font>` .. v5 .. "</stroke>",
		Price = price,
		OriginalPrice = 6449,
		SaleFinishAt = v and v.Date.Finish:unwrap(),
		OnPreviewClick = props.OnPreviewClick,
		OnClick = props.OnClick and function()
			props.OnClick(foxSpiritBundle)
		end,
		FlexWidthRatio = props.FlexWidthRatio or 4
	})
end