local createVector = vector.create

local function CalculateBrightness(data)
	return (math.sqrt(data.R ^ 2 * 0.241 + data.G ^ 2 * 0.691 + data.B ^ 2 * 0.068))
end

local function CalculateColorByIntensity(data, p)
	if p > 1 then
		local v = Vector3.new(1 - data.r, 1 - data.g, 1 - data.b) * (p - 1)
		return Color3.new(data.r + v.x, data.g + v.y, data.b + v.z)
	else
		return Color3.new(data.r * p, data.g * p, data.b * p)
	end
end

local color = BrickColor.new("Black").Color
math.sqrt(color.R ^ 2 * 0.241 + color.G ^ 2 * 0.691 + color.B ^ 2 * 0.068)
local Tween = require(game.ReplicatedStorage.Util.Tween)
local RunService = game:GetService("RunService")
local _ = workspace._WorldOrigin
local FX = require(game.ReplicatedStorage.FX)
local auraSpike = FX:WaitForChild("Dragon").FX.AuraSpike
local v = {}
RunService:BindToRenderStep(script.Parent.Name .. "-" .. script.Name, Enum.RenderPriority.Last.Value - 1000, function(_)
	local now = tick()

	for k, v2 in pairs(v) do
		local v3 = now - v2.Start
		local v4 = v2.Object.AngleInfluence[2]
		local v5 = { v2.Object.Scale[1], v2.Object.Scale[2] }
		local v6 = 1

		if v2.Object.FadeIn + v2.Object.FadeOut + v2.Object.Lifetime < v3 then
			for _, attachment in next, v2.Object.Attachments, nil do
				attachment:Destroy()
			end

			v[k] = nil
		elseif v2.Object.FadeIn + v2.Object.Lifetime < v3 then
			local v7 = (v3 - (v2.Object.FadeIn + v2.Object.Lifetime)) / v2.Object.FadeOut
			v6 = Tween.ease.inout.quad(v7, 1, -1, 1)
			local quad = Tween.ease.inout.quad(v7, 0, 1, 1)

			for _, trail in next, v2.Object.Trails, nil do
				trail.Transparency = NumberSequence.new(1, 1 - v2.Object.TransparencyInfluence + quad)
			end
		elseif v2.Object.FadeIn < v3 then
			local _ = (v3 - v2.Object.FadeIn) / v2.Object.Lifetime
		else
			local v7 = v3 / v2.Object.FadeIn
			local quad = Tween.ease["in"].quad(v7, 0, 1, 1)
			local quad2 = Tween.ease.out.quad(v7, 0, 1, 1)
			v5[1] *= quad2
			v5[2] *= quad2
			v4 = v2.Object.AngleInfluence[1]:Lerp(v2.Object.AngleInfluence[2], quad)
			v6 = 1
		end

		if not (v3 < v2.Object.FadeIn + v2.Object.FadeOut + v2.Object.Lifetime) then
			continue
		end

		local v7 = v3 % (v2.Object.Lifetime / v2.Object.PulseSpeed) / (v2.Object.Lifetime / v2.Object.PulseSpeed)
		v2.Object.Attachments[2].CFrame = v2.Object.CFrame * CFrame.Angles(v4.X, v4.Y, v4.Z) * CFrame.new(
			0,
			v5[2] + v6 * v5[2] / 2 * math.sin(3.141592653589793 * v7) ^ 2,
			0
		)

		for k2, trail in next, v2.Object.Trails, nil do
			trail.Width0 = (v2.Object.Attachments[1].Position - v2.Object.Attachments[2].Position).Magnitude

			if k2 == 1 then
				trail.Width1 = v5[1] + v6 * v5[1] / 2 * math.abs((math.cos(3.141592653589793 * v7))) ^ 2
			else
				trail.Width1 = v2.Object.Trails[1].Width1 * 0.76
			end
		end
	end
end)
local SpikyFlare = {}

function SpikyFlare.new(options)
	local v2 = options or {}
	return setmetatable({
		Scale = v2.Scale or { 3, 6 },
		CFrame = v2.CFrame,
		FadeIn = v2.FadeIn or 0.5,
		FadeOut = v2.FadeOut or 0.5,
		Lifetime = v2.Lifetime or 1,
		TransparencyInfluence = v2.TransparencyInfluence or 1,
		AngleInfluence = v2.AngleInfluence or { Vector3.new(), createVector(0, 0, 1.5707964) },
		PulseSpeed = v2.PulseSpeed or 1,
		InnerColor = v2.InnerColor or Color3.new(1, 0.75, 0),
		OuterColor = v2.OuterColor or Color3.new(1, 0, 0)
	}, {
		__index = SpikyFlare
	}):__init()
end

function SpikyFlare:__updateColor(p, p2)
	self.InnerColor = p or Color3.new()
	self.OuterColor = p2 or Color3.new(1, 1, 1)
	local innerColor = self.InnerColor
	self.InnerColorIntensity = math.sqrt(innerColor.R ^ 2 * 0.241 + innerColor.G ^ 2 * 0.691 + innerColor.B ^ 2 * 0.068)
	self.InnerColorIntensity = math.min(1, 1.6 * self.InnerColorIntensity)
	local outerColor = self.OuterColor
	self.OuterColorIntensity = math.sqrt(outerColor.R ^ 2 * 0.241 + outerColor.G ^ 2 * 0.691 + outerColor.B ^ 2 * 0.068)
	self.OuterColorIntensity = math.min(1, 1.75 * self.OuterColorIntensity)
end

function SpikyFlare:UpdateColor(p, p2)
	local Global = require(game.ReplicatedStorage.Global)

	if Global.FastMode then
		return
	end

	self:__updateColor(self.InnerColor or p, self.OuterColor or p2)

	for k, trail in next, self.Trails, nil do
		trail.Color = ColorSequence.new(k == 1 and self.InnerColor or self.OuterColor)
		trail.LightEmission = k == 1 and self.InnerColorIntensity or self.OuterColorIntensity

		if self.TransparencyInfluence then
			trail.Transparency = NumberSequence.new(1 - self.TransparencyInfluence)
		end
	end
end

function SpikyFlare:__init()
	local Global = require(game.ReplicatedStorage.Global)

	if Global.FastMode or self.Attachments then
		return
	end

	self.Lifetime = type(self.Lifetime) == "table" and Random.new():NextNumber(self.Lifetime[1], self.Lifetime[2]) or self.Lifetime
	self.Attachments = {}
	self.Trails = {}

	for i = 1, 2 do
		local attachment = Instance.new("Attachment")
		attachment.CFrame = self.CFrame
		attachment.Parent = workspace.Terrain
		local clone = auraSpike:Clone()
		clone.ZOffset = i == 1 and 0.888 or 1
		table.insert(self.Attachments, attachment)
		table.insert(self.Trails, clone)
	end

	self:UpdateColor()

	for k, trail in next, self.Trails, nil do
		trail.Width0 = self.Scale[2]

		if k == 1 then
			trail.Width1 = self.Scale[1] * 0
		else
			trail.Width1 = self.Scale[1] * 0.75 * 0
		end

		trail.Attachment0 = self.Attachments[2]
		trail.Attachment1 = self.Attachments[1]
		trail.Parent = self.Attachments[1]
	end

	table.insert(v, {
		Object = self,
		Start = tick()
	})
	return self
end

return SpikyFlare