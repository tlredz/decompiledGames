local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
game:GetService("TweenService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local yoru = FX:WaitForChild("Yoru")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local _ = Util.LightningBolt
return function(data)
	local stage = data.Stage or 1
	local _ = data.player
	local hrp = data.hrp

	if hrp == nil or hrp.Parent == nil then
		return
	end

	local _ = hrp.Parent
	local currentCamera = Workspace.CurrentCamera

	if (hrp.CFrame.Position - currentCamera.CFrame.Position).Magnitude > 500 then
		return
	end

	local child = yoru:FindFirstChild(string.format("Yoru%sSkill1", stage == 2 and "V2" or stage == 3 and "V3" or ""))

	if not child then
		return
	end

	local origin = data.origin
	local fireDir = data.fireDir
	local v = CFrame.lookAt(createVector(0, 0, 0), fireDir) * CFrame.new(0, 0, -10) + origin
	local clone = child.Start:Clone()
	clone.CFrame = v * CFrame.new(0, 3.5, 0) * CFrame.new(0, 1, 0)
	clone.Parent = _WorldOrigin
	destroyAfter(clone, 4)

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount"))
		end
	end
end