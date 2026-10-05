local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Textures = require(game.ReplicatedStorage.Textures)
local Card = require(game.ReplicatedStorage.React.Components.Shop.Card)
local useSale = require(game.ReplicatedStorage.React.Hooks.useSale)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local halloween2025Bundle = IdMap.Redeemable["Halloween 2025 Bundle"]
local unwrapped = ItemConfig.match(halloween2025Bundle):unwrap()
local createElement = React.createElement
return function(props)
	local v = useSale("HalloweenBundle2025")
	local price = useRobuxPrice(halloween2025Bundle)
	return createElement(Card, {
		ZIndex = props.ZIndex,
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		SizeConstraint = props.SizeConstraint,
		AutomaticSize = props.AutomaticSize,
		Title = unwrapped.Display.Name or unwrapped.Index.StorageKey,
		TitleColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#fa9d00")),
			ColorSequenceKeypoint.new(0.202, Color3.fromHex("#ffc700")),
			ColorSequenceKeypoint.new(0.606, Color3.fromHex("#9dabbd")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#616ca3"))
		}),
		ProductImage = Textures.banner.shop["halloween-2025.png"],
		ProductGlow = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromHex("#fa9d00")),
			ColorSequenceKeypoint.new(0.267703, Color3.fromHex("#f1c110")),
			ColorSequenceKeypoint.new(0.690846, Color3.fromHex("#0099ff")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#a700d5"))
		}),
		Description = "<stroke thickness=\"1\">Get <font color=\"rgb(255,200,90)\">Permanent </font>&lt;Tiger&gt; and &lt;Werewolf (Tiger)&gt; mutation +<font color=\"rgb(102,255,102)\"> $810,000</font> +<font color=\"rgb(255,0,255)\"> ƒ4,500</font> in storage!</stroke>",
		Price = price,
		OriginalPrice = 5498,
		SaleFinishAt = v and v.Date.Finish:unwrap(),
		OnPreviewClick = props.OnPreviewClick,
		OnClick = props.OnClick and function()
			props.OnClick(halloween2025Bundle)
		end,
		FlexWidthRatio = props.FlexWidthRatio or 4
	})
end