local React = require(game.ReplicatedStorage.Packages.React)
local IdMap = require(game.ReplicatedStorage.IdMap)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local Textures = require(game.ReplicatedStorage.Textures)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local Card = require(game.ReplicatedStorage.React.Components.Shop.Card)
local useSale = require(game.ReplicatedStorage.React.Hooks.useSale)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local easter2026Bundle = IdMap.Redeemable.Easter2026Bundle
local unwrapped = ItemConfig.match(easter2026Bundle):unwrap()
local createElement = React.createElement
return function(props)
	local v = useSale("Easter2026")
	local v2 = useRobuxPrice(easter2026Bundle)
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
			ColorSequenceKeypoint.new(0, Color3.fromHex("#00d0ff")),
			ColorSequenceKeypoint.new(0.366, Color3.fromHex("#00ffff")),
			ColorSequenceKeypoint.new(0.625, Color3.fromHex("#008df3")),
			ColorSequenceKeypoint.new(1, Color3.fromHex("#006eff"))
		}),
		ProductImage = Textures.banner.shop["Easter2026.png"],
		Description = FormatUtil.stroke("Get " .. table.concat({ FormatUtil.font("Permanent", {
				color = Color3.fromRGB(255, 200, 90)
			}), FormatUtil.clean("<Lightning>") }, " ") .. " & " .. FormatUtil.clean("<Gas>") .. " + " .. FormatUtil.font(
			"$" .. FormatUtil.commaInteger(810000),
			{
				color = Color3.fromRGB(102, 255, 102)
			}
		) .. (" + " .. FormatUtil.font("ƒ" .. FormatUtil.commaInteger(4500), {
			color = Color3.fromRGB(255, 0, 255)
		})) .. " in storage!", {
			thickness = 1.5
		}),
		Price = v2 or nil,
		OriginalPrice = 5598,
		SaleFinishAt = v and v.Date.Finish:unwrap(),
		OnPreviewClick = props.OnPreviewClick,
		OnClick = props.OnClick and function()
			props.OnClick(easter2026Bundle)
		end,
		FlexWidthRatio = props.FlexWidthRatio or 4
	})
end