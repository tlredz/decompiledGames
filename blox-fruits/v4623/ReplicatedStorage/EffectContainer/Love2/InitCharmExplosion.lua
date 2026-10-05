local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local loveCharm = FX:WaitForChild("LoveEffects").LoveCharm
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function emitWithDelay(emitter)
	local emitDelay = emitter:GetAttribute("EmitDelay")

	if emitDelay then
		task.delay(emitDelay, function()
			emitter:Emit(emitter:GetAttribute("EmitCount") * 0.33)
		end)
	else
		emitter:Emit(emitter:GetAttribute("EmitCount") * 0.33)
	end
end

return function(p)
	local root = p.root
	local currentCamera = Workspace.CurrentCamera

	if root == nil or root.Parent == nil or (root.Position - currentCamera.CFrame.Position).Magnitude > 1000 then
		return
	end

	local clone = loveCharm.CirclePart2:Clone()
	clone.Anchored = false
	clone.CFrame = root.CFrame:ToWorldSpace(CFrame.new(0, -2.25018167, 0, 0, 0, -1, 0, 1, 0, 1, 0, 0))
	clone.Parent = _WorldOrigin
	local weldConstraint = Instance.new("WeldConstraint", clone)
	weldConstraint.Part0 = clone
	weldConstraint.Part1 = root
	destroyAfter(clone, 4)
	local play = Util.Sound:Play("LoveV2CharmedInit", root)
	play.PlaybackSpeed = random:NextNumber(1.4, 1.6)

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitWithDelay(emitter)
		end
	end
end