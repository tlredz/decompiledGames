local Ticker = require(script.Parent:WaitForChild("Ticker"))
local Sparkle = {}
Sparkle.__index = Sparkle
local defaults = {
	Rate = 2.5,
	Pool = 5,
	Size = 0.22,
	Life = 0.8,
	Spin = 90,
	Color = Color3.new(1, 1, 1),
	Inset = 0.12
}
Sparkle.Defaults = defaults
local random = Random.new()
local numberSequence = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 1),
	NumberSequenceKeypoint.new(0.5, 0),
	NumberSequenceKeypoint.new(1, 1)
})

local function opt(p, p2)
	local v2 = p[p2]

	if v2 == nil then
		return defaults[p2]
	end

	return v2
end

function Sparkle.new(target, options)
	local v2 = options or {}
	local low = v2.Low == true
	local rate = v2.Rate

	if rate == nil then
		rate = defaults.Rate
	end

	local v3 = {
		target = target,
		rate = rate * (low and 0.5 or 1),
		pool = 0,
		size = 0,
		life = 0,
		spin = 0,
		color = 0,
		image = 0,
		inset = 0,
		low = 0,
		interval = 0,
		built = false,
		step = nil,
		glint = 0,
		scale = 0,
		age = 0,
		rot0 = 0,
		dir = 0,
		live = 0
	}
	local pool = v2.Pool

	if pool == nil then
		pool = defaults.Pool
	end

	v3.pool = math.max(1, (math.floor(pool * (low and 0.5 or 1) + 0.5)))
	local size = v2.Size

	if size == nil then
		size = defaults.Size
	end

	v3.size = size
	local life = v2.Life

	if life == nil then
		life = defaults.Life
	end

	v3.life = life
	local spin = v2.Spin

	if spin == nil then
		spin = defaults.Spin
	end

	v3.spin = spin
	local color = v2.Color

	if color == nil then
		color = defaults.Color
	end

	v3.color = color
	v3.image = v2.Image
	local inset = v2.Inset

	if inset == nil then
		inset = defaults.Inset
	end

	v3.inset = inset
	v3.low = low
	v3.interval = v2.Interval or low and 0.05 or 0
	v3.glint = {}
	v3.scale = {}
	v3.age = {}
	v3.rot0 = {}
	v3.dir = {}
	return (setmetatable(v3, Sparkle))
end

function Sparkle:_build()
	if self.built then
		return
	end

	self.built = true
	local frame = Instance.new("Frame")
	frame.Name = "Sparkles"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1, 1)
	frame.ZIndex = self.target.ZIndex + 1
	frame.Active = false
	frame.Parent = self.target
	self.holder = frame

	for i = 1, self.pool do
		local parent

		if self.image then
			parent = Instance.new("ImageLabel")
			parent.Image = self.image
			parent.ImageColor3 = self.color
			parent.BackgroundTransparency = 1
		else
			parent = Instance.new("Frame")
			parent.BackgroundTransparency = 1

			for i2 = 1, 2 do
				local frame2 = Instance.new("Frame")
				frame2.AnchorPoint = Vector2.new(0.5, 0.5)
				frame2.Position = UDim2.fromScale(0.5, 0.5)
				frame2.Size = UDim2.fromScale(1, 0.16)
				frame2.Rotation = i2 == 1 and 0 or 90
				frame2.BorderSizePixel = 0
				frame2.BackgroundColor3 = self.color
				frame2.ZIndex = frame.ZIndex
				local uIGradient = Instance.new("UIGradient")
				uIGradient.Transparency = numberSequence
				uIGradient.Parent = frame2

				if not self.low then
					local uICorner = Instance.new("UICorner")
					uICorner.CornerRadius = UDim.new(1, 0)
					uICorner.Parent = frame2
				end

				frame2.Parent = parent
			end
		end

		parent.Name = "Glint"
		parent.AnchorPoint = Vector2.new(0.5, 0.5)
		parent.SizeConstraint = Enum.SizeConstraint.RelativeYY
		parent.Size = UDim2.fromScale(self.size, self.size)
		parent.ZIndex = frame.ZIndex
		parent.Visible = false
		local uIScale = Instance.new("UIScale")
		uIScale.Scale = 0
		uIScale.Parent = parent
		parent.Parent = frame
		local glint = self.glint
		local scale = self.scale
		glint[i] = parent
		scale[i] = uIScale
		local age = self.age
		local rot0 = self.rot0
		local dir = self.dir
		age[i] = -1
		rot0[i] = 0
		dir[i] = 1
	end
end

local function shown(p)
	return Ticker.isShown(p)
end

function Sparkle:_spawn()
	for i = 1, self.pool do
		if not (self.age[i] < 0) then
			continue
		end

		local inset = self.inset
		local v2 = self.glint[i]
		v2.Position = UDim2.fromScale(random:NextNumber(inset, 1 - inset), random:NextNumber(inset, 1 - inset))
		local v3 = self.size * random:NextNumber(0.7, 1.25)
		v2.Size = UDim2.fromScale(v3, v3)
		self.rot0[i] = random:NextNumber(0, 90)
		self.dir[i] = random:NextInteger(0, 1) == 0 and -1 or 1
		self.age[i] = 0
		self.scale[i].Scale = 0
		v2.Rotation = self.rot0[i]
		v2.Visible = true
		self.live += 1
		break
	end
end

function Sparkle:_hideAll()
	for i = 1, self.pool do
		if not (self.age[i] >= 0) then
			continue
		end

		self.age[i] = -1
		self.scale[i].Scale = 0
		self.glint[i].Visible = false
	end

	self.live = 0
end

function Sparkle:Warm()
	if self.target.Parent then
		self:_build()
	end
end

function Sparkle:Start(p, p2)
	if self.step then
		return
	end

	if self.driven then
		return self.driven
	end

	if not self.target.Parent then
		return
	end

	self:_build()
	local v2 = p or self.interval
	local number = random:NextNumber(0, 1 / self.rate)
	local v3 = 0
	local v4 = true
	local life = self.life
	local spin = self.spin
	local age = self.age
	local scale = self.scale
	local glint = self.glint
	local rot0 = self.rot0
	local dir = self.dir
	local pool = self.pool
	local sin = math.sin
	local v5 = self.target.AbsoluteSize.Y * self.size * 0.5
	local v6 = v5 > 1 and math.min(0.25 / v5, 0.02) or 0.01
	local lastScale = self.lastScale

	if not lastScale then
		lastScale = table.create(pool, 0)
		self.lastScale = lastScale
	end

	local function step(p3)
		v3 -= p3

		if v3 <= 0 then
			v3 = 0.5
			local target = self.target
			v4 = Ticker.isShown(target)

			if not v4 and self.live > 0 then
				self:_hideAll()
			end
		end

		if not v4 then
			return
		end

		number -= p3

		if number <= 0 then
			number = random:NextNumber(0.4, 1.6) / self.rate
			self:_spawn()
		end

		if self.live == 0 then
			return
		end

		for i = 1, pool do
			local v7 = age[i]

			if not (v7 >= 0) then
				continue
			end

			local v8 = v7 + p3

			if life <= v8 then
				age[i] = -1
				scale[i].Scale = 0
				lastScale[i] = 0
				glint[i].Visible = false
				self.live -= 1
			else
				age[i] = v8
				local v9 = v8 / life
				local scale2 = sin(3.141592653589793 * v9) ^ 0.6
				local v12 = scale2 - lastScale[i]

				if v6 < v12 or v12 < -v6 then
					lastScale[i] = scale2
					scale[i].Scale = scale2
				end

				glint[i].Rotation = rot0[i] + dir[i] * spin * v9
			end
		end
	end

	if p2 then
		self.driven = step
		return step
	else
		self.step = v2 > 0 and Ticker.every(v2, step) or Ticker.add(step)
	end
end

function Sparkle:Stop()
	if self.step then
		self.step:Stop()
		self.step = nil
	end

	self.driven = nil

	if self.built then
		self:_hideAll()
	end
end

function Sparkle:Destroy()
	self:Stop()

	if self.holder then
		self.holder:Destroy()
	end

	self.holder = nil
	self.built = false
	table.clear(self.glint)
	table.clear(self.scale)
end

function Sparkle.attach(p, p2)
	local v2 = Sparkle.new(p, p2)
	local v3 = Ticker.watchVisible(p, function(p3)
		if p3 then
			v2:Start()
		else
			v2:Stop()
		end
	end)
	return {
		Stop = function(self)
			v3:Stop()
			v2:Stop()
		end,
		Destroy = function(self)
			v3:Stop()
			v2:Destroy()
		end
	}
end

return Sparkle