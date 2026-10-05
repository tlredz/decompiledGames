local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
require(script.Parent.Parent.Parent.Types)
require(game.ReplicatedStorage.Economy.EconomyItem)
require(game.ReplicatedStorage.React.Util)
local FruitTile = require(game.ReplicatedStorage.React.Components.FruitShop.FruitCard.Card.Profile.FruitTile)
local FactChipContainer = require(script.FactChipContainer)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local useDiscountedDragonPrice = require(game.ReplicatedStorage.React.Hooks.Fruit.useDiscountedDragonPrice)
local useHasDragonDiscount = require(game.ReplicatedStorage.React.Hooks.Player.useHasDragonDiscount)
local useSpring = require(game.ReplicatedStorage.React.Hooks.Animation.useSpring)
local useKeyInfo = require(game.ReplicatedStorage.React.Hooks.Fruit.useKeyInfo)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local rbxassetfontsfamiliesPermanentMarkerjson = Font.new("rbxasset://fonts/families/PermanentMarker.json")
local color = Color3.fromRGB(0, 25, 15)
local createElement = React.createElement
return function(props)
	local isOwned = props.IsOwned
	local isLocked = props.IsLocked
	local isSelected = props.IsSelected
	local isTemporary = props.IsTemporary
	local displayName = props.DisplayName
	local description = props.Description
	local robuxPrice = props.RobuxPrice
	local v = useRobuxPrice(props.Item.ItemId) or robuxPrice
	local beliPrice = props.BeliPrice
	local skillWeight = props.SkillWeight
	local isDragon = props.IsDragon
	local v2 = useDiscountedDragonPrice()

	if useHasDragonDiscount() and isDragon then
		v = v2 or v
	end

	local isEquipped = props.IsEquipped
	local facts = props.Facts
	local buildQuality = props.BuildQuality
	local isComingSoon = props.IsComingSoon
	local v3 = useKeyInfo(displayName .. "-" .. displayName)
	local selectionAlpha = useSpring(isSelected and 1 or 0, isSelected and 1 or 0, 1, 4)
	local v5 = description and 0 or 0.075
	local mergeGuiObject = RobloxTypes.mergeGuiObject({}, props)
	local v8 = {
		UIListLayout = createElement("UIListLayout", {
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0.035, 3),
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = Enum.VerticalAlignment.Center
		}),
		TopInfo = 0,
		Icon = 0
	}
	local topInfo

	if buildQuality ~= "Minimal" then
		local v12 = {
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			LayoutOrder = 2,
			Position = UDim2.fromScale(0.454, 0.5),
			Size = UDim2.fromScale(1.29, 0.95 + selectionAlpha * 0.05),
			ClipsDescendants = false
		}
		local comingSoonLabel

		if isComingSoon then
			comingSoonLabel = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticSize = Enum.AutomaticSize.None,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(-7.96e-8, 0.308),
				Size = UDim2.fromScale(0, v5 + 0.247):Lerp(UDim2.fromScale(0, v5 + 0.127), selectionAlpha),
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				UIListLayout = createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = CONSTANTS.SPACING.PADDING.NONE
				}),
				Background = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://82332807858397",
					ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					Position = UDim2.fromScale(0.5, 0.5),
					AutomaticSize = Enum.AutomaticSize.None,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.fromScale(4.5, 1.1)
				}, {
					UIListLayout = createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = CONSTANTS.SPACING.PADDING.NONE
					}),
					TextLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						AutoLocalize = false,
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						AutomaticSize = Enum.AutomaticSize.None,
						FontFace = rbxassetfontsfamiliesPermanentMarkerjson,
						Position = UDim2.fromScale(0.5, 0.5),
						RichText = true,
						Size = UDim2.fromScale(0.9, 1),
						Text = "(In-Progress)",
						TextColor3 = Color3.fromHex("#DB651D"),
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center,
						TextScaled = true,
						TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
						TextWrapped = false,
						ZIndex = CONSTANTS.LAYER.RAISED
					})
				})
			})
		end

		local outOfStockLabel

		if not (isComingSoon or not (isTemporary and isLocked)) then
			outOfStockLabel = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticSize = Enum.AutomaticSize.None,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(-7.96e-8, 0.308),
				Size = UDim2.fromScale(0, v5 + 0.247):Lerp(UDim2.fromScale(0, v5 + 0.127), selectionAlpha),
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				UIListLayout = createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = CONSTANTS.SPACING.PADDING.NONE
				}),
				Background = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://82332807858397",
					ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					Position = UDim2.fromScale(0.5, 0.5),
					AutomaticSize = Enum.AutomaticSize.None,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.fromScale(4.5, 1.1)
				}, {
					UIListLayout = createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = CONSTANTS.SPACING.PADDING.NONE
					}),
					TextLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						AutoLocalize = false,
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						AutomaticSize = Enum.AutomaticSize.None,
						FontFace = rbxassetfontsfamiliesPermanentMarkerjson,
						Position = UDim2.fromScale(0.5, 0.5),
						RichText = true,
						Size = UDim2.fromScale(0.9, 1),
						Text = "(Out of Stock)",
						TextColor3 = Color3.fromRGB(255, 41, 41),
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center,
						TextScaled = true,
						TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
						TextWrapped = false,
						ZIndex = CONSTANTS.LAYER.RAISED
					})
				})
			})
		end

		local price

		if not (isComingSoon or isOwned or isLocked and isTemporary) then
			local v18 = {
				AutoLocalize = false,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(-7.96e-8, 0.308),
				Size = UDim2.fromScale(0.992, v5 + 0.247):Lerp(UDim2.fromScale(0.992, v5 + 0.127), selectionAlpha),
				Text = 0,
				TextColor3 = 0,
				TextScaled = true,
				TextStrokeColor3 = 0,
				TextStrokeTransparency = 0.4,
				TextWrapped = true,
				TextXAlignment = 0
			}
			local text

			if isTemporary then
				text = not beliPrice and "???" or `${FormatUtil.commaInteger(beliPrice)}`
			else
				text = not v and "" or "" .. `{FormatUtil.commaInteger(v)}`
			end

			v18.Text = text
			v18.TextColor3 = Color3.fromRGB(38, 255, 0)
			v18.TextStrokeColor3 = Color3.fromRGB(11, 77, 0)
			v18.TextXAlignment = Enum.TextXAlignment.Left
			price = createElement("TextLabel", v18)
		end

		local ownedLabel

		if not (isComingSoon or not isOwned) then
			ownedLabel = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutomaticSize = Enum.AutomaticSize.None,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(-7.96e-8, 0.308),
				Size = UDim2.fromScale(0, v5 + 0.247):Lerp(UDim2.fromScale(0, v5 + 0.127), selectionAlpha),
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				UIListLayout = createElement("UIListLayout", {
					SortOrder = Enum.SortOrder.LayoutOrder,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					Padding = CONSTANTS.SPACING.PADDING.NONE
				}),
				Background = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundColor3 = Color3.fromRGB(29, 29, 29),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					BorderColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					Image = "rbxassetid://82332807858397",
					ImageColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					Position = UDim2.fromScale(0.5, 0.5),
					AutomaticSize = Enum.AutomaticSize.None,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.fromScale(4.5, 1.1)
				}, {
					UIListLayout = createElement("UIListLayout", {
						SortOrder = Enum.SortOrder.LayoutOrder,
						VerticalAlignment = Enum.VerticalAlignment.Center,
						Padding = CONSTANTS.SPACING.PADDING.NONE
					}),
					TextLabel = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						AutoLocalize = false,
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						AutomaticSize = Enum.AutomaticSize.None,
						FontFace = rbxassetfontsfamiliesPermanentMarkerjson,
						Position = UDim2.fromScale(0.5, 0.5),
						RichText = true,
						Size = UDim2.fromScale(0.9, 1),
						Text = "(Owned)",
						TextColor3 = Color3.fromRGB(255, 209, 41),
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center,
						TextScaled = true,
						TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
						TextWrapped = false,
						ZIndex = CONSTANTS.LAYER.RAISED
					})
				})
			})
		end

		local children = {
			ComingSoonLabel = comingSoonLabel,
			OutOfStockLabel = outOfStockLabel,
			Price = price,
			OwnedLabel = ownedLabel,
			UIListLayout = createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				Padding = CONSTANTS.SPACING.PADDING.NONE
			}),
			Title = createElement("TextLabel", {
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				FontFace = CONSTANTS.FONT.FACE.BODY,
				LayoutOrder = -1,
				Size = UDim2.fromScale(0.936, 0.4):Lerp(
					UDim2.fromScale(0.936, (description and 0 or 0.175) + 0.275),
					selectionAlpha
				),
				Text = displayName,
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true,
				TextSize = 14,
				TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
				TextWrapped = true,
				TextXAlignment = Enum.TextXAlignment.Left
			}, {
				FruitName = createElement("TextLabel", {
					AutomaticSize = Enum.AutomaticSize.X,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					FontFace = CONSTANTS.FONT.FACE.BODY,
					LayoutOrder = -1,
					Position = UDim2.fromScale(0, -0.0621),
					Size = UDim2.fromScale(1, 1),
					Text = displayName,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					TextSize = 14,
					TextStrokeTransparency = CONSTANTS.ALPHA.OPAQUE,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left
				})
			}),
			InfoWrapper = 0,
			Facts = 0
		}
		local infoWrapper

		if selectionAlpha > 0 and description then
			local v20 = {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				ClipsDescendants = true,
				Size = UDim2.fromScale(0.8, 0.25 * selectionAlpha)
			}
			local descriptionContainer

			if description then
				descriptionContainer = createElement("Frame", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					SizeConstraint = Enum.SizeConstraint.RelativeXX,
					Size = UDim2.fromScale(1, 0.25)
				}, {
					UIListLayout = createElement("UIListLayout", {
						HorizontalAlignment = Enum.HorizontalAlignment.Left,
						Padding = CONSTANTS.SPACING.PADDING.OFFSET.SM,
						SortOrder = Enum.SortOrder.LayoutOrder
					}),
					Description = createElement("TextLabel", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
						FontFace = CONSTANTS.FONT.FACE.BODY,
						LayoutOrder = 2,
						Position = UDim2.fromScale(0, 0.389),
						Size = UDim2.fromScale(1 - math.clamp((skillWeight - 0.2) / 0.4, 0, 1) * 0.2, 0.5),
						Text = description,
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextScaled = true,
						ClipsDescendants = true,
						TextSize = 14,
						TextStrokeTransparency = 1 - 0.5 * selectionAlpha,
						TextTransparency = 1 - selectionAlpha,
						TextWrapped = true,
						TextXAlignment = Enum.TextXAlignment.Left,
						children = {
							UIPadding = createElement("UIPadding", {
								PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.XS,
								PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XS,
								PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.XS
							})
						}
					})
				})
			end

			infoWrapper = createElement("Frame", v20, {
				DescriptionContainer = descriptionContainer
			})
		end

		children.InfoWrapper = infoWrapper
		local v20 = {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			LayoutOrder = 999,
			Position = UDim2.fromScale(0.439, 0.709),
			Size = UDim2.fromScale(0.76, 0.225):Lerp(UDim2.fromScale(0.76, 0.315), selectionAlpha),
			ClipsDescendants = true,
			ChipTransparency = isDragon and 0.25 or nil,
			ChipBackgroundColor3 = 0,
			Facts = 0,
			SelectionAlpha = 0
		}
		local chipBackgroundColor

		if isDragon then
			chipBackgroundColor = color
		end

		v20.ChipBackgroundColor3 = chipBackgroundColor
		v20.Facts = facts
		v20.SelectionAlpha = selectionAlpha
		children.Facts = createElement(FactChipContainer, v20)
		topInfo = createElement("Frame", v12, children)
	end

	v8.TopInfo = topInfo
	local icon

	if v3 then
		local v13 = {
			OnEggSelect = props.OnEggSelect,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.207, 0.5),
			Size = UDim2.fromScale(0.9, 0.9),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			ZIndex = CONSTANTS.LAYER.RAISED,
			FruitStorageKey = 0,
			IsSelected = 0,
			IsEquipped = 0
		}
		local fruitStorageKey

		if isTemporary then
			fruitStorageKey = v3.Physical
		else
			fruitStorageKey = v3.Permanent
		end

		v13.FruitStorageKey = fruitStorageKey
		v13.IsSelected = isSelected
		v13.IsEquipped = isEquipped
		icon = createElement(FruitTile, v13)
	end

	v8.Icon = icon
	return createElement("Frame", mergeGuiObject, v8)
end