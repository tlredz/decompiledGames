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
local heartShotProjectile = FX:WaitForChild("LoveEffects").HeartShotProjectile
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
return function(data)
	local groundPos = data.groundPos
	local rainTargetRadius = data.rainTargetRadius
	local rainDownArrowsFor = data.rainDownArrowsFor

	if (groundPos - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1500 then
		return
	end

	local clone = heartShotProjectile:Clone()
	clone.Parent = _WorldOrigin
	destroyAfter(clone, rainDownArrowsFor + 2)
	local v = groundPos + createVector(0, 4.5, 0)

	-- equivalent calls inferred from this helper; original call sites unknown
	local function circle(p)
		return v + CFrame.Angles(0, 10 * p, 0) * Vector3.new(rainTargetRadius, 0, 0)
	end

	local total = 0
	heartbeatLoopFor2(rainDownArrowsFor * 1.2, function(p)
		total += 0.022222222222222223 * (1 - p * 0.25)
		local v2 = clone
		local v4 = circle(total) -- equivalent call inferred; original call site unknown
		v2.CFrame = CFrame.lookAt(v4, circle(total + 0.01))
	end)
	task.delay(rainDownArrowsFor * 0.8, function()
		for _, emitter in ipairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end
	end)
end