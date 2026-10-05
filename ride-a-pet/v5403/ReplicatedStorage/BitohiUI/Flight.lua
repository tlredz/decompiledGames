local Players = game:GetService("Players")
local Ticker = require(script.Parent:WaitForChild("Ticker"))
local defaults = {
	Duration = 0.55,
	Stagger = 0.045,
	Arc = 90,
	Spread = 26,
	Spin = 0,
	Scale = 0.6,
	Pool = 16,
	Size = UDim2.fromOffset(32, 32),
	DisplayOrder = 5000
}
local Flight = {
	Defaults = defaults
}
local class = {}
class.__index = class
local random = Random.new()

-- equivalent calls inferred from this helper; original call sites unknown
local function centreOf(p, absolutePosition)
	return p.AbsolutePosition + p.AbsoluteSize * 0.5 - absolutePosition
end

-- equivalent arithmetic calls inferred from this bytecode helper; original call sites unknown
local function ease(p)
	return 1 - (1 - p) * (1 - p) * (1 - p)
end

local function backOut(p)
	local v2 = p - 1
	return 1 + 2.70158 * v2 * v2 * v2 + 1.70158 * v2 * v2
end

function Flight.new(options)
	return (setmetatable({
		opts = setmetatable(options or {}, {
			__index = defaults
		}),
		pool = {},
		active = {},
		ticker = nil,
		built = false
	}, class))
end

function class:_build()
	if self.built then
		return
	end

	self.built = true
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = self.opts.Name or "BitohiFlightLayer"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.DisplayOrder = self.opts.DisplayOrder
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Enabled = false
	screenGui.Parent = playerGui
	self.gui = screenGui
	local frame = Instance.new("Frame")
	frame.Name = "Canvas"
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1, 1)
	frame.Parent = screenGui
	self.canvas = frame

	for _ = 1, self.opts.Pool do
		self.pool[#self.pool + 1] = self:_newFlier()
	end
end

function class:_newFlier()
	local imageLabel = Instance.new("ImageLabel")
	imageLabel.Name = "Flier"
	imageLabel.BackgroundTransparency = 1
	imageLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	imageLabel.Size = self.opts.Size
	imageLabel.Image = self.opts.Image or ""
	imageLabel.Visible = false
	imageLabel.Parent = self.canvas
	return imageLabel
end

function class:_acquire()
	return table.remove(self.pool) or self:_newFlier()
end

function class:_release(p2)
	p2.Visible = false
	self.pool[#self.pool + 1] = p2
end

function class:_wake()
	if self.ticker then
		return
	end

	local active = self.active
	self.gui.Enabled = true
	self.ticker = Ticker.add(function(p)
		local absolutePosition = self.canvas.AbsolutePosition

		for i = #active, 1, -1 do
			local v2 = active[i]
			v2.elapsed += p

			if v2.elapsed < 0 then
				continue
			end

			if v2.elapsed < v2.pop then
				local v3 = v2.elapsed / v2.pop - 1
				local v4 = 1 + 2.70158 * v3 * v3 * v3 + 1.70158 * v3 * v3
				v2.flier.Position = UDim2.fromOffset(v2.start.X, v2.start.Y)
				v2.flier.Rotation = 0
				v2.flier.Size = UDim2.fromOffset(v2.width * v4, v2.height * v4)
				v2.flier.Visible = true
			else
				local v3 = math.clamp((v2.elapsed - v2.pop) / v2.duration, 0, 1)
				local v4 = ease(v3)
				local finish

				if v2.target.Parent then
					finish = centreOf(v2.target, absolutePosition)

					if not finish then
						finish = v2.finish
					end
				else
					finish = v2.finish
				end

				v2.finish = finish
				local start = v2.start
				local control = v2.control
				local v5 = 1 - v4
				local v6 = start * (v5 * v5) + control * (2 * v5 * v4) + finish * (v4 * v4)
				v2.flier.Position = UDim2.fromOffset(v6.X, v6.Y)
				v2.flier.Rotation = v2.spin * v4
				local v7 = 1 + (v2.scale - 1) * v4
				v2.flier.Size = UDim2.fromOffset(v2.width * v7, v2.height * v7)
				v2.flier.Visible = true

				if v3 >= 1 then
					table.remove(active, i)
					self:_release(v2.flier)

					if v2.onArrive then
						task.spawn(v2.onArrive, v2.index)
					end

					if v2.last and v2.onDone then
						task.spawn(v2.onDone)
					end
				end
			end
		end

		if #active == 0 then
			self.ticker:Stop()
			self.ticker = nil
			self.gui.Enabled = false
		end
	end)
end

function class:Send(p, target, value, options)
	if not (p and target and p.Parent and target.Parent) then
		return
	end

	local v2 = math.max(1, value or 1)
	local v3 = options or {}
	self:_build()
	local absolutePosition = self.canvas.AbsolutePosition
	local v4 = centreOf(p, absolutePosition) -- equivalent call inferred; original call site unknown
	local finish = centreOf(target, absolutePosition) -- equivalent call inferred; original call site unknown
	local duration = v3.Duration or self.opts.Duration
	local stagger = v3.Stagger or self.opts.Stagger
	local delay = v3.Delay or 0
	local arc = v3.Arc or self.opts.Arc
	local spread = v3.Spread or self.opts.Spread
	local spin = v3.Spin or self.opts.Spin
	local scale = v3.Scale or self.opts.Scale
	local popIn = v3.PopIn or self.opts.PopIn or 0

	for i = 1, v2 do
		local _acquire = self:_acquire()
		local start = v4 + Vector2.new(random:NextNumber(-spread, spread), random:NextNumber(-spread, spread))
		local v7 = (start + finish) * 0.5
		local v8 = finish - start
		local magnitude = v8.Magnitude
		local v9 = magnitude > 0.001 and Vector2.new(-v8.Y, v8.X) / magnitude or Vector2.new(0, -1)
		local v10 = arc * (i % 2 == 0 and 1 or -1) * random:NextNumber(0.5, 1.2)
		_acquire.Size = self.opts.Size
		_acquire.Rotation = 0
		_acquire.Position = UDim2.fromOffset(start.X, start.Y)
		_acquire.Visible = false
		self.active[#self.active + 1] = {
			flier = _acquire,
			start = start,
			control = v7 + v9 * v10,
			finish = finish,
			target = target,
			elapsed = -(delay + (i - 1) * stagger),
			duration = duration,
			spin = spin * (i % 2 == 0 and 1 or -1),
			scale = scale,
			pop = popIn,
			width = self.opts.Size.X.Offset,
			height = self.opts.Size.Y.Offset,
			index = i,
			last = i == v2,
			onArrive = v3.OnArrive,
			onDone = v3.OnDone
		}
	end

	self:_wake()
end

function class:Stop()
	for i = #self.active, 1, -1 do
		self:_release(self.active[i].flier)
		self.active[i] = nil
	end

	if self.ticker then
		self.ticker:Stop()
		self.ticker = nil
	end

	if self.gui then
		self.gui.Enabled = false
	end
end

class.Destroy = class.Stop
return Flight