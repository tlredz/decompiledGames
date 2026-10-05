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
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
require(interpolationScheme:WaitForChild("PlaySchemes"))

-- equivalent calls inferred from this helper; original call sites unknown
local function insertSoundInto(clone, p)
	local clone2 = xEnemyHit[p]:Clone()
	clone2.Parent = clone
	return clone2
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
	local v3 = time()
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		if syncedEndTime < Workspace:GetServerTimeNow() or enemyRoot == nil or enemyRoot.Parent == nil or projectilePart == nil or projectilePart.Parent == nil then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil
		else
			local v4 = time() - v2

			if time() - v3 > 0.15 then
				v3 = time()
				local clone = xEnemyHit.HitAttachment:Clone()
				destroyAfter(clone, 1)
				clone.Parent = enemyRoot

				for _, child in ipairs(clone:GetChildren()) do
					child:Emit(child:GetAttribute("EmitCount"))
				end

				local clone2 = insertSoundInto(clone, "XHit") -- equivalent call inferred; original call site unknown
				Util.UtilSoundWrapper.Play(clone2, clone.WorldPosition)
				clone2:Destroy()
			end

			v = CFrame.Angles(0, rotPerFrame, 0) * v
			enemyRoot.CFrame = CFrame.lookAt(createVector(0, 0, 0), v) * CFrame.Angles(7 * v4, 5 * v4, 5 * v4) + projectilePart.Position + v * projectilePart.Size.Z * 0.5 + createVector(
				0,
				3,
				0
			)
		end
	end)
end