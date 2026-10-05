local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
ReplicatedStorage:WaitForChild("Assets")
local FX = require(game.ReplicatedStorage.FX)
local dough = FX:WaitForChild("Dough")
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))

local function scaleDonut(model, value, unitSize, value2)
	if not (model and model:IsA("Model") and model.PrimaryPart) then
		return
	end

	local v = value or 1
	local v2 = unitSize or createVector(1, 1, 1)

	if not model.PrimaryPart:GetAttribute("Size") then
		model.PrimaryPart:SetAttribute("Size", model.PrimaryPart.Size)
	end

	if not model.Haki:GetAttribute("Size") then
		model.Haki:SetAttribute("Size", model.Haki.Size)
	end

	if not model.Haki:GetAttribute("Offset") then
		model.Haki:SetAttribute("Offset", model.PrimaryPart.CFrame:ToObjectSpace(model.Haki.CFrame).p)
	end

	if not model.Outline:GetAttribute("Size") then
		model.Outline:SetAttribute("Size", model.Outline.Size)
	end

	if not model.Outline:GetAttribute("Offset") then
		model.Outline:SetAttribute("Offset", model.PrimaryPart.CFrame:ToObjectSpace(model.Outline.CFrame).p)
	end

	model.PrimaryPart.Size = v2 * v
	model.Haki.Size = model.Haki:GetAttribute("Size") / model.PrimaryPart:GetAttribute("Size") * v2 * v
	model.Outline.Size = model.Outline:GetAttribute("Size") / model.PrimaryPart:GetAttribute("Size") * v2 * v * (model.Outline:GetAttribute("Scale") or 1) * (value2 or 1)
	model.Haki.CFrame = model.PrimaryPart.CFrame + model.Haki:GetAttribute("Offset") * v
	model.Outline.CFrame = model.PrimaryPart.CFrame + model.Outline:GetAttribute("Offset") * v
end

local function darkenColor(p, p2)
	return (p2 or Color3.new(0.1, 0.1, 0.1)):Lerp(p or Color3.new(1, 1, 1), 0.5):Lerp(Color3.new(), 0.575)
end

local Effect = {}

function Effect.new(data)
	local v = {
		Buso = data.Buso,
		Anchor = data.Anchor or data.Root,
		EffectPart = data.EffectPart
	}
	local unitSize = data.UnitSize
	local v2 = math.min(unitSize.X, unitSize.Y, unitSize.Z)
	local v3 = math.max(unitSize.X, unitSize.Y, unitSize.Z)
	v.UnitSize = Vector3.new(v3, v3, v2 * 1.5)
	v.Scale = data.Scale or 1
	v.CFrame = data.Offset or data.CFrame or CFrame.Angles(0, 1.5707963267948966, 0)
	v.FlameParticleRateInfluence = 1
	v.ParticleRateInfluence = 1
	v.RevolutionsPerSecond = 0
	v.Rotation = 0
	return setmetatable(v, {
		__index = Effect
	}):__init()
end

function Effect:__scale(p)
	local scale = p or self.Scale
	self.Scale = scale
	scaleDonut(self.Model, scale, self.UnitSize)

	for _, particle in pairs(self.Particles) do
		for _, v2 in pairs(particle) do
			if v2.Object then
				Util.Misc.ScaleParticle(v2.Object, self.Scale * 2, v2.Data)
			else
				for _, v3 in pairs(v2) do
					Util.Misc.ScaleParticle(v3.Object, self.Scale * 2, v3.Data)
				end
			end
		end
	end
end

function Effect:__init()
	self.Attachments = {
		Sides = {
			self.EffectPart:FindFirstChild("LeftDriftAttachment"),
			self.EffectPart:FindFirstChild("RightDriftAttachment")
		},
		Head = self.EffectPart:FindFirstChild("HeadAttachment")
	}
	self.Particles = {
		Generic = {},
		Left = {
			Flames = {},
			Debris = {},
			Water = {}
		},
		Right = {
			Flames = {},
			Debris = {},
			Water = {}
		}
	}

	for i = 1, 2 do
		local v = i == 1 and "Left" or "Right"
		local particle = self.Particles[v]

		for _, v2 in pairs({
			dough.Particles.Wheel.Debris,
			dough.Particles.Wheel.Flames,
			dough.Particles.Wheel.Water[v],
			dough.Particles.Wheel.Water.Generic
		}) do
			for _, child in pairs(v2:GetChildren()) do
				local v3 = particle[v2.Name] or particle[v2.Parent.Name]
				local clone = child:Clone()

				if v2.Name == "Flames" and child.Name == "Sparks" then
					clone.EmissionDirection = i == 1 and Enum.NormalId.Top or Enum.NormalId.Bottom
				end

				local v4 = {
					Size = clone.Size.Keypoints,
					Speed = clone.Speed,
					Rate = clone.Rate,
					Acceleration = clone.Acceleration,
					ZOffset = clone.ZOffset,
					LockedToPart = clone.LockedToPart
				}
				Util.Misc.ScaleParticle(clone, self.Scale * 2, v4)
				clone.Parent = self.Attachments.Sides[i]
				table.insert(v3, {
					Object = clone,
					Data = v4
				})
			end
		end
	end

	for _, child in pairs(dough.Particles.Wheel.Motion:GetChildren()) do
		local clone = child:Clone()
		local v = {
			Size = clone.Size.Keypoints,
			Speed = clone.Speed,
			Rate = clone.Rate,
			Acceleration = clone.Acceleration,
			ZOffset = clone.ZOffset,
			LockedToPart = clone.LockedToPart
		}
		Util.Misc.ScaleParticle(clone, self.Scale * 2, v)
		clone.Parent = self.EffectPart
		table.insert(self.Particles.Generic, {
			Object = clone,
			Data = v
		})
	end

	self.Model = dough.Models.Wheel.Model:Clone()
	self.Model.Name = "DoughWheel"
	local __getCFrame = self:__getCFrame()
	self:__scale()
	self:enable()
	self.Model:SetPrimaryPartCFrame(__getCFrame)
	self.Model.Parent = _WorldOrigin
	return self
end

function Effect:__paint()
	local buso = self.Buso

	if typeof(buso) == "Instance" then
		buso = buso.Color
	end

	for _, child in pairs(self.Model:GetChildren()) do
		if child.Name == "Outline" then
			if buso and typeof(buso) == "Color3" then
				child.Color = buso
			else
				child.Color = Color3.new()
			end
		elseif child.Name == "Haki" then
			if typeof(buso) == "Color3" then
				child.Color = darkenColor(buso)
			else
				child.Color = darkenColor(Color3.new())
			end
		end
	end
end

function Effect.clear(p, p2, p3)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function handleParticle(_, p4)
		p4.Object:Clear()
	end

	for k, particle in pairs(p.Particles) do
		if not (p2 == "All" or p2 == k) then
			continue
		end

		for k2, v in pairs(particle) do
			if v.Object then
				if p3 == nil then
					handleParticle(nil, v) -- equivalent call inferred; original call site unknown
				end
			elseif p3 == "All" or p3 == k2 then
				for _, v2 in pairs(v) do
					handleParticle(nil, v2) -- equivalent call inferred; original call site unknown
				end
			end
		end
	end
end

function Effect.lock(p, p2, p3, lockedToPart)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function handleParticle(_, p4)
		p4.Object.LockedToPart = lockedToPart
	end

	for k, particle in pairs(p.Particles) do
		if not (p2 == "All" or p2 == k) then
			continue
		end

		for k2, v in pairs(particle) do
			if v.Object then
				if p3 == nil then
					handleParticle(nil, v) -- equivalent call inferred; original call site unknown
				end
			elseif p3 == "All" or p3 == k2 then
				for _, v2 in pairs(v) do
					handleParticle(nil, v2) -- equivalent call inferred; original call site unknown
				end
			end
		end
	end
end

function Effect.setColor(p, p2, p3, p4)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function handleParticle(_, p5)
		p5.Object.Color = ColorSequence.new(p4)
	end

	for k, particle in pairs(p.Particles) do
		if not (p2 == "All" or p2 == k) then
			continue
		end

		for k2, v in pairs(particle) do
			if v.Object then
				if p3 == nil then
					handleParticle(nil, v) -- equivalent call inferred; original call site unknown
				end
			elseif p3 == "All" or p3 == k2 then
				for _, v2 in pairs(v) do
					handleParticle(nil, v2) -- equivalent call inferred; original call site unknown
				end
			end
		end
	end
end

function Effect:enable(p, p2, enabled)
	-- equivalent calls inferred from this helper; original call sites unknown
	local function handleParticle(k, p3)
		local flameParticleRateInfluence = k == "Flames" and self.FlameParticleRateInfluence or self.ParticleRateInfluence
		p3.Object.Enabled = enabled
		p3.Object.Rate = p3.Data.Rate * flameParticleRateInfluence

		if enabled then
			p3.Object.LockedToPart = p3.Data.LockedToPart
		end
	end

	for k, particle in pairs(self.Particles) do
		if not (p == "All" or p == k) then
			continue
		end

		for k2, v in pairs(particle) do
			if v.Object then
				if p2 == nil then
					handleParticle(k2, v) -- equivalent call inferred; original call site unknown
				end
			elseif p2 == "All" or p2 == k2 then
				for _, v2 in pairs(v) do
					handleParticle(k2, v2) -- equivalent call inferred; original call site unknown
				end
			end
		end
	end
end

function Effect:__getCFrame()
	local identity = CFrame.identity

	if typeof(self.Anchor) ~= "Instance" or not self.Anchor:IsDescendantOf(workspace) then
		return (self.LastCFrame or identity) * self.CFrame
	end

	if self.Anchor:IsA("Attachment") then
		identity = self.Anchor.WorldCFrame
	else
		identity = self.Anchor.CFrame
	end

	self.LastCFrame = identity
	return (self.LastCFrame or identity) * self.CFrame
end

function Effect:update(value)
	self:__paint()
	self.Rotation = self.Rotation % 6.283185307179586 + 6.283185307179586 * self.RevolutionsPerSecond * (value or 0.016666666666666666)
	self.Model:SetPrimaryPartCFrame(self:__getCFrame() * CFrame.Angles(0, 0, -self.Rotation))
end

function Effect:Destroy()
	self.Model:Destroy()
end

return Effect