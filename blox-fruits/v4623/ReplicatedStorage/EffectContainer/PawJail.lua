local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local FX = require(ReplicatedStorage:WaitForChild("FX"))
game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local debris = Util.Debris
local Util2 = require(ReplicatedStorage:WaitForChild("Util"))
local tween = Util2.Tween
local part = FX:WaitForChild("StrongPawSplosion").Part
local pawSparkle = FX:WaitForChild("PawSparkle")

local function lerpNumber(p, p2, p3)
	return p + (p2 - p) * p3
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

local function BuildPaw(origin, scale)
	local cframe = CFrame.Angles(-1.5707963267948966, 0, 0)
	local cframe2 = CFrame.Angles(0, 0, 0)
	local clones = {}
	local clone = part:Clone()
	clone.Anchored = true
	clone.CanCollide = false
	clone.Color = Color3.new(1, 1, 1)
	clone.Transparency = 0
	clone.CFrame = origin * cframe
	clone.Mesh.Scale = createVector(1, 1, 1) * scale
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
		clone2.CFrame = origin * cframe * CFrame.new(0, scale * 0.8 * v3, scale * 0.7 * v2)
		clone2.Mesh.Scale = createVector(1, 1, 1) * scale * 0.35
		clone2.Parent = clone
		table.insert(clones, clone2)
	end

	return {
		Parts = clones,
		SetParent = function(self, parent)
			self.Parts[1].Parent = parent
		end,
		SetColor = function(self, color)
			for _, part2 in next, self.Parts, nil do
				part2.Color = color
			end
		end,
		Fade = function(self, transparency)
			for _, part2 in next, self.Parts, nil do
				part2.Transparency = transparency
			end
		end,
		Rotate = function(_, p)
			cframe2 = p
		end,
		Scale = function(self, p2)
			for k, part2 in next, self.Parts, nil do
				local v = k == 1 and 1 or 0.35
				part2.Mesh.Scale = createVector(1, 1, 1) * p2 * v

				if not (k > 1) then
					continue
				end

				local v2 = -0.7853981633974483 + 0.5235987755982988 * (k - 2)
				local v3 = math.cos(v2)
				local v4 = math.sin(v2)
				part2.CFrame = origin * cframe2 * cframe * CFrame.new(0, p2 * 0.8 * v4, p2 * 0.7 * v3)
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
	local origin = data.Origin or CFrame.new() * CFrame.Angles(0, 1.5707963267948966, 0)
	local color = data.Color or Color3.fromRGB(255, 89, 89)
	local transparency = data.Transparency or 0.25
	local scale = data.Scale or 8
	local duration = data.Duration or 5
	local paw = BuildPaw(origin, scale)
	paw:SetColor(color)
	paw:Fade(transparency)
	paw:SetParent(_WorldOrigin)
	local paw2 = BuildPaw(origin, scale)
	paw2:SetColor(color)
	paw2:Fade(transparency * 3)
	paw2:SetParent(_WorldOrigin)
	local total = 3.141592653589793
	local total2 = 0
	Routine(duration, function(_)
		total += 0.08333333333333333
		total2 += 0.08333333333333333
		paw:Fade(transparency - transparency * 0.5 * math.sin(total))
		paw2:Fade(transparency * 3 - transparency * 0.5 * math.sin(total2))
		paw:Scale(scale + scale * 0.15 * math.sin(total))
		paw2:Scale(scale + scale * 0.3 * math.sin(total2))
	end)
	Routine(0.5, function(p)
		local back = tween.ease["in"].back(p, 0, 1, 0.5)
		local v3 = scale
		paw:Scale(v3 + (0 - v3) * back)
		local v4 = scale
		paw2:Scale(v4 + (0 - v4) * back)
	end)
	paw:Destroy()
	paw2:Destroy()
	local attachment = Instance.new("Attachment")
	attachment.CFrame = CFrame.new(origin.p)
	local clone = pawSparkle:Clone()
	clone.Enabled = false
	clone.Lifetime = NumberRange.new(0.5)
	clone.Speed = NumberRange.new(scale * 3, scale * 6)
	clone.Color = ColorSequence.new(color)
	clone.Size = Resize(clone, scale * 0.75)
	clone.Parent = attachment
	attachment.Parent = workspace.Terrain
	clone:Emit(15)
	debris:AddItem(attachment, clone.Lifetime.Max)
end