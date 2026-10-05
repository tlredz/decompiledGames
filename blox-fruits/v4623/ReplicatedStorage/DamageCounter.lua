local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage:WaitForChild("Util"))
local ColorLerp = require(script.ColorLerp)
local Styling = require(script.Styling)
local digitColors = Styling.DigitColors
local percentageColors = Styling.PercentageColors
local animationStyles = Styling.AnimationStyles

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function getGradientColor(amount, colorMethod, maxNumber)
	assert(colorMethod == "Digits" or colorMethod == "Percent", "[DamageCounter] Invalid mode for color shifting")

	if colorMethod == "Digits" then
		local v = #string.format("%.0f", amount)
		return digitColors[math.clamp(v, 1, #digitColors)]
	end

	if colorMethod ~= "Percent" then
		return
	end

	local v = amount / maxNumber
	local v2 = 1

	for k, percentageColor in pairs(percentageColors) do
		if percentageColor[1] <= v then
			v2 = k
		end
	end

	return percentageColors[v2][2]
end

local DamageCounter = {}
DamageCounter.__index = DamageCounter

function DamageCounter.new(parent)
	assert(parent, "[DamageCounter] Parent provided during .new does not exist")
	local clone = script.DmgCounter:Clone()
	clone.Parent = parent
	local v = {
		Life = 2,
		MaxNumber = 15000,
		ColorMethod = "Percent",
		AnimationStyle = "Thump",
		BarDelay = 0.45,
		HideWhenInactive = true,
		Enabled = true,
		Frame = clone,
		Bar = clone.BarFrame,
		TextLabel = clone.Text,
		RestingProperties = { clone.Position, clone.Size }
	}
	v.AnimationData = animationStyles[v.AnimationStyle]
	v.StoredRandoms = {}
	v.LastUpdate = tick()
	v.LastHit = tick() - 10
	v.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 138, 138))
	})
	v.Amount = 0
	v.RenderLoop = nil
	setmetatable(v, DamageCounter)
	return v
end

function DamageCounter:Disconnect()
	if self.RenderLoop ~= nil then
		self.RenderLoop:Disconnect()
		self.RenderLoop = nil
	end
end

function DamageCounter:Reset()
	self.Amount = 0
	self.TextLabel.Text = 0
	self.Bar.BackgroundTransparency = 1
	local uIGradient = self.TextLabel.UIGradient
	local gradientColor = getGradientColor(self.Amount, self.ColorMethod, self.MaxNumber)

	if uIGradient.Color ~= gradientColor then
		uIGradient.Color = ColorLerp.ColorSequenceLerp(uIGradient.Color, gradientColor)(1)
	end
end

function DamageCounter:Update()
	if self.TextLabel then
		local text = string.format("%.0f", self.Amount)
		self.TextLabel.Text = text
	end
end

function DamageCounter:SetAnimationStyle(_)
	self.AnimationData = animationStyles[self.AnimationStyle]
end

function DamageCounter:Increment(p)
	if self.Enabled then
		if self.HideWhenInactive and self.RenderLoop == nil then
			self:Start()
		end

		self.Amount += p
		self:Update()
		self.LastUpdate = tick()
		self.Bar.BackgroundTransparency = 1
		self.Bar.Size = UDim2.new(1.4, 0, 0.05, 0)
		self.Bar.UIGradient.Color = getGradientColor(self.Amount, self.ColorMethod, self.MaxNumber)

		if tick() - self.LastHit > self.AnimationData[1] then
			self.LastHit = tick()
			local v = self.AnimationData[4]
			self.StoredRandoms.Rotation = v[math.random(1, #v)]
		end
	end
end

function DamageCounter.SetPosition(p, position)
	p.RestingProperties[1] = position
	p.Frame.Position = position
end

function DamageCounter:Start()
	if self.RenderLoop ~= nil then
		self:Disconnect()
	end

	if self.HideWhenInactive then
		self.Frame.Visible = true
	end

	self.RenderLoop = RunService.RenderStepped:Connect(function(dt)
		local uIGradient = self.TextLabel.UIGradient
		local frame = self.Frame
		local gradientColor = getGradientColor(self.Amount, self.ColorMethod, self.MaxNumber)

		if uIGradient.Color ~= gradientColor then
			uIGradient.Color = ColorLerp.ColorSequenceLerp(uIGradient.Color, gradientColor)(dt * 3)
		end

		local v = tick() - self.LastHit
		local v2 = tick() - self.LastUpdate
		local animationData = self.AnimationData

		if v < animationData[1] then
			local v3 = ColorLerp.Easing[animationData[5]]((math.min(v / animationData[1], 1)))
			frame.Position = frame.Position:Lerp(self.RestingProperties[1] + animationData[2], v3)
			frame.Size = frame.Size:Lerp(self.RestingProperties[2] + animationData[3], v3)
			local rotation = frame.Rotation
			frame.Rotation = rotation + ((self.StoredRandoms.Rotation or 0) - rotation) * v3
		else
			if animationData[1] + self.BarDelay < v then
				local bar = self.Bar
				local backgroundTransparency = self.Bar.BackgroundTransparency
				bar.BackgroundTransparency = backgroundTransparency + (0 - backgroundTransparency) * 0.1
				self.Bar.Size = UDim2.new(1.4 + -1.4 * (math.min(v, self.Life) / self.Life), 0, 0.05, 0)
			end

			frame.Position = frame.Position:Lerp(self.RestingProperties[1], 0.1)
			frame.Size = frame.Size:Lerp(self.RestingProperties[2], 0.1)
			local rotation = frame.Rotation
			frame.Rotation = rotation + (0 - rotation) * 0.1
		end

		if self.Life < v2 then
			self.LastUpdate = tick()

			if self.HideWhenInactive then
				self:Stop()
			else
				self:Reset()
			end
		end

		RunService.RenderStepped:Wait()
	end)
end

function DamageCounter:Stop()
	self:Reset()
	self:Disconnect()

	if self.HideWhenInactive then
		self.Frame.Visible = false
	end
end

function DamageCounter:Debug(p, p2, duration)
	if p then
		for _ = 1, p2 do
			self:Increment(p)
			task.wait(duration)
		end
	end
end

return DamageCounter