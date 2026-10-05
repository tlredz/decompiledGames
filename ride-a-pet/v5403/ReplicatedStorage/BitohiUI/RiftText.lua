local Ticker = require(script.Parent:WaitForChild("Ticker"))
local Store = require(script.Parent:WaitForChild("Store"))
local RiftText = {}
local defaults = {
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
	GhostTransparency = 0.3,
	ScrambleChance = 0.6,
	MaxScrambledChars = 2,
	ShardsEnabled = true,
	ShardCount = 7,
	ShardSizeMin = 3,
	ShardSizeMax = 9,
	ShardSpread = 34,
	ShardRise = 22,
	FlickerChance = 0.1,
	StrokeFlashChance = 0.5,
	GradientSlide = true
}
RiftText.Defaults = defaults
local palette = {
	core = Color3.fromRGB(255, 242, 255),
	lilac = Color3.fromRGB(217, 166, 255),
	bright = Color3.fromRGB(168, 85, 247),
	mid = Color3.fromRGB(106, 33, 214)
}
RiftText.Palette = palette
local color = Color3.fromRGB(240, 183, 255)
local color2 = Color3.fromRGB(191, 200, 255)
local v3 = {
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
}
local v4 = { palette.lilac, palette.bright, palette.core }
local random = Random.new()
local v5 = Store.new()
local class = {}
class.__index = class

local function opt(p, attributeName)
	local attribute = p.label:GetAttribute(attributeName)

	if attribute == nil then
		return p.opts[attributeName]
	end

	return attribute
end

function class:_bareClone(name)
	local clone = self.label:Clone()
	clone:ClearAllChildren()
	clone.Name = name
	clone.BackgroundTransparency = 1

	if self.stroke then
		local clone_2 = self.stroke:Clone()
		clone_2.Parent = clone
	end

	return clone
end

function class:_build()
	if self.built then
		return
	end

	self.built = true
	local label = self.label
	local parent = self.label.Parent
	label.ZIndex = math.max(label.ZIndex, 3)
	local tearEnabled = self.label:GetAttribute("TearEnabled")

	if tearEnabled == nil then
		tearEnabled = self.opts.TearEnabled
	end

	if tearEnabled then
		local frame = Instance.new("Frame")
		frame.Name = "RiftTearTop"
		frame.BackgroundTransparency = 1
		frame.ClipsDescendants = true
		frame.AnchorPoint = label.AnchorPoint
		frame.ZIndex = label.ZIndex
		frame.Visible = false
		frame.Parent = parent
		local clone = frame:Clone()
		clone.Name = "RiftTearBottom"
		clone.Parent = parent
		local _bareClone = self:_bareClone("RiftTearTopText")
		_bareClone.AnchorPoint = Vector2.zero
		_bareClone.Position = UDim2.fromScale(0, 0)
		_bareClone.ZIndex = label.ZIndex
		_bareClone.Parent = frame
		local _bareClone2 = self:_bareClone("RiftTearBottomText")
		_bareClone2.AnchorPoint = Vector2.zero
		_bareClone2.ZIndex = label.ZIndex
		_bareClone2.Parent = clone
		self.topClip = frame
		self.botClip = clone
		self.topText = _bareClone
		self.botText = _bareClone2
	end

	local seamEnabled = self.label:GetAttribute("SeamEnabled")

	if seamEnabled == nil then
		seamEnabled = self.opts.SeamEnabled
	end

	if seamEnabled then
		local frame = Instance.new("Frame")
		frame.Name = "RiftSeamGlow"
		frame.BorderSizePixel = 0
		frame.BackgroundColor3 = palette.bright
		frame.BackgroundTransparency = 0.72
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.ZIndex = label.ZIndex + 1
		frame.Visible = false
		frame.Parent = parent
		local uIGradient = Instance.new("UIGradient")
		uIGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(0.5, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		uIGradient.Parent = frame
		local clone = frame:Clone()
		clone.Name = "RiftSeamCore"
		clone.BackgroundColor3 = palette.core
		clone.BackgroundTransparency = 0.05
		clone.ZIndex = label.ZIndex + 2
		clone.Parent = parent
		self.seamGlow = frame
		self.seamCore = clone
	end

	self.ghosts = {}
	local ghostEnabled = self.label:GetAttribute("GhostEnabled")

	if ghostEnabled == nil then
		ghostEnabled = self.opts.GhostEnabled
	end

	if ghostEnabled then
		for _, textColor in ipairs({ color, color2 }) do
			local clone = label:Clone()
			clone:ClearAllChildren()
			clone.Name = "RiftGhost"
			clone.TextColor3 = textColor
			clone.TextTransparency = 1
			clone.BackgroundTransparency = 1
			clone.ZIndex = label.ZIndex - 1
			clone.Parent = parent
			self.ghosts[#self.ghosts + 1] = clone
		end
	end

	self.shards = {}
	local shardsEnabled = self.label:GetAttribute("ShardsEnabled")

	if shardsEnabled == nil then
		shardsEnabled = self.opts.ShardsEnabled
	end

	if shardsEnabled then
		local shardCount = self.label:GetAttribute("ShardCount")

		if shardCount == nil then
			shardCount = self.opts.ShardCount
		end

		for i = 1, shardCount do
			local frame = Instance.new("Frame")
			frame.Name = "RiftShard"
			frame.BorderSizePixel = 0
			frame.BackgroundColor3 = i % 2 == 0 and palette.lilac or palette.core
			frame.BackgroundTransparency = 1
			frame.AnchorPoint = Vector2.new(0.5, 0.5)
			frame.ZIndex = label.ZIndex + 2
			frame.Parent = parent
			local uICorner = Instance.new("UICorner")
			uICorner.CornerRadius = UDim.new(0, 1)
			uICorner.Parent = frame
			self.shards[#self.shards + 1] = frame
		end
	end
end

function class:_scrambleText()
	local v6 = {}

	for i = 1, #self.text do
		v6[i] = string.sub(self.text, i, i)
	end

	if #v6 == 0 then
		return self.text
	end

	local maxScrambledChars = self.label:GetAttribute("MaxScrambledChars")

	if maxScrambledChars == nil then
		maxScrambledChars = self.opts.MaxScrambledChars
	end

	for _ = 1, random:NextInteger(1, maxScrambledChars) do
		local integer = random:NextInteger(1, #v6)

		if v6[integer] ~= " " then
			v6[integer] = v3[random:NextInteger(1, #v3)]
		end
	end

	return table.concat(v6)
end

function class:_setGhosts(p, p2, p3)
	local ghostOffset = self.label:GetAttribute("GhostOffset")

	if ghostOffset == nil then
		ghostOffset = self.opts.GhostOffset
	end

	for i, ghost in ipairs(self.ghosts) do
		if p then
			local v6 = i == 1 and 1 or -1
			ghost.Text = self.label.Text
			ghost.Rotation = self.label.Rotation
			local ghostTransparency = self.label:GetAttribute("GhostTransparency")

			if ghostTransparency == nil then
				ghostTransparency = self.opts.GhostTransparency
			end

			ghost.TextTransparency = ghostTransparency
			ghost.Position = self.homePosition + UDim2.fromOffset(
				p2 + v6 * ghostOffset,
				p3 + v6 * math.ceil(ghostOffset / 2)
			)
		else
			ghost.TextTransparency = 1
		end
	end
end

function class:_setTear(p, p2, p3, p4, text, rotation)
	if not self.topClip then
		return
	end

	if p then
		local size = self.label.Size
		local homePosition = self.homePosition
		self.topClip.Size = UDim2.new(size.X.Scale, size.X.Offset, size.Y.Scale * p2, size.Y.Offset * p2)
		self.topClip.Position = homePosition + UDim2.fromOffset(p3, -p4)
		self.topClip.Rotation = rotation
		self.topText.Size = UDim2.fromScale(1, 1 / p2)
		self.topText.Text = text
		local v6 = 1 - p2
		self.botClip.Size = UDim2.new(size.X.Scale, size.X.Offset, size.Y.Scale * v6, size.Y.Offset * v6)
		self.botClip.Position = homePosition + UDim2.fromOffset(-p3, p4) + UDim2.new(
			0,
			0,
			size.Y.Scale * p2,
			size.Y.Offset * p2
		)
		self.botClip.Rotation = rotation
		self.botText.Size = UDim2.fromScale(1, 1 / v6)
		self.botText.Position = UDim2.fromScale(0, -p2 / v6)
		self.botText.Text = text
		self.topClip.Visible = true
		self.botClip.Visible = true
	else
		self.topClip.Visible = false
		self.botClip.Visible = false
	end
end

function class:_setSeam(p, p2, p3)
	if not self.seamGlow then
		return
	end

	if p then
		local size = self.label.Size
		local position = self.homePosition + UDim2.new(
			size.X.Scale * 0.5,
			size.X.Offset * 0.5,
			size.Y.Scale * p2,
			size.Y.Offset * p2
		)
		self.seamGlow.Position = position
		local seamGlow = self.seamGlow
		local v7 = size.X.Scale * 1.1
		local v8 = size.X.Offset * 1.1
		local seamGlowThickness = self.label:GetAttribute("SeamGlowThickness")

		if seamGlowThickness == nil then
			seamGlowThickness = self.opts.SeamGlowThickness
		end

		seamGlow.Size = UDim2.new(v7, v8, 0, seamGlowThickness)
		self.seamGlow.BackgroundTransparency = 0.6 + 0.25 * (1 - p3)
		self.seamGlow.BackgroundColor3 = p3 > 0.5 and palette.lilac or palette.bright
		self.seamGlow.Visible = true
		self.seamCore.Position = position
		local seamCore = self.seamCore
		local v10 = size.X.Scale * (0.75 + 0.3 * p3)
		local offset = size.X.Offset
		local seamThickness = self.label:GetAttribute("SeamThickness")

		if seamThickness == nil then
			seamThickness = self.opts.SeamThickness
		end

		seamCore.Size = UDim2.new(v10, offset, 0, seamThickness)
		self.seamCore.BackgroundTransparency = 0.05
		self.seamCore.Visible = true
	else
		self.seamGlow.Visible = false
		self.seamCore.Visible = false
	end
end

function class:_setShards(p, p2, value)
	local shardSpread = self.label:GetAttribute("ShardSpread")

	if shardSpread == nil then
		shardSpread = self.opts.ShardSpread
	end

	local shardRise = self.label:GetAttribute("ShardRise")

	if shardRise == nil then
		shardRise = self.opts.ShardRise
	end

	local shardSizeMin = self.label:GetAttribute("ShardSizeMin")

	if shardSizeMin == nil then
		shardSizeMin = self.opts.ShardSizeMin
	end

	local shardSizeMax = self.label:GetAttribute("ShardSizeMax")

	if shardSizeMax == nil then
		shardSizeMax = self.opts.ShardSizeMax
	end

	for i, shard in ipairs(self.shards) do
		if p then
			local v6 = i * 7919 % 97 / 97
			local v7 = i % 2 == 0 and 1 or -1
			local size = self.label.Size
			local integer = random:NextInteger(shardSizeMin, shardSizeMax)
			shard.Size = UDim2.fromOffset(integer, integer)
			shard.Rotation = v6 * 360 + value * 180 * v7
			shard.Position = self.homePosition + UDim2.new(
				size.X.Scale * 0.5,
				size.X.Offset * 0.5,
				size.Y.Scale * p2,
				size.Y.Offset * p2
			) + UDim2.fromOffset((v6 - 0.5) * 2 * shardSpread * value, v7 * shardRise * value * (0.4 + v6 * 0.6))
			shard.BackgroundTransparency = math.clamp(value, 0, 1)
		else
			shard.BackgroundTransparency = 1
		end
	end
end

function class:_restore()
	local label = self.label
	label.Text = self.text
	label.Position = self.homePosition
	label.Rotation = self.homeRotation
	label.TextTransparency = self.homeTransparency

	if self.stroke then
		self.stroke.Color = self.homeStrokeColor
	end

	if self.gradient then
		self.gradient.Offset = self.homeGradientOffset
	end

	self:_setGhosts(false, 0, 0)
	self:_setTear(false, 0.5, 0, 0, self.text, 0)
	self:_setSeam(false, 0.5, 0)
	self:_setShards(false, 0.5, 1)
end

function class:_pose(p)
	local label = self.label
	local jitterX = self.label:GetAttribute("JitterX")

	if jitterX == nil then
		jitterX = self.opts.JitterX
	end

	local v7 = -jitterX
	local jitterX2 = self.label:GetAttribute("JitterX")

	if jitterX2 == nil then
		jitterX2 = self.opts.JitterX
	end

	local integer = random:NextInteger(v7, jitterX2)
	local jitterY = self.label:GetAttribute("JitterY")

	if jitterY == nil then
		jitterY = self.opts.JitterY
	end

	local v9 = -jitterY
	local jitterY2 = self.label:GetAttribute("JitterY")

	if jitterY2 == nil then
		jitterY2 = self.opts.JitterY
	end

	local integer2 = random:NextInteger(v9, jitterY2)
	local rotationJitter = self.label:GetAttribute("RotationJitter")

	if rotationJitter == nil then
		rotationJitter = self.opts.RotationJitter
	end

	local rotation = self.homeRotation + random:NextNumber(-rotationJitter, rotationJitter)
	local number = random:NextNumber()
	local scrambleChance = self.label:GetAttribute("ScrambleChance")

	if scrambleChance == nil then
		scrambleChance = self.opts.ScrambleChance
	end

	local text = number < scrambleChance and self:_scrambleText() or self.text
	label.Position = self.homePosition + UDim2.fromOffset(integer, integer2)
	label.Rotation = rotation
	label.Text = text
	local number2 = random:NextNumber()
	local flickerChance = self.label:GetAttribute("FlickerChance")

	if flickerChance == nil then
		flickerChance = self.opts.FlickerChance
	end

	label.TextTransparency = number2 < flickerChance and 1 or self.homeTransparency

	if self.topClip then
		local tearSlideMin = self.label:GetAttribute("TearSlideMin")

		if tearSlideMin == nil then
			tearSlideMin = self.opts.TearSlideMin
		end

		local tearSlideMax = self.label:GetAttribute("TearSlideMax")

		if tearSlideMax == nil then
			tearSlideMax = self.opts.TearSlideMax
		end

		local integer3 = random:NextInteger(tearSlideMin, tearSlideMax)
		local tearGapMax = self.label:GetAttribute("TearGapMax")

		if tearGapMax == nil then
			tearGapMax = self.opts.TearGapMax
		end

		local integer4 = random:NextInteger(0, tearGapMax)
		label.TextTransparency = 1
		self:_setTear(true, self.frac, integer3, integer4, text, rotation)
		self:_setSeam(true, self.frac, random:NextNumber())
	end

	if self.stroke then
		local number3 = random:NextNumber()
		local strokeFlashChance = self.label:GetAttribute("StrokeFlashChance")

		if strokeFlashChance == nil then
			strokeFlashChance = self.opts.StrokeFlashChance
		end

		if number3 < strokeFlashChance then
			self.stroke.Color = v4[random:NextInteger(1, #v4)]
		else
			self.stroke.Color = self.homeStrokeColor
		end
	end

	if self.gradient then
		local gradientSlide = self.label:GetAttribute("GradientSlide")

		if gradientSlide == nil then
			gradientSlide = self.opts.GradientSlide
		end

		if gradientSlide then
			self.gradient.Offset = Vector2.new(random:NextNumber(-0.5, 0.5), 0)
		end
	end

	self:_setGhosts(true, integer, integer2)
	self:_setShards(true, self.frac, p)
end

function class:_step(p)
	if self.bursting then
		self.elapsed += p

		if self.elapsed >= self.duration then
			self.bursting = false
			local burstIntervalMin = self.label:GetAttribute("BurstIntervalMin")

			if burstIntervalMin == nil then
				burstIntervalMin = self.opts.BurstIntervalMin
			end

			local burstIntervalMax = self.label:GetAttribute("BurstIntervalMax")

			if burstIntervalMax == nil then
				burstIntervalMax = self.opts.BurstIntervalMax
			end

			self.wait = random:NextNumber(burstIntervalMin, burstIntervalMax)
			self:_restore()
		else
			self.tick += p
			local tickRate = self.label:GetAttribute("TickRate")

			if tickRate == nil then
				tickRate = self.opts.TickRate
			end

			if tickRate <= self.tick then
				self.tick -= tickRate * math.floor(self.tick / tickRate)
				self:_pose((math.clamp(self.elapsed / self.duration, 0, 1)))
			end
		end
	else
		self.wait -= p

		if self.wait <= 0 then
			self:Burst()
		end
	end
end

function class:Burst()
	self:_build()

	if not self.bursting then
		self.homePosition = self.label.Position
		self.homeRotation = self.label.Rotation
	end

	self.text = self.label.Text ~= "" and self.label.Text or self.text
	self.bursting = true
	self.elapsed = 0
	self.tick = 0
	local burstDurationMin = self.label:GetAttribute("BurstDurationMin")

	if burstDurationMin == nil then
		burstDurationMin = self.opts.BurstDurationMin
	end

	local burstDurationMax = self.label:GetAttribute("BurstDurationMax")

	if burstDurationMax == nil then
		burstDurationMax = self.opts.BurstDurationMax
	end

	self.duration = random:NextNumber(burstDurationMin, burstDurationMax)
	local tearHeightMin = self.label:GetAttribute("TearHeightMin")

	if tearHeightMin == nil then
		tearHeightMin = self.opts.TearHeightMin
	end

	local tearHeightMax = self.label:GetAttribute("TearHeightMax")

	if tearHeightMax == nil then
		tearHeightMax = self.opts.TearHeightMax
	end

	self.frac = random:NextNumber(tearHeightMin, tearHeightMax)
	return self
end

function class:SetText(text)
	self.text = text

	if not self.bursting then
		self.label.Text = text
	end

	return self
end

function class:Stop()
	if self.ticker then
		self.ticker:Stop()
		self.ticker = nil
	end

	if self.built then
		self.bursting = false
		self:_restore()

		for _, v6 in ipairs({
			self.topClip,
			self.botClip,
			self.seamGlow,
			self.seamCore
		}) do
			if v6 then
				v6:Destroy()
			end
		end

		for _, v6 in ipairs(self.ghosts or {}) do
			v6:Destroy()
		end

		for _, v6 in ipairs(self.shards or {}) do
			v6:Destroy()
		end

		self.topClip = nil
		self.botClip = nil
		self.topText = nil
		self.botText = nil
		self.seamGlow = nil
		self.seamCore = nil
		self.ghosts = {}
		self.shards = {}
		self.built = false
	end

	if v5[self.label] == self then
		v5[self.label] = nil
	end
end

class.Destroy = class.Stop

function RiftText.attach(instance, p)
	local v6 = v5[instance]

	if v6 then
		v6:Stop()
	end

	local object = setmetatable({
		label = instance,
		opts = setmetatable(p and table.clone(p) or {}, {
			__index = defaults
		}),
		text = instance.Text,
		homePosition = instance.Position,
		homeRotation = instance.Rotation,
		homeTransparency = instance.TextTransparency,
		built = false,
		bursting = false,
		elapsed = 0,
		tick = 0,
		duration = 0,
		frac = 0.5,
		ghosts = {},
		shards = {}
	}, class)
	object.stroke = instance:FindFirstChildOfClass("UIStroke")
	object.homeStrokeColor = object.stroke and object.stroke.Color
	object.gradient = instance:FindFirstChildOfClass("UIGradient")
	object.homeGradientOffset = object.gradient and object.gradient.Offset
	local burstIntervalMin = object.label:GetAttribute("BurstIntervalMin")

	if burstIntervalMin == nil then
		burstIntervalMin = object.opts.BurstIntervalMin
	end

	local burstIntervalMax = object.label:GetAttribute("BurstIntervalMax")

	if burstIntervalMax == nil then
		burstIntervalMax = object.opts.BurstIntervalMax
	end

	object.wait = random:NextNumber(burstIntervalMin, burstIntervalMax)
	object.ticker = Ticker.whileVisible(instance, function(p2)
		object:_step(p2)
	end, 0, function()
		if object.built then
			object.bursting = false
			object:_restore()
		end
	end)
	v5[instance] = object
	return object
end

function RiftText.attachAll(folder, p)
	local v6 = {}

	-- equivalent calls inferred from this helper; original call sites unknown
	local function try(label)
		if label:IsA("TextLabel") and label:GetAttribute("RiftText") == true then
			v6[#v6 + 1] = RiftText.attach(label, p)
		end
	end

	try(folder) -- equivalent call inferred; original call site unknown

	for _, descendant in ipairs(folder:GetDescendants()) do
		try(descendant) -- equivalent call inferred; original call site unknown
	end

	return v6
end

function RiftText.get(p)
	return v5[p]
end

function RiftText.stop(p)
	local v6 = v5[p]

	if v6 then
		v6:Stop()
	end
end

return RiftText