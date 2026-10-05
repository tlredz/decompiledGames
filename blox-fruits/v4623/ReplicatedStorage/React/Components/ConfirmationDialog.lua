local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.RobloxTypes)
local Button = require(game.ReplicatedStorage.React.Components.Button)
local useViewportSize = require(game.ReplicatedStorage.React.Hooks.useViewportSize)
local useSpring = require(game.ReplicatedStorage.React.Hooks.Animation.useSpring)
local useGuiServiceSelect = require(game.ReplicatedStorage.React.Hooks.useGuiServiceSelect)
local use = require(game.ReplicatedStorage.React.Hooks.UID.use)
local useFirstTagged = require(game.ReplicatedStorage.React.Hooks.Instance.useFirstTagged)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local color = Color3.fromRGB(43, 43, 43)
local color2 = Color3.fromRGB(199, 199, 199)
local color3 = Color3.fromRGB(255, 240, 69)
local color4 = Color3.fromRGB(255, 197, 20)
local color5 = Color3.fromRGB(105, 255, 118)
local createElement = React.createElement

local function getLayout(point: Vector2)
	local buttonHeight = math.max(20, (math.round(point.Y * 0.075)))
	local buttonWidth = math.round(buttonHeight * 4)
	local titleHeight = math.ceil(buttonHeight * 1.6 * 0.8)
	local topSpacer = math.ceil(buttonHeight * 0.5 * 1.2)
	local bottomSpacer = math.ceil(buttonHeight * 0.5)
	local buttonRow = math.round(buttonHeight * 2)
	local v7 = titleHeight + topSpacer + bottomSpacer + buttonRow
	return {
		buttonHeight = buttonHeight,
		buttonWidth = buttonWidth,
		pad = UDim.new(0, (math.ceil(buttonHeight * 0.25))),
		titleHeight = titleHeight,
		topSpacer = topSpacer,
		bottomSpacer = bottomSpacer,
		buttonRow = buttonRow,
		bodyWidth = math.min(buttonWidth * 3, (math.floor(point.X * 0.9))),
		bodyMaxHeight = math.max(buttonHeight, math.floor(point.Y * 0.9) - v7),
		scrollBar = math.max(4, (math.round(buttonHeight * 0.12)))
	}
end

return function(props)
	local onResponse = props.OnResponse
	local onCloseComplete = props.OnCloseComplete
	local title = props.Title
	local body = props.Body
	local confirmText = props.ConfirmText
	local cancelText = props.CancelText
	local state, setState = React.useState(true)
	local state2, setState2 = React.useState(false)
	local state3, setState3 = React.useState(0)
	local v = use("LegacyConfirmationDialogCancel")
	local v2 = use("LegacyConfirmationDialogConfirm")
	local v3 = useFirstTagged(v)
	local v4 = useFirstTagged(v2)
	local v5 = use("ConfirmationDialog")
	useGuiServiceSelect(v5, state)
	local v6 = useViewportSize()
	local v7 = useSpring(0, state and 1 or 0, 5, 10)

	if v7 > 0 and not state then
		if not state2 then
			setState2(true)
		end
	elseif v7 <= 0 and state2 then
		setState2(false)
		onCloseComplete()
	end

	local layout = getLayout(v6)
	local v10 = {
		IgnoreGuiInset = true,
		ClipToDeviceSafeArea = false,
		DisplayOrder = 20,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	}
	local v11 = {
		Scrim = createElement("Frame", {
			Size = UDim2.fromScale(1, 1),
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = 1 - v7 * 0.5,
			ZIndex = CONSTANTS.LAYER.CONTENT
		}),
		Container = 0
	}
	local container

	if not (v7 <= 0) then
		local v15 = {
			[React.Tag] = v5,
			ZIndex = CONSTANTS.LAYER.RAISED,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromOffset(0, 0),
			Position = UDim2.fromScale(0.5, -0.1 + 0.6 * v7),
			AnchorPoint = Vector2.new(0.5, 1 - 0.5 * v7),
			AutomaticSize = Enum.AutomaticSize.XY,
			Selectable = true,
			SelectionGroup = true,
			SelectionBehaviorDown = Enum.SelectionBehavior.Stop,
			SelectionBehaviorLeft = Enum.SelectionBehavior.Stop,
			SelectionBehaviorRight = Enum.SelectionBehavior.Stop,
			SelectionBehaviorUp = Enum.SelectionBehavior.Stop
		}
		local v16 = {
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Vertical,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder
			}),
			TitleContainer = createElement("Frame", {
				LayoutOrder = 1,
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BackgroundTransparency = 1 - v7,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				AutomaticSize = Enum.AutomaticSize.X,
				Size = UDim2.fromOffset(0, layout.titleHeight)
			}, {
				UIFlex = createElement("UIFlexItem", {
					FlexMode = Enum.UIFlexMode.Fill,
					ItemLineAlignment = Enum.ItemLineAlignment.Stretch
				}),
				UIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = layout.pad
				}),
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
					Color = color4,
					Transparency = 1 - v7,
					LineJoinMode = Enum.LineJoinMode.Miter
				}),
				Title = createElement("TextLabel", {
					LayoutOrder = 1,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					AutomaticSize = Enum.AutomaticSize.X,
					RichText = true,
					Size = UDim2.fromScale(0, 1),
					Text = title,
					TextScaled = true,
					TextXAlignment = Enum.TextXAlignment.Center,
					TextYAlignment = Enum.TextYAlignment.Center,
					FontFace = CONSTANTS.FONT.FACE.BODY_BOLD
				})
			}),
			BodyContainer = createElement("Frame", {
				LayoutOrder = 2,
				BackgroundColor3 = color,
				BackgroundTransparency = 1 - v7,
				Size = UDim2.fromOffset(0, 0),
				AutomaticSize = Enum.AutomaticSize.XY,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE
			}, {
				UIFlex = createElement("UIFlexItem", {
					FlexMode = Enum.UIFlexMode.Grow,
					ItemLineAlignment = Enum.ItemLineAlignment.Stretch
				}),
				UIListLayout = createElement("UIListLayout", {
					FillDirection = Enum.FillDirection.Vertical,
					HorizontalAlignment = Enum.HorizontalAlignment.Center,
					VerticalAlignment = Enum.VerticalAlignment.Center,
					SortOrder = Enum.SortOrder.LayoutOrder,
					Padding = CONSTANTS.SPACING.PADDING.NONE
				}),
				UIStroke = createElement("UIStroke", {
					Thickness = CONSTANTS.THICKNESS.OUTLINE.HAIRLINE,
					Color = color4,
					Transparency = 1 - v7,
					LineJoinMode = Enum.LineJoinMode.Miter
				}),
				TopSpacer = createElement("Frame", {
					LayoutOrder = 0,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Size = UDim2.fromOffset(0, layout.topSpacer)
				}),
				BodyScroller = createElement("ScrollingFrame", {
					LayoutOrder = 1,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
					Size = UDim2.fromOffset(layout.bodyWidth, (math.min(state3, layout.bodyMaxHeight))),
					AutomaticCanvasSize = Enum.AutomaticSize.Y,
					CanvasSize = UDim2.fromOffset(0, 0),
					ScrollingDirection = Enum.ScrollingDirection.Y,
					ElasticBehavior = Enum.ElasticBehavior.Never,
					ScrollBarThickness = layout.scrollBar,
					ScrollBarImageColor3 = color4,
					ScrollBarImageTransparency = 1 - v7,
					Selectable = false
				}, {
					Body = createElement("TextLabel", {
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						AutomaticSize = Enum.AutomaticSize.Y,
						Size = UDim2.fromOffset(layout.bodyWidth - layout.scrollBar, 0),
						TextSize = math.round(layout.buttonHeight * 0.7),
						Text = body,
						TextColor3 = color2,
						TextTransparency = 1 - v7,
						TextScaled = false,
						TextWrapped = true,
						RichText = true,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center,
						FontFace = CONSTANTS.FONT.FACE.BODY,
						[React.Change.AbsoluteSize] = function(p)
							setState3((math.ceil(p.AbsoluteSize.Y)))
						end
					}, {
						UIPadding = createElement("UIPadding", {
							PaddingTop = CONSTANTS.SPACING.PADDING.NONE,
							PaddingBottom = CONSTANTS.SPACING.PADDING.NONE,
							PaddingLeft = CONSTANTS.SPACING.PADDING.SCALE.LG,
							PaddingRight = CONSTANTS.SPACING.PADDING.SCALE.LG
						})
					})
				}),
				BottomSpacer = createElement("Frame", {
					LayoutOrder = 2,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Size = UDim2.fromOffset(0, layout.bottomSpacer)
				})
			}),
			ButtonContainer = 0
		}
		local v27 = {
			BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			BackgroundTransparency = 1 - v7,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			GroupTransparency = 1 - v7,
			LayoutOrder = 3,
			Size = UDim2.fromOffset(0, layout.buttonRow),
			AutomaticSize = Enum.AutomaticSize.X
		}
		local v28 = {
			UIStroke = createElement("UIStroke", {
				Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
				Color = color4,
				Transparency = 1 - v7,
				LineJoinMode = Enum.LineJoinMode.Miter
			}),
			UIFlex = createElement("UIFlexItem", {
				FlexMode = Enum.UIFlexMode.Fill,
				ItemLineAlignment = Enum.ItemLineAlignment.Stretch
			}),
			UIListLayout = createElement("UIListLayout", {
				FillDirection = Enum.FillDirection.Horizontal,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				SortOrder = Enum.SortOrder.LayoutOrder,
				HorizontalFlex = Enum.UIFlexAlignment.None,
				Padding = UDim.new(0.04, 0)
			}),
			Cancel = 0,
			Confirm = 0
		}
		local cancel

		if props.CancelText then
			cancel = createElement(Button, {
				[React.Tag] = v,
				SwipeTransparency = 1,
				IsDisabled = false,
				BackgroundColor3 = CONSTANTS.COLOR.PRIMARY.BACKGROUND,
				Text = cancelText,
				LayoutOrder = 1,
				AutomaticSize = Enum.AutomaticSize.None,
				NextSelectionLeft = v4,
				NextSelectionRight = v4,
				ElevatedBackgroundColor3 = color3,
				Size = UDim2.fromOffset(layout.buttonWidth, layout.buttonHeight),
				OnClick = function()
					if state then
						setState(false)
						onResponse(false)
					end
				end
			})
		end

		v28.Cancel = cancel
		local v32 = {
			[React.Tag] = v2,
			SwipeTransparency = 0.5,
			IsDisabled = false
		}
		local backgroundColor

		if props.CancelText then
			backgroundColor = CONSTANTS.COLOR.PURCHASE.BACKGROUND
		else
			backgroundColor = CONSTANTS.COLOR.PRIMARY.BACKGROUND
		end

		v32.BackgroundColor3 = backgroundColor
		v32.InitialLockDuration = props.CancelText and 3 or nil
		v32.Text = confirmText
		v32.LayoutOrder = 2
		v32.AutomaticSize = Enum.AutomaticSize.None
		v32.NextSelectionLeft = v3
		v32.NextSelectionRight = v3
		local elevatedBackgroundColor

		if props.CancelText then
			elevatedBackgroundColor = color5
		else
			elevatedBackgroundColor = color3
		end

		v32.ElevatedBackgroundColor3 = elevatedBackgroundColor
		v32.Size = UDim2.fromOffset(layout.buttonWidth, layout.buttonHeight)

		function v32.OnClick()
			if state then
				setState(false)
				onResponse(true)
			end
		end

		v28.Confirm = createElement(Button, v32)
		v16.ButtonContainer = createElement("CanvasGroup", v27, v28)
		container = createElement("Frame", v15, v16)
	end

	v11.Container = container
	return createElement("ScreenGui", v10, v11)
end