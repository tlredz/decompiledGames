local Effect = require(script.Parent.Effect)
local Renderable = {}
Renderable.__index = Renderable

local function configure(state, data)
	if not data then
		return state
	end

	local alignment = data.alignment
	state._layout = data.layout or data.direction or state._layout
	state._columns = data.columns or state._columns
	state._gap = data.gap or state._gap
	state._cellSize = data.cellSize or state._cellSize
	state._cellPadding = data.cellPadding or state._cellPadding
	state._xAlignment = data.x or data.xAlignment or alignment and alignment.x or state._xAlignment
	state._yAlignment = data.y or data.yAlignment or alignment and alignment.y or state._yAlignment
	local frameSize = data.frameSize or data.size

	if typeof(frameSize) ~= "UDim2" then
		frameSize = state._frameSize
	end

	state._frameSize = frameSize
	state._framePosition = data.framePosition or data.position or state._framePosition
	state._frameAnchorPoint = data.frameAnchorPoint or data.anchorPoint or state._frameAnchorPoint
	state._layoutOrder = data.layoutOrder or state._layoutOrder
	state._textXAlignment = data.textXAlignment or state._textXAlignment
	state._textYAlignment = data.textYAlignment or state._textYAlignment
	state._capLines = data.capLines or state._capLines
	state._visibleGraphemes = data.visibleGraphemes or state._visibleGraphemes
	state._textColor = data.textColor or state._textColor
	state._textTransparency = data.textTransparency or state._textTransparency

	if data.stroke ~= nil then
		state._stroke = data.stroke
	end

	if data.isolateWords ~= nil then
		state._isolateWords = data.isolateWords
	end

	state._calculatedAbsoluteSize = nil
	return state
end

local function parseConfigAndConstructor(value, callback)
	if typeof(value) == "function" then
		return callback, value
	end

	assert(typeof(value) == "table", "renderable child expects a config table or constructor function")
	assert(typeof(callback) == "function", "renderable child expects a constructor function")
	return value, callback
end

function Renderable.new(p)
	return (configure(setmetatable({
		_kind = "group",
		_children = {},
		_effects = {},
		_calculatedAbsoluteSize = nil
	}, Renderable), p))
end

function Renderable.configure(p, p2)
	return (configure(p, p2))
end

function Renderable:addChild(value, callback)
	if typeof(value) == "function" then
		callback, value = value, callback
	else
		assert(typeof(value) == "table", "renderable child expects a config table or constructor function")
		assert(typeof(callback) == "function", "renderable child expects a constructor function")
	end

	local v = Renderable.new(value)
	callback(v)
	table.insert(self._children, v)
	self._calculatedAbsoluteSize = nil
	return self
end

function Renderable:addText(textSource: string, p2)
	local Translation = require(script.Parent.Parent.Translation)
	local Word = require(script.Word)
	local v = Renderable.new(p2)
	v._kind = "text"
	v._textSource = textSource
	v._words = {}
	local translated = Translation.translate(textSource)

	for _, v2 in Translation.toWords(translated) do
		table.insert(v._words, Word.new(v2))
	end

	table.insert(self._children, v)
	self._calculatedAbsoluteSize = nil
	return self
end

function Renderable:addIcon(value, p2)
	local Icon = require(script.Icon)
	local v = Icon.new(p2)

	if typeof(value) == "string" then
		v:setSprite(value)
	elseif typeof(value) == "function" then
		value(v)
	elseif value ~= nil then
		error("addIcon expects a sprite name or icon constructor function", 2)
	end

	table.insert(self._children, v)
	self._calculatedAbsoluteSize = nil
	return self
end

function Renderable:addReactComponent(reactComponent, options, reactChildren, p2)
	assert(reactComponent ~= nil, "addReactComponent expects a React component or Instance class name")
	local v = Renderable.new(p2)
	v._kind = "react"
	v._reactComponent = reactComponent
	v._reactProps = options or {}
	v._reactChildren = reactChildren

	if not v._frameSize then
		local size = v._reactProps.Size

		if typeof(size) == "UDim2" then
			v._frameSize = size
		end
	end

	if not v._framePosition then
		local position = v._reactProps.Position

		if typeof(position) == "UDim2" then
			v._framePosition = position
		end
	end

	if not v._frameAnchorPoint then
		local anchorPoint = v._reactProps.AnchorPoint

		if typeof(anchorPoint) == "Vector2" then
			v._frameAnchorPoint = anchorPoint
		end
	end

	table.insert(self._children, v)
	self._calculatedAbsoluteSize = nil
	return self
end

function Renderable:addEffect(p2)
	table.insert(self._effects, Effect.create(self, p2))
	return self
end

function Renderable:swapTranslatedText(p: string, p2: string)
	local v

	if self._kind == "text" and self._textSource == p then
		local Translation = require(script.Parent.Parent.Translation)
		local Word = require(script.Word)
		local words = {}

		for _, v3 in Translation.toWords(p2) do
			table.insert(words, Word.new(v3))
		end

		self._words = words
		v = true
	else
		v = false
	end

	for _, v2 in self._children do
		if v2:swapTranslatedText(p, p2) then
			v = true
		end
	end

	return v
end

function Renderable:_measure()
	local zero = Vector2.zero

	for _, v in self._children do
		local absoluteSize = v:getAbsoluteSize()
		zero = Vector2.new(zero.X + absoluteSize.X, (math.max(zero.Y, absoluteSize.Y)))
	end

	return zero
end

function Renderable:getAbsoluteSize()
	if not self._calculatedAbsoluteSize then
		self._calculatedAbsoluteSize = self:_measure()
	end

	return self._calculatedAbsoluteSize
end

return Renderable