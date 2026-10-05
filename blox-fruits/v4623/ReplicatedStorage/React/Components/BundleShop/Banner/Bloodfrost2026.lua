local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Textures = require(game.ReplicatedStorage.Textures)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local Card = require(game.ReplicatedStorage.React.Components.Shop.Card)
local useSale = require(game.ReplicatedStorage.React.Hooks.useSale)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local bloodfrostBundle = IdMap.Redeemable["Bloodfrost Bundle"]
local unwrapped = ItemConfig.match(bloodfrostBundle):unwrap()
assert("Fiend", "bad first name part: Fiend")
local joined = table.concat({ FormatUtil.font("Fiend", {
		color = Color3.fromHex("#ED2000")
	}) .. FormatUtil.clean("<Yeti>") }, " ")
local yetiYeti = IdMap.PhysicalMoveset["Yeti-Yeti"]
local unwrapped2 = ItemConfig.match(yetiYeti):unwrap()
local joined2 = table.concat({ FormatUtil.font("Permanent", {
		color = Color3.fromRGB(255, 200, 90)
	}), FormatUtil.clean((`<{unwrapped2.Display.Name or unwrapped2.Index.StorageKey}>`)) }, " ")
local createElement = React.createElement
return function(props)
	local v = useSale("Valentines2026Bundle")
	local price = useRobuxPrice(bloodfrostBundle)
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
			ColorSequenceKeypoint.new(0, Color3.fromRGB(227, 0, 27)),
			ColorSequenceKeypoint.new(0.443, Color3.fromRGB(255, 103, 99)),
			ColorSequenceKeypoint.new(0.55, Color3.fromRGB(131, 234, 243)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 175, 244))
		}),
		ProductImage = Textures.banner.shop["BloodfrostBundle.png"],
		Description = FormatUtil.stroke("Get " .. joined .. ", " .. joined2 .. FormatUtil.font(" in storage", {
			color = Color3.fromHex("#00bfff")
		}) .. "! + " .. FormatUtil.font(FormatUtil.commaInteger(810000), {
			color = Color3.fromRGB(102, 255, 102)
		}) .. " + " .. FormatUtil.font("ƒ" .. FormatUtil.commaInteger(2100), {
			color = Color3.fromRGB(255, 0, 255)
		}), {
			thickness = 1.5
		}),
		Price = price,
		OriginalPrice = 5498,
		SaleFinishAt = v and v.Date.Finish:unwrap(),
		OnPreviewClick = props.OnPreviewClick,
		OnClick = props.OnClick and function()
			props.OnClick(bloodfrostBundle)
		end,
		FlexWidthRatio = props.FlexWidthRatio or 4
	})
end