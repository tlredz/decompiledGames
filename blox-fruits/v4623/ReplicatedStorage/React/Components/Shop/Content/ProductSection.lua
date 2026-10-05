local React = require(game.ReplicatedStorage.Packages.React)
local SimpleShopTile = require(game.ReplicatedStorage.React.Components.Shop.SimpleShopTile)
local SectionHeader = require(script.Parent.SectionHeader)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement

function productTile(props)
	local index = props.Index
	local itemInfo = props.ItemInfo
	local v2

	if type(itemInfo) == "table" then
		v2 = itemInfo.ProductOverrideId or itemInfo.ItemId
	end

	local v3 = useRobuxPrice(v2)
	local robuxPrice

	if type(itemInfo) == "table" then
		robuxPrice = itemInfo.RobuxPrice
	end

	if typeof(itemInfo) == "boolean" then
		return createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://2882228740",
			ImageColor3 = Color3.fromHex("#1C1C1C"):Lerp(CONSTANTS.COLOR.PALETTE.WHITE, 0.02),
			LayoutOrder = index,
			Position = UDim2.fromScale(0.5, 0.04),
			ScaleType = Enum.ScaleType.Slice,
			Size = UDim2.fromScale(0.19, 0.24),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			SliceCenter = Rect.new(4, 4, 16, 16),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {})
	end

	if props.UseFinalPrice then
		robuxPrice = v3
	end

	return createElement(SimpleShopTile, {
		ItemId = itemInfo.ItemId,
		LayoutOrder = index,
		Title = itemInfo.Title,
		TitleFontFace = itemInfo.TitleFontFace,
		HypeText = itemInfo.HypeText,
		HypeTextStrokeColor3 = itemInfo.HypeTextStrokeColor3,
		HypeTextColor3 = itemInfo.HypeTextColor3,
		HeaderColor3 = itemInfo.HeaderColor3,
		IconBackgroundColor3 = itemInfo.IconBackgroundColor3,
		IconBackgroundTransparency = itemInfo.IconBackgroundTransparency,
		UpperHypeText = itemInfo.UpperHypeText,
		HypeTextStrokeTransparency = itemInfo.HypeTextStrokeTransparency,
		HypeTextSize = itemInfo.HypeTextSize,
		IconSize = itemInfo.IconSize,
		IconSizeConstraint = itemInfo.IconSizeConstraint,
		ProductOverrideId = itemInfo.ProductOverrideId,
		Sunburst = itemInfo.Sunburst,
		TileFontFace = itemInfo.TileFontFace,
		RobuxPrice = robuxPrice,
		OnClick = function()
			props.OnClick(itemInfo.ItemId, itemInfo.ProductOverrideId)
		end
	})
end

return function(props)
	local children = {}

	for i, product in ipairs(props.Products) do
		children[`Card{i}`] = createElement(productTile, {
			UseFinalPrice = props.UseFinalPrice,
			ItemInfo = product,
			Index = i,
			OnClick = props.OnClick
		})
	end

	return createElement(React.Fragment, {}, {
		[`Section{props.LayoutOrder}Header`] = createElement(SectionHeader, {
			Text = props.Title,
			LayoutOrder = props.LayoutOrder,
			TextColor3 = props.TitleColor3
		}),
		[`Section{props.LayoutOrder}Items`] = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			LayoutOrder = (props.LayoutOrder or 0) + 1,
			Size = props.Size or UDim2.fromScale(1, 0.22),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			UIGridLayout = createElement("UIGridLayout", {
				CellPadding = props.CellPadding or UDim2.fromScale(0.012, 0),
				CellSize = props.CellSize or UDim2.fromScale(0.19, 1),
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalAlignment = Enum.HorizontalAlignment.Left,
				VerticalAlignment = Enum.VerticalAlignment.Top
			}),
			Cards = createElement(React.Fragment, {}, children)
		})
	})
end