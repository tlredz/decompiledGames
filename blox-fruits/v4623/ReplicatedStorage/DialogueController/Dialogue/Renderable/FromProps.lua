local parentModule = require(script.Parent)
local Icon = require(script.Parent.Icon)
local Snapshot = require(script.Parent.Snapshot)
local FromProps = {}
local v = {
	Renderable = true,
	Renderables = true,
	GroupRenderable = true,
	GroupRenderables = true,
	Text = true,
	TextRenderable = true,
	TextRenderables = true,
	IconRenderable = true,
	IconRenderables = true,
	ReactComponentRenderable = true,
	ReactComponentRenderables = true
}
local v2 = {
	Position = true,
	Size = true,
	AnchorPoint = true,
	ZIndex = true,
	children = true
}

local function first(p, ...)
	for _, v3 in { ... } do
		local v4 = p[v3]

		if v4 ~= nil then
			return v4
		end
	end

	return nil
end

local function renderableConfigFromDescriptor(data)
	local alignment = data.Alignment
	return {
		x = data.X,
		y = data.Y,
		xAlignment = data.XAlignment,
		yAlignment = data.YAlignment,
		alignment = typeof(alignment) == "table" and {
			x = alignment.X,
			y = alignment.Y
		} or nil,
		layout = data.Layout,
		direction = data.Direction,
		columns = data.Columns,
		gap = data.Gap,
		cellSize = data.CellSize,
		cellPadding = data.CellPadding,
		frameSize = data.FrameSize,
		framePosition = data.FramePosition,
		frameAnchorPoint = data.FrameAnchorPoint,
		layoutOrder = data.LayoutOrder,
		textXAlignment = data.TextXAlignment,
		textYAlignment = data.TextYAlignment,
		capLines = data.CapLines,
		visibleGraphemes = data.VisibleGraphemes,
		textColor = data.TextColor,
		textTransparency = data.TextTransparency,
		stroke = data.Stroke,
		isolateWords = data.IsolateWords
	}
end

local function normalizeEffectName(value)
	if typeof(value) == "string" then
		return value
	end

	if typeof(value) == "table" then
		return first(value, "Effect", "Name") or value[1]
	end

	return nil
end

local function textWithEffect(p: string, p2)
	local effects = first(p2, "AnimateEffect", "Effect")

	if not effects then
		effects = p2.Effects

		if typeof(effects) ~= "string" then
			if typeof(effects) == "table" then
				effects = first(effects, "Effect", "Name") or effects[1]
			else
				effects = nil
			end
		end
	end

	if effects then
		return (`<AnimateEffect={effects}>{p}<AnimateEffect=/>`)
	end

	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
local function appendDescriptorList(list, list2)
	if list2 == nil then
		return
	end

	if typeof(list2) ~= "table" or list2[1] == nil then
		table.insert(list, list2)
		return
	end

	for _, v3 in list2 do
		table.insert(list, v3)
	end
end

local function withoutLayerProps(items)
	local result = {}

	for k, item in items do
		if not v2[k] then
			result[k] = item
		end
	end

	return result
end

local function descriptorChildren(p, p2)
	if p.Children == nil then
		return p2
	end

	return p.Children
end

local function applyIconDescriptor(object, data)
	local image = data.Image
	local sprite = data.Sprite

	if sprite then
		object:setSprite(sprite)
	elseif image then
		object:setImage(image)
	end

	local backgroundSprite = data.BackgroundSprite

	if backgroundSprite then
		object:setBackgroundSprite(backgroundSprite)
	end

	local bubble = data.Bubble

	if typeof(bubble) == "table" then
		object:setBubble(bubble.Color or "White", bubble.Text or "")
	end

	local color = data.Color

	if color ~= nil then
		object:setColor(color)
	end

	local transparency = data.Transparency

	if transparency ~= nil then
		object:setTransparency(transparency)
	end

	local scaleType = data.ScaleType

	if scaleType ~= nil then
		object:setScaleType(scaleType)
	end

	local effects = first(data, "IconEffect", "Effect")

	if not effects then
		effects = data.Effects

		if typeof(effects) ~= "string" then
			if typeof(effects) == "table" then
				effects = first(effects, "Effect", "Name") or effects[1]
			else
				effects = nil
			end
		end
	end

	if effects ~= nil then
		object:setEffect(effects)
	end

	local iconSize = data.IconSize

	if iconSize ~= nil then
		object:setSize(iconSize)
	end
end

local buildRenderable

local function buildTextRenderable(p)
	local v3 = renderableConfigFromDescriptor(p)
	local v4 = parentModule.new(v3)
	local text = p.Text or ""
	local effects = first(p, "AnimateEffect", "Effect")

	if not effects then
		effects = p.Effects

		if typeof(effects) ~= "string" then
			if typeof(effects) == "table" then
				effects = first(effects, "Effect", "Name") or effects[1]
			else
				effects = nil
			end
		end
	end

	if effects then
		text = `<AnimateEffect={effects}>{text}<AnimateEffect=/>`
	end

	v4:addText(text, v3)
	return v4._children[1]
end

-- equivalent calls inferred from this helper; original call sites unknown
local function buildIconRenderable(data)
	local v3 = Icon.new((renderableConfigFromDescriptor(data)))
	applyIconDescriptor(v3, data)
	return v3
end

local function buildReactComponentRenderable(data, children)
	local v3 = renderableConfigFromDescriptor(data)
	local v4 = parentModule.new(v3)
	local v5 = first(data, "Component", "ClassName", "Name") or "Frame"
	local props = data.Props or data

	if data.Children ~= nil then
		children = data.Children
	end

	v4:addReactComponent(v5, props, children, v3)
	return v4._children[1]
end

local function buildGroupRenderable(data, p)
	local v3 = parentModule.new((renderableConfigFromDescriptor(data)))

	for _, v4 in FromProps.descriptorsFromProps(data, p) do
		table.insert(v3._children, buildRenderable(v4))
	end

	return v3
end

buildRenderable = function(data)
	assert(typeof(data) == "table", "renderable descriptor must be a table")

	if data._children ~= nil or data._kind ~= nil then
		return data
	end

	if first(data, "Component", "ClassName") ~= nil then
		return (buildReactComponentRenderable(data))
	end

	if data.Text == nil then
		if first(data, "Image", "Sprite", "Bubble") == nil then
			return (buildGroupRenderable(data))
		end

		return buildIconRenderable(data)
	else
		local v3 = renderableConfigFromDescriptor(data)
		local v4 = parentModule.new(v3)
		local text = data.Text or ""
		local effects = first(data, "AnimateEffect", "Effect")

		if not effects then
			effects = data.Effects

			if typeof(effects) ~= "string" then
				if typeof(effects) == "table" then
					effects = first(effects, "Effect", "Name") or effects[1]
				else
					effects = nil
				end
			end
		end

		if effects then
			text = `<AnimateEffect={effects}>{text}<AnimateEffect=/>`
		end

		v4:addText(text, v3)
		return v4._children[1]
	end
end

function FromProps.descriptorsFromProps(p, p2)
	local v3 = {}

	if not p then
		return v3
	end

	appendDescriptorList(v3, p.Renderable) -- equivalent call inferred; original call site unknown
	appendDescriptorList(v3, p.Renderables) -- equivalent call inferred; original call site unknown
	appendDescriptorList(v3, p.GroupRenderable) -- equivalent call inferred; original call site unknown
	appendDescriptorList(v3, p.GroupRenderables) -- equivalent call inferred; original call site unknown
	appendDescriptorList(v3, p.TextRenderable) -- equivalent call inferred; original call site unknown
	appendDescriptorList(v3, p.TextRenderables) -- equivalent call inferred; original call site unknown
	appendDescriptorList(v3, p.IconRenderable) -- equivalent call inferred; original call site unknown
	appendDescriptorList(v3, p.IconRenderables) -- equivalent call inferred; original call site unknown
	appendDescriptorList(v3, p.ReactComponentRenderable) -- equivalent call inferred; original call site unknown
	appendDescriptorList(v3, p.ReactComponentRenderables) -- equivalent call inferred; original call site unknown

	if p.Text ~= nil then
		local v4 = {}

		for k, v5 in p do
			if not v2[k] then
				v4[k] = v5
			end
		end

		table.insert(v3, v4)
	end

	if #v3 == 0 and p2 == nil then
		for k in p do
			if v[k] then
				return v3
			end
		end
	end

	return v3
end

function FromProps.renderablesFromProps(p, p2)
	local result = {}

	for _, v3 in FromProps.descriptorsFromProps(p, p2) do
		table.insert(result, buildRenderable(v3))
	end

	return result
end

function FromProps.snapshotsFromProps(p, p2)
	return Snapshot.renderableSnapshots(FromProps.renderablesFromProps(p, p2))
end

return FromProps