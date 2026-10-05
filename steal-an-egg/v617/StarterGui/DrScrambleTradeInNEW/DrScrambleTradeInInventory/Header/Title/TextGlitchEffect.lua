local parent = script.Parent
assert(parent:IsA("TextLabel"), "Put this LocalScript inside the TextLabel")
local random = Random.new()
local v = {
	BurstIntervalMin = 1.4,
	BurstIntervalMax = 4,
	BurstDurationMin = 0.14,
	BurstDurationMax = 0.4,
	TickRate = 0.03,
	JitterX = 4,
	JitterY = 3,
	RotationJitter = 2,
	TearEnabled = true,
	TearHeightMin = 0.38,
	TearHeightMax = 0.62,
	TearSlideMin = 3,
	TearSlideMax = 12,
	TearGapMax = 5,
	SeamEnabled = true,
	SeamThickness = 2,
	SeamGlowThickness = 10,
	GhostEnabled = true,
	GhostOffset = 3,
	GhostColorA = Color3.fromRGB(240, 183, 255),
	GhostColorB = Color3.fromRGB(191, 200, 255),
	GhostTransparency = 0.3,
	ScrambleChance = 0.6,
	MaxScrambledChars = 2,
	GlitchChars = {
		"◢",
		"◣",
		"◤",
		"◥",
		"▲",
		"▼",
		"◆",
		"▓",
		"▒",
		"░",
		"/",
		"\\",
		"X",
		"#",
		"%"
	},
	ShardsEnabled = true,
	ShardCount = 7,
	ShardSizeMin = 3,
	ShardSizeMax = 9,
	ShardSpread = 34,
	ShardRise = 22,
	FlickerChance = 0.1,
	StrokeFlashChance = 0.5,
	StrokeFlashColors = { Color3.fromRGB(217, 166, 255), Color3.fromRGB(168, 85, 247), Color3.fromRGB(255, 242, 255) },
	GradientSlide = true
}
local v2 = {
	core = Color3.fromRGB(255, 242, 255),
	lilac = Color3.fromRGB(217, 166, 255),
	bright = Color3.fromRGB(168, 85, 247),
	mid = Color3.fromRGB(106, 33, 214)
}
local parent2 = parent.Parent
local text = parent.Text
local position = parent.Position
local rotation = parent.Rotation
local textTransparency = parent.TextTransparency
local uIStroke = parent:FindFirstChildOfClass("UIStroke")
local color = uIStroke and uIStroke.Color
local uIGradient = parent:FindFirstChildOfClass("UIGradient")
local offset = uIGradient and uIGradient.Offset
parent.ZIndex = math.max(parent.ZIndex, 3)

local function bareClone(name: string)
	local clone = parent:Clone()
	clone:ClearAllChildren()
	clone.Name = name
	clone.BackgroundTransparency = 1

	if uIStroke then
		local clone_2 = uIStroke:Clone()
		clone_2.Parent = clone
	end

	return clone
end

local frame, clone, clone2, clone3

if v.TearEnabled then
	frame = Instance.new("Frame")
	frame.Name = "RiftTearTop"
	frame.BackgroundTransparency = 1
	frame.ClipsDescendants = true
	frame.AnchorPoint = parent.AnchorPoint
	frame.ZIndex = parent.ZIndex
	frame.Visible = false
	frame.Parent = parent2
	clone = frame:Clone()
	clone.Name = "RiftTearBottom"
	clone.Parent = parent2
	clone2 = parent:Clone()
	clone2:ClearAllChildren()
	clone2.Name = "RiftTearTopText"
	clone2.BackgroundTransparency = 1

	if uIStroke then
		local clone_2 = uIStroke:Clone()
		clone_2.Parent = clone2
	end

	clone2.AnchorPoint = Vector2.new(0, 0)
	clone2.Position = UDim2.fromScale(0, 0)
	clone2.ZIndex = parent.ZIndex
	clone2.Parent = frame
	clone3 = parent:Clone()
	clone3:ClearAllChildren()
	clone3.Name = "RiftTearBottomText"
	clone3.BackgroundTransparency = 1

	if uIStroke then
		local clone_3 = uIStroke:Clone()
		clone_3.Parent = clone3
	end

	clone3.AnchorPoint = Vector2.new(0, 0)
	clone3.ZIndex = parent.ZIndex
	clone3.Parent = clone
else
	frame = nil
	clone = nil
	clone2 = nil
	clone3 = nil
end

local frame2, clone4

if v.SeamEnabled then
	frame2 = Instance.new("Frame")
	frame2.Name = "RiftSeamGlow"
	frame2.BorderSizePixel = 0
	frame2.BackgroundColor3 = v2.bright
	frame2.BackgroundTransparency = 0.72
	frame2.AnchorPoint = Vector2.new(0.5, 0.5)
	frame2.ZIndex = parent.ZIndex + 1
	frame2.Visible = false
	frame2.Parent = parent2
	local uIGradient2 = Instance.new("UIGradient")
	uIGradient2.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	uIGradient2.Parent = frame2
	clone4 = frame2:Clone()
	clone4.Name = "RiftSeamCore"
	clone4.BackgroundColor3 = v2.core
	clone4.BackgroundTransparency = 0.05
	clone4.ZIndex = parent.ZIndex + 2
	clone4.Parent = parent2
else
	frame2 = nil
	clone4 = nil
end

local clones = {}

if v.GhostEnabled then
	for _, textColor in { v.GhostColorA, v.GhostColorB } do
		local clone5 = parent:Clone()
		clone5:ClearAllChildren()
		clone5.Name = "RiftGhost"
		clone5.TextColor3 = textColor
		clone5.TextTransparency = 1
		clone5.BackgroundTransparency = 1
		clone5.ZIndex = parent.ZIndex - 1
		clone5.Parent = parent2
		table.insert(clones, clone5)
	end
end

local v3 = {}

if v.ShardsEnabled then
	for i = 1, v.ShardCount do
		local frame3 = Instance.new("Frame")
		frame3.Name = "RiftShard"
		frame3.BorderSizePixel = 0
		frame3.BackgroundColor3 = i % 2 == 0 and v2.lilac or v2.core
		frame3.BackgroundTransparency = 1
		frame3.AnchorPoint = Vector2.new(0.5, 0.5)
		frame3.ZIndex = parent.ZIndex + 2
		frame3.Parent = parent2
		local uICorner = Instance.new("UICorner")
		uICorner.CornerRadius = UDim.new(0, 1)
		uICorner.Parent = frame3
		table.insert(v3, frame3)
	end
end

local function scrambleText()
	local v4 = {}

	for i = 1, #text do
		v4[i] = string.sub(text, i, i)
	end

	for _ = 1, random:NextInteger(1, v.MaxScrambledChars) do
		local integer = random:NextInteger(1, #v4)

		if v4[integer] ~= " " then
			v4[integer] = v.GlitchChars[random:NextInteger(1, #v.GlitchChars)]
		end
	end

	return table.concat(v4)
end

local function setGhosts(flag: boolean, integer: number, integer2: number)
	for k, v4 in clones do
		if flag then
			local v5 = k == 1 and 1 or -1
			v4.Text = parent.Text
			v4.Rotation = parent.Rotation
			v4.TextTransparency = v.GhostTransparency
			v4.Position = position + UDim2.fromOffset(
				integer + v5 * v.GhostOffset,
				integer2 + v5 * math.ceil(v.GhostOffset / 2)
			)
		else
			v4.TextTransparency = 1
		end
	end
end

local function setTear(flag: boolean, number: number, integer: number, integer2: number, text2: string, rotation2: number)
	if not v.TearEnabled then
		return
	end

	if flag then
		local size = parent.Size
		local position2 = position
		frame.Size = UDim2.new(size.X.Scale, size.X.Offset, size.Y.Scale * number, size.Y.Offset * number)
		frame.Position = position2 + UDim2.fromOffset(integer, -integer2)
		frame.Rotation = rotation2
		clone2.Size = UDim2.fromScale(1, 1 / number)
		clone2.Text = text2
		local v5 = 1 - number
		clone.Size = UDim2.new(size.X.Scale, size.X.Offset, size.Y.Scale * v5, size.Y.Offset * v5)
		clone.Position = position2 + UDim2.fromOffset(-integer, integer2) + UDim2.new(
			0,
			0,
			size.Y.Scale * number,
			size.Y.Offset * number
		)
		clone.Rotation = rotation2
		clone3.Size = UDim2.fromScale(1, 1 / v5)
		clone3.Position = UDim2.fromScale(0, -number / v5)
		clone3.Text = text2
		frame.Visible = true
		clone.Visible = true
	else
		frame.Visible = false
		clone.Visible = false
	end
end

local function setSeam(flag: boolean, number: number, p: number)
	if not v.SeamEnabled then
		return
	end

	if flag then
		local size = parent.Size
		local position2 = position + UDim2.new(
			size.X.Scale * 0.5,
			size.X.Offset * 0.5,
			size.Y.Scale * number,
			size.Y.Offset * number
		)
		frame2.Position = position2
		frame2.Size = UDim2.new(size.X.Scale * 1.1, size.X.Offset * 1.1, 0, v.SeamGlowThickness)
		frame2.BackgroundTransparency = (1 - p) * 0.25 + 0.6
		frame2.BackgroundColor3 = p > 0.5 and v2.lilac or v2.bright
		frame2.Visible = true
		clone4.Position = position2
		clone4.Size = UDim2.new(size.X.Scale * (p * 0.3 + 0.75), size.X.Offset, 0, v.SeamThickness)
		clone4.BackgroundTransparency = 0.05
		clone4.Visible = true
	else
		frame2.Visible = false
		clone4.Visible = false
	end
end

local function setShards(flag: boolean, number: number, value: number)
	if not v.ShardsEnabled then
		return
	end

	for k, v4 in v3 do
		if flag then
			local v5 = k * 7919 % 97 / 97
			local v6 = k % 2 == 0 and 1 or -1
			local size = parent.Size
			local integer = random:NextInteger(v.ShardSizeMin, v.ShardSizeMax)
			v4.Size = UDim2.fromOffset(integer, integer)
			v4.Rotation = v5 * 360 + value * 180 * v6
			v4.Position = position + UDim2.new(
				size.X.Scale * 0.5,
				size.X.Offset * 0.5,
				size.Y.Scale * number,
				size.Y.Offset * number
			) + UDim2.fromOffset((v5 - 0.5) * 2 * v.ShardSpread * value, v6 * v.ShardRise * value * (0.4 + v5 * 0.6))
			v4.BackgroundTransparency = math.clamp(value, 0, 1)
		else
			v4.BackgroundTransparency = 1
		end
	end
end

local function restore()
	parent.Text = text
	parent.Position = position
	parent.Rotation = rotation
	parent.TextTransparency = textTransparency

	if uIStroke then
		uIStroke.Color = color
	end

	if uIGradient then
		uIGradient.Offset = offset
	end

	for _, v4 in clones do
		v4.TextTransparency = 1
	end

	if v.TearEnabled then
		frame.Visible = false
		clone.Visible = false
	end

	if v.SeamEnabled then
		frame2.Visible = false
		clone4.Visible = false
	end

	if not v.ShardsEnabled then
		return
	end

	for _, v4 in v3 do
		v4.BackgroundTransparency = 1
	end
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local v4 = require(ReplicatedStorage.Client.UIEffects.GuiVisibility).Watch(parent, function(p)
	if not p then
		restore()
	end
end, script)

local function doBurst()
	local number = random:NextNumber(v.BurstDurationMin, v.BurstDurationMax)
	local number2 = random:NextNumber(v.TearHeightMin, v.TearHeightMax)
	local total = 0

	while total < number do
		if not v4.IsVisible() then
			return
		end

		local v5 = math.clamp(total / number, 0, 1)
		local integer = random:NextInteger(-v.JitterX, v.JitterX)
		local integer2 = random:NextInteger(-v.JitterY, v.JitterY)
		local rotation2 = rotation + random:NextNumber(-v.RotationJitter, v.RotationJitter)
		local text2 = random:NextNumber() < v.ScrambleChance and scrambleText() or text
		parent.Position = position + UDim2.fromOffset(integer, integer2)
		parent.Rotation = rotation2
		parent.Text = text2
		parent.TextTransparency = random:NextNumber() < v.FlickerChance and 1 or textTransparency

		if v.TearEnabled then
			local integer3 = random:NextInteger(v.TearSlideMin, v.TearSlideMax)
			local integer4 = random:NextInteger(0, v.TearGapMax)
			parent.TextTransparency = 1
			setTear(true, number2, integer3, integer4, text2, rotation2)
			setSeam(true, number2, random:NextNumber())
		end

		if uIStroke then
			if random:NextNumber() < v.StrokeFlashChance then
				uIStroke.Color = v.StrokeFlashColors[random:NextInteger(1, #v.StrokeFlashColors)]
			else
				uIStroke.Color = color
			end
		end

		if uIGradient and v.GradientSlide then
			uIGradient.Offset = Vector2.new(random:NextNumber(-0.5, 0.5), 0)
		end

		setGhosts(true, integer, integer2)
		setShards(true, number2, v5)
		total += task.wait(v.TickRate)
	end

	restore()
end

task.spawn(function()
	while parent.Parent and v4.WaitUntilVisible() do
		task.wait(random:NextNumber(v.BurstIntervalMin, v.BurstIntervalMax))

		if v4.IsVisible() then
			doBurst()
		end
	end

	v4.Destroy()
end)