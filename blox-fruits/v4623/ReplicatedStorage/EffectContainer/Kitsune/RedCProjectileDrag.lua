local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local xEnemyHit = FX:WaitForChild("TigerEffects").X_Untrans.XEnemyHit
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))

local function insertSoundInto(parent, p)
	local clone = xEnemyHit[p]:Clone()
	clone.Parent = parent
	return clone
end

return function(data)
	local enemyRoot = data.enemyRoot
	local projectilePart = data.projectilePart
	local _ = data.victimRootParts
	local syncedEndTime = data.syncedEndTime
	local initVec = data.initVec
	local rotPerFrame = data.rotPerFrame

	if enemyRoot == nil or enemyRoot.Parent == nil or (enemyRoot.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1100 then
		return
	end

	if projectilePart then
		projectilePart.CanCollide = false
	end

	local heartbeatConnection = nil
	local v = initVec
	local v2 = time()
	time()
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if syncedEndTime < Workspace:GetServerTimeNow() or enemyRoot == nil or enemyRoot.Parent == nil or projectilePart == nil or projectilePart.Parent == nil then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		else
			local v3 = time() - v2
			v = CFrame.Angles(0, rotPerFrame, 0) * v
			enemyRoot.CFrame = CFrame.lookAt(createVector(0, 0, 0), v) * CFrame.Angles(7 * v3, 5 * v3, 5 * v3) + projectilePart.Position + v * projectilePart.Size.Z * 0.5 + createVector(
				0,
				3,
				0
			)
		end
	end)
end