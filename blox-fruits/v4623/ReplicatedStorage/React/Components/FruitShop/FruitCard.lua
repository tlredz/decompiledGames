local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
require(script.Parent.Types)
require(game.ReplicatedStorage.Economy.EconomyItem)
require(game.ReplicatedStorage.Spritesheets)
local Card = require(script.Card)
local ControlPanel = require(script.ControlPanel)
local useLastInput = require(game.ReplicatedStorage.React.Hooks.useLastInput)
local useControllerMap = require(game.ReplicatedStorage.React.Hooks.useControllerMap)
local useIsComingSoon = require(game.ReplicatedStorage.React.Hooks.Fruit.useIsComingSoon)
local useLerp = require(game.ReplicatedStorage.React.Components.FruitShop.useLerp)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local color = Color3.fromRGB(75, 75, 75)
local createElement = React.createElement
return function(props)
	local cardAnimationDuration = props.CardAnimationDuration
	local cardAnimationEasingStyle = props.CardAnimationEasingStyle
	local cardAnimationEasingDirection = props.CardAnimationEasingDirection
	local cardHeightRatio = props.CardHeightRatio
	local panelHeightRatio = props.PanelHeightRatio
	local panelPadding = props.PanelPadding
	local isEquipped = props.IsEquipped
	local isOwned = props.IsOwned
	local isSelected = props.IsSelected
	local buildQuality = props.BuildQuality
	local isLocked = props.IsLocked
	local hoverWiggleEnabled = props.HoverWiggleEnabled
	local onCardClick = props.OnCardClick
	local onDragonSwap = props.OnDragonSwap
	local onPermPurchaseClick = props.OnPermPurchaseClick
	local onTempPurchaseClick = props.OnTempPurchaseClick
	local onGiftClick = props.OnGiftClick
	local onCardSelectionGained = props.OnCardSelectionGained
	local isControllerActive = props.IsControllerActive
	local data = props.Data
	local consoleTag = props.ConsoleTag
	local currentDragonSwapType = props.CurrentDragonSwapType
	local isComingSoon = useIsComingSoon(data.Name)
	local robuxPrice = useRobuxPrice(props.Item.ItemId) or data.PermanentRobuxPrice
	local item = props.Item
	local displayName = data.DisplayName
	local skills = data.Skills
	local facts = data.Facts
	local description = data.Description
	local icon = data.Icon
	local artworkIcon = data.ArtworkIcon
	local isAnimatedBackground = data.IsAnimatedBackground
	local price = data.Price
	local idleBackground = data.Rarity.IdleBackground
	local hoverBackground = data.Rarity.HoverBackground
	local v3 = useLastInput()
	local value = TweenService:GetValue(
		useLerp(isSelected and 1 or 0, isSelected and 1 or 0, cardAnimationDuration),
		cardAnimationEasingStyle,
		cardAnimationEasingDirection
	)
	local v4 = onDragonSwap and isOwned
	local v5 = React.useMemo(function()
		return {
			Main = {
				[Enum.KeyCode.DPadDown] = onTempPurchaseClick and "TempButton" or "PermButton",
				[Enum.KeyCode.DPadUp] = onTempPurchaseClick and "TempButton" or "PermButton"
			},
			TempButton = {
				[Enum.KeyCode.DPadUp] = "Main",
				[Enum.KeyCode.DPadLeft] = "GiftButton",
				[Enum.KeyCode.DPadRight] = "PermButton",
				[Enum.KeyCode.DPadDown] = "Main"
			},
			PermButton = {
				[Enum.KeyCode.DPadUp] = "Main",
				[Enum.KeyCode.DPadLeft] = onTempPurchaseClick and "TempButton" or "GiftButton",
				[Enum.KeyCode.DPadRight] = v4 and "SwapButton" or "GiftButton",
				[Enum.KeyCode.DPadDown] = "Main"
			},
			MutationButton = {
				[Enum.KeyCode.DPadUp] = "Main",
				[Enum.KeyCode.DPadRight] = "GiftButton",
				[Enum.KeyCode.DPadLeft] = v4 and "SwapButton" or "PermButton",
				[Enum.KeyCode.DPadDown] = "Main"
			},
			GiftButton = {
				[Enum.KeyCode.DPadUp] = "Main",
				[Enum.KeyCode.DPadRight] = onTempPurchaseClick and "TempButton" or "PermButton",
				[Enum.KeyCode.DPadLeft] = props.OnMutationClick and "MutationButton" or v4 and "SwapButton" or "PermButton",
				[Enum.KeyCode.DPadDown] = "Main"
			},
			SwapButton = {
				[Enum.KeyCode.DPadUp] = "Main",
				[Enum.KeyCode.DPadRight] = props.OnMutationClick and "MutationButton" or "GiftButton",
				[Enum.KeyCode.DPadLeft] = "PermButton",
				[Enum.KeyCode.DPadDown] = "Main"
			}
		}
	end, {
		v4,
		v4,
		onTempPurchaseClick,
		props.OnMutationClick
	})
	local v8

	if v3 == "Gamepad" then
		v8 = isSelected and isControllerActive
	else
		v8 = false
	end

	local v9

	if v3 == "Gamepad" then
		v9 = isSelected and isControllerActive
	else
		v9 = false
	end

	local _, tagConversions, _ = useControllerMap("Main", v8, v9, displayName, v5)
	React.useEffect(function()
		local inputBeganConnection

		if v3 == "Gamepad" and isSelected and isControllerActive then
			inputBeganConnection = UserInputService.InputBegan:Connect(function(input)
				if input.KeyCode == Enum.KeyCode.ButtonB then
					onCardClick(false)
				end
			end)
		else
			inputBeganConnection = nil
		end

		return function()
			if inputBeganConnection then
				inputBeganConnection:Disconnect()
			end
		end
	end, { v3, isSelected, isControllerActive })

	if isOwned then
		onTempPurchaseClick = nil
	end

	local mergeGuiObject = RobloxTypes.mergeGuiObject
	local mainsByTag = {
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
		ZIndex = (props.ZIndex or 0) + (props.OnEggSelect and 1 or 0),
		Selectable = false
	}
	local tag = React.Tag
	local main

	if buildQuality == "Full" then
		if consoleTag and typeof(consoleTag) == "string" then
			main = `{consoleTag} {tagConversions.Main}`
		else
			main = tagConversions.Main
		end
	end

	mainsByTag[tag] = main
	local v13 = mergeGuiObject(mainsByTag, props)
	local v14 = {
		UIListLayout = createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = UDim.new(panelPadding.Scale * value, panelPadding.Offset * value),
			SortOrder = Enum.SortOrder.LayoutOrder
		}),
		ControlPanel = 0,
		CardButton = 0
	}
	local controlPanel

	if value > 0 then
		controlPanel = createElement(ControlPanel, {
			Visibile = value > 0,
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundColor3 = color,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			LayoutOrder = 2,
			Position = UDim2.fromScale(0.5, 1),
			SizeConstraint = Enum.SizeConstraint.RelativeXX,
			HeightRatio = panelHeightRatio,
			Size = UDim2.fromScale(1, value * 1 * panelHeightRatio),
			IsOwned = isOwned,
			IsEquipped = isEquipped,
			IsLocked = isLocked,
			IsDragon = isAnimatedBackground,
			CurrentDragonSwapType = currentDragonSwapType,
			OnDragonSwap = onDragonSwap,
			OnMutationClick = props.OnMutationClick,
			OnPermPurchaseClick = onPermPurchaseClick,
			OnTempPurchaseClick = onTempPurchaseClick,
			OnGiftClick = onGiftClick,
			Item = item,
			TagConversions = tagConversions,
			IsComingSoon = isComingSoon,
			RobuxPrice = robuxPrice,
			BeliPrice = price
		})
	end

	v14.ControlPanel = controlPanel
	v14.CardButton = createElement(Card, {
		Active = false,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.fromScale(1, 1 * cardHeightRatio),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		Position = UDim2.fromScale(0.497, 0.28),
		SizeConstraint = Enum.SizeConstraint.RelativeXX,
		AutoButtonColor = false,
		ZIndex = CONSTANTS.LAYER.RAISED,
		BuildQuality = buildQuality,
		ClipsDescendants = false,
		Selectable = true,
		OnEggSelect = props.OnEggSelect,
		HoverIconBackground = hoverBackground,
		IdleIconBackground = idleBackground,
		FruitTile = icon,
		IsComingSoon = isComingSoon,
		ArtworkIcon = artworkIcon,
		IsTemporary = onTempPurchaseClick ~= nil,
		IsSelected = isSelected,
		IsDragon = isAnimatedBackground,
		IsWiggleEnabled = hoverWiggleEnabled,
		IsEquipped = isEquipped,
		IsOwned = isOwned,
		IsLocked = isLocked,
		DisplayName = displayName,
		Description = description,
		RobuxPrice = robuxPrice,
		BeliPrice = price,
		Facts = facts,
		Skills = skills,
		Item = item,
		CardHeightRatio = cardHeightRatio,
		OnCardClick = onCardClick,
		OnCardSelectionGained = onCardSelectionGained,
		ConsoleTag = consoleTag,
		TagConversions = tagConversions
	})
	return createElement("Frame", v13, v14)
end