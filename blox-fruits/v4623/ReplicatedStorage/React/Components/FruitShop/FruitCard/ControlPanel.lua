local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(script.Parent.Parent.Types)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local Button = require(game.ReplicatedStorage.React.Components.Button)
local ToolTip = require(script.ToolTip)
local useDiscountedDragonPrice = require(game.ReplicatedStorage.React.Hooks.Fruit.useDiscountedDragonPrice)
local useHasDragonDiscount = require(game.ReplicatedStorage.React.Hooks.Player.useHasDragonDiscount)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local color = Color3.fromRGB(255, 240, 69)
local color2 = Color3.fromRGB(105, 255, 118)
local createElement = React.createElement
return function(props)
	local isOwned = props.IsOwned
	local isEquipped = props.IsEquipped
	local isLocked = props.IsLocked
	local currentDragonSwapType = props.CurrentDragonSwapType
	local onDragonSwap = props.OnDragonSwap
	local onPermPurchaseClick = props.OnPermPurchaseClick
	local onTempPurchaseClick = props.OnTempPurchaseClick
	local onMutationClick = props.OnMutationClick
	local onGiftClick = props.OnGiftClick
	local tagConversions = props.TagConversions
	local beliPrice = props.BeliPrice
	local robuxPrice = props.RobuxPrice
	local isDragon = props.IsDragon
	local v = useDiscountedDragonPrice()

	if useHasDragonDiscount() and isDragon then
		robuxPrice = v or robuxPrice
	end

	local heightRatio = props.HeightRatio
	local isComingSoon = props.IsComingSoon
	local mergeGuiObject = RobloxTypes.mergeGuiObject({}, props)
	local v4 = {
		UIStroke = createElement("UIStroke", {
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = Color3.fromRGB(143, 143, 143),
			LineJoinMode = Enum.LineJoinMode.Miter
		}),
		Shadow = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = Color3.fromRGB(50, 50, 50),
			BackgroundTransparency = 0.2,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromScale(0.5, 0),
			Size = UDim2.fromScale(1, 0.069)
		}),
		Content = 0
	}
	local v7 = {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.5, 1),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		Size = UDim2.fromScale(1, heightRatio)
	}
	local v11 = {
		AnchorPoint = Vector2.new(0.5, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		LayoutOrder = 10,
		Position = UDim2.fromScale(0.5, 0.965),
		Size = UDim2.fromScale(0.985, isComingSoon and 0.8 or 0.59)
	}
	local v15 = {
		FillDirection = Enum.FillDirection.Horizontal,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		HorizontalFlex = Enum.UIFlexAlignment.Fill,
		Padding = CONSTANTS.SPACING.PADDING.OFFSET.MD,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = 0
	}
	local verticalAlignment

	if isComingSoon and isOwned then
		verticalAlignment = Enum.VerticalAlignment.Bottom
	else
		verticalAlignment = Enum.VerticalAlignment.Center
	end

	v15.VerticalAlignment = verticalAlignment
	local v12 = {
		UIListLayout = createElement("UIListLayout", v15),
		ComingSoonLabel = 0,
		MutationButton = 0,
		TempPurchaseButton = 0,
		GiftButton = 0,
		UIPadding = 0,
		SwapButton = 0,
		PermPurchaseButton = 0
	}
	local comingSoonLabel

	if isComingSoon and not isOwned then
		comingSoonLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.TITLE,
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromScale(10, 0.4),
			TextTransparency = CONSTANTS.ALPHA.OPAQUE,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true,
			TextWrapped = true,
			Text = "Coming Soon!"
		}, {
			UIStroke = createElement("UIStroke")
		})
	end

	v12.ComingSoonLabel = comingSoonLabel
	local mutationButton

	if not (isComingSoon or not onMutationClick) then
		mutationButton = createElement(Button, {
			SwipeTransparency = 0,
			Text = "Mutations",
			Size = UDim2.fromScale(0.451, 0.9),
			HoverImage = onTempPurchaseClick and "rbxassetid://96688805097967" or "rbxassetid://133373335823481",
			Image = onTempPurchaseClick and "rbxassetid://99715845768175" or "rbxassetid://102463242586371",
			ScaleType = Enum.ScaleType.Stretch,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
			ElevatedBackgroundColor3 = color,
			LayoutOrder = 2,
			Position = UDim2.fromScale(0.456, -0.0529),
			OnClick = onMutationClick,
			[React.Tag] = tagConversions.MutationButton
		})
	end

	v12.MutationButton = mutationButton
	local tempPurchaseButton

	if not (isComingSoon or not onTempPurchaseClick) then
		local tempButtonsByTag = {
			Text = isEquipped and "Equipped" or (isLocked or not beliPrice) and "Out of Stock" or `${FormatUtil.commaInteger(beliPrice)}`,
			OnClick = onTempPurchaseClick,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			IsDisabled = isEquipped or isLocked,
			AnchorPoint = Vector2.new(1, 1),
			BackgroundColor3 = CONSTANTS.COLOR.PURCHASE.BACKGROUND,
			ElevatedBackgroundColor3 = color2,
			LayoutOrder = 10,
			Position = UDim2.new(1, -2, 0.883, -2),
			Size = UDim2.fromScale(0.451, 0.9),
			[React.Tag] = tagConversions.TempButton
		}
		local toolTip

		if not isEquipped then
			toolTip = createElement(ToolTip, {
				Text = "Equip"
			})
		end

		tempButtonsByTag.children = {
			ToolTip = toolTip
		}
		tempPurchaseButton = createElement(Button, tempButtonsByTag)
	end

	v12.TempPurchaseButton = tempPurchaseButton
	local giftButton

	if not isComingSoon then
		local size

		if onTempPurchaseClick then
			size = UDim2.fromScale(0.221, 0.9)
		else
			size = UDim2.fromScale(0.451, 0.9)
		end

		giftButton = createElement(Button, {
			SwipeTransparency = 0,
			Text = "Gift",
			Icon = "rbxassetid://120406821796387",
			Size = size,
			HoverImage = onTempPurchaseClick and "rbxassetid://96688805097967" or "rbxassetid://133373335823481",
			Image = onTempPurchaseClick and "rbxassetid://99715845768175" or "rbxassetid://102463242586371",
			ScaleType = Enum.ScaleType.Stretch,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
			ElevatedBackgroundColor3 = color,
			LayoutOrder = 3,
			Position = UDim2.fromScale(0.456, -0.0529),
			OnClick = onGiftClick,
			[React.Tag] = tagConversions.GiftButton
		})
	end

	v12.GiftButton = giftButton
	local uIPadding

	if not isComingSoon then
		uIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0.05, 2),
			PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.XS,
			PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.XS,
			PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XS
		})
	end

	v12.UIPadding = uIPadding
	local swapButton

	if not (isComingSoon or not (onDragonSwap and isOwned)) then
		swapButton = createElement(Button, {
			SwipeTransparency = 0,
			Text = currentDragonSwapType == "East" and "Swap to West" or "Swap to East",
			IsDisabled = false,
			Size = UDim2.fromScale(0.45, 0.9),
			ScaleType = Enum.ScaleType.Stretch,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			LayoutOrder = 0,
			HoverImage = "rbxassetid://133373335823481",
			Image = "rbxassetid://102463242586371",
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(0.455, -2, 0.883, -2),
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
			ElevatedBackgroundColor3 = color,
			OnClick = onDragonSwap,
			[React.Tag] = tagConversions.SwapButton,
			ZIndex = CONSTANTS.LAYER.CONTENT
		})
	end

	v12.SwapButton = swapButton
	local permPurchaseButton

	if not (isComingSoon and not isOwned) then
		local text

		if isOwned then
			text = isEquipped and "Equipped" or "Equip"
		else
			text = not robuxPrice and "Offsale" or "" .. FormatUtil.commaInteger(robuxPrice)
		end

		local permButtonsByTag = {
			SwipeTransparency = 0,
			Text = text,
			IsDisabled = isOwned and isEquipped,
			HoverImage = "rbxassetid://133373335823481",
			Image = "rbxassetid://102463242586371",
			Size = UDim2.fromScale(0.45, isComingSoon and 0.6 or 0.9),
			ScaleType = Enum.ScaleType.Stretch,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			LayoutOrder = 0,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(0.455, -2, 0.883, -2),
			BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
			ElevatedBackgroundColor3 = color,
			OnClick = onPermPurchaseClick,
			ZIndex = CONSTANTS.LAYER.CONTENT,
			[React.Tag] = tagConversions.PermButton
		}
		local isComingSoonToolTip

		if isComingSoon and isOwned then
			isComingSoonToolTip = createElement(ToolTip, {
				Text = "Will be buyable again soon."
			})
		end

		local toolTip

		if not isOwned then
			toolTip = createElement(ToolTip, {
				Text = "Unlock Permanently"
			})
		end

		permButtonsByTag.children = {
			IsComingSoonToolTip = isComingSoonToolTip,
			ToolTip = toolTip
		}
		permPurchaseButton = createElement(Button, permButtonsByTag)
	end

	v12.PermPurchaseButton = permPurchaseButton
	v4.Content = createElement("Frame", v7, {
		Buttons = createElement("Frame", v11, v12)
	})
	return createElement("Frame", mergeGuiObject, v4)
end