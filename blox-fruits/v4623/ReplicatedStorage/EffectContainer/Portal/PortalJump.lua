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
local portalJumpTrail = FX:WaitForChild("PortalEffects").PortalJumpTrail
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { Workspace.Map }
require(script.Parent:WaitForChild("CreatePortal"))
return function(p)
	local player = p.player
	local hrp = p.hrp
	local currentCamera = Workspace.CurrentCamera

	if (hrp.Position - currentCamera.CFrame.Position).Magnitude > 2500 then
		return
	end

	if player == localPlayer then
		local portalFlip = Util.Anims:Get(hrp.Parent, "PortalFlip")
		portalFlip.Priority = Enum.AnimationPriority.Action2
		portalFlip:Play()
	end

	for i = 1, 2 do
		local v = hrp.Parent[i == 1 and "LeftHand" or "RightHand"]
		local clone = portalJumpTrail.A0:Clone()
		local clone2 = portalJumpTrail.A1:Clone()
		Util.SetParentOverrideWithColor(clone, v, player, "PortalFruitVFXColor")
		Util.SetParentOverrideWithColor(clone2, v, player, "PortalFruitVFXColor")
		local trail1 = clone.Trail1
		local trail12 = clone.Trail1
		trail1.Attachment0 = clone
		trail12.Attachment1 = clone2
		clone.Trail1.Enabled = true
		local v2 = clone.Trail1.Lifetime + 1.5
		destroyAfter(clone, v2)
		destroyAfter(clone2, v2)
		task.delay(0.6, function()
			clone.Trail1.Enabled = false
		end)
	end
end