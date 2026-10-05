local React = require(game.ReplicatedStorage.Packages.React)
local Bubble = require(script.Parent.Bubble)
local DialogueText = require(script.Parent.DialogueText)
local Effects = require(script.Parent.Effects)
local Icon = require(script.Parent.Icon)
local rbxassetfontsfamiliesHighwayGothicjson = Font.new("rbxasset://fonts/families/HighwayGothic.json")
local uDim = UDim2.fromOffset(240, 44)
local uDim2 = UDim2.fromOffset(40, 40)
local uDim3 = UDim2.fromOffset(100, 100)
local uDim4 = UDim2.fromOffset(72, 72)
local v = {}
local v2 = {}
local v3 = {}

local function normalizeX(value)
	if typeof(value) ~= "string" then
		return "middle"
	end

	local lower = value:lower()

	if lower == "left" or lower == "right" then
		return lower
	end

	if lower == "middle" or lower == "center" or lower == "centre" then
		return "middle"
	end

	return "middle"
end

local function normalizeY(value)
	if typeof(value) ~= "string" then
		return "middle"
	end

	local lower = value:lower()

	if lower == "top" or lower == "bottom" then
		return lower
	end

	if lower == "middle" or lower == "center" or lower == "centre" then
		return "middle"
	end

	return "middle"
end

local function anchorFor(p)
	local xAlignment = p.xAlignment
	local v4

	if typeof(xAlignment) == "string" then
		v4 = xAlignment:lower()

		if v4 ~= "left" and v4 ~= "right" then
			v4 = "middle"
		end
	else
		v4 = "middle"
	end

	local yAlignment = p.yAlignment
	local v5

	if typeof(yAlignment) == "string" then
		v5 = yAlignment:lower()

		if v5 ~= "top" and v5 ~= "bottom" then
			v5 = "middle"
		end
	else
		v5 = "middle"
	end

	return Vector2.new(
		v4 == "left" and 0 or v4 == "right" and 1 or 0.5,
		v5 == "top" and 0 or v5 == "bottom" and 1 or 0.5
	)
end

local function positionFor(p)
	local xAlignment = p.xAlignment
	local v4

	if typeof(xAlignment) == "string" then
		v4 = xAlignment:lower()

		if v4 ~= "left" and v4 ~= "right" then
			v4 = "middle"
		end
	else
		v4 = "middle"
	end

	local yAlignment = p.yAlignment
	local v5

	if typeof(yAlignment) == "string" then
		v5 = yAlignment:lower()

		if v5 ~= "top" and v5 ~= "bottom" then
			v5 = "middle"
		end
	else
		v5 = "middle"
	end

	return UDim2.fromScale(
		v4 == "left" and 0 or v4 == "right" and 1 or 0.5,
		v5 == "top" and 0 or v5 == "bottom" and 1 or 0.5
	)
end

local function horizontalAlignmentFor(value)
	local v4

	if typeof(value) == "string" then
		v4 = value:lower()

		if v4 ~= "left" and v4 ~= "right" then
			v4 = "middle"
		end
	else
		v4 = "middle"
	end

	if v4 == "left" then
		return Enum.HorizontalAlignment.Left
	elseif v4 == "right" then
		return Enum.HorizontalAlignment.Right
	end

	return Enum.HorizontalAlignment.Center
end

local function verticalAlignmentFor(value)
	local v4

	if typeof(value) == "string" then
		v4 = value:lower()

		if v4 ~= "top" and v4 ~= "bottom" then
			v4 = "middle"
		end
	else
		v4 = "middle"
	end

	if v4 == "top" then
		return Enum.VerticalAlignment.Top
	elseif v4 == "bottom" then
		return Enum.VerticalAlignment.Bottom
	end

	return Enum.VerticalAlignment.Center
end

local function normalizeLayout(value)
	if typeof(value) ~= "string" then
		return "row"
	end

	local lower = value:lower()

	if lower == "column" or lower == "vertical" then
		return "column"
	end

	if lower == "grid" then
		return "grid"
	end

	return "row"
end

local function gapUDim(value)
	if typeof(value) == "UDim" then
		return value
	end

	if typeof(value) == "number" then
		return UDim.new(0, value)
	end

	return UDim.new(0, 0)
end

local function gapUDim2(gap)
	if typeof(gap) == "UDim2" then
		return gap
	end

	if typeof(gap) == "Vector2" then
		return UDim2.fromOffset(gap.X, gap.Y)
	end

	if typeof(gap) == "number" then
		return UDim2.fromOffset(gap, gap)
	end

	return UDim2.fromOffset(0, 0)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function toPascalCase(value: string)
	return value:sub(1, 1):upper() .. value:sub(2)
end

local function getProbe(p: string)
	local v4 = v[p]

	if v4 == nil then
		local success, result = pcall(Instance.new, p)

		if success then
			v[p] = result
			return result
		end

		v[p] = false
		return nil
	elseif v4 == false then
		return nil
	else
		return v4
	end
end

local function isValidInstanceProp(p: string, k: string)
	if k == "ref" or k == "key" then
		return true
	end

	local v4 = v2[p]

	if not v4 then
		v4 = {}
		v2[p] = v4
	end

	local v5 = v4[k]

	if v5 ~= nil then
		return v5
	end

	local result = v[p]

	if result == nil then
		local success
		success, result = pcall(Instance.new, p)

		if success then
			v[p] = result
		else
			v[p] = false
			result = nil
		end
	elseif result == false then
		result = nil
	end

	if not result then
		v4[k] = true
		return true
	end

	local v6 = pcall(function()
		local _ = result[k]
	end)
	v4[k] = v6
	return v6
end

local function sanitizeProps(reactComponent: string, reactProps)
	local result = {}

	for k, v4 in reactProps or {} do
		if typeof(k) == "string" then
			if k ~= "ref" and k ~= "key" then
				k = toPascalCase(k)
			end

			if isValidInstanceProp(reactComponent, k) then
				result[k] = v4
			else
				local formatted = `{reactComponent}.{k}`

				if not v3[formatted] then
					warn("[DIALOGUE]", (`unknown {reactComponent} prop "{k}"`))
					v3[formatted] = true
				end
			end
		else
			result[k] = v4
		end
	end

	return result
end

local function cloneProps(options)
	local result = {}

	for k, v4 in options or {} do
		result[k] = v4
	end

	return result
end

local function applyNodeLayoutProps(state, data, flag: boolean, size: UDim2, p: number?)
	state.BackgroundTransparency = state.BackgroundTransparency or 1
	state.LayoutOrder = state.LayoutOrder or data.layoutOrder
	state.Size = state.Size or data.frameSize or size
	state.ZIndex = state.ZIndex or p

	if flag then
		state.AnchorPoint = state.AnchorPoint or Vector2.zero
		state.Position = state.Position or UDim2.new()
	else
		local anchorPoint = state.AnchorPoint or data.frameAnchorPoint

		if not anchorPoint then
			local xAlignment = data.xAlignment
			local v4

			if typeof(xAlignment) == "string" then
				v4 = xAlignment:lower()

				if v4 ~= "left" and v4 ~= "right" then
					v4 = "middle"
				end
			else
				v4 = "middle"
			end

			local yAlignment = data.yAlignment
			local v5

			if typeof(yAlignment) == "string" then
				v5 = yAlignment:lower()

				if v5 ~= "top" and v5 ~= "bottom" then
					v5 = "middle"
				end
			else
				v5 = "middle"
			end

			anchorPoint = Vector2.new(
				v4 == "left" and 0 or v4 == "right" and 1 or 0.5,
				v5 == "top" and 0 or v5 == "bottom" and 1 or 0.5
			)
		end

		state.AnchorPoint = anchorPoint
		local position = state.Position or data.framePosition

		if not position then
			local xAlignment = data.xAlignment
			local v4

			if typeof(xAlignment) == "string" then
				v4 = xAlignment:lower()

				if v4 ~= "left" and v4 ~= "right" then
					v4 = "middle"
				end
			else
				v4 = "middle"
			end

			local yAlignment = data.yAlignment
			local v5

			if typeof(yAlignment) == "string" then
				v5 = yAlignment:lower()

				if v5 ~= "top" and v5 ~= "bottom" then
					v5 = "middle"
				end
			else
				v5 = "middle"
			end

			position = UDim2.fromScale(
				v4 == "left" and 0 or v4 == "right" and 1 or 0.5,
				v5 == "top" and 0 or v5 == "bottom" and 1 or 0.5
			)
		end

		state.Position = position
	end
end

local renderNode

local function renderTextNode(props, flag: boolean, p: number?, flag2: boolean)
	local v4 = {}
	local v6

	if flag2 then
		v6 = UDim2.fromScale(1, 1)
	else
		v6 = uDim
	end

	applyNodeLayoutProps(v4, props, flag, v6, p)
	return React.createElement("Frame", v4, {
		text = React.createElement(DialogueText, {
			words = props.words,
			visibleGraphemes = props.visibleGraphemes or -1,
			anchorPoint = Vector2.zero,
			position = UDim2.new(),
			size = UDim2.fromScale(1, 1),
			textXAlignment = props.textXAlignment,
			textYAlignment = props.textYAlignment,
			textColor = props.textColor,
			textTransparency = props.textTransparency,
			stroke = props.stroke,
			capLines = props.capLines,
			isolateWords = props.isolateWords
		})
	})
end

local function renderBubbleIcon(p, props, flag: boolean, zIndex: number?)
	local v4 = {}
	applyNodeLayoutProps(v4, p, flag, props.size or p.frameSize or uDim2, zIndex)
	local effect

	if props.effect then
		effect = Effects[props.effect]
	end

	return React.createElement("Frame", v4, {
		bubble = React.createElement(Bubble, {
			color = props.bubble.color,
			anchorPoint = Vector2.zero,
			position = UDim2.new(),
			size = UDim2.fromScale(1, 1),
			effect = effect,
			transparent = props.bubble.transparent,
			zIndex = zIndex
		}, {
			textLabel = React.createElement("TextLabel", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				AutoLocalize = false,
				BackgroundTransparency = 1,
				FontFace = rbxassetfontsfamiliesHighwayGothicjson,
				Position = UDim2.fromScale(0.5, 0.5),
				RichText = true,
				Size = UDim2.fromScale(0.9, 0.8),
				Text = props.bubble.text,
				TextColor3 = Color3.new(1, 1, 1),
				TextScaled = true,
				ZIndex = (zIndex or 1) + 1
			}, {
				uIStroke = React.createElement("UIStroke", {
					StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize,
					Thickness = 0.05
				})
			})
		})
	})
end

local function renderIconNode(p, flag: boolean, zIndex: number?)
	local icon = p.icon

	if icon.bubble then
		return renderBubbleIcon(p, icon, flag, zIndex)
	end

	local v4 = {}
	applyNodeLayoutProps(v4, p, flag, icon.size or p.frameSize or uDim2, zIndex)
	return React.createElement("Frame", v4, {
		icon = React.createElement(Icon, {
			anchorPoint = Vector2.new(0.5, 0.5),
			image = icon.image,
			imageRectOffset = icon.imageRectOffset,
			imageRectSize = icon.imageRectSize,
			backgroundImage = icon.backgroundImage,
			backgroundImageRectOffset = icon.backgroundImageRectOffset,
			backgroundImageRectSize = icon.backgroundImageRectSize,
			color = icon.color,
			transparency = icon.transparency,
			position = UDim2.fromScale(0.5, 0.5),
			scaleType = icon.scaleType,
			size = UDim2.fromScale(1, 1),
			effect = icon.effect,
			zIndex = zIndex
		})
	})
end

local function renderReactNode(props, flag: boolean, p: number?)
	local reactComponent = props.reactComponent
	local v4

	if typeof(reactComponent) == "string" then
		v4 = sanitizeProps(reactComponent, props.reactProps)
	else
		v4 = {}

		for k, v5 in props.reactProps or {} do
			v4[k] = v5
		end
	end

	v4.LayoutOrder = v4.LayoutOrder or props.layoutOrder
	v4.ZIndex = v4.ZIndex or p
	v4.Size = v4.Size or props.frameSize or uDim3

	if flag then
		v4.AnchorPoint = v4.AnchorPoint or Vector2.zero
		v4.Position = v4.Position or UDim2.new()
	else
		local anchorPoint = v4.AnchorPoint or props.frameAnchorPoint

		if not anchorPoint then
			local xAlignment = props.xAlignment
			local v5

			if typeof(xAlignment) == "string" then
				v5 = xAlignment:lower()

				if v5 ~= "left" and v5 ~= "right" then
					v5 = "middle"
				end
			else
				v5 = "middle"
			end

			local yAlignment = props.yAlignment
			local v6

			if typeof(yAlignment) == "string" then
				v6 = yAlignment:lower()

				if v6 ~= "top" and v6 ~= "bottom" then
					v6 = "middle"
				end
			else
				v6 = "middle"
			end

			anchorPoint = Vector2.new(
				v5 == "left" and 0 or v5 == "right" and 1 or 0.5,
				v6 == "top" and 0 or v6 == "bottom" and 1 or 0.5
			)
		end

		v4.AnchorPoint = anchorPoint
		local position = v4.Position or props.framePosition

		if not position then
			local xAlignment = props.xAlignment
			local v5

			if typeof(xAlignment) == "string" then
				v5 = xAlignment:lower()

				if v5 ~= "left" and v5 ~= "right" then
					v5 = "middle"
				end
			else
				v5 = "middle"
			end

			local yAlignment = props.yAlignment
			local v6

			if typeof(yAlignment) == "string" then
				v6 = yAlignment:lower()

				if v6 ~= "top" and v6 ~= "bottom" then
					v6 = "middle"
				end
			else
				v6 = "middle"
			end

			position = UDim2.fromScale(
				v5 == "left" and 0 or v5 == "right" and 1 or 0.5,
				v6 == "top" and 0 or v6 == "bottom" and 1 or 0.5
			)
		end

		v4.Position = position
	end

	return React.createElement(reactComponent, v4, props.reactChildren)
end

local function renderGroupNode(props, flag: boolean, p: number?, flag2: boolean)
	local layout = props.layout
	local v4

	if typeof(layout) == "string" then
		local lower = layout:lower()
		v4 = (lower == "column" or lower == "vertical") and "column" or lower == "grid" and "grid" or "row"
	else
		v4 = "row"
	end

	local v5 = {}
	local v7

	if flag2 then
		v7 = UDim2.fromScale(1, 1)
	else
		v7 = UDim2.fromOffset(0, 0)
	end

	applyNodeLayoutProps(v5, props, flag, v7, p)

	if not (flag2 or props.frameSize) then
		v5.AutomaticSize = Enum.AutomaticSize.XY
	end

	local children = {}

	for k, v8 in props.children or {} do
		children[`child{k}`] = renderNode(v8, true, p, false)
	end

	if v4 == "grid" then
		local createElement = React.createElement
		local v9 = {
			CellPadding = props.cellPadding or gapUDim2(props.gap),
			CellSize = props.cellSize or uDim4,
			FillDirectionMaxCells = props.columns or 0,
			HorizontalAlignment = 0,
			SortOrder = 0,
			VerticalAlignment = 0
		}
		local xAlignment = props.xAlignment
		local v10

		if typeof(xAlignment) == "string" then
			v10 = xAlignment:lower()

			if v10 ~= "left" and v10 ~= "right" then
				v10 = "middle"
			end
		else
			v10 = "middle"
		end

		local left

		if v10 == "left" then
			left = Enum.HorizontalAlignment.Left
		elseif v10 == "right" then
			left = Enum.HorizontalAlignment.Right
		else
			left = Enum.HorizontalAlignment.Center
		end

		v9.HorizontalAlignment = left
		v9.SortOrder = Enum.SortOrder.LayoutOrder
		local yAlignment = props.yAlignment
		local v11

		if typeof(yAlignment) == "string" then
			v11 = yAlignment:lower()

			if v11 ~= "top" and v11 ~= "bottom" then
				v11 = "middle"
			end
		else
			v11 = "middle"
		end

		local top

		if v11 == "top" then
			top = Enum.VerticalAlignment.Top
		elseif v11 == "bottom" then
			top = Enum.VerticalAlignment.Bottom
		else
			top = Enum.VerticalAlignment.Center
		end

		v9.VerticalAlignment = top
		children.layout = createElement("UIGridLayout", v9)
	else
		local createElement = React.createElement
		local fillDirection

		if v4 == "column" then
			fillDirection = Enum.FillDirection.Vertical
		else
			fillDirection = Enum.FillDirection.Horizontal
		end

		local xAlignment = props.xAlignment
		local v11

		if typeof(xAlignment) == "string" then
			v11 = xAlignment:lower()

			if v11 ~= "left" and v11 ~= "right" then
				v11 = "middle"
			end
		else
			v11 = "middle"
		end

		local left

		if v11 == "left" then
			left = Enum.HorizontalAlignment.Left
		elseif v11 == "right" then
			left = Enum.HorizontalAlignment.Right
		else
			left = Enum.HorizontalAlignment.Center
		end

		local gap = props.gap

		if typeof(gap) ~= "UDim" then
			if typeof(gap) == "number" then
				gap = UDim.new(0, gap)
			else
				gap = UDim.new(0, 0)
			end
		end

		local v9 = {
			FillDirection = fillDirection,
			HorizontalAlignment = left,
			Padding = gap,
			SortOrder = Enum.SortOrder.LayoutOrder,
			VerticalAlignment = 0
		}
		local yAlignment = props.yAlignment
		local v12

		if typeof(yAlignment) == "string" then
			v12 = yAlignment:lower()

			if v12 ~= "top" and v12 ~= "bottom" then
				v12 = "middle"
			end
		else
			v12 = "middle"
		end

		local top

		if v12 == "top" then
			top = Enum.VerticalAlignment.Top
		elseif v12 == "bottom" then
			top = Enum.VerticalAlignment.Bottom
		else
			top = Enum.VerticalAlignment.Center
		end

		v9.VerticalAlignment = top
		children.layout = createElement("UIListLayout", v9)
	end

	return React.createElement("Frame", v5, children)
end

renderNode = function(p, flag: boolean, zIndex: number?, flag2: boolean?)
	if p.kind == "text" then
		return renderTextNode(p, flag, zIndex, flag2 == true)
	end

	if p.kind == "icon" then
		return renderIconNode(p, flag, zIndex)
	end

	if p.kind == "react" then
		return renderReactNode(p, flag, zIndex)
	end

	return renderGroupNode(p, flag, zIndex, flag2 == true)
end

local function mergeExtraChildren(p, children)
	if children == nil then
		return
	end

	if typeof(children) ~= "table" or children.type ~= nil or children["$$typeof"] ~= nil then
		p.extra = children
		return
	end

	for k, v4 in children do
		p[`extra{tostring(k)}`] = v4
	end
end

local function RenderableLayer(props)
	local v4 = {}

	for k, v5 in props.Renderables or {} do
		v4[`renderable{k}`] = renderNode(v5, false, props.ZIndex or 2, true)
	end

	mergeExtraChildren(v4, props.Children)
	return React.createElement("Frame", {
		AnchorPoint = props.AnchorPoint or Vector2.new(0.5, 0),
		BackgroundTransparency = 1,
		Position = props.Position or UDim2.fromScale(0.5, 0.46),
		Size = props.Size or UDim2.fromScale(0.85, 0.52),
		ZIndex = props.ZIndex or 2
	}, v4)
end

return React.memo(RenderableLayer)