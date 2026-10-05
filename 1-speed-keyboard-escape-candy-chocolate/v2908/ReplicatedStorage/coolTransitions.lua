local ContentProvider = game:GetService("ContentProvider")
local RunService = game:GetService("RunService")
local imagesByName = {}

for _, image in script:GetChildren() do
	if image:IsA("ImageLabel") then
		imagesByName[image.Name] = image.Image
	end
end

ContentProvider:PreloadAsync(script:GetChildren())
local color = Color3.fromRGB(20, 20, 20)

-- equivalent calls inferred from this helper; original call sites unknown
local function easeInOutSine(p: number)
	return -(math.cos(3.141592653589793 * p) - 1) / 2
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function easeOutQuad(p: number)
	return 1 - (1 - p) * (1 - p)
end

local function easeInQuad(p: number)
	return p * p
end

local class = {}
class.__index = class

function class.new(config)
	return (setmetatable({
		_config = config,
		_cells = {},
		_background = nil,
		_screenWidth = 0,
		_screenHeight = 0
	}, class))
end

function class:Build(parent, screenWidth: number, screenHeight: number, color2: Color3)
	self._screenWidth = screenWidth
	self._screenHeight = screenHeight
	local frame = Instance.new("Frame")
	frame.Name = "GridBackground"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = color2
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.ZIndex = 0
	frame.Visible = false
	frame.Parent = parent
	self._background = frame
	local cells = self._config.cells(screenWidth, screenHeight)
	local v = self._config.content ~= nil
	local v2 = #cells
	local cells2 = table.create(v2)

	for k, cell in cells do
		local element

		if v then
			element = Instance.new("ImageLabel")
			element.Image = self._config.content
			element.ImageColor3 = color2
			element.BackgroundTransparency = 1
			element.ScaleType = Enum.ScaleType.Stretch
			element.AnchorPoint = Vector2.new(0.5, 0.5)
			element.Position = UDim2.fromOffset(cell.x, cell.y)
			element.Size = UDim2.fromOffset(cell.width, cell.height)
			element.Visible = false

			if cell.rotation then
				element.Rotation = cell.rotation
			end
		else
			element = Instance.new("Frame")
			element.BackgroundColor3 = color2
			element.BorderSizePixel = 0
			element.AnchorPoint = Vector2.new(0.5, 0.5)
			element.Position = UDim2.fromOffset(cell.x, cell.y)
			element.Size = UDim2.fromOffset(cell.width, cell.height)
			element.Visible = false
		end

		element.ZIndex = 1
		element.Parent = parent
		cells2[k] = {
			element = element,
			x = cell.x,
			y = cell.y,
			fullWidth = cell.width,
			fullHeight = cell.height,
			threshold = 0,
			lastSize = -1
		}
	end

	self._cells = cells2
end

function class:Prepare(p: string)
	if self._config.randomThreshold then
		for _, _cell in self._cells do
			_cell.threshold = math.random()
		end
	else
		local _getOriginPoint, v = self:_getOriginPoint(p)
		local v2 = 0

		for _, _cell in self._cells do
			local v3 = _cell.x - _getOriginPoint
			local v4 = _cell.y - v
			local v5 = math.sqrt(v3 * v3 + v4 * v4)

			if v2 < v5 then
				v2 = v5
			end
		end

		if v2 == 0 then
			return
		end

		local v3 = 1 / v2

		for _, _cell in self._cells do
			local v4 = _cell.x - _getOriginPoint
			local v5 = _cell.y - v
			_cell.threshold = math.sqrt(v4 * v4 + v5 * v5) * v3
		end
	end
end

function class:Update(p: number, p2: string)
	local v = p2 == "In"

	if not v then
		p = 1 - p
	end

	local spread = self._config.spread
	local v2 = 1 / (1 - spread)
	local scaleUniform = self._config.scaleUniform
	local v3 = math.clamp((p - 0.95) / 0.050000000000000044, 0, 1)
	self._background.BackgroundTransparency = 1 - v3
	self._background.Visible = v3 > 0

	for _, _cell in self._cells do
		local v4 = math.clamp((p - _cell.threshold * spread) * v2, 0, 1)
		local v5

		if v then
			v5 = easeOutQuad(v4)
		else
			local v6 = 1 - v4
			v5 = 1 - v6 * v6
		end

		local v6

		if scaleUniform then
			v6 = _cell.fullWidth * v5
		else
			v6 = _cell.fullHeight * v5
		end

		local lastSize = math.floor(v6)

		if lastSize ~= _cell.lastSize then
			_cell.lastSize = lastSize

			if scaleUniform then
				_cell.element.Size = UDim2.fromOffset(lastSize, lastSize)
			else
				_cell.element.Size = UDim2.fromOffset(_cell.fullWidth, lastSize)
			end
		end

		_cell.element.Visible = v5 > 0.01
	end
end

function class:Show()
	self._background.BackgroundTransparency = 0
	self._background.Visible = true

	for _, _cell in self._cells do
		_cell.element.Size = UDim2.fromOffset(_cell.fullWidth, _cell.fullHeight)
		_cell.element.Visible = true
		_cell.lastSize = _cell.fullHeight
	end
end

function class:Hide()
	self._background.BackgroundTransparency = 1
	self._background.Visible = false

	for _, _cell in self._cells do
		_cell.element.Visible = false
		_cell.lastSize = -1
	end
end

function class:Destroy()
	if self._background then
		self._background:Destroy()
		self._background = nil
	end

	for _, _cell in self._cells do
		_cell.element:Destroy()
	end

	self._cells = {}
end

function class:_getOriginPoint(p2: string)
	if p2 == "Center" then
		return self._screenWidth / 2, self._screenHeight / 2
	elseif p2 == "TopLeft" then
		return 0, 0
	end

	return self._screenWidth, self._screenHeight
end

local function rectGrid(p: number, p2: number, p3: number, p4: number, flag: boolean?, flag2: boolean?, p5: number?)
	local v = p5 or p3
	local v2 = p + p4 * 2
	local v3 = p2 + p4 * 2
	local v4 = math.ceil(v2 / p3) + 1
	local v5 = math.ceil(v3 / p3) + 1
	local v6 = v4 * v5

	if flag2 then
		v6 = math.ceil(v6 / 2)
	end

	local result = table.create(v6)
	local count = 0

	for i = 0, v4 - 1 do
		for i2 = 0, v5 - 1 do
			if not (not flag2 or (i + i2) % 2 == 0) then
				continue
			end

			local v7 = i * p3 - p4 + ((not flag or i2 % 2 ~= 1) and 0 or p3 / 2)
			local v8 = i2 * p3 - p4
			count += 1
			result[count] = {
				x = v7,
				y = v8,
				width = v,
				height = v
			}
		end
	end

	return result
end

local v = {
	HEXAGON = {
		content = imagesByName.Hexagon,
		scaleUniform = true,
		spread = 0.65,
		randomThreshold = false,
		cells = function(p, p2)
			local v2 = math.ceil((p + 220) / 82.5) + 1
			local v3 = math.ceil((p2 + 220) / 95.26279441628824) + 1
			local result = table.create(v2 * v3)
			local count = 0

			for i = 0, v2 - 1 do
				for i2 = 0, v3 - 1 do
					count += 1
					result[count] = {
						x = i * 82.5 - 110,
						y = i2 * 95.26279441628824 + (i % 2 == 1 and 47.63139720814412 or 0) - 110,
						width = 110,
						height = 110
					}
				end
			end

			return result
		end
	},
	TRIANGLE = {
		content = imagesByName.Triangle,
		scaleUniform = true,
		spread = 0.65,
		randomThreshold = false,
		cells = function(p, p2)
			local v2 = math.ceil((p + 290) / 43.30127018922193) + 1
			local v3 = math.ceil((p2 + 290) / 75) + 1
			local result = table.create(v2 * v3)
			local count = 0

			for i = 0, v2 - 1 do
				for i2 = 0, v3 - 1 do
					count += 1
					result[count] = {
						x = i * 43.30127018922193 - 145,
						y = i2 * 75 - 145,
						width = 145,
						height = 145,
						rotation = (i + i2) % 2 == 1 and 180 or 0
					}
				end
			end

			return result
		end
	},
	TILES = {
		scaleUniform = true,
		spread = 0.65,
		randomThreshold = false,
		cells = function(p, p2)
			return (rectGrid(p, p2, 80, 80))
		end
	},
	POLKA_DOTS = {
		content = imagesByName.Circle,
		scaleUniform = true,
		spread = 0.55,
		randomThreshold = false,
		cells = function(p, p2)
			return (rectGrid(p, p2, 70, 70, true, false, 105))
		end
	},
	BLINDS = {
		scaleUniform = false,
		spread = 0.4,
		randomThreshold = false,
		cells = function(p, p2)
			local width = p + 200
			local v3 = math.ceil((p2 + 120) / 60) + 1
			local result = table.create(v3)

			for i = 0, v3 - 1 do
				result[i + 1] = {
					x = p / 2,
					y = i * 60 - 60,
					width = width,
					height = 60
				}
			end

			return result
		end
	},
	CHECKERBOARD = {
		scaleUniform = true,
		spread = 0.6,
		randomThreshold = false,
		cells = function(p, p2)
			return (rectGrid(p, p2, 80, 80, false, true, 160))
		end
	},
	RANDOM_TILES = {
		scaleUniform = true,
		spread = 0.85,
		randomThreshold = true,
		cells = function(p, p2)
			return (rectGrid(p, p2, 80, 80))
		end
	}
}
local class2 = {}
class2.__index = class2

function class2.new()
	return (setmetatable({
		_frame = nil
	}, class2))
end

function class2:Build(parent, _: number, _: number, backgroundColor: Color3)
	local frame = Instance.new("Frame")
	frame.Name = "Fade"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = backgroundColor
	frame.BackgroundTransparency = 1
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = parent
	self._frame = frame
end

function class2:Prepare(_: string) end

function class2:Update(p2: number, p3: string)
	if p3 ~= "In" then
		p2 = 1 - p2
	end

	self._frame.BackgroundTransparency = 1 - p2
	self._frame.Visible = p2 > 0.01
end

function class2:Show()
	self._frame.BackgroundTransparency = 0
	self._frame.Visible = true
end

function class2:Hide()
	self._frame.BackgroundTransparency = 1
	self._frame.Visible = false
end

function class2:Destroy()
	self._frame:Destroy()
end

local class3 = {}
class3.__index = class3

function class3.new(mode: string)
	return (setmetatable({
		_mode = mode,
		_element = nil,
		_maxSize = 0,
		_originX = 0,
		_originY = 0,
		_screenWidth = 0,
		_screenHeight = 0
	}, class3))
end

function class3:Build(parent, screenWidth: number, screenHeight: number, color2: Color3)
	self._screenWidth = screenWidth
	self._screenHeight = screenHeight
	local maxSize = math.sqrt(screenWidth * screenWidth + screenHeight * screenHeight)

	if self._mode == "box" then
		self._maxSize = math.max(screenWidth, screenHeight)
		local frame = Instance.new("Frame")
		frame.BackgroundColor3 = color2
		frame.BorderSizePixel = 0
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Visible = false
		frame.Parent = parent
		self._element = frame
	elseif self._mode == "diamond" then
		self._maxSize = maxSize
		local frame = Instance.new("Frame")
		frame.BackgroundColor3 = color2
		frame.BorderSizePixel = 0
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.Rotation = 45
		frame.Visible = false
		frame.Parent = parent
		self._element = frame
	else
		self._maxSize = maxSize
		local imageLabel = Instance.new("ImageLabel")
		imageLabel.Image = imagesByName.Circle or ""
		imageLabel.ImageColor3 = color2
		imageLabel.BackgroundTransparency = 1
		imageLabel.ScaleType = Enum.ScaleType.Stretch
		imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		imageLabel.Visible = false
		imageLabel.Parent = parent
		self._element = imageLabel
	end
end

function class3:Prepare(p: string)
	if p == "Center" then
		self._originX = self._screenWidth / 2
		self._originY = self._screenHeight / 2
	elseif p == "TopLeft" then
		self._originX = 0
		self._originY = 0
	else
		self._originX = self._screenWidth
		self._originY = self._screenHeight
	end

	self._element.Position = UDim2.fromOffset(self._originX, self._originY)
end

function class3:Update(p: number, p2: string)
	if p2 ~= "In" then
		p = 1 - p
	end

	if self._mode == "box" then
		self._element.Size = UDim2.fromOffset(math.floor(self._screenWidth * p), (math.floor(self._screenHeight * p)))
	else
		local v2 = math.floor(self._maxSize * p)
		self._element.Size = UDim2.fromOffset(v2, v2)
	end

	self._element.Visible = p > 0.01
end

function class3:Show()
	if self._mode == "box" then
		self._element.Size = UDim2.fromOffset(self._screenWidth, self._screenHeight)
	else
		self._element.Size = UDim2.fromOffset(self._maxSize, self._maxSize)
	end

	self._element.Visible = true
end

function class3:Hide()
	self._element.Visible = false
end

function class3:Destroy()
	self._element:Destroy()
end

local class4 = {}
class4.__index = class4

function class4.new()
	return (setmetatable({
		_frame = nil,
		_screenWidth = 0,
		_wipeFromLeft = true
	}, class4))
end

function class4:Build(parent, screenWidth: number, _: number, backgroundColor: Color3)
	self._screenWidth = screenWidth
	local frame = Instance.new("Frame")
	frame.Name = "LinearWipe"
	frame.Size = UDim2.fromScale(1, 1)
	frame.BackgroundColor3 = backgroundColor
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0, 0)
	frame.Visible = false
	frame.Parent = parent
	self._frame = frame
end

function class4:Prepare(p2: string)
	self._wipeFromLeft = p2 ~= "BottomRight"
end

function class4:Update(p: number, p2: string)
	if p2 ~= "In" then
		p = 1 - p
	end

	local v2

	if self._wipeFromLeft then
		v2 = math.floor(-self._screenWidth * (1 - p))
	else
		v2 = math.floor(self._screenWidth * (1 - p))
	end

	self._frame.Position = UDim2.fromOffset(v2, 0)
	self._frame.Visible = p > 0.01
end

function class4:Show()
	self._frame.Position = UDim2.fromOffset(0, 0)
	self._frame.Visible = true
end

function class4:Hide()
	self._frame.Visible = false
end

function class4:Destroy()
	self._frame:Destroy()
end

local class5 = {}
class5.__index = class5

function class5.new()
	return (setmetatable({
		_left = nil,
		_right = nil,
		_screenWidth = 0,
		_screenHeight = 0
	}, class5))
end

function class5:Build(parent, screenWidth: number, screenHeight: number, backgroundColor: Color3)
	self._screenWidth = screenWidth
	self._screenHeight = screenHeight
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = backgroundColor
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(1, 0)
	frame.Size = UDim2.fromOffset(0, screenHeight)
	frame.Visible = false
	frame.Parent = parent
	self._left = frame
	local frame2 = Instance.new("Frame")
	frame2.BackgroundColor3 = backgroundColor
	frame2.BorderSizePixel = 0
	frame2.AnchorPoint = Vector2.new(0, 0)
	frame2.Size = UDim2.fromOffset(0, screenHeight)
	frame2.Visible = false
	frame2.Parent = parent
	self._right = frame2
end

function class5:Prepare(_: string)
	local v2 = math.floor(self._screenWidth / 2)
	self._left.Position = UDim2.fromOffset(v2, 0)
	self._right.Position = UDim2.fromOffset(v2, 0)
end

function class5:Update(p: number, p2: string)
	if p2 ~= "In" then
		p = 1 - p
	end

	local v2 = math.floor((math.ceil(self._screenWidth / 2) + 2) * p)
	self._left.Size = UDim2.fromOffset(v2, self._screenHeight)
	self._right.Size = UDim2.fromOffset(v2, self._screenHeight)
	local visible = p > 0.01
	self._left.Visible = visible
	self._right.Visible = visible
end

function class5:Show()
	local v2 = math.ceil(self._screenWidth / 2) + 2
	self._left.Size = UDim2.fromOffset(v2, self._screenHeight)
	self._right.Size = UDim2.fromOffset(v2, self._screenHeight)
	self._left.Visible = true
	self._right.Visible = true
end

function class5:Hide()
	self._left.Visible = false
	self._right.Visible = false
end

function class5:Destroy()
	self._left:Destroy()
	self._right:Destroy()
end

local class6 = {}
class6.__index = class6

function class6.new()
	return (setmetatable({
		_horizontal = nil,
		_vertical = nil,
		_screenWidth = 0,
		_screenHeight = 0
	}, class6))
end

function class6:Build(parent, screenWidth: number, screenHeight: number, backgroundColor: Color3)
	self._screenWidth = screenWidth
	self._screenHeight = screenHeight
	local frame = Instance.new("Frame")
	frame.BackgroundColor3 = backgroundColor
	frame.BorderSizePixel = 0
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.Position = UDim2.fromOffset(screenWidth / 2, screenHeight / 2)
	frame.Visible = false
	frame.Parent = parent
	self._horizontal = frame
	local frame2 = Instance.new("Frame")
	frame2.BackgroundColor3 = backgroundColor
	frame2.BorderSizePixel = 0
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.Position = UDim2.fromOffset(screenWidth / 2, screenHeight / 2)
	frame2.Visible = false
	frame2.Parent = parent
	self._vertical = frame2
end

function class6:Prepare(_: string) end

function class6:Update(p: number, p2: string)
	if p2 ~= "In" then
		p = 1 - p
	end

	local v2 = math.floor(self._screenWidth * p)
	local v3 = math.floor(self._screenHeight * p)
	self._horizontal.Size = UDim2.fromOffset(self._screenWidth + 4, v3)
	self._vertical.Size = UDim2.fromOffset(v2, self._screenHeight + 4)
	local visible = p > 0.01
	self._horizontal.Visible = visible
	self._vertical.Visible = visible
end

function class6:Show()
	self._horizontal.Size = UDim2.fromOffset(self._screenWidth + 4, self._screenHeight)
	self._vertical.Size = UDim2.fromOffset(self._screenWidth, self._screenHeight + 4)
	self._horizontal.Visible = true
	self._vertical.Visible = true
end

function class6:Hide()
	self._horizontal.Visible = false
	self._vertical.Visible = false
end

function class6:Destroy()
	self._horizontal:Destroy()
	self._vertical:Destroy()
end

local v2 = {
	Fade = function()
		return class2.new()
	end,
	Iris = function()
		return class3.new("iris")
	end,
	Diamond = function()
		return class3.new("diamond")
	end,
	Box = function()
		return class3.new("box")
	end,
	LinearWipe = function()
		return class4.new()
	end,
	Split = function()
		return class5.new()
	end,
	CrossWipe = function()
		return class6.new()
	end,
	Hexagon = function()
		return class.new(v.HEXAGON)
	end,
	Triangle = function()
		return class.new(v.TRIANGLE)
	end,
	Tiles = function()
		return class.new(v.TILES)
	end,
	PolkaDots = function()
		return class.new(v.POLKA_DOTS)
	end,
	Blinds = function()
		return class.new(v.BLINDS)
	end,
	Checkerboard = function()
		return class.new(v.CHECKERBOARD)
	end,
	RandomTiles = function()
		return class.new(v.RANDOM_TILES)
	end
}
local frozen = table.freeze({
	Fade = "Fade",
	Iris = "Iris",
	Diamond = "Diamond",
	Box = "Box",
	LinearWipe = "LinearWipe",
	Split = "Split",
	CrossWipe = "CrossWipe",
	Hexagon = "Hexagon",
	Triangle = "Triangle",
	Tiles = "Tiles",
	PolkaDots = "PolkaDots",
	Blinds = "Blinds",
	Checkerboard = "Checkerboard",
	RandomTiles = "RandomTiles"
})
local frozen2 = table.freeze({
	In = "In",
	Out = "Out"
})
local frozen3 = table.freeze({
	Center = "Center",
	TopLeft = "TopLeft",
	BottomRight = "BottomRight"
})
local count = 0
local class7 = {}
class7.__index = class7

function class7.new(parent, p)
	count += 1
	local object = setmetatable({
		_color = p and p.color or color,
		_gui = nil,
		_effects = {},
		_activeEffect = nil,
		_playing = false,
		_destroyed = false,
		_elapsed = 0,
		_duration = 0,
		_direction = "In",
		_renderStepName = "coolTransitions_render" .. "_" .. tostring(count)
	}, class7)
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "TransitionOverlay"
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = p and p.displayOrder or 99
	screenGui.Enabled = false
	screenGui.ResetOnSpawn = false
	screenGui.Parent = parent
	object._gui = screenGui
	RunService:BindToRenderStep(object._renderStepName, Enum.RenderPriority.Camera.Value + 1, function(p2)
		object:_onRender(p2)
	end)
	return object
end

function class7:IsPlaying()
	return self._playing
end

function class7:Play(direction: string, duration: number, value: string?, value2: string?)
	if self._destroyed then
		error("TransitionManager has been destroyed")
	end

	if self._playing then
		self._playing = false

		if self._activeEffect then
			self._activeEffect:Hide()
		end
	end

	local _getOrCreateEffect = self:_getOrCreateEffect(value2 or "Hexagon")
	self._activeEffect = _getOrCreateEffect
	self._gui.Enabled = true
	_getOrCreateEffect:Prepare(value or "Center")
	self._elapsed = 0
	self._duration = duration
	self._direction = direction
	self._playing = true

	repeat
		task.wait()
	until not self._playing
end

function class7:PlayInOut(p: number, callback, value: string?, value2: string?, duration: number?)
	local v3 = value or "Center"
	local v4 = value2 or "Hexagon"
	self:Play("In", p / 2, v3, v4)

	if callback then
		callback()
	end

	if duration and duration > 0 then
		task.wait(duration)
	end

	self:Play("Out", p / 2, v3, v4)
end

function class7:Destroy()
	if self._destroyed then
		return
	end

	self._destroyed = true
	RunService:UnbindFromRenderStep(self._renderStepName)

	for _, _effect in self._effects do
		_effect:Destroy()
	end

	self._effects = {}
	self._gui:Destroy()
end

function class7:_onRender(p: number)
	if not (self._playing and self._activeEffect) then
		return
	end

	self._elapsed += p
	local v3 = math.clamp(self._elapsed / self._duration, 0, 1)
	local v4 = easeInOutSine(v3) -- equivalent call inferred; original call site unknown
	self._activeEffect:Update(v4, self._direction)

	if v3 < 1 then
		return
	end

	self._playing = false

	if self._direction == "Out" then
		self._activeEffect:Hide()
		self._gui.Enabled = false
	end
end

function class7:_getScreenSize()
	local enabled = self._gui.Enabled

	if not enabled then
		self._gui.Enabled = true
		task.wait()
	end

	local X = self._gui.AbsoluteSize.X
	local Y = self._gui.AbsoluteSize.Y

	if not enabled then
		self._gui.Enabled = false
	end

	if X <= 0 or Y <= 0 then
		return 1920, 1080
	end

	return X, Y
end

function class7:_getOrCreateEffect(p: string)
	local _effect = self._effects[p]

	if _effect then
		return _effect
	end

	local v3 = v2[p]

	if not v3 then
		error("Unknown transition type: " .. p)
	end

	local v4 = v3()
	local _getScreenSize, v5 = self:_getScreenSize()
	v4:Build(self._gui, _getScreenSize, v5, self._color)
	self._effects[p] = v4
	return v4
end

return table.freeze({
	TransitionManager = class7,
	TransitionType = frozen,
	TransitionDirection = frozen2,
	TransitionWaveOrigin = frozen3
})