local TweenService = game:GetService("TweenService")
local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.Packages.Result)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local Shop = require(game.ReplicatedStorage.Shop)
require(game.ReplicatedStorage.Economy.EconomyItem)
require(game.ReplicatedStorage.Spritesheets)
local Button = require(game.ReplicatedStorage.React.Components.Button)
local DoubleText = require(script.DoubleText)
local ExitButton = require(script.ExitButton)
local useTime = require(game.ReplicatedStorage.React.Hooks.Animation.useTime)
local useOscillation = require(game.ReplicatedStorage.React.Hooks.Animation.useOscillation)
local usePeriod = require(game.ReplicatedStorage.React.Hooks.Animation.usePeriod)
local useViewportSize = require(game.ReplicatedStorage.React.Hooks.useViewportSize)
local useSpring = require(game.ReplicatedStorage.React.Hooks.Animation.useSpring)
local useGuiServiceSelect = require(game.ReplicatedStorage.React.Hooks.useGuiServiceSelect)
local use = require(game.ReplicatedStorage.React.Hooks.UID.use)
local useTagGuiObject = require(game.ReplicatedStorage.React.Hooks.UID.useTagGuiObject)
local useRobuxPrice = require(game.ReplicatedStorage.React.Hooks.Item.useRobuxPrice)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local color = Color3.fromRGB(43, 43, 43)
local color2 = Color3.fromRGB(255, 240, 69)
local color3 = Color3.fromRGB(255, 197, 20)
local rbxassetfontsfamiliesPermanentMarkerjson = Font.new("rbxasset://fonts/families/PermanentMarker.json")
local unwrapped = Shop.match("Discounted Permanent Dragon"):unwrap()
local v = {
	Image = "http://www.roblox.com/asset/?id=92720114148977",
	ImageRectOffset = Vector2.new(0, 0),
	ImageRectSize = Vector2.new(400, 400)
}
local v2 = {
	Image = "http://www.roblox.com/asset/?id=92720114148977",
	ImageRectOffset = Vector2.new(400, 0),
	ImageRectSize = Vector2.new(400, 400)
}
local v3 = { "rbxassetid://130859278826136" }
local color4 = Color3.fromHex("FCE100")
local color5 = Color3.fromHex("FF36BB")
local createElement = React.createElement

function spinnerBackground(props)
	local alpha = props.Alpha
	local finalSize = props.FinalSize
	local onExplosionStart = props.OnExplosionStart
	local isQuick = props.IsQuick
	local state, setState = React.useState(isQuick)
	local v5

	if alpha > 0 then
		v5 = not isQuick
	else
		v5 = false
	end

	local v6 = usePeriod(v5, 0.5)
	local v8

	if alpha > 0 then
		v8 = not isQuick
	else
		v8 = false
	end

	local v9 = useOscillation(v8, 0.5)
	local v10 = useViewportSize()
	local v11 = math.floor(isQuick and 4 or alpha * 4)
	local v12 = Vector2.one * v10.Y * (v11 / 4 * 0.125 + 0.15) * (1 + 0.05 * v9)
	local uDim = UDim2.fromOffset(v12.Y * 0.95 * (1 + 0.055 * v9), v12.Y * 0.95 * (1 + 0.055 * v9))
	local backgroundTransparency = useSpring(v11 >= 4 and 1 or 0, (v11 >= 4 or isQuick) and 1 or 0, 0.5, 4)
	React.useEffect(function()
		if backgroundTransparency > 0 and not state then
			setState(true)
			onExplosionStart()
		end

		return function() end
	end, { backgroundTransparency, state })
	local imageTransparency = TweenService:GetValue(
		math.clamp(backgroundTransparency * 4, 0, 1),
		Enum.EasingStyle.Quad,
		Enum.EasingDirection.Out
	)
	local mergeGuiObject = RobloxTypes.mergeGuiObject
	local v16 = {
		Size = UDim2.fromScale(v11 / 4 * 0.125 + 0.15, v11 / 4 * 0.125 + 0.15):Lerp(finalSize, backgroundTransparency),
		SizeConstraint = Enum.SizeConstraint.RelativeYY,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		children = 0
	}
	local children = {
		Background = createElement("Frame", {
			ZIndex = CONSTANTS.LAYER.CONTENT,
			Size = UDim2.fromOffset(v12.Y * 1 * (1 + 0.025 * v9), v12.Y * 1 * (1 + 0.025 * v9)):Lerp(
				UDim2.fromScale(1, 1),
				backgroundTransparency
			),
			Position = UDim2.fromScale(0.5, 0.5),
			BackgroundTransparency = backgroundTransparency,
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK:Lerp(CONSTANTS.COLOR.PALETTE.WHITE, backgroundTransparency),
			AnchorPoint = Vector2.new(0.5, 0.5)
		}, {
			UICorners = createElement("UICorner", {
				CornerRadius = UDim.new(0.5 * (1 - backgroundTransparency), 4 * backgroundTransparency)
			}),
			UIStroke = createElement("UIStroke", {
				Transparency = state and 1 or 0,
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
				Color = color3
			}),
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, color5:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.8)),
					ColorSequenceKeypoint.new(
						0.4,
						color5:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.8):Lerp(CONSTANTS.COLOR.PRIMARY.HIGHLIGHT, 0.4)
					),
					ColorSequenceKeypoint.new(0.5, CONSTANTS.COLOR.PRIMARY.HIGHLIGHT),
					ColorSequenceKeypoint.new(
						0.6,
						color4:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.8):Lerp(CONSTANTS.COLOR.PRIMARY.HIGHLIGHT, 0.4)
					),
					ColorSequenceKeypoint.new(1, color4:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, 0.8))
				}),
				Rotation = state and 0 or v6 * 360
			})
		}),
		Ring = 0,
		EastIcon = 0,
		WestIcon = 0
	}
	local ring

	if backgroundTransparency < 1 then
		ring = createElement("ImageLabel", {
			ZIndex = 10,
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			ImageTransparency = backgroundTransparency ^ 5,
			Size = UDim2.fromOffset(v12.Y * 1.9, v12.Y * 1.9):Lerp(UDim2.fromScale(2, 2), backgroundTransparency),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Image = "rbxassetid://535697787",
			Rotation = v6 * 360
		}, {
			UIGradient = createElement("UIGradient", {
				Color = ColorSequence.new({
					ColorSequenceKeypoint.new(0, color5),
					ColorSequenceKeypoint.new(0.3 + 0.2 * v9, color5),
					ColorSequenceKeypoint.new(0.7 + 0.2 * v9, color4),
					ColorSequenceKeypoint.new(1, color4)
				}),
				Rotation = 0
			}),
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
			})
		})
	end

	children.Ring = ring
	local eastIcon

	if backgroundTransparency < 1 then
		eastIcon = createElement("ImageLabel", {
			ZIndex = CONSTANTS.LAYER.RAISED,
			Size = uDim,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageTransparency = imageTransparency,
			Image = typeof(v2.Image) ~= "string" and "" or v2.Image,
			ImageRectOffset = v2.ImageRectOffset,
			ImageRectSize = v2.ImageRectSize
		}, {
			UIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.4, 0),
					NumberSequenceKeypoint.new(0.6, 1),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Rotation = (v6 * 360 + 180) % 360
			}),
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
			})
		})
	end

	children.EastIcon = eastIcon
	local westIcon

	if backgroundTransparency < 1 then
		westIcon = createElement("ImageLabel", {
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH,
			Size = uDim,
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			ImageTransparency = imageTransparency,
			Image = typeof(v.Image) ~= "string" and "" or v.Image,
			ImageRectOffset = v.ImageRectOffset,
			ImageRectSize = v.ImageRectSize
		}, {
			UIGradient = createElement("UIGradient", {
				Transparency = NumberSequence.new({
					NumberSequenceKeypoint.new(0, 0),
					NumberSequenceKeypoint.new(0.4, 0),
					NumberSequenceKeypoint.new(0.6, 1),
					NumberSequenceKeypoint.new(1, 1)
				}),
				Rotation = v6 * 360
			}),
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
			})
		})
	end

	children.WestIcon = westIcon
	v16.children = children
	return createElement("Frame", mergeGuiObject(v16, props))
end

return function(props)
	local isOpen = props.IsOpen
	local onCloseComplete = props.OnCloseComplete
	local isQuick = props.IsQuick
	local onSelectionClick = props.OnSelectionClick
	local headerOverride = props.HeaderOverride
	local bodyText = props.BodyText
	local onDiscountClick = props.OnDiscountClick
	local equipButtonText = props.EquipButtonText or "Equip"
	local isWestEnabled = props.IsWestEnabled
	local isEastEnabled = props.IsEastEnabled
	local state, setState = React.useState(false)
	local v4 = useRobuxPrice(unwrapped.ItemId)
	local v5, v6 = useTagGuiObject("DragonSelectionMenu_WestButton")
	local v7, v8 = useTagGuiObject("DragonSelectionMenu_EastButton")
	local v9, v10 = useTagGuiObject("DragonSelectionMenu_CloseButton")
	local nextSelectionDown, v12 = useTagGuiObject("DragonSelectionMenu_DiscountButton")
	local v13 = use("DragonSelectionMenu")
	useGuiServiceSelect(v13, isOpen)
	local v14 = useSpring(0, isOpen and 1 or 0, 1, 1.5)
	local state2, setState2 = React.useState(isQuick)
	local v15 = useViewportSize()
	local v16 = usePeriod(v4 ~= nil, 2)
	local v17 = React.useMemo(function()
		return string.rep(".", (math.round(3 * v16)))
	end, { v16 })
	local v18 = useSpring(state2 and 1 or 0, state2 and 1 or 0, 0.5, 4)

	if isQuick and not state then
		v18 = v14
	end

	local v19 = usePeriod(v14 > 0, 0.5)
	local alpha = math.clamp(useTime(true), 0, 2) / 2

	if not isOpen and v14 > 0 and not state then
		setState(true)
	end

	if state and v14 == 0 then
		onCloseComplete()
		setState(false)
	end

	local v21 = 0.5 - 0.25 * v18
	local v22 = 0.5 + 0.25 * v18
	local uDim

	if bodyText then
		uDim = UDim2.fromScale(0.4, 0.4)
	else
		uDim = UDim2.fromScale(0.5, 0.5)
	end

	local v23 = bodyText and 0.5 or 0.4
	local v24 = isWestEnabled and 0 or 0.7
	local v25 = isEastEnabled and 0 or 0.7
	local v28 = {
		Enabled = true,
		DisplayOrder = 10,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
		ClipToDeviceSafeArea = false
	}
	local v29 = {
		Scrim = createElement("Frame", {
			ZIndex = CONSTANTS.LAYER.BASE,
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = 1 - v14 * 0.7
		}),
		Container = 0
	}
	local container

	if v14 > 0 then
		local v33 = {
			ZIndex = CONSTANTS.LAYER.CONTENT,
			Size = UDim2.fromScale(v15.Y * 0.5, v15.Y * 0.5),
			SizeConstraint = Enum.SizeConstraint.RelativeXY,
			Position = UDim2.fromScale(0.5, -0.1 + 0.6 * v14),
			AnchorPoint = Vector2.new(0.5, 1 - v14 * 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
		}
		local v34 = {
			SpinnerFrame = createElement(spinnerBackground, {
				ZIndex = CONSTANTS.LAYER.RAISED,
				IsQuick = isQuick,
				FinalSize = UDim2.fromOffset(math.max(v15.Y * 1, 450), math.max(v15.Y * 0.5, 250) * 0),
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Alpha = alpha,
				OnExplosionStart = function()
					if not state2 then
						setState2(true)
					end
				end
			}),
			Background = 0
		}
		local background

		if state2 then
			local v38 = {
				[React.Tag] = v13,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				BackgroundTransparency = 1 - v18,
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				Size = UDim2.fromScale(0, 0):Lerp(
					UDim2.fromOffset(math.max(v15.Y * 1, 450), (math.max(v15.Y * 0.5, 200))),
					v18
				),
				ImageTransparency = 1 - v18,
				Image = typeof(v3.Image) ~= "string" and "" or v3.Image,
				ImageRectOffset = v3.ImageRectOffset,
				ImageRectSize = v3.ImageRectSize,
				SelectionGroup = true,
				SelectionBehaviorDown = Enum.SelectionBehavior.Stop,
				SelectionBehaviorLeft = Enum.SelectionBehavior.Stop,
				SelectionBehaviorRight = Enum.SelectionBehavior.Stop,
				SelectionBehaviorUp = Enum.SelectionBehavior.Stop
			}
			local header

			if headerOverride then
				header = createElement("Frame", {
					ZIndex = CONSTANTS.LAYER.OVERLAY,
					AnchorPoint = Vector2.new(0.5, 0.75),
					Position = UDim2.fromScale(0.5, 0),
					Size = UDim2.new(1, 0, 0.05, 20),
					BackgroundTransparency = 1 - v18,
					BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK
				}, {
					UIStroke = createElement("UIStroke", {
						Transparency = 1 - v18,
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
						Color = color3
					}),
					UIListLayout = createElement("UIListLayout", {
						Padding = CONSTANTS.SPACING.PADDING.NONE,
						SortOrder = Enum.SortOrder.LayoutOrder,
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
						FillDirection = Enum.FillDirection.Horizontal
					}),
					UIPadding = createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 5),
						PaddingTop = UDim.new(0, 5),
						PaddingBottom = UDim.new(0, 5)
					}),
					Title = createElement("TextLabel", {
						LayoutOrder = 1,
						AutomaticSize = Enum.AutomaticSize.X,
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						TextTransparency = 1 - v18,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0, 1),
						FontFace = CONSTANTS.FONT.FACE.DISPLAY,
						TextScaled = true,
						Text = headerOverride,
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center
					}, {
						UIFlexItem = createElement("UIFlexItem", {
							FlexMode = Enum.UIFlexMode.Fill,
							ItemLineAlignment = Enum.ItemLineAlignment.Stretch
						})
					})
				})
			end

			local footer

			if onDiscountClick then
				local v43 = {
					ZIndex = CONSTANTS.LAYER.OVERLAY,
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 1, -4),
					Size = UDim2.new(1, 0, 0.1, 20),
					BackgroundTransparency = 1 - v18,
					BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK
				}
				local v44 = {
					UIStroke = createElement("UIStroke", {
						Transparency = 1 - v18,
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
						Color = color3
					}),
					UIPadding = createElement("UIPadding", {
						PaddingLeft = CONSTANTS.SPACING.PADDING.NONE,
						PaddingRight = CONSTANTS.SPACING.PADDING.NONE,
						PaddingTop = CONSTANTS.SPACING.PADDING.SCALE.XXL,
						PaddingBottom = CONSTANTS.SPACING.PADDING.SCALE.XXL
					}),
					Container = 0
				}
				local v47 = {
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(0.45, 0.95),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
				}
				local v48 = {
					LeftLabel = createElement("TextLabel", {
						LayoutOrder = 1,
						AutomaticSize = Enum.AutomaticSize.None,
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						TextTransparency = CONSTANTS.ALPHA.OPAQUE,
						AnchorPoint = Vector2.new(1, 0.5),
						Position = UDim2.fromScale(-0.05, 0.5),
						Size = UDim2.fromScale(4, 0.45),
						FontFace = CONSTANTS.FONT.FACE.TITLE,
						TextScaled = true,
						Text = "Unlock both now",
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextXAlignment = Enum.TextXAlignment.Right,
						TextYAlignment = Enum.TextYAlignment.Center
					}),
					DiscountButton = 0,
					RightLabel = 0
				}
				local v51 = {
					[React.Tag] = v12,
					ZIndex = CONSTANTS.LAYER.RAISED,
					LayoutOrder = 2,
					HoverImage = "rbxassetid://133373335823481",
					Image = "rbxassetid://102463242586371",
					SliceCenter = Rect.new(215, 37, 338, 37),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
					ElevatedBackgroundColor3 = color2,
					Size = UDim2.fromScale(1, 1),
					FontFace = CONSTANTS.FONT.FACE.DISPLAY,
					NextSelectionUp = v5,
					NextSelectionDown = v9,
					LabelPadding = UDim2.fromScale(0.05, 0.2),
					OnClick = function()
						onDiscountClick()
					end
				}
				local text

				if v4 == nil then
					text = "Loading" .. v17
				else
					text = "" .. FormatUtil.commaInteger(v4) .. " (50% Discount)"
				end

				v51.Text = text
				v48.DiscountButton = createElement(Button, v51)
				v48.RightLabel = createElement("TextLabel", {
					LayoutOrder = 3,
					AutomaticSize = Enum.AutomaticSize.None,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					TextTransparency = CONSTANTS.ALPHA.OPAQUE,
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.fromScale(1.05, 0.5),
					Size = UDim2.fromScale(4, 0.45),
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					TextScaled = true,
					Text = "...or later on in the shop!",
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center
				})
				v44.Container = createElement("Frame", v47, v48)
				footer = createElement("Frame", v43, v44)
			end

			local titleFrame

			if not headerOverride then
				titleFrame = createElement("Frame", {
					ZIndex = CONSTANTS.LAYER.OVERLAY,
					AnchorPoint = Vector2.new(0.5, 0.75),
					Position = UDim2.fromScale(0.5, 0),
					Size = UDim2.fromScale(0.5, 0.15),
					BackgroundTransparency = 1 - v18,
					BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK
				}, {
					UIStroke = createElement("UIStroke", {
						Transparency = 1 - v18,
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
						Color = color3
					}),
					UICorners = createElement("UICorner", {
						CornerRadius = UDim.new(0, 4)
					}),
					UIPadding = createElement("UIPadding", {
						PaddingLeft = CONSTANTS.SPACING.PADDING.SCALE.LG,
						PaddingRight = CONSTANTS.SPACING.PADDING.SCALE.LG,
						PaddingTop = CONSTANTS.SPACING.PADDING.SCALE.XL,
						PaddingBottom = CONSTANTS.SPACING.PADDING.SCALE.LG
					}),
					Title = createElement("TextLabel", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						TextTransparency = 1 - v18,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(1, 1),
						FontFace = CONSTANTS.FONT.FACE.DISPLAY,
						TextScaled = true,
						Text = "SELECT YOUR DRAGON",
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center
					})
				})
			end

			local exitButton

			if not headerOverride then
				exitButton = createElement(ExitButton, {
					[React.Tag] = v10,
					ZIndex = CONSTANTS.LAYER.OVERLAY,
					Position = UDim2.fromScale(1, 0),
					Size = UDim2.fromOffset(26, 26),
					AnchorPoint = Vector2.new(0.6, 0.4),
					OnClick = function()
						onSelectionClick(nil)
					end
				})
			end

			local children = {
				Header = header,
				Footer = footer,
				TitleFrame = titleFrame,
				ExitButton = exitButton,
				UIStroke = createElement("UIStroke", {
					Transparency = 1 - v18,
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
					Color = color3
				}),
				UICorners = createElement("UICorner", {
					CornerRadius = UDim.new(0, 4)
				}),
				Lightning = createElement("Frame", {
					ZIndex = CONSTANTS.LAYER.CONTENT,
					Size = UDim2.fromScale(1, 1),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.OPAQUE,
					BackgroundColor3 = CONSTANTS.COLOR.PALETTE.WHITE
				}, {
					UIGradient = createElement("UIGradient", {
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0.9),
							NumberSequenceKeypoint.new(0.475, 0.7),
							NumberSequenceKeypoint.new(0.525, 0.6),
							NumberSequenceKeypoint.new(0.575, 0.7),
							NumberSequenceKeypoint.new(1, 0.9)
						}),
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, color5:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, v24)),
							ColorSequenceKeypoint.new(0.5, color3),
							ColorSequenceKeypoint.new(1, color4:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, v25))
						}),
						Rotation = 5
					}),
					Lightning1 = createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Size = UDim2.fromScale(0.7, 1),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						Rotation = 180,
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Image = "rbxassetid://7216850022",
						ImageTransparency = 1 - v18,
						ImageColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT
					}),
					Lightning2 = createElement("ImageLabel", {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.55, 0.51),
						Size = UDim2.fromScale(0.7, 1.04),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						Rotation = 15,
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						Image = "rbxassetid://7216850022",
						ImageTransparency = 1 - v18,
						ImageColor3 = CONSTANTS.COLOR.PRIMARY.HIGHLIGHT
					})
				}),
				WestIcon = createElement("Frame", {
					ZIndex = CONSTANTS.LAYER.RAISED,
					Size = uDim,
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					BackgroundTransparency = v24,
					BackgroundColor3 = color,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(v21, v23)
				}, {
					Icon = createElement("ImageLabel", {
						ZIndex = 10,
						Size = UDim2.fromScale(1, 1),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						ImageTransparency = v24,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Image = typeof(v.Image) ~= "string" and "" or v.Image,
						ImageRectOffset = v.ImageRectOffset,
						ImageRectSize = v.ImageRectSize
					}),
					UICorners = createElement("UICorner", {
						CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
					}),
					UIStroke = createElement("UIStroke", {
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
						Color = color5,
						Transparency = v24
					}),
					Ring = createElement("ImageLabel", {
						ZIndex = CONSTANTS.LAYER.CONTENT,
						Position = UDim2.fromScale(0.5, 0.5),
						AnchorPoint = Vector2.new(0.5, 0.5),
						SizeConstraint = Enum.SizeConstraint.RelativeYY,
						ImageTransparency = isWestEnabled and 0 or 1,
						ImageColor3 = color5,
						Size = UDim2.fromScale(2, 2),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						Image = "rbxassetid://535697787",
						Rotation = (180 + v19 * 360) % 360
					})
				}),
				WestLabel = createElement(DoubleText, {
					ZIndex = CONSTANTS.LAYER.RAISED_HIGH,
					Text = "Western",
					FontFace = rbxassetfontsfamiliesPermanentMarkerjson,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, v24),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					Size = UDim2.fromScale(0.7, 0.15),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(v21, 0.75)
				}),
				WestButton = 0,
				EastIcon = 0,
				EastLabel = 0,
				EastButton = 0,
				BodyText = 0
			}
			local v45 = {
				[React.Tag] = v6,
				ZIndex = CONSTANTS.LAYER.RAISED,
				IsDisabled = not isWestEnabled,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(v21, 0.9),
				BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
				ElevatedBackgroundColor3 = color2,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.fromScale(0.3, 0.1),
				NextSelectionUp = v9
			}
			local nextSelectionDown2

			if onDiscountClick then
				nextSelectionDown2 = nextSelectionDown
			else
				nextSelectionDown2 = v9
			end

			v45.NextSelectionDown = nextSelectionDown2
			v45.NextSelectionRight = v7
			v45.NextSelectionLeft = v7

			function v45.OnClick()
				onSelectionClick("West")
			end

			v45.Text = equipButtonText
			children.WestButton = createElement(Button, v45)
			children.EastIcon = createElement("Frame", {
				ZIndex = CONSTANTS.LAYER.RAISED,
				Size = uDim,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				BackgroundTransparency = v25,
				BackgroundColor3 = color,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(v22, v23)
			}, {
				Icon = createElement("ImageLabel", {
					ZIndex = 10,
					Size = UDim2.fromScale(1, 1),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.fromScale(0.5, 0.5),
					ImageTransparency = v25,
					Image = typeof(v2.Image) ~= "string" and "" or v2.Image,
					ImageRectOffset = v2.ImageRectOffset,
					ImageRectSize = v2.ImageRectSize
				}),
				UICorners = createElement("UICorner", {
					CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.CIRCLE
				}),
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
					Color = color4,
					Transparency = v25
				}),
				Ring = createElement("ImageLabel", {
					ZIndex = CONSTANTS.LAYER.CONTENT,
					Position = UDim2.fromScale(0.5, 0.5),
					AnchorPoint = Vector2.new(0.5, 0.5),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					ImageTransparency = isEastEnabled and 0 or 1,
					ImageColor3 = color4,
					Size = UDim2.fromScale(2, 2),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://535697787",
					Rotation = v19 * 360
				})
			})
			children.EastLabel = createElement(DoubleText, {
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH,
				Text = "Eastern",
				FontFace = rbxassetfontsfamiliesPermanentMarkerjson,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE:Lerp(CONSTANTS.COLOR.PALETTE.BLACK, v25),
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.fromScale(0.7, 0.15),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(v22, 0.75)
			})
			local v49 = {
				[React.Tag] = v8,
				ZIndex = CONSTANTS.LAYER.RAISED,
				IsDisabled = not isEastEnabled,
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(v22, 0.9),
				BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
				ElevatedBackgroundColor3 = color2,
				SizeConstraint = Enum.SizeConstraint.RelativeYY,
				Size = UDim2.fromScale(0.3, 0.1),
				NextSelectionUp = v9
			}

			if not onDiscountClick then
				nextSelectionDown = v9
			end

			v49.NextSelectionDown = nextSelectionDown
			v49.NextSelectionRight = v5
			v49.NextSelectionLeft = v5

			function v49.OnClick()
				onSelectionClick("East")
			end

			v49.Text = equipButtonText
			children.EastButton = createElement(Button, v49)
			local bodyText2

			if bodyText then
				bodyText2 = createElement("TextLabel", {
					ZIndex = CONSTANTS.LAYER.RAISED_HIGH,
					LayoutOrder = 1,
					RichText = true,
					AutomaticSize = Enum.AutomaticSize.None,
					BackgroundTransparency = CONSTANTS.ALPHA.HALF,
					BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					TextTransparency = 1 - v18,
					AnchorPoint = Vector2.new(0.5, 0),
					Position = UDim2.new(0.5, 0, 0, 15),
					Size = UDim2.new(1, -20, 0.2, 0),
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					TextScaled = true,
					Text = bodyText,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center
				}, {
					UICorners = createElement("UICorner", {
						CornerRadius = UDim.new(0.5 * (1 - v18), 4 * v18)
					}),
					UIStroke = createElement("UIStroke", {
						Transparency = CONSTANTS.ALPHA.OPAQUE,
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
						Color = CONSTANTS.COLOR.PALETTE.BLACK
					}),
					UIPadding = createElement("UIPadding", {
						PaddingLeft = UDim.new(0, 10),
						PaddingRight = UDim.new(0, 10),
						PaddingTop = UDim.new(0, 5),
						PaddingBottom = UDim.new(0, 5)
					})
				})
			end

			children.BodyText = bodyText2
			background = createElement("ImageLabel", v38, children)
		end

		v34.Background = background
		container = createElement("Frame", v33, v34)
	end

	v29.Container = container
	return createElement("ScreenGui", v28, v29)
end