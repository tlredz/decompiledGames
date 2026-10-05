local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
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
local lightningBolt2 = Util.LightningBolt2
local attachmentPair = Util.AttachmentPair
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

local function insertParticleIntoBody(player, parent, fTeleportDamageParticles2, duration)
	local v2 = fTeleportDamageParticles2.Lifetime.Max + duration + 0.5

	for childName, _ in pairs(v) do
		local child = parent:FindFirstChild(childName)

		if child == nil then
			continue
		end

		local clone = fTeleportDamageParticles2:Clone()
		Util.SetParentOverrideWithColor(clone, child, player, "PortalFruitVFXColor")
		clone.Enabled = true
		clone:Emit(1)
		destroyAfter(clone, v2)
		task.delay(duration, function()
			clone.Enabled = false
		end)
	end
end

return function(data)
	local player = data.player
	local origin = data.origin
	local victimRoot = data.victimRoot

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 300 or victimRoot == nil or victimRoot.Parent == nil then
		return
	end

	local v2 = attachmentPair.new()
	Util.SetParentOverrideWithColor(v2.attachment1, victimRoot, player, "PortalFruitVFXColor")
	local attachment0 = v2.attachment0
	local attachment02 = v2.attachment0
	local unit = (victimRoot.Position - origin).Unit
	attachment0.WorldPosition = origin
	attachment02.WorldAxis = unit
	local v3 = lightningBolt2.new(v2.attachment0, v2.attachment1, random:NextInteger(7, 9))
	v3.CurveSize0 = 0.1
	v3.CurveSize1 = 0.1
	v3.PulseSpeed = 10
	v3.PulseLength = 1000
	v3.Color = Util.WrapColor3Constructor(Color3.new(0.286275, 0.690196, 1), player, "PortalFruitVFXColor")
	local v4 = 2 * v3.Thickness
	heartbeatLoopFor2(0.8, function(p, _, _)
		v3.Thickness = v4 * math.sin(29.4 * p) ^ 2
	end, function()
		v3:Destroy()
		v2:destroy()
	end)
	insertParticleIntoBody(player, victimRoot.Parent, fTeleportDamageParticles, 0.8)
	Util.Sound:Play("PortalDamage", victimRoot)
end