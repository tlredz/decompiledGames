local React = require(game.ReplicatedStorage.Packages.React)
local ItemConfig = require(game.ReplicatedStorage.ItemConfig)
local ItemId = require(game.ReplicatedStorage.Economy.ItemId)
require(game.ReplicatedStorage.Modules.Asset.RarityUtil)
local Tile = require(game.ReplicatedStorage.React.Components.Tile)
local RobloxTypes = require(game.ReplicatedStorage.React.RobloxTypes)
local CONSTANTS = require(game.ReplicatedStorage.React.CONSTANTS)
local horizontal = Enum.FillDirection.Horizontal
local uDim = UDim2.fromScale(0.95, 0.7)
local color = Color3.fromRGB(255, 234, 0)
local color2 = Color3.fromRGB(21, 21, 21)
local color3 = Color3.fromRGB(0, 227, 4)
local createElement = React.createElement

-- equivalent calls inferred from this helper; original call sites unknown
local function layoutOrder()
	local v = 0
	return function()
		if horizontal == Enum.FillDirection.Vertical then
			v -= 1
		else
			v += 1
		end

		return v
	end
end

function assetTile(props)
	local tileOverlays = nil
	local category = nil
	local sprite = nil
	local spriteBorderThickness = nil
	local outlineSprite = nil
	local cornerIcon = nil
	local rarity = "Common"
	local quantity = props.Quantity
	local title

	if props.IdType then
		local id = ItemId.getId(props.Name, props.IdType)
		local unwrapped = ItemConfig.match(id:unwrap()):unwrap()

		if id:isErr() then
			id:inspect(error)
		end

		rarity = unwrapped.Quality.Rarity
		tileOverlays = unwrapped.Inventory.TileOverlays
		title = unwrapped.Display.Title
		category = unwrapped.Display.Category
		sprite = unwrapped.Display.Sprite
		spriteBorderThickness = unwrapped.Display.SpriteBorderThickness
		outlineSprite = unwrapped.Display.OutlineSprite
		cornerIcon = unwrapped.Display.CornerIcon
	else
		title = props.Name
	end

	local variant = props.Claimed and "Display" or "Elevated"
	return createElement(Tile, {
		Size = UDim2.fromScale(1, 1),
		Selectable = false,
		Variant = variant,
		IsSelected = false,
		DrawContext = "Default",
		Quantity = quantity,
		IsEquipped = false,
		IsPermanent = false,
		Rarity = rarity,
		Overlays = tileOverlays,
		Title = title or "",
		Category = category,
		Icon = sprite,
		IconBorderThickness = spriteBorderThickness,
		OutlineIcon = outlineSprite,
		CornerIcon = cornerIcon,
		WasRecentlyReceived = props.IsNew
	})
end

return function(props)
	local state, setState = React.useState(UDim2.new(0, 0, 0, 0))
	local state2, setState2 = React.useState(nil)
	local ref = React.useRef(nil)
	local ref2 = React.useRef(nil)
	local ref3 = React.useRef(nil)
	React.useEffect(function()
		if not (ref2.current and ref.current and ref3.current) then
			return function() end
		end

		local thread = nil
		setState2(Vector2.zero)
		thread = task.defer(function()
			thread = nil
			local v = 0
			local v2 = 0

			if horizontal == Enum.FillDirection.Vertical then
				local v3 = ref.current.AbsoluteSize.Y / 2
				v2 = ref.current.AbsolutePosition.Y - (ref2.current.AbsoluteSize.Y / 2 + v3) - ref2.current.AbsolutePosition.Y
			else
				local v3 = ref.current.AbsoluteSize.X / 2
				v = ref.current.AbsolutePosition.X - (ref2.current.AbsoluteSize.x / 2 + v3) - ref2.current.AbsolutePosition.X
			end

			setState2(Vector2.new(v, v2))
		end)
		return function()
			if thread then
				task.cancel(thread)
				thread = nil
			end
		end
	end, {
		state,
		ref2.current,
		ref.current,
		ref3.current
	})
	local v = React.useMemo(function()
		local count = #props.Items

		for i = #props.Items, 1, -1 do
			local item = props.Items[i]

			if props.Progress < item.Goal then
				count = i
			end
		end

		return count
	end, { props.Progress })
	local thickness = React.useMemo(function()
		return math.clamp(workspace.CurrentCamera.ViewportSize.X / 1000, 2, 10) * 0.6
	end, { workspace.CurrentCamera.ViewportSize })
	local v3 = layoutOrder() -- equivalent call inferred; original call site unknown
	local v5 = (props.SegmentLength or 120) * 0.5

	local function newSegment(p: number, p2: number, layoutOrder2: number?)
		UDim2.new()
		UDim2.new()
		local v6 = p == #props.Items + 1
		local v7 = p == 1
		local uDim2, uDim3

		if horizontal == Enum.FillDirection.Vertical then
			uDim2 = UDim2.new(0.075, 0, 0, v5)
			uDim3 = UDim2.fromScale(1, p2)
		else
			local v9

			if v6 or v7 then
				v9 = v5 * 0.5
			else
				v9 = v5
			end

			uDim2 = UDim2.new(0, v9, 0.075, 0)
			uDim3 = UDim2.fromScale(p2, 1)
		end

		local v10 = {
			BackgroundTransparency = CONSTANTS.ALPHA.HEAVY,
			BackgroundColor3 = color,
			LayoutOrder = layoutOrder2,
			Size = uDim2,
			BorderSizePixel = CONSTANTS.THICKNESS.OUTLINE.NONE,
			ZIndex = CONSTANTS.LAYER.CONTENT
		}
		local backgroundTransparency

		if p2 == 0 then
			backgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
		else
			backgroundTransparency = CONSTANTS.ALPHA.OPAQUE
		end

		local position

		if horizontal == Enum.FillDirection.Vertical then
			position = UDim2.fromScale(0.5, 1)
		else
			position = UDim2.fromScale(0, 0.5)
		end

		local anchorPoint

		if horizontal == Enum.FillDirection.Vertical then
			anchorPoint = Vector2.new(0.5, 1)
		else
			anchorPoint = Vector2.new(0, 0.5)
		end

		return createElement("Frame", v10, {
			Fill = createElement("Frame", {
				BackgroundTransparency = backgroundTransparency,
				Position = position,
				AnchorPoint = anchorPoint,
				BackgroundColor3 = color,
				Size = uDim3
			})
		})
	end

	local v4 = {
		Segment_last = newSegment(#props.Items + 1, 0, 9999)
	}

	for i = 1, #props.Items do
		local item = props.Items[i]
		local isNew = i == v
		local claimed = props.Progress >= item.Goal
		local v8

		if claimed then
			v8 = 1
		elseif i == 1 then
			v8 = props.Progress / item.Goal
		else
			local v9 = 1 / (item.Goal - props.Progress)
			v8 = v < i and 0 or v9
		end

		v4[`Segment_{i}`] = newSegment(i, v8, v3())
		local formatted = `{item.Goal}`

		if isNew then
			formatted = `{math.clamp(props.Progress, 0, item.Goal)}/{item.Goal}`
		end

		local ref4

		if isNew then
			ref4 = ref
		end

		local v11 = {
			ref = ref4,
			LayoutOrder = v3(),
			Size = props.TileSize or uDim,
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			ZIndex = CONSTANTS.LAYER.RAISED
		}
		local children = {
			UIAspectRatio = createElement("UIAspectRatioConstraint"),
			UICorner = createElement("UICorner", {
				CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.MD
			}),
			Tile = createElement(assetTile, {
				Name = item.Name,
				IdType = item.IdType,
				Quantity = item.Quantity,
				IsNew = isNew,
				Claimed = claimed
			}),
			UIStroke = 0,
			Progress = 0,
			ClaimedCover = 0
		}
		local uIStroke

		if claimed then
			uIStroke = createElement("UIStroke", {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = thickness
			})
		end

		children.UIStroke = uIStroke
		children.Progress = createElement("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			BackgroundColor3 = color2,
			BackgroundTransparency = CONSTANTS.ALPHA.SUBTLE,
			Position = UDim2.fromScale(0.5, 0.958),
			Size = UDim2.fromScale(0.7, 0.23),
			ZIndex = 999
		}, {
			UICorner = createElement("UICorner", {
				CornerRadius = UDim.new(1, 0)
			}),
			UIStroke = createElement("UIStroke", {
				Thickness = 0.1,
				StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
			}),
			TextLabel = createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
				FontFace = CONSTANTS.FONT.FACE.DISPLAY,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(0.9, 1.05),
				Text = formatted,
				TextColor3 = CONSTANTS.COLOR.PALETTE.WHITE,
				TextScaled = true
			}, {
				UIStroke = createElement("UIStroke", {
					LineJoinMode = Enum.LineJoinMode.Miter,
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					Thickness = 0.08
				})
			})
		})
		local claimedCover

		if claimed then
			claimedCover = createElement("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = CONSTANTS.COLOR.PALETTE.BLACK,
				BackgroundTransparency = CONSTANTS.ALPHA.LIGHT,
				Position = UDim2.fromScale(0.5, 0.5),
				Size = UDim2.fromScale(1, 1),
				ZIndex = CONSTANTS.LAYER.RAISED_HIGH
			}, {
				UICorner = createElement("UICorner", {
					CornerRadius = CONSTANTS.SPACING.CORNER_RADIUS.SCALE.SM
				}),
				Glow = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://98629857383584",
					ImageColor3 = color3,
					Position = UDim2.fromScale(0.5, 0.5),
					Size = UDim2.fromScale(1.35, 1.35)
				}),
				Checkmark = createElement("ImageLabel", {
					AnchorPoint = Vector2.new(0.5, 0.5),
					BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
					Image = "rbxassetid://105017710071760",
					Position = UDim2.fromScale(0.5, 0.5),
					ScaleType = Enum.ScaleType.Fit,
					Size = UDim2.fromScale(0.5, 0.5),
					ZIndex = CONSTANTS.LAYER.RAISED
				})
			})
		end

		children.ClaimedCover = claimedCover
		local v15 = createElement("Frame", v11, children)
		v4[`Tile{i}`] = v15
	end

	React.useEffect(function()
		if not (ref2.current and ref3.current) then
			return nil
		end

		-- equivalent calls inferred from this helper; original call sites unknown
		local function fn()
			local X = 0
			local Y = 0

			if horizontal == Enum.FillDirection.Vertical then
				Y = ref3.current.AbsoluteContentSize.Y
			else
				X = ref3.current.AbsoluteContentSize.X
			end

			setState(UDim2.new(0, X, 0, Y))
		end

		fn() -- equivalent call inferred; original call site unknown
		local absoluteContentSizeChangedConnection = ref3.current:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(fn)
		return function()
			absoluteContentSizeChangedConnection:Disconnect()
		end
	end, { ref2.current, ref3.current, props.Progress })
	return createElement("Frame", RobloxTypes.mergeFrame({
		BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE
	}, props), {
		ScrollingFrame = createElement("ScrollingFrame", {
			ref = ref2,
			ClipsDescendants = true,
			Size = UDim2.fromScale(1, 1),
			Position = UDim2.fromScale(0.5, 0.5),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = CONSTANTS.ALPHA.INVISIBLE,
			CanvasSize = state,
			CanvasPosition = state2,
			ScrollBarThickness = CONSTANTS.THICKNESS.SCROLLBAR.NONE,
			VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
			ZIndex = CONSTANTS.LAYER.RAISED_HIGH
		}, {
			Tiles = createElement(React.Fragment, {}, v4),
			UIListLayout = createElement("UIListLayout", {
				ref = ref3,
				FillDirection = horizontal,
				SortOrder = Enum.SortOrder.LayoutOrder,
				VerticalAlignment = Enum.VerticalAlignment.Center,
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalFlex = Enum.UIFlexAlignment.SpaceAround
			})
		})
	})
end