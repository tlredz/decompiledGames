local parent = script.Parent
require(parent.Types)
local random = Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function resolveNumber(value)
	if typeof(value) == "NumberSequence" then
		return value.Keypoints[1].Value
	end

	if typeof(value) == "NumberRange" then
		return random:NextNumber(value.Min, value.Max)
	end

	if typeof(value) == "number" then
		return value
	end

	return 0
end

local function resolveColor(sequence)
	if typeof(sequence) == "ColorSequence" then
		return sequence.Keypoints[1].Value
	end

	if typeof(sequence) == "Color3" then
		return sequence
	end

	return Color3.new()
end

local function evalColorSequence(color, p: number)
	if p <= 0 then
		return color.Keypoints[1].Value
	end

	if p >= 1 then
		return color.Keypoints[#color.Keypoints].Value
	end

	for i = 1, #color.Keypoints - 1 do
		local keypoint = color.Keypoints[i]
		local keypoint2 = color.Keypoints[i + 1]

		if not (keypoint.Time <= p and p < keypoint2.Time) then
			continue
		end

		local v = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		return Color3.new(
			(keypoint2.Value.R - keypoint.Value.R) * v + keypoint.Value.R,
			(keypoint2.Value.G - keypoint.Value.G) * v + keypoint.Value.G,
			(keypoint2.Value.B - keypoint.Value.B) * v + keypoint.Value.B
		)
	end

	return color.Keypoints[#color.Keypoints].Value
end

local function evalNumberSequence(sequence, p: number)
	if p <= 0 then
		return sequence.Keypoints[1].Value
	end

	if p >= 1 then
		return sequence.Keypoints[#sequence.Keypoints].Value
	end

	for i = 1, #sequence.Keypoints - 1 do
		local keypoint = sequence.Keypoints[i]
		local keypoint2 = sequence.Keypoints[i + 1]

		if not (keypoint.Time <= p and p < keypoint2.Time) then
			continue
		end

		local v = (p - keypoint.Time) / (keypoint2.Time - keypoint.Time)
		return keypoint.Value + (keypoint2.Value - keypoint.Value) * v
	end

	return sequence.Keypoints[#sequence.Keypoints].Value
end

local function mapNumberSequence(sequence)
	local v = {}

	for _, keypoint in ipairs(sequence.Keypoints) do
		if keypoint.Envelope > 0 then
			local number = random:NextNumber(-keypoint.Envelope, keypoint.Envelope)
			table.insert(v, (NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value + number)))
		else
			table.insert(v, keypoint)
		end
	end

	return NumberSequence.new(v)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function evalDirection(emissionDirection)
	if emissionDirection == "Top" then
		return -Vector2.yAxis
	elseif emissionDirection == "Bottom" then
		return Vector2.yAxis
	elseif emissionDirection == "Left" then
		return -Vector2.xAxis
	elseif emissionDirection == "Right" then
		return Vector2.xAxis
	end

	return Vector2.zero
end

local function evalFlipbookDimension(data)
	local flipbookLayout = data.FlipbookLayout

	if flipbookLayout == Enum.ParticleFlipbookLayout.Grid2x2 then
		return Vector2.new(2, 2)
	end

	if flipbookLayout == Enum.ParticleFlipbookLayout.Grid4x4 then
		return Vector2.new(4, 4)
	end

	if flipbookLayout == Enum.ParticleFlipbookLayout.Grid8x8 then
		return Vector2.new(8, 8)
	end

	if flipbookLayout == Enum.ParticleFlipbookLayout.Custom then
		return Vector2.new(data.FlipbookSizeX, data.FlipbookSizeY)
	end

	return Vector2.new(1, 1)
end

local function getTotalUIScale(parent2)
	local v = 1

	while parent2.Parent and not parent2:IsA("ScreenGui") do
		local uIScale = parent2.Parent:FindFirstChildOfClass("UIScale")

		if uIScale then
			v *= uIScale.Scale
		end

		parent2 = parent2.Parent
	end

	return v
end

local function setupParticle(state)
	local _particleEmitter = state._particleEmitter

	if typeof(state.Size) == "NumberSequence" then
		state.Size = mapNumberSequence(_particleEmitter.Size)
	end

	if typeof(state.Transparency) == "NumberSequence" then
		state.Transparency = mapNumberSequence(_particleEmitter.Transparency)
	end

	local parent2 = _particleEmitter.Parent
	local number = resolveNumber(state.Size) -- equivalent call inferred; original call site unknown
	local color = state.Color

	if typeof(color) == "ColorSequence" then
		color = color.Keypoints[1].Value
	elseif typeof(color) ~= "Color3" then
		color = Color3.new()
	end

	local number2 = resolveNumber(state.Transparency) -- equivalent call inferred; original call site unknown
	local v = not parent2.Parent and 1 or getTotalUIScale(parent2.Parent)
	local uDim = UDim2.fromOffset(
		random:NextNumber(0, parent2.AbsoluteSize.X / v),
		random:NextNumber(0, parent2.AbsoluteSize.Y / v)
	)
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Particle"
	imageLabel.AnchorPoint = Vector2.one / 2
	imageLabel.BackgroundTransparency = 1
	imageLabel.Position = uDim
	imageLabel.Rotation = state.Rotation
	imageLabel.Size = UDim2.fromOffset(number, number)
	imageLabel.ZIndex = state.ZOffset
	imageLabel.Image = state.Texture
	imageLabel.ImageTransparency = number2
	imageLabel.ImageColor3 = color
	imageLabel.ScaleType = Enum.ScaleType.Fit
	imageLabel.Parent = _particleEmitter.Parent

	if state.FlipbookLayout ~= Enum.ParticleFlipbookLayout.None then
		imageLabel.ScaleType = Enum.ScaleType.Stretch
		imageLabel.Image = `http://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId={state.Texture:match("%d+")}`
		imageLabel.ImageRectSize = Vector2.new(420, 420) / evalFlipbookDimension(state)
	end

	local uIAspectRatioConstraint = Instance.new("UIAspectRatioConstraint")
	uIAspectRatioConstraint.Name = "Ratio"
	uIAspectRatioConstraint.AspectRatio = state.AspectRatio
	uIAspectRatioConstraint.Parent = imageLabel
	state._position = Vector2.new(uDim.X.Offset, uDim.Y.Offset)
	state._label = imageLabel
end

local function updatePosition(state, p: number)
	local v = evalDirection(state.EmissionDirection) -- equivalent call inferred; original call site unknown
	local spreadAngle = math.rad(state.SpreadAngle)
	local vector = Vector2.new(
		v.X * math.cos(spreadAngle) - v.Y * math.sin(spreadAngle),
		v.X * math.sin(spreadAngle) + v.Y * math.cos(spreadAngle)
	)
	state._currentAcceleration += state.Acceleration * p

	if state.Drag > 0 then
		local v2 = 0.5 ^ (p / (1 / state.Drag))
		state._currentSpeed *= v2
	end

	state._position += vector * state._currentSpeed * p + state._currentAcceleration * p
end

local function updateVisual(state, p: number)
	local v = math.min(1, state._elapsed / state.Lifetime)
	local transparency = state.Transparency
	local color = state.Color
	local size = state.Size

	if typeof(state.Color) == "ColorSequence" then
		color = evalColorSequence(state.Color, v)
	end

	if typeof(state.Size) == "NumberSequence" then
		size = evalNumberSequence(state.Size, v)
	end

	if typeof(state.Transparency) == "NumberSequence" then
		transparency = evalNumberSequence(state.Transparency, v)
	end

	if state.FlipbookLayout ~= Enum.ParticleFlipbookLayout.None then
		local v2 = evalFlipbookDimension(state)
		local v3 = v2.X * v2.Y
		local v4 = os.clock() - state._lastFlipbookUpdate > 1 / state.FlipbookFramerate

		if state.FlipbookMode == Enum.ParticleFlipbookMode.Loop then
			if v4 then
				state._lastFlipbookUpdate = os.clock()
				state._flipbookIndex = 1 + state._flipbookIndex % v3
			end
		elseif state.FlipbookMode == Enum.ParticleFlipbookMode.Random then
			if v4 then
				state._lastFlipbookUpdate = os.clock()
				state._flipbookIndex = random:NextInteger(1, v3)
			end
		elseif state.FlipbookMode == Enum.ParticleFlipbookMode.OneShot then
			state._flipbookIndex = math.round(state._elapsed / state.Lifetime * v3)
		end

		local v5 = math.floor(state._flipbookIndex / v2.Y)
		local v6 = state._flipbookIndex - v5 * v2.Y
		state._label.ImageRectOffset = Vector2.new(v6, v5) * state._label.ImageRectSize
	end

	state._label.Size = UDim2.fromOffset(size, size)
	state._label.Position = UDim2.fromOffset(state._position.X, state._position.Y)
	state._label.ImageTransparency = transparency
	state._label.ImageColor3 = color
	state._label.Rotation += state.RotSpeed * p
end

local Particle = {}
local class = {}
class.__index = class

function Particle.new(particleEmitter)
	local v = {}
	setmetatable(v, class)
	v.Color = particleEmitter.Color
	v.Size = particleEmitter.Size
	v.Texture = particleEmitter.Texture
	v.Transparency = particleEmitter.Transparency
	local number = resolveNumber(particleEmitter.ZOffset) -- equivalent call inferred; original call site unknown
	v.ZOffset = number
	v.EmissionDirection = particleEmitter.EmissionDirection
	local number2 = resolveNumber(particleEmitter.Lifetime) -- equivalent call inferred; original call site unknown
	v.Lifetime = number2
	local number3 = resolveNumber(particleEmitter.Rotation) -- equivalent call inferred; original call site unknown
	v.Rotation = number3
	local number4 = resolveNumber(particleEmitter.RotSpeed) -- equivalent call inferred; original call site unknown
	v.RotSpeed = number4
	local number5 = resolveNumber(particleEmitter.Speed) -- equivalent call inferred; original call site unknown
	v.Speed = number5
	v.SpreadAngle = random:NextNumber(-particleEmitter.SpreadAngle, particleEmitter.SpreadAngle)
	v.Shape = particleEmitter.Shape
	v.ShapeInOut = particleEmitter.ShapeInOut
	v.ShapeStyle = particleEmitter.ShapeStyle
	v.FlipbookLayout = particleEmitter.FlipbookLayout
	v.FlipbookMode = particleEmitter.FlipbookMode
	v.FlipbookFramerate = random:NextInteger(
		particleEmitter.FlipbookFramerate.Min,
		particleEmitter.FlipbookFramerate.Max
	)
	v.FlipbookSizeX = particleEmitter.FlipbookSizeX
	v.FlipbookSizeY = particleEmitter.FlipbookSizeY
	v.FlipbookStartRandom = particleEmitter.FlipbookStartRandom
	v.FlipbookBlendFrames = particleEmitter.FlipbookBlendFrames
	v.Acceleration = particleEmitter.Acceleration
	v.AspectRatio = particleEmitter.AspectRatio
	v.TimeScale = particleEmitter.TimeScale
	v.Drag = particleEmitter.Drag
	v._currentAcceleration = Vector2.zero
	v._particleEmitter = particleEmitter
	v._currentSpeed = v.Speed
	v._position = nil
	v._elapsed = 0
	v._lastFlipbookUpdate = os.clock()
	v._flipbookIndex = 1
	v._label = nil
	setupParticle(v)
	return v
end

function class:Update(p: number)
	local v = p * self.TimeScale
	self._elapsed += v
	updatePosition(self, v)
	updateVisual(self, v)
end

function class:Destroy()
	self._label:Destroy()
	table.clear(self)
	setmetatable(self, nil)
end

return Particle