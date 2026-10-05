workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("RunService")
game:GetService("TweenService")
require(ReplicatedStorage:WaitForChild("Effect"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)

local function lerp(p, p2, p3)
	return p + (p2 - p) * p3
end

local function viewerIsClose(p, p2, callback)
	local character = game.Players.LocalPlayer.Character

	if character ~= nil then
		local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoidRootPart and (humanoidRootPart.Position - p).magnitude <= p2 then
			callback((p - humanoidRootPart.Position).magnitude)
		end
	end
end

local flashStep = FX:WaitForChild("RaceAwakenings").Human.FlashStep

for _, descendant in ipairs(flashStep:GetDescendants()) do
	if not (descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("PointLight")) then
		continue
	end

	descendant.Enabled = false
end

game:GetService("ReplicatedStorage")
local sound = Util.Sound
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _WorldOrigin = workspace._WorldOrigin

-- equivalent calls inferred from this helper; original call sites unknown
local function hueShift(value, p)
	local HSV, v, v2 = value:ToHSV()
	return Color3.fromHSV((HSV + p) % 1, v, v2)
end

local function hueShiftColorSequence(color, p)
	local keypoints = color.Keypoints
	local colorSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		colorSequenceKeypoints[i] = ColorSequenceKeypoint.new(keypoint.Time, hueShift(keypoint.Value, p))
	end

	return ColorSequence.new(colorSequenceKeypoints)
end

local function flashStepVFX(data)
	local originPos = data.originPos
	local goalPos = data.goalPos

	if typeof(originPos) == "CFrame" then
		originPos = originPos.Position
	end

	if typeof(goalPos) == "CFrame" then
		goalPos = goalPos.Position
	end

	sound:Play("DodgeQuick", originPos)
	sound:Play("DodgeQuick", goalPos)
	local clone = flashStep:Clone()
	local v = -0.64

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") or descendant:IsA("Beam") or descendant:IsA("PointLight") then
			descendant.Enabled = false

			if typeof(descendant.Color) == "ColorSequence" then
				descendant.Color = hueShiftColorSequence(descendant.Color, v)
			elseif typeof(descendant.Color) == "Color3" then
				descendant.Color = hueShift(descendant.Color, v)
			end
		elseif descendant.ClassName == "Script" then
			descendant:Destroy()
		end
	end

	clone.Origin:SetPrimaryPartCFrame(CFrame.new(originPos) * CFrame.Angles(-1.5707963267948966, 0, 0))
	clone.Target:SetPrimaryPartCFrame(CFrame.new(goalPos) * CFrame.Angles(-1.5707963267948966, 0, 0))
	clone.Parent = _WorldOrigin
	task.delay(4, function()
		if clone and clone.Parent ~= nil then
			clone:Destroy()
		end
	end)
	local descendants = {}
	local descendants2 = {}
	local descendants3 = {}

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			table.insert(descendants, descendant)
		elseif descendant:IsA("Beam") then
			table.insert(descendants2, descendant)
		elseif descendant:IsA("PointLight") then
			table.insert(descendants3, descendant)
		end
	end

	local v2 = data.Root and data.Root.Size.Y / 2 or 1

	for _, descendant in pairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			Util.Misc.ScaleParticle(descendant, v2)
		elseif descendant:IsA("PointLight") then
			descendant.Range *= v2
		elseif descendant:IsA("Attachment") then
			descendant.Position *= v2
		end
	end

	for _, v3 in ipairs(descendants3) do
		v3.Brightness = 0
		v3.Enabled = true
		local v4 = v3
		heartbeatLoopFor2(0.1, function(p, p2, p3)
			v4.Brightness = p3 * 3
		end)
	end

	for _, v3 in ipairs(descendants) do
		v3.Enabled = true
		v3:Emit((math.ceil(v3.Rate * 0.1)))
	end

	for _, v3 in ipairs(descendants2) do
		local brightness = v3.Brightness
		local lightEmission = v3.LightEmission
		v3.Brightness = 0
		v3.LightEmission = 1
		v3.Enabled = true
		local v4 = v3
		heartbeatLoopFor2(0.1, function(p, p2, p3)
			v4.Brightness = brightness * p3
			v4.LightEmission = 1 + (lightEmission - 1) * p3
		end)
	end

	task.wait(0.12000000000000001)

	for _, v3 in ipairs(descendants3) do
		local v4 = v3
		local v5 = v3
		heartbeatLoopFor2(0.1, function(p, p2, p3)
			v4.Brightness = (1 - p3) * 3
		end, function()
			v5.Enabled = false
		end)
	end

	for _, v3 in ipairs(descendants) do
		v3.Enabled = false
	end

	for _, v3 in ipairs(descendants2) do
		local v4 = v3
		local brightness = v3.Brightness
		local lightEmission = v3.LightEmission
		local width = v3.Width0
		local width2 = v3.Width1
		local v9 = v3
		heartbeatLoopFor2(0.06, function(p, p2, p3)
			v4.Brightness = brightness * (1 - p3)
			v4.LightEmission = lightEmission + (1 - lightEmission) * p3
			v4.Width0 = width * (1 - p3)
			v4.Width0 = width2 * (1 - p3)
		end, function()
			v9.Enabled = false
		end)
	end
end

return flashStepVFX