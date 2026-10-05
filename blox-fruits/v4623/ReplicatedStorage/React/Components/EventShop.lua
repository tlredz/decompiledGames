local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local Textures = require(game.ReplicatedStorage.Textures)
local Spritesheets = require(game.ReplicatedStorage.Spritesheets)
local useDelayedState = require(game.ReplicatedStorage.React.Hooks.useDelayedState)
local ExitButton = require(game.ReplicatedStorage.React.Components.Inventory.Main.Header.ExitButton)
local Card = require(game.ReplicatedStorage.React.Components.Shop.Card)
local LoadingIcon = require(game.ReplicatedStorage.React.Components.LoadingIcon)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local v = {
	Valentines2026 = {
		Title = "Valentine's Day Event Shop",
		TitleIcons = {
			{
				Image = Textures.misc["heart.png"],
				ImageRectOffset = Vector2.new(0, 0),
				ImageRectSize = Vector2.new(128, 119)
			}
		},
		TitleColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 94, 161)),
			ColorSequenceKeypoint.new(0.355786, Color3.fromRGB(255, 181, 212)),
			ColorSequenceKeypoint.new(0.509499, Color3.fromRGB(255, 181, 212)),
			ColorSequenceKeypoint.new(0.699482, Color3.fromRGB(255, 181, 212)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 94, 161))
		}),
		DescriptionStrokeColor = Color3.fromRGB(255, 94, 161),
		CurrencyEmoji = "❤️",
		CurrencyName = "Heart"
	},
	Easter2026 = {
		Title = "🐰 Easter Event Shop 🌷",
		TitleIcons = {
			Spritesheets.match("Pink Egg1"):unwrap(),
			Spritesheets.match("Yellow Striped Egg1"):unwrap(),
			Spritesheets.match("Blue Egg1"):unwrap(),
			Spritesheets.match("Orange Egg1"):unwrap(),
			Spritesheets.match("Green Egg1"):unwrap()
		},
		TitleColor = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(212, 255, 120)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(171, 251, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(213, 179, 255))
		}),
		CurrencyEmoji = "🥚",
		CurrencyName = "Candy Egg",
		DescriptionStrokeColor = Color3.fromRGB(130, 195, 255)
	}
}
local createElement = React.createElement

function rotaryIndex(list, p: number)
	return list[(p - 1) % #list + 1]
end

function eventTile(props)
	if props.IsLoading then
		return createElement("ImageLabel", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://2882228740",
			ImageColor3 = Color3.fromHex("#1C1C1C"):Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.5),
			LayoutOrder = props.LayoutOrder,
			Position = props.Position,
			ScaleType = Enum.ScaleType.Slice,
			Size = props.Size,
			SizeConstraint = props.SizeConstraint,
			SliceCenter = Rect.new(4, 4, 16, 16),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			Icon = createElement(LoadingIcon, {
				ZIndex = CONSTANTS.LAYER.CONTENT,
				Position = UDim2.fromScale(0.5, 0.475),
				Size = UDim2.fromScale(0.7, 0.7),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ImageTransparency = 0.7,
				LayoutOrder = 1,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				AutomaticSize = Enum.AutomaticSize.None
			})
		})
	end

	return createElement(Card, {
		ZIndex = props.ZIndex,
		Position = props.Position,
		Size = props.Size,
		AnchorPoint = props.AnchorPoint,
		LayoutOrder = props.LayoutOrder,
		SizeConstraint = props.SizeConstraint,
		AutomaticSize = props.AutomaticSize,
		Title = props.Item.Title,
		TitleColor = props.Config.TitleColor,
		ProductImage = typeof(props.Item.Icon.Image) ~= "string" and "" or props.Item.Icon.Image,
		ProductImageOffset = props.Item.Icon.ImageRectOffset,
		ProductImageSize = props.Item.Icon.ImageRectSize,
		ProductGlow = nil,
		StorageKey = nil,
		ProductImageIconSize = UDim2.fromScale(0.7, 0.7),
		ProductImageIconAnchorPoint = Vector2.new(0.5, 0.525),
		Description = props.Item.HypeText,
		DescriptionHeight = UDim.new(0.75, 0),
		DescriptionYPosition = UDim.new(0.025, 0),
		DescriptionStrokeColor3 = props.Config.DescriptionStrokeColor,
		OnClick = props.OnClick,
		Price = `{props.Config.CurrencyEmoji} ` .. props.Item.Price,
		IsDisabled = props.OnClick == nil,
		IsRework = false,
		BuyButtonHeight = UDim.new(0.2, 0),
		YellowBuyButtonYPadding = UDim.new(0, 0),
		FlexWidthRatio = 1,
		BuyButtonStyle = "Yellow"
	})
end

return function(props)
	local config = v[props.EventType or "Valentines2026"]
	local title = config.Title
	local state, setState = React.useState(nil)
	local state2, setState2 = React.useState(nil)
	local v3, v4 = useDelayedState(false)
	React.useEffect(function()
		if v3 and state2 then
			local thread = task.spawn(function()
				setState2(nil)
				v4(false, 0)
			end)
			return function()
				task.cancel(thread)
			end
		else
			return function() end
		end
	end, { v3, state2 })
	local children = {}

	for i = 1, 6 do
		local item = props.Items[i]

		if item and not item.Sold then
			local v5 = item
			children[`Featured{i}`] = createElement(eventTile, {
				IsLoading = state and state.Key == item.Key and true or state2 == item.Key,
				Item = item,
				LayoutOrder = i,
				Config = config,
				OnClick = not state and function()
					if v5.Type == "Fruit" then
						setState(v5)
						return
					end

					setState(nil)
					setState2(v5.Key)
					v4(true, 2)
					props.OnClick(v5.Key)
				end or nil
			})
		else
			children[`Card{i}`] = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://2882228740",
				ImageColor3 = Color3.fromHex("#1C1C1C"):Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.5),
				LayoutOrder = i,
				Position = UDim2.fromScale(0.5, 0.04),
				ScaleType = Enum.ScaleType.Slice,
				Size = UDim2.fromScale(0.19, 0.24),
				SizeConstraint = Enum.SizeConstraint.RelativeXX,
				SliceCenter = Rect.new(4, 4, 16, 16),
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = Font.new("rbxasset://fonts/families/PermanentMarker.json"),
					Position = UDim2.fromScale(0.5, 0.45),
					Size = UDim2.fromScale(0.8, 0.3),
					Text = "SOLD OUT",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextTransparency = 0.7,
					TextScaled = true
				})
			})
		end
	end

	local mergeGuiObject = RobloxTypes.mergeGuiObject({
		BackgroundColor3 = Color3.fromRGB(21, 21, 21),
		BackgroundTransparency = 0.04
	}, props)
	local blackout

	if state ~= nil then
		blackout = createElement("Frame", {
			Active = true,
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = 0.2,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			Position = UDim2.fromOffset(-2, -2),
			Size = UDim2.new(1, 4, 1, 4),
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		}, {
			Confirm = createElement("ImageLabel", {
				Active = true,
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(43, 43, 43),
				BorderColor3 = Color3.fromRGB(255, 197, 20),
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
				ImageColor3 = Color3.fromRGB(250, 238, 238),
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(0.8, 0.45),
				ZIndex = 4
			}, {
				ImageLabel = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0),
					BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					BorderColor3 = Color3.fromRGB(255, 197, 20),
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
					Position = UDim2.fromScale(0.5, -0.15),
					Size = UDim2.fromScale(1, 0.15),
					ZIndex = 4
				}, {
					TextLabel = createElement("TextLabel", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = CONSTANTS.FONT.FACE.BODY_BOLD,
						Position = UDim2.fromScale(0, -0.1),
						Size = UDim2.fromScale(1, 1.5),
						Text = "CONFIRM",
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextScaled = true,
						TextYAlignment = Enum.TextYAlignment.Top,
						ZIndex = CONSTANTS.LAYER.OVERLAY
					}),
					UIPadding = createElement("UIPadding", {
						PaddingBottom = UDim.new(0.3, 0),
						PaddingTop = CONSTANTS.SPACING.PADDING.SCALE.XXL
					})
				}),
				TextLabel = createElement("TextLabel", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
					Position = UDim2.fromScale(0.025, 0.05),
					Size = UDim2.fromScale(0.95, 0.55),
					Text = "This will replace your current fruit, are you sure?",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true,
					ZIndex = 4
				}),
				Buy = createElement("TextButton", {
					BackgroundColor3 = Color3.fromRGB(79, 239, 34),
					BorderColor3 = Color3.fromRGB(34, 108, 0),
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
					FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
					Position = UDim2.fromScale(0.05, 0.66),
					Size = UDim2.fromScale(0.4, 0.25),
					Text = "",
					TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					TextScaled = true,
					TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					[React.Event.Activated] = function()
						setState(nil)
						setState2(state.Key)
						v4(true, 2)
						props.OnClick(state.Key)
					end,
					ZIndex = 4
				}, {
					Trans = createElement("Frame", {
						BackgroundColor3 = Color3.fromRGB(128, 255, 114),
						BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
						Position = UDim2.fromOffset(2, 2),
						Size = UDim2.new(1, -4, 0.4, 0),
						ZIndex = CONSTANTS.LAYER.OVERLAY
					}),
					TextLabel = createElement("TextLabel", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
						Size = UDim2.fromScale(1, 1),
						Text = "BUY",
						TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
						TextScaled = true,
						ZIndex = 6
					})
				}),
				Cancel = createElement("TextButton", {
					BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
					BorderColor3 = Color3.fromRGB(255, 240, 69),
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
					FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.fromScale(0.95, 0.66),
					Size = UDim2.fromScale(0.4, 0.25),
					Text = "",
					TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					TextScaled = true,
					TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					[React.Event.Activated] = function()
						setState(nil)
					end,
					ZIndex = 4
				}, {
					Trans = createElement("Frame", {
						BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT,
						BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
						Position = UDim2.fromOffset(2, 2),
						Size = UDim2.new(1, -4, 0.4, 0),
						ZIndex = CONSTANTS.LAYER.OVERLAY
					}),
					TextLabel = createElement("TextLabel", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
						Size = UDim2.fromScale(1, 1),
						Text = "CANCEL",
						TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
						TextScaled = true,
						ZIndex = 6
					})
				})
			})
		})
	end

	return createElement("Frame", mergeGuiObject, {
		Blackout = blackout,
		Main = createElement("Frame", {
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Position = UDim2.fromScale(0, 0.115),
			Size = UDim2.fromScale(1, 0.786484),
			ZIndex = CONSTANTS.LAYER.RAISED
		}, {
			Content = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Position = UDim2.fromScale(0.5, 0.05),
				Size = UDim2.fromScale(0.975, 0.9),
				ZIndex = CONSTANTS.LAYER.RAISED
			}, {
				UIGridLayout = createElement("UIGridLayout", {
					CellPadding = UDim2.fromScale(0.02, 0.03),
					CellSize = UDim2.fromScale(0.31, 0.49),
					SortOrder = Enum.SortOrder.LayoutOrder,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center
				}),
				Cards = createElement(React.Fragment, {}, children)
			})
		}),
		CurrencyLabel = createElement("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			FontFace = CONSTANTS.FONT.FACE.DISPLAY,
			Position = UDim2.fromScale(0.5, 0.965),
			Size = UDim2.fromScale(1, 0.065),
			Text = `You currently have {config.CurrencyEmoji} {props.CurrencyAmount} {config.CurrencyName}{props.CurrencyAmount == 1 and "" or "s"}.`,
			TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			TextScaled = true
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = UDim.new(0.02, 0)
		}),
		UIStroke = createElement("UIStroke", {
			Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			ZIndex = CONSTANTS.LAYER.BASE
		}),
		Title = createElement("Frame", {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			Size = UDim2.fromScale(1, 0.115)
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
			}),
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
				ZIndex = CONSTANTS.LAYER.BASE
			}),
			UIGradient = createElement("UIGradient", {
				Color = config.TitleColor
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.55),
				Size = UDim2.fromScale(0.8, 0.8),
				Text = title,
				TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.THIN,
					ZIndex = CONSTANTS.LAYER.BASE
				}),
				TextLabel = createElement("TextLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					Position = UDim2.fromScale(0.5, 0.45),
					Size = UDim2.fromScale(1, 1),
					Text = title,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextScaled = true
				}, {
					UIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
						ZIndex = CONSTANTS.LAYER.BASE
					})
				})
			}),
			Dec1 = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = rotaryIndex(config.TitleIcons, 1).Image,
				ImageRectOffset = rotaryIndex(config.TitleIcons, 1).ImageRectOffset,
				ImageRectSize = rotaryIndex(config.TitleIcons, 1).ImageRectSize,
				Position = UDim2.fromScale(0.015, 0.289),
				ScaleType = Enum.ScaleType.Fit,
				Rotation = -15,
				Size = UDim2.fromScale(0.091, 0.91)
			}),
			Dec2 = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = rotaryIndex(config.TitleIcons, 2).Image,
				ImageRectOffset = rotaryIndex(config.TitleIcons, 2).ImageRectOffset,
				ImageRectSize = rotaryIndex(config.TitleIcons, 2).ImageRectSize,
				Position = UDim2.fromScale(0.0978171, 0.719136),
				Rotation = 25,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.074409, 0.715242)
			}),
			Dec3 = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = rotaryIndex(config.TitleIcons, 3).Image,
				ImageRectOffset = rotaryIndex(config.TitleIcons, 3).ImageRectOffset,
				ImageRectSize = rotaryIndex(config.TitleIcons, 3).ImageRectSize,
				Position = UDim2.fromScale(0.9025, 0.723689),
				Rotation = 10,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.091, 0.91)
			}),
			Dec4 = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = rotaryIndex(config.TitleIcons, 4).Image,
				ImageRectOffset = rotaryIndex(config.TitleIcons, 4).ImageRectOffset,
				ImageRectSize = rotaryIndex(config.TitleIcons, 4).ImageRectSize,
				Position = UDim2.fromScale(1, 0),
				Rotation = -5,
				ScaleType = Enum.ScaleType.Fit,
				Size = UDim2.fromScale(0.091, 0.724711)
			}),
			Exit = createElement(ExitButton, {
				AnchorPoint = Vector2.new(1, 0.5),
				OnExit = props.OnExit,
				Position = UDim2.fromScale(0.99, 0.5),
				Size = UDim2.fromScale(0.85, 0.85),
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			})
		}),
		UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.3
		}),
		UISizeConstraint = createElement("UISizeConstraint", {
			MaxSize = Vector2.new(1e999, 575)
		})
	})
end