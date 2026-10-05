local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(-1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local fTeleportDamageParticles = FX:WaitForChild("PortalEffects").FTeleportDamageParticles
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { Workspace.Map }
require(script.Parent:WaitForChild("CreatePortal"))
local v = {
	RightLowerLeg = 1,
	RightUpperLeg = 1,
	LeftLowerLeg = 1,
	LeftUpperLeg = 1,
	UpperTorso = 1,
	LowerTorso = 1,
	Head = 1,
	LeftUpperArm = 1,
	LeftLowerArm = 1,
	RightUpperArm = 1,
	RightLowerArm = 1
}

local function insertParticleIntoBody(playerFromCharacter, parent, fTeleportDamageParticles2, duration)
	local v2 = fTeleportDamageParticles2.Lifetime.Max + duration + 0.5

	for childName, _ in pairs(v) do
		local child = parent:FindFirstChild(childName)

		if child == nil then
			continue
		end

		local clone = fTeleportDamageParticles2:Clone()
		Util.SetParentOverrideWithColor(clone, child, playerFromCharacter, "PortalFruitVFXColor")
		clone.Enabled = true
		clone:Emit(1)
		destroyAfter(clone, v2)
		task.delay(duration, function()
			clone.Enabled = false
		end)
	end
end

return function(data)
	local _ = data.player
	local rootTeleported = data.rootTeleported
	local _ = data.teleportCFrame
	local wasDamagedByTeleport = data.wasDamagedByTeleport
	local currentCamera = Workspace.CurrentCamera

	if (rootTeleported.Position - currentCamera.CFrame.Position).Magnitude > 2500 then
		return
	end

	local parent = rootTeleported.Parent
	local Players2 = game:GetService("Players")
	local playerFromCharacter = Players2:GetPlayerFromCharacter(parent)

	if playerFromCharacter == localPlayer then
		heartbeatLoopFor2(1.5, function(p)
			currentCamera.FieldOfView = math.sin(p * 60) * 5 * math.exp(-p * 4) + 70
		end, function()
			currentCamera.FieldOfView = 70
		end)
	end

	Util.Sound:Play("PortalFTeleport", rootTeleported)

	if wasDamagedByTeleport == true then
		insertParticleIntoBody(playerFromCharacter, parent, fTeleportDamageParticles, 1.2)
		Util.Sound:Play("PortalDamage", rootTeleported)
	end
end