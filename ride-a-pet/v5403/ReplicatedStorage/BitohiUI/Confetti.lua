local UserInputService = game:GetService("UserInputService")
local Ticker = require(script.Parent:WaitForChild("Ticker"))
local Confetti = {}
local touchEnabled = UserInputService.TouchEnabled
local v = {
	Color3.fromRGB(168, 100, 253),
	Color3.fromRGB(41, 205, 255),
	Color3.fromRGB(120, 255, 68),
	Color3.fromRGB(255, 113, 141),
	Color3.fromRGB(253, 255, 106),
	Color3.fromRGB(255, 225, 0)
}
local class = {}
class.__index = class

function Confetti.new(frame, templates, options)
	local v2 = options or {}
	local self = setmetatable({}, class)
	self.frame = frame
	self.templates = templates
	self.o = {
		PoolSize = v2.PoolSize or touchEnabled and 22 or 34,
		PerBurst = v2.PerBurst or touchEnabled and 10 or 16,
		Cooldown = v2.Cooldown or 0.1,
		Lifetime = v2.Lifetime or 1.6,
		FadeTail = v2.FadeTail or 0.55,
		SkipFade = v2.SkipFade or 0.25,
		Gravity = v2.Gravity or 1500,
		Drag = v2.Drag or 0.9,
		SpeedMin = v2.SpeedMin or 950,
		SpeedMax = v2.SpeedMax or 1650,
		Spread = v2.Spread or 0.8,
		SizeMin = v2.SizeMin or 13,
		SizeMax = v2.SizeMax or 23,
		SpinMin = v2.SpinMin or 120,
		SpinMax = v2.SpinMax or 460,
		KillMargin = v2.KillMargin or 80,
		Colors = v2.Colors or v,
		ZIndex = v2.ZIndex or 20,
		OnWake = v2.OnWake,
		OnSleep = v2.OnSleep
	}
	local poolSize = self.o.PoolSize
	self.labels = table.create(poolSize)
	local px = table.create(poolSize)
	local py = table.create(poolSize)
	local vx = table.create(poolSize)
	local vy = table.create(poolSize)
	self.px = px
	self.py = py
	self.vx = vx
	self.vy = vy
	local rot = table.create(poolSize)
	local spin = table.create(poolSize)
	local life = table.create(poolSize)
	self.rot = rot
	self.spin = spin
	self.life = life
	self.pooled = 0
	self.cursor = 0
	self.lastBurst = 0
	self.pending = 0
	self.ticker = nil
	self.random = Random.new()
	return self
end

function class:_buildPool()
	local o = self.o

	if self.pooled >= o.PoolSize then
		return
	end

	for i = self.pooled + 1, o.PoolSize do
		local clone = self.templates[i % #self.templates + 1]:Clone()
		clone.Name = "P"
		clone.AnchorPoint = Vector2.new(0.5, 0.5)
		clone.ZIndex = o.ZIndex
		clone.Visible = false
		clone.Parent = self.frame
		self.labels[i] = clone
		local px = self.px
		local py = self.py
		local vx = self.vx
		local vy = self.vy
		local rot = self.rot
		local spin = self.spin
		local life = self.life
		px[i] = 0
		py[i] = 0
		vx[i] = 0
		vy[i] = 0
		rot[i] = 0
		spin[i] = 0
		life[i] = 0
	end

	self.pooled = o.PoolSize
end

function class:_wake()
	if not self.ticker then
		if self.o.OnWake then
			self.o.OnWake()
		end

		self.ticker = Ticker.add(function(p)
			self:_step(p)
		end)
	end
end

function class:_sleep()
	if self.ticker then
		self.ticker:Stop()
		self.ticker = nil
	end

	if self.o.OnSleep then
		self.o.OnSleep()
	end
end

function class:_step(p)
	local o = self.o
	local v2 = self.frame.AbsoluteSize.Y + o.KillMargin
	local v3 = math.max(0, 1 - o.Drag * p)
	local labels = self.labels
	local px = self.px
	local py = self.py
	local vx = self.vx
	local vy = self.vy
	local rot = self.rot
	local spin = self.spin
	local life = self.life
	local count = 0

	for i = 1, self.pooled do
		local v4 = life[i]

		if not (v4 > 0) then
			continue
		end

		local v5 = v4 - p
		local v6 = py[i] + vy[i] * p

		if v5 <= 0 or v2 < v6 then
			life[i] = 0
			labels[i].Visible = false
		else
			local v7 = px[i] + vx[i] * p
			local rotation = rot[i] + spin[i] * p
			life[i] = v5
			px[i] = v7
			py[i] = v6
			vx[i] *= v3
			vy[i] += o.Gravity * p
			rot[i] = rotation
			local label = labels[i]
			label.Position = UDim2.fromOffset(v7, v6)
			label.Rotation = rotation

			if v5 < o.FadeTail then
				label.ImageTransparency = 1 - v5 / o.FadeTail
			end

			count += 1
		end
	end

	if self.pending > 0 and os.clock() - self.lastBurst >= o.Cooldown then
		local pending = self.pending
		self.pending = 0
		self:Burst(pending)
	elseif count == 0 then
		self:_sleep()
	end
end

function class:Burst(p)
	local o = self.o
	local perBurst = p or o.PerBurst
	local now = os.clock()

	if now - self.lastBurst < o.Cooldown then
		if self.pending < perBurst then
			self.pending = perBurst
		end

		self:_wake()
	else
		self:_buildPool()
		local absoluteSize = self.frame.AbsoluteSize

		if absoluteSize.X < 1 or absoluteSize.Y < 1 then
			if self.pending < perBurst then
				self.pending = perBurst
			end

			self:_wake()
		else
			self.lastBurst = now

			if o.PerBurst < perBurst then
				perBurst = o.PerBurst
			end

			local v2 = absoluteSize.X * 0.5
			local Y = absoluteSize.Y
			local random = self.random

			for _ = 1, perBurst do
				self.cursor += 1

				if self.cursor > o.PoolSize then
					self.cursor = 1
				end

				local cursor = self.cursor
				local number = random:NextNumber(-o.Spread, o.Spread)
				local number2 = random:NextNumber(o.SpeedMin, o.SpeedMax)
				local integer = random:NextInteger(o.SizeMin, o.SizeMax)
				self.px[cursor] = v2 + random:NextNumber(-40, 40)
				self.py[cursor] = Y
				self.vx[cursor] = math.sin(number) * number2
				self.vy[cursor] = -math.cos(number) * number2
				self.rot[cursor] = random:NextNumber(0, 360)
				self.spin[cursor] = random:NextNumber(o.SpinMin, o.SpinMax) * (random:NextInteger(0, 1) == 0 and -1 or 1)
				self.life[cursor] = o.Lifetime
				local label = self.labels[cursor]
				label.Size = UDim2.fromOffset(integer, integer)
				label.ImageColor3 = o.Colors[random:NextInteger(1, #o.Colors)]
				label.ImageTransparency = 0
				label.Position = UDim2.fromOffset(self.px[cursor], self.py[cursor])
				label.Visible = true
			end

			self:_wake()
		end
	end
end

function class:Fade()
	self.pending = 0

	for i = 1, self.pooled do
		if self.life[i] > self.o.SkipFade then
			self.life[i] = self.o.SkipFade
		end
	end
end

function class:Destroy()
	self:_sleep()

	for _, label in ipairs(self.labels) do
		label:Destroy()
	end

	table.clear(self.labels)
	self.pooled = 0
end

return Confetti