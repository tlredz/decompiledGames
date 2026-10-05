local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")
local React = require(game.ReplicatedStorage.Packages.React)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local Textures = require(game.ReplicatedStorage.Textures)
local Spring = require(game.ReplicatedStorage.Packages.Spring)
local Util = require(game.ReplicatedStorage.React.Components.Map.Util)
require(game.ReplicatedStorage.React.Components.Map.Types)
local Marker = require(game.ReplicatedStorage.React.Components.Map.Marker)
local Button = require(game.ReplicatedStorage.React.Components.Map.Button)
require(game.ReplicatedStorage.React.Components.Map.Line)
local IslandContainer = require(game.ReplicatedStorage.React.Components.Map.IslandContainer)
local Cursor = require(game.ReplicatedStorage.React.Components.Map.Cursor)
local IslandVictorySequence = require(game.ReplicatedStorage.React.Components.IslandVictorySequence)
local DrawContextProvider = require(game.ReplicatedStorage.React.Components.DrawContextProvider)
local CompassRose = require(script.CompassRose)
local useCurrentSea = require(game.ReplicatedStorage.React.Hooks.useCurrentSea)
require(game.ReplicatedStorage.React.Hooks.useCameraCFrame)
local useTagInstanceRef = require(game.ReplicatedStorage.React.Hooks.UID.useTagInstanceRef)
local useFirstTagged = require(game.ReplicatedStorage.React.Hooks.Instance.useFirstTagged)
local useAbsoluteArea = require(game.ReplicatedStorage.React.Hooks.useAbsoluteArea)
local useAll = require(game.ReplicatedStorage.React.Hooks.Island.useAll)
local useMapPositions = require(game.ReplicatedStorage.React.Hooks.Map.useMapPositions)
local useRedirectedPositions = require(game.ReplicatedStorage.React.Hooks.Map.useRedirectedPositions)
local useMapDefinition = require(game.ReplicatedStorage.React.Hooks.Map.useMapDefinition)
local useStrictLerp = require(game.ReplicatedStorage.React.Hooks.Animation.useStrictLerp)
local useSpringEffect = require(game.ReplicatedStorage.React.Hooks.Animation.useSpringEffect)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local CONSTANTS2 = require(game.ReplicatedStorage.React.Components.Map.CONSTANTS)
local createElement = React.createElement

function compassAnimation(state)
	state.NavigationStartPosition = React.useRef(state.NavigationStartPosition).current
	local v = useStrictLerp(0, 1, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut)
	local v2 = useStrictLerp(0, 1, 0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local image = useFirstTagged(CONSTANTS2.COMPASS_BILLBOARD_IMAGE.TAG)
	local v3 = useAbsoluteArea(image)
	React.useEffect(function()
		if image and image:IsA("ImageLabel") and v < 1 then
			pcall(function()
				image.ImageTransparency = 1
			end)
			return function()
				pcall(function()
					image.ImageTransparency = 0
				end)
			end
		else
			return function() end
		end
	end, { image, v < 1 })

	if not image or image.ClassName ~= "ImageLabel" then
		return
	end

	if not (v3 and v3.Min + Vector2.new(v3.Width, v3.Height) / 2 and v3) then
		return
	end

	local uDim = UDim2.fromOffset(
		v3.Min.X + v3.Width / 2,
		v3.Min.Y + v3.Height / 2 + GuiService:GetInsetArea(Enum.ScreenInsets.TopbarSafeInsets).Height
	)
	local uDim2 = UDim2.fromOffset(state.NavigationStartPosition.X, state.NavigationStartPosition.Y)

	if v < 1 then
		return (createElement("ScreenGui", {
			DisplayOrder = 51,
			ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			ScreenInsets = Enum.ScreenInsets.None,
			SafeAreaCompatibility = Enum.SafeAreaCompatibility.None,
			IgnoreGuiInset = true,
			Enabled = true,
			ResetOnSpawn = false
		}, {
			FakeTracker = createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Size = UDim2.fromOffset(state.NavigationStartSize.X, state.NavigationStartSize.Y):Lerp(
					UDim2.fromOffset(v3.Width, v3.Height),
					v2
				),
				Position = uDim2:Lerp(uDim, v),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Image = state.Island.Display.Icon.Image,
				ImageRectOffset = state.Island.Display.Icon.ImageRectOffset,
				ImageRectSize = state.Island.Display.Icon.ImageRectSize,
				ZIndex = CONSTANTS.LAYER.RAISED
			}),
			TargetStart = not RunService:IsRunning() and createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Size = UDim2.fromOffset(v3.Width, v3.Height),
				Position = uDim2,
				AnchorPoint = Vector2.new(0.5, 0.5),
				ImageColor3 = Color3.new(0, 0, 1),
				Image = state.Island.Display.Icon.Image,
				ImageRectOffset = state.Island.Display.Icon.ImageRectOffset,
				ImageRectSize = state.Island.Display.Icon.ImageRectSize
			}),
			TargetTracker = not RunService:IsRunning() and createElement("ImageLabel", {
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Size = UDim2.fromOffset(v3.Width, v3.Height),
				Position = uDim,
				AnchorPoint = Vector2.new(0.5, 0.5),
				ImageColor3 = Color3.new(1, 0, 0),
				Image = state.Island.Display.Icon.Image,
				ImageRectOffset = state.Island.Display.Icon.ImageRectOffset,
				ImageRectSize = state.Island.Display.Icon.ImageRectSize
			})
		}))
	else
		return false
	end
end

return function(props)
	local v, v2 = useTagInstanceRef("NavigatedIsland", true)
	local current = v.current
	local state, setState = React.useState(nil)
	React.useEffect(function()
		if not v.current then
			return function()
				if state then
					setState(nil)
				end
			end
		end

		setState(tick())
		local flag = true
		task.delay(1, function()
			if flag then
				setState(nil)
			end
		end)
		return function()
			flag = false

			if state then
				setState(nil)
			end
		end
	end, { v.current })
	local v3, v4 = useTagInstanceRef("MapCanvas", true)
	local v5, v6 = useTagInstanceRef("Map", true)
	local v7 = useAbsoluteArea(v3.current)
	local vector = v7 and Vector2.new(v7.Width, v7.Height) or Vector2.one
	local v9 = useMapDefinition((useCurrentSea()))
	local v10 = not v9 and 0 or v9.WORLD_BUFFER or 0
	local islands = useAll()
	local mapBounds = React.useMemo(function()
		local v13 = 0
		local v14 = 0
		local v15 = 0
		local v16 = 0

		for _, v17 in islands do
			local halfDiameter = v17.World.Diameter / 2
			local position = v17.World.Position
			v13 = math.min(v13, position.X - halfDiameter)
			v14 = math.max(v14, position.X + halfDiameter)
			v15 = math.min(v15, position.Z - halfDiameter)
			v16 = math.max(v16, position.Z + halfDiameter)
		end

		return Rect.new(v13 - v10, v15 - v10, v14 + v10, v16 + v10)
	end, { islands, v10 })
	useMapPositions(v9, mapBounds)
	local v13 = useRedirectedPositions(v9, mapBounds, vector)
	local children = {}

	for _, marker in props.Markers do
		children[`Marker-{marker.Key}`] = createElement(Marker, {
			Marker = marker,
			MapBounds = mapBounds,
			AbsoluteCanvasSize = vector
		})
	end

	for _, island in islands do
		local v15 = (v9 and not CONSTANTS2.USE_REAL_SCALE and island.Display.Diameter or island.World.Diameter) / mapBounds.Height * vector.Y
		local isSelected

		if props.SelectedIsland then
			isSelected = props.SelectedIsland.Index.Key == island.Index.Key
		else
			isSelected = false
		end

		local isRecommended

		if props.Recommendation then
			isRecommended = props.Recommendation.Index.Key == island.Index.Key
		else
			isRecommended = false
		end

		local position = island.World.Position

		if v13 and v13[island.Index.Key] then
			position = v13[island.Index.Key]
		end

		local formatted = `Island-{island.Index.Key}`
		local tag = React.Tag
		local v21

		if props.NavigationTarget and props.NavigationTarget.Index.Key == island.Index.Key then
			v21 = v2
		end

		local v20 = {
			[tag] = v21,
			Visible = not props.NavigationTarget or props.NavigationTarget ~= island or not (state and tick() - state < 1),
			Position = Util.getGuiPosition(position.X, position.Z, mapBounds, vector, true),
			Size = UDim2.fromOffset(v15, v15),
			AnchorPoint = Vector2.new(0.5, 0.5),
			IsSelected = isSelected,
			IsRecommended = isRecommended,
			Island = island,
			ZIndex = CONSTANTS.LAYER.OVERLAY
		}
		local island2 = island
		v20.OnClick = props.NavigationTarget == nil and not table.find(island.Tags, "NavigationBlocked") and (function()
			if isSelected then
				props.OnAction({
					Type = "Select"
				})
			else
				props.OnAction({
					Type = "Select",
					Island = island2
				})
			end
		end or nil) or nil
		children[formatted] = createElement(IslandContainer, v20)
	end

	local state2, setState2 = React.useState(props.IsOpen and "Default" or "Offscreen")
	local isOpen = props.IsOpen
	local ref = React.useRef(isOpen)
	ref.current = isOpen
	useSpringEffect(isOpen and 1 or 0, Spring.new(0.85, 2, isOpen and 1 or 0), true, function(p: number, _: number)
		local current2 = v5.current

		if current2 then
			current2.Visible = p > 0
			current2.Position = UDim2.fromScale(0.5, 1):Lerp(UDim2.fromScale(0.5, 0.5), p)
			current2.AnchorPoint = Vector2.new(0.5, p * 0.5)
		end
	end, function()
		setState2("Moving")
	end, function()
		if ref.current then
			setState2("Default")
		else
			setState2("Offscreen")
		end
	end)
	local fragment = React.Fragment
	local navigationTarget = current and props.NavigationTarget

	if navigationTarget then
		if state then
			if tick() - state < 1 then
				navigationTarget = createElement(compassAnimation, {
					NavigationStartPosition = current.AbsolutePosition + Vector2.new(
						current.AbsoluteSize.X,
						current.AbsoluteSize.Y * 0.75
					),
					NavigationStartSize = current.AbsoluteSize,
					Island = props.NavigationTarget
				})
			else
				navigationTarget = false
			end
		else
			navigationTarget = state
		end
	end

	local createElement2 = React.createElement
	local v23 = RobloxTypes.mergeFrame({
		Visible = props.IsOpen,
		BackgroundColor3 = CONSTANTS.COLOR.PANEL.BACKGROUND,
		BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
		[React.Tag] = v6
	}, props)
	local children2 = {
		Exit = createElement("TextButton", {
			AnchorPoint = Vector2.new(0.575, 0.425),
			BackgroundColor3 = CONSTANTS.COLOR.DANGER.BACKGROUND,
			BorderColor3 = CONSTANTS.COLOR.DANGER.BORDER,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.REGULAR,
			FontFace = Font.new(CONSTANTS.FONT.FAMILY.SOURCE_SANS_PRO),
			LayoutOrder = -999,
			Position = UDim2.fromScale(1, 0),
			Size = UDim2.fromScale(0.08, 0.08),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			Text = "",
			TextColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
			TextScaled = true,
			TextStrokeColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
			ZIndex = CONSTANTS.LAYER.RAISED,
			[React.Event.Activated] = function()
				props.OnAction({
					Type = "Exit"
				})
			end
		}, {
			Trans = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 1),
				BackgroundColor3 = CONSTANTS.COLOR.DANGER.HIGHLIGHT,
				BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.94, 0.47),
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			}),
			Icon = createElement("ImageLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				Image = "rbxassetid://127503254560275",
				ImageRectSize = Vector2.new(100, 100),
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				ZIndex = 4
			}),
			UIAspectRatio = createElement("UIAspectRatioConstraint", {
				AspectRatio = 1
			})
		}),
		UIAspectRatio = createElement("UIAspectRatioConstraint", {
			AspectRatio = 1.881
		}),
		UICorner = createElement("UICorner", {
			CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.XXS
		}),
		CanvasContainer = 0
	}
	local v28 = {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1)
	}
	local v29 = {
		VictorySequence = props.VictoryIsland and createElement(IslandVictorySequence, {
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0, 0),
			IsPlaying = props.IsOpen,
			Island = props.VictoryIsland,
			ZIndex = CONSTANTS.LAYER.MODAL,
			ClipsDescendants = true
		}),
		CanvasBorder = 0
	}
	local v32 = {
		Size = UDim2.fromScale(1, 1),
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		AnchorPoint = Vector2.new(0.5, 1),
		Image = Textures.background.map["ocean.png"],
		ScaleType = Enum.ScaleType.Fit,
		Position = UDim2.fromScale(0.5, 1)
	}
	local v33 = {
		UIStroke = createElement("UIStroke", {
			Color = Color3.fromRGB(89, 63, 10),
			Thickness = 0.004,
			StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
		}),
		UIPadding = createElement("UIPadding", {
			PaddingBottom = UDim.new(0, 10),
			PaddingTop = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10)
		}),
		Canvas = 0
	}
	local v36 = {
		Size = UDim2.fromScale(1, 1),
		BorderColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
		BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		ClipsDescendants = true,
		[React.Tag] = v4
	}
	local children3 = {
		CompassRose = createElement(CompassRose, {
			Size = UDim2.fromScale(0.125, 0.125),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(0.975, 0, 0.05, 0),
			SizeConstraint = Enum.SizeConstraint.RelativeYY,
			ZIndex = CONSTANTS.LAYER.RAISED
		}),
		Label = 0,
		NavigatingTo = 0,
		User = 0,
		Clouds = 0,
		Islands = 0
	}
	local label

	if props.Title ~= nil then
		label = createElement("Frame", {
			Position = UDim2.fromOffset(15, 15),
			AnchorPoint = Vector2.new(0, 0),
			BackgroundTransparency = CONSTANTS.ALPHA.OPAQUE,
			BorderColor3 = Color3.fromHex("#BD9D63"),
			BackgroundColor3 = Color3.fromHex("#E9CDA4"),
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.HAIRLINE,
			Size = UDim2.fromScale(0.05, 0.065),
			SizeConstraint = Enum.SizeConstraint.RelativeXY,
			ZIndex = 20
		}, {
			UIAspectRatio = createElement("UIAspectRatioConstraint", {
				AspectRatio = 3.5,
				DominantAxis = Enum.DominantAxis.Height,
				AspectType = Enum.AspectType.ScaleWithParentSize
			}),
			UIPadding = createElement("UIPadding", {
				PaddingBottom = CONSTANTS.SPACING.PADDING.SCALE.XL,
				PaddingTop = CONSTANTS.SPACING.PADDING.SCALE.XL,
				PaddingLeft = CONSTANTS.SPACING.PADDING.OFFSET.XS,
				PaddingRight = CONSTANTS.SPACING.PADDING.OFFSET.XS
			}),
			TextLabel = createElement("TextLabel", {
				Text = props.Title,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Center,
				Position = UDim2.fromScale(0.5, 0.5),
				AnchorPoint = Vector2.new(0.5, 0.5),
				FontFace = Font.new(
					CONSTANTS.FONT.FAMILY.HIGHWAY_GOTHIC,
					Enum.FontWeight.SemiBold,
					Enum.FontStyle.Normal
				),
				TextScaled = true,
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				TextColor3 = Color3.fromHex("#47351A"),
				Size = UDim2.fromScale(1, 1),
				ZIndex = 20
			})
		})
	end

	children3.Label = label
	local navigatingTo

	if props.NavigationTarget or props.SelectedIsland then
		local v41 = {
			Position = UDim2.new(1, 0, 1, 0),
			AnchorPoint = Vector2.new(1, 1),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			Size = UDim2.fromScale(0.05, 0.2),
			ZIndex = 60
		}
		local v42 = {
			UIAspectRatio = createElement("UIAspectRatioConstraint", {
				AspectRatio = 3.5,
				DominantAxis = Enum.DominantAxis.Height,
				AspectType = Enum.AspectType.ScaleWithParentSize
			}),
			Label = props.NavigationTarget and createElement("Frame", {
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				Size = UDim2.new(0.8, 0, 0.6, -9),
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0)
			}, {
				UIGradient = createElement("UIGradient", {
					Transparency = NumberSequence.new({
						NumberSequenceKeypoint.new(0, 1),
						NumberSequenceKeypoint.new(0.2, 0.2),
						NumberSequenceKeypoint.new(1, 0.2)
					})
				}),
				UIPadding = createElement("UIPadding", {
					PaddingBottom = CONSTANTS.SPACING.PADDING.SCALE.XL,
					PaddingTop = CONSTANTS.SPACING.PADDING.SCALE.XL,
					PaddingLeft = CONSTANTS.SPACING.PADDING.NONE,
					PaddingRight = UDim.new(0.025, 0)
				}),
				NavigatingTo = createElement("TextLabel", {
					Text = "Navigating to:",
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					LineHeight = 0,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextTransparency = CONSTANTS.ALPHA.LIGHT,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					TextScaled = true,
					Size = UDim2.fromScale(1, 0.35),
					Position = UDim2.fromScale(0, 0),
					TextXAlignment = Enum.TextXAlignment.Right
				}),
				Title = createElement("TextLabel", {
					Text = props.NavigationTarget.Display.Name or props.NavigationTarget.Index.Key,
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					LineHeight = 0,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					TextTransparency = CONSTANTS.ALPHA.OPAQUE,
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					TextScaled = true,
					Size = UDim2.fromScale(1, 0.65),
					Position = UDim2.fromScale(0, 1),
					AnchorPoint = Vector2.new(0, 1),
					TextXAlignment = Enum.TextXAlignment.Right
				}, {
					UIStroke = createElement("UIStroke", {
						Color = CONSTANTS.COLOR.PALETTE.BLACK,
						Thickness = CONSTANTS.THICKNESS.OUTLINE.REGULAR
					})
				})
			}),
			CancelButton = 0,
			NavigateButton = 0
		}
		local cancelButton

		if props.NavigationTarget == nil then
			cancelButton = false
		else
			cancelButton = createElement(Button, {
				Variant = "Red",
				Text = "Cancel",
				FontFace = CONSTANTS.FONT.FACE.TITLE,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -6, 1, -8),
				Size = UDim2.new(0.25, 0, 0.4, -8),
				[React.Event.Activated] = function()
					props.OnAction({
						Type = "ClearNavigation"
					})
				end
			})
		end

		v42.CancelButton = cancelButton
		local selectedIsland

		if props.NavigationTarget == nil then
			selectedIsland = props.SelectedIsland

			if selectedIsland then
				selectedIsland = createElement(Button, {
					Variant = "Yellow",
					Text = "Navigate",
					FontFace = CONSTANTS.FONT.FACE.TITLE,
					TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
					AnchorPoint = Vector2.new(1, 1),
					Position = UDim2.new(1, -6, 1, -8),
					Size = UDim2.new(0.25, 0, 0.4, -8),
					[React.Event.Activated] = function()
						props.OnAction({
							Type = "NavigateTo",
							Target = props.SelectedIsland
						})
					end
				})
			end
		else
			selectedIsland = false
		end

		v42.NavigateButton = selectedIsland
		navigatingTo = createElement("Frame", v41, v42)
	end

	children3.NavigatingTo = navigatingTo
	children3.User = props.UserId ~= nil and createElement(Cursor, {
		MapBounds = mapBounds,
		UserId = props.UserId,
		AbsoluteCanvasSize = vector,
		Islands = islands,
		Color = Color3.fromHex("#FFE635")
	})
	children3.Clouds = createElement(React.Fragment, {}, {
		LeftCenterCloud = createElement("ImageLabel", {
			Image = Textures.misc["cloud-2.png"],
			Size = UDim2.fromScale(0.6400000000000001, 0.2),
			Position = UDim2.fromScale(0, 0.425),
			AnchorPoint = Vector2.new(0.55, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			SizeConstraint = Enum.SizeConstraint.RelativeYY
		}),
		BottomCenterCloud = createElement("ImageLabel", {
			Image = Textures.misc["cloud-4.png"],
			Size = UDim2.fromScale(0.68, 0.255),
			Position = UDim2.fromScale(0.5, 1),
			AnchorPoint = Vector2.new(0.5, 0.8),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			SizeConstraint = Enum.SizeConstraint.RelativeYY
		}),
		BottomLeftCloud = createElement("ImageLabel", {
			Image = Textures.misc["cloud-2.png"],
			Size = UDim2.fromScale(0.6, 0.2),
			Position = UDim2.fromScale(0, 1),
			AnchorPoint = Vector2.new(0.7, 0.7),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			SizeConstraint = Enum.SizeConstraint.RelativeYY
		}),
		BottomRightCloud = createElement("ImageLabel", {
			Image = Textures.misc["cloud-2.png"],
			Size = UDim2.fromScale(0.6, 0.2),
			Position = UDim2.fromScale(1, 1),
			AnchorPoint = Vector2.new(0.8, 0.8),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			SizeConstraint = Enum.SizeConstraint.RelativeYY
		}),
		LowerRightCloud = createElement("ImageLabel", {
			Image = Textures.misc["cloud-1.png"],
			Size = UDim2.fromScale(0.3, 0.15),
			Position = UDim2.fromScale(1, 0.6),
			AnchorPoint = Vector2.new(0.8, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			SizeConstraint = Enum.SizeConstraint.RelativeYY
		}),
		MidRightCloud = createElement("ImageLabel", {
			Image = Textures.misc["cloud-4.png"],
			Size = UDim2.fromScale(0.4, 0.15),
			Position = UDim2.fromScale(1, 0.3),
			AnchorPoint = Vector2.new(0.7, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			SizeConstraint = Enum.SizeConstraint.RelativeYY
		}),
		TopCenterCloud = createElement("ImageLabel", {
			Image = Textures.misc["cloud-2.png"],
			Size = UDim2.fromScale(0.35, 0.25),
			Position = UDim2.fromScale(0.475, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			SizeConstraint = Enum.SizeConstraint.RelativeYY
		})
	})
	children3.Islands = createElement(React.Fragment, {}, children)
	v33.Canvas = createElement("Frame", v36, children3)
	v29.CanvasBorder = createElement("ImageLabel", v32, v33)
	children2.CanvasContainer = createElement("Frame", v28, v29)
	return createElement(fragment, {}, {
		NavigationAnimation = navigationTarget,
		Map = createElement2(DrawContextProvider, {
			Context = state2
		}, {
			Map = createElement("Frame", v23, children2)
		})
	})
end