local React = require(game.ReplicatedStorage.Packages.React)
require(game.ReplicatedStorage.React.Components.Inventory.Types)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local FormatUtil = require(game.ReplicatedStorage.React.FormatUtil)
local useMatch = require(game.ReplicatedStorage.React.Hooks.Item.Config.useMatch)
local useMoveList = require(game.ReplicatedStorage.React.Hooks.Item.useMoveList)
local useSelection = require(game.ReplicatedStorage.React.Hooks.Item.useSelection)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local createElement = React.createElement
return function(p)
	local v, _, _ = useSelection()
	local v2 = useMatch(v)
	assert(v2, (`bad ItemConfig: {v}`))
	local v3 = useMoveList(v2.Index.ItemId)
	local children = {}

	if v3 then
		for i, v4 in ipairs(v3) do
			children[`Move-{i}`] = createElement("Frame", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				LayoutOrder = v4.Mastery,
				Size = UDim2.fromScale(1, 0.125),
				SizeConstraint = Enum.SizeConstraint.RelativeXX
			}, {
				MarginPadding = createElement("UIPadding", {
					PaddingBottom = UDim.new(0.05, 0),
					PaddingTop = UDim.new(0.05, 0)
				}),
				Inner = createElement("Frame", {
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					LayoutOrder = v4.Mastery,
					Size = UDim2.fromScale(1, 0.125),
					SizeConstraint = Enum.SizeConstraint.RelativeXX
				}, {
					UIPadding = createElement("UIPadding", {
						PaddingBottom = CONSTANTS.SPACING.PADDING.OFFSET.XS,
						PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.SM,
						PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.SM,
						PaddingTop = CONSTANTS.SPACING.PADDING.OFFSET.XS
					}),
					UICorner = createElement("UICorner", {
						CornerRadius = UDim.new(0, 1)
					}),
					Key = createElement("Frame", {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
						BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
						Position = UDim2.fromScale(0, 0.5),
						Size = UDim2.fromScale(1, 1)
					}, {
						Outline = createElement("UIStroke", {
							ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
							Color = CONSTANTS.COLOR.PALETTE.WHITE,
							Thickness = CONSTANTS.THICKNESS.OUTLINE.HAIRLINE
						}),
						UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
							AspectType = Enum.AspectType.ScaleWithParentSize,
							DominantAxis = Enum.DominantAxis.Height
						}),
						UICorner = createElement("UICorner", {
							CornerRadius = UDim.new(0, 2)
						}),
						Label = createElement("TextLabel", {
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							FontFace = CONSTANTS.FONT.FACE.DISPLAY_LIGHT,
							LineHeight = 0,
							Position = UDim2.fromScale(0.5, 0.5),
							Size = UDim2.fromScale(1, 1),
							Text = v4.Binding,
							TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Center
						})
					}),
					Label = createElement("TextLabel", {
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						FontFace = CONSTANTS.FONT.FACE.DISPLAY_LIGHT,
						LineHeight = 0,
						Position = UDim2.fromScale(0.15, 0.5),
						Size = UDim2.fromScale(0.575, 0.7),
						Text = v4.Name,
						TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
						TextScaled = true,
						TextXAlignment = Enum.TextXAlignment.Left
					}),
					MasteryBox = createElement("Frame", {
						AnchorPoint = Vector2.new(1, 0.5),
						BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
						Position = UDim2.fromScale(1, 0.5),
						Size = UDim2.fromScale(1, 1)
					}, {
						MarginPadding = createElement("UIPadding", {
							PaddingBottom = UDim.new(0.05, 0),
							PaddingTop = UDim.new(0.05, 0)
						}),
						UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
							AspectRatio = 2.5,
							AspectType = Enum.AspectType.ScaleWithParentSize,
							DominantAxis = Enum.DominantAxis.Height
						}),
						StarIcon = createElement("ImageLabel", {
							AnchorPoint = Vector2.new(0, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							Image = "rbxassetid://113701888044237",
							Position = UDim2.fromScale(0, 0.5),
							ScaleType = Enum.ScaleType.Fit,
							Size = UDim2.fromScale(0, 1)
						}, {
							UIAspectRatioConstraint = createElement("UIAspectRatioConstraint", {
								AspectRatio = 1,
								AspectType = Enum.AspectType.ScaleWithParentSize,
								DominantAxis = Enum.DominantAxis.Height
							})
						}),
						Label = createElement("TextLabel", {
							AnchorPoint = Vector2.new(1, 0.5),
							BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
							FontFace = CONSTANTS.FONT.FACE.DISPLAY_LIGHT,
							LineHeight = 0,
							Position = UDim2.fromScale(1, 0.5),
							Size = UDim2.fromScale(0.6, 1),
							Text = FormatUtil.commaInteger(v4.Mastery),
							TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
							TextScaled = true,
							TextXAlignment = Enum.TextXAlignment.Left
						})
					})
				})
			})
		end
	end

	local state, setState = React.useState(1)
	return createElement("ScrollingFrame", RobloxTypes.mergeScrollingFrame({
		AutomaticCanvasSize = Enum.AutomaticSize.None,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		CanvasSize = UDim2.fromOffset(0, (math.ceil(state))),
		HorizontalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		ScrollBarThickness = CONSTANTS.THICKNESS.SCROLLBAR.THIN,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		VerticalScrollBarInset = Enum.ScrollBarInset.Always
	}, p), {
		UIListLayout = createElement("UIListLayout", {
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			Padding = CONSTANTS.SPACING.PADDING.OFFSET.SM,
			SortOrder = Enum.SortOrder.LayoutOrder,
			[React.Change.AbsoluteContentSize] = function(p2)
				setState(p2.AbsoluteContentSize.Y)
			end
		}),
		Rows = createElement(React.Fragment, {}, children)
	})
end