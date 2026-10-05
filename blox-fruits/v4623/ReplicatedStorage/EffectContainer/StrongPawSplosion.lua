local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local currentCamera = workspace.CurrentCamera
local TweenService = game:GetService("TweenService")
local Effect = require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local debris = Util.Debris
local Util2 = require(ReplicatedStorage:WaitForChild("Util"))
local tween = Util2.Tween
local strongPawSplosion = FX:WaitForChild("StrongPawSplosion")
local part = strongPawSplosion.Part
local _ = strongPawSplosion.Dust
local shockwave = strongPawSplosion.Shockwave

local function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
end

local function xzAim(p, p2)
	return CFrame.new(p, p2 * createVector(1, 0, 1) + Vector3.new(0, p.Y))
end

local function Resize(clone, value)
	local numberSequenceKeypoints = {}
	local v = value or 1

	for _, keypoint in next, clone.Size.Keypoints, nil do
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(keypoint.Time, keypoint.Value * v))
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

local function Routine(p, fn)
	local lastTime = tick()
	local v = false

	while tick() - lastTime < p do
		local v2 = tick() - lastTime

		if fn(v2, v2 / p) then
			v = true
			break
		else
			RunService.RenderStepped:Wait()
		end
	end

	if not v then
		fn(p, 1)
	end
end

local function BuildPaw(origin, p)
	local cframe = CFrame.Angles(-1.5707963267948966, 0, 0)
	local cframe2 = CFrame.Angles(0, 0, 0)
	local clones = {}
	local clone = part:Clone()
	clone.Anchored = true
	clone.CanCollide = false
	clone.Color = Color3.new(1, 1, 1)
	clone.Transparency = 0
	clone.CFrame = origin * cframe
	clone.Mesh.Scale = createVector(1, 1, 1) * p
	table.insert(clones, clone)

	for i = 1, 4 do
		local v = -0.7853981633974483 + 0.5235987755982988 * (i - 1)
		local v2 = math.cos(v)
		local v3 = math.sin(v)
		local clone2 = part:Clone()
		clone2.Anchored = true
		clone2.CanCollide = false
		clone2.Color = clone.Color
		clone2.Transparency = clone.Transparency
		clone2.CFrame = origin * cframe * CFrame.new(0, p * 0.8 * v3, p * 0.7 * v2)
		clone2.Mesh.Scale = createVector(1, 1, 1) * p * 0.35
		clone2.Parent = clone
		table.insert(clones, clone2)
	end

	return {
		Offsets = {},
		Parts = clones,
		SetParent = function(self, parent)
			self.Parts[1].Parent = parent
		end,
		Fade = function(self, transparency)
			for _, part2 in next, self.Parts, nil do
				part2.Transparency = transparency
			end
		end,
		Rotate = function(self, p2)
			cframe2 = p2
		end,
		Scale = function(self, p3)
			for k, part2 in next, self.Parts, nil do
				local v = k == 1 and 1 or 0.35
				part2.Mesh.Scale = createVector(1, 1, 1) * p3 * v

				if not (k > 1) then
					continue
				end

				local v2 = -0.7853981633974483 + 0.5235987755982988 * (k - 2)
				local v3 = math.cos(v2)
				local v4 = math.sin(v2)
				local p4 = origin.p
				local p5 = currentCamera.CFrame.p
				part2.CFrame = CFrame.new(p4, p5 * createVector(1, 0, 1) + Vector3.new(0, p4.Y)) * cframe2 * cframe * CFrame.new(
					0,
					p3 * 0.8 * v4,
					p3 * 0.7 * v3
				)
			end
		end,
		Destroy = function(self)
			for _, part2 in next, self.Parts, nil do
				part2:Destroy()
			end
		end
	}
end

return function(data)
	local origin = data.Origin or CFrame.new()
	local scale = data.Scale or 3
	local duration = data.Duration or 1
	spawn(function()
		for i = 1, 10 do
			local clone = shockwave:Clone()
			clone.Transparency = 0.1
			clone.CFrame = origin
			clone.Mesh.Scale = createVector(0, 0, 0)
			clone.Parent = _WorldOrigin
			local tweenInfo = TweenInfo.new(duration * 0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
			local tween2 = TweenService:Create(clone, tweenInfo, {
				Transparency = 1
			})
			local tween3 = TweenService:Create(clone.Mesh, tweenInfo, {
				Scale = createVector(0.005, 0.004, 0.005) * scale * (i / 10 * 1.5 + 1.5)
			})
			tween2.Completed:Connect(function()
				clone:Destroy()
			end)
			tween2:Play()
			tween3:Play()
			wait(duration * 0.1 + duration / 10 * (i / 10))
		end
	end)
	Effect.new("Slash"):replicate({
		CFrame = origin,
		Color = Color3.new(1, 1, 1),
		Width = { 1.5 * scale, 0 },
		Radius = { 0, 1.5 * scale },
		Transparency = { 0.25, 1 },
		Duration = { duration, duration }
	})
	Effect.new("Slash"):replicate({
		CFrame = origin * CFrame.new(0, scale / 2, 0),
		Color = Color3.new(1, 1, 1),
		Width = { 1.5 * scale, 0 },
		Radius = { 0, 1.5 * scale },
		Transparency = { 0.25, 1 },
		Direction = -1,
		Duration = { duration * 0.75, duration * 1.1 }
	})
	local paw = BuildPaw(origin, 0)
	paw:Fade(1)
	paw:SetParent(_WorldOrigin)
	Routine(duration * 0.75, function(p, _)
		local quint = tween.ease.out.quint(p, 0, 1, duration * 0.75)
		paw:Fade(1 + -0.75 * quint)
		paw:Rotate(CFrame.Angles(0, 1.5707963267948966 * quint + 6.283185307179586 * quint, 0))
		paw:Scale(0 + (scale - 0) * quint)
	end)

	for _, v2 in next, {}, nil do
		v2.Particle.Enabled = false
	end

	task.spawn(function()
		Routine(duration * 0.25, function(_, _)
			paw:Scale(scale)
		end)
	end)
	delay(duration * 0.25, function()
		Routine(duration * 0.3, function(p, _)
			local quart = tween.ease["in"].quart(p, 0, 1, duration * 0.3)
			local v2 = scale
			paw:Scale(v2 + (scale * 0.75 - v2) * quart)
			paw:Fade(0.25 + 0.75 * quart)
		end)
		local clone = shockwave:Clone()
		clone.Transparency = 0.1
		clone.CFrame = origin
		clone.Mesh.Scale = createVector(0, 0, 0)
		clone.Parent = _WorldOrigin
		local tweenInfo = TweenInfo.new(duration * 0.75, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local tween2 = TweenService:Create(clone, tweenInfo, {
			Transparency = 1
		})
		local tween3 = TweenService:Create(clone.Mesh, tweenInfo, {
			Scale = createVector(0.005, 0.004, 0.005) * scale * 4.5
		})
		tween2.Completed:Connect(function()
			clone:Destroy()
		end)
		tween2:Play()
		tween3:Play()
		paw:Destroy()
		local attachment = Instance.new("Attachment")
		attachment.CFrame = origin
		local clone2 = FX:WaitForChild("PawSparkle"):Clone()
		clone2.Enabled = false
		clone2.Lifetime = NumberRange.new(duration * 0.5, duration * 0.9)
		clone2.Speed = NumberRange.new(scale * 2, scale * 5)
		clone2.Size = Resize(clone2, scale * 0.5)
		clone2.Parent = attachment
		attachment.Parent = workspace.Terrain
		debris:AddItem(attachment, duration)
		clone2:Emit(12)
	end)
end