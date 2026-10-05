local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local loveShockwave = FX:WaitForChild("LoveEffects").LoveShockwave
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function ScaleParticle(descendant, p)
	local keypoints = descendant.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	descendant.Size = NumberSequence.new(numberSequenceKeypoints)
	descendant.Speed = NumberRange.new(descendant.Speed.Min * p, descendant.Speed.Max * p)
	descendant.Acceleration *= p
end

local function emitWithDelay(emitter)
	local emitDelay = emitter:GetAttribute("EmitDelay")

	if emitDelay then
		task.delay(emitDelay, function()
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end)
	else
		emitter:Emit(emitter:GetAttribute("EmitCount"))
	end
end

local v = {
	"rbxassetid://8313797644",
	"rbxassetid://8313742436",
	"rbxassetid://8313749259",
	"rbxassetid://8313756846",
	"rbxassetid://8313761878",
	"rbxassetid://8313768156",
	"rbxassetid://8313773106",
	"rbxassetid://8313780127",
	"rbxassetid://8314338712",
	"rbxassetid://8314340888",
	"rbxassetid://8314344719",
	"rbxassetid://8314350294",
	""
}
return function(p)
	local originCF = p.originCF
	local shockwaveRadius = p.shockwaveRadius
	local currentCamera = Workspace.CurrentCamera

	if (originCF.Position - currentCamera.CFrame.Position).Magnitude > 900 then
		return
	end

	local clone = loveShockwave:Clone()
	local v2 = shockwaveRadius / 28

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("ParticleEmitter") then
			ScaleParticle(descendant, v2)
		elseif descendant:IsA("SpecialMesh") then
			descendant.Scale *= v2
		elseif descendant:IsA("Attachment") then
			descendant.Position *= v2
		elseif descendant:IsA("BasePart") then
			descendant.Position *= v2
		end
	end

	clone:PivotTo(originCF - createVector(0, 2.2, 0))
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 4)
	local wind = clone.Wind
	local wind2 = clone.Wind2
	local v3 = wind.Mesh.Scale * 0.1

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitWithDelay(emitter)
		end
	end

	Util.Sound:Play("LoveC", clone.PrimaryPart.Position)
	task.wait(0.1)
	task.spawn(function()
		heartbeatLoopFor2(1, function(_, p2, p3)
			wind.CFrame *= CFrame.Angles(0, 0.017453292519943295 * p2 * -150, 0)
			wind2.CFrame *= CFrame.Angles(0, 0.017453292519943295 * p2 * 150, 0)
			wind.Mesh.Scale = v3 * (createVector(1, 1, 1) + createVector(17.5, 17.5, 17.5) * p3 ^ 0.5)
			wind2.Mesh.Scale = wind.Mesh.Scale
		end)

		for _, texture in ipairs(v) do
			wind.Decal.Texture = texture
			wind2.Decal.Texture = texture
			task.wait(0.0485)
		end
	end)
	local _ = (clone.PrimaryPart.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 200 + shockwaveRadius
end