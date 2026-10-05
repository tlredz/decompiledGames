local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local inverse = CFrame.lookAt(Vector3.new(), createVector(-1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { Workspace.Map }
local CreatePortal = require(script.Parent:WaitForChild("CreatePortal"))
return function(data)
	local player = data.player
	local hrp = data.hrp
	local origin = data.origin
	local fireDir = data.fireDir
	local _ = data.forwardCylinderRadius
	local timeUntilReachedEndPoint = data.timeUntilReachedEndPoint
	local _ = data.victimExists
	local endPoint = data.endPoint
	local _ = data.forwardCylinderLength

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 600 then
		return
	end

	hrp.Parent:FindFirstChildOfClass("Humanoid")
	Util.Sound:Play("PortalDash", hrp)
	local origin2 = origin + fireDir * 9 + createVector(0, 3, 0)
	local unit = (endPoint - origin2).Unit
	CreatePortal({
		player = player,
		origin = origin2,
		lookDir = unit,
		lastsFor = 1.5,
		emitLightShockwave = true
	})
	local magnitude = (endPoint - origin2).Magnitude

	if player == localPlayer and hrp.Anchored == false then
		local zPortalDashPose = Util.Anims:Get(hrp.Parent, "ZPortalDashPose")
		zPortalDashPose.Looped = true
		zPortalDashPose.Priority = Enum.AnimationPriority.Action
		zPortalDashPose:Play()
		local v2 = Util.BodyMover.new(hrp.Parent):Create("BodyPosition", {
			Position = hrp.Position,
			P = 50000,
			D = 100,
			Duration = timeUntilReachedEndPoint + 0.1
		})
		local ray, _, _ = Util.Ray(hrp.Position, origin2 - hrp.Position, { Workspace.Characters, Workspace.Enemies })

		if ray == nil then
			hrp.CFrame = CFrame.lookAt(origin2, origin2 + unit)
		end

		local position = hrp.Position
		local connection = nil
		connection = heartbeatLoopFor2(timeUntilReachedEndPoint, function(_, _, p)
			local v3 = CFrame.lookAt(origin2, origin2 + unit) * CFrame.new(0, 0, -p * magnitude)
			local ray2, _, _ = Util.Ray(position, v3.Position - position, { Workspace.Characters, Workspace.Enemies })

			if ray2 == nil then
				v2:Set(v3.p)
				position = v3.Position
			else
				connection:Disconnect()
				connection = nil
				zPortalDashPose:Stop()
			end
		end, function()
			local v3 = CFrame.lookAt(origin2, origin2 + unit) * CFrame.new(0, 0, -1 * magnitude)
			local ray2, _, _ = Util.Ray(position, v3.Position - position, { Workspace.Characters, Workspace.Enemies })

			if ray2 == nil then
				v2:Set(v3.p)
				position = v3.Position
				zPortalDashPose:Stop()
				wait()
				v2:Destroy()
			else
				connection:Disconnect()
				connection = nil
			end
		end)
	end

	local clone = FX:WaitForChild("PortalEffects").DashAura:Clone()
	local objectSpace = clone:GetAttribute("ObjectSpace")
	local cframe = CFrame.lookAt(origin2, origin2 + unit)
	clone:PivotTo(CFrame.lookAt(createVector(0, 0, 0), unit) * inverse + cframe:PointToWorldSpace(objectSpace))
	Util.SetParentOverrideWithColor(clone, _WorldOrigin, player, "PortalFruitVFXColor")
	destroyAfter(clone, timeUntilReachedEndPoint + 1)
	heartbeatLoopFor2(timeUntilReachedEndPoint, function(_, _, p)
		local cframe2 = CFrame.lookAt(origin2, origin2 + unit) * CFrame.new(0, 0, -p * magnitude)
		clone:PivotTo(CFrame.lookAt(createVector(0, 0, 0), unit) * inverse + cframe2:PointToWorldSpace(objectSpace))
	end, function()
		clone.BeamInner.Beams:Destroy()
		clone.BeamInnerDark.Beams:Destroy()
	end)
	local clone2 = FX:WaitForChild("PortalEffects").PortalDashLines:Clone()
	clone2.CFrame = CFrame.lookAt(createVector(0, 0, 0), unit) + origin2
	Util.SetParentOverrideWithColor(clone2, _WorldOrigin, player, "PortalFruitVFXColor")
	destroyAfter(clone2, 1.5)

	for _, child in ipairs(clone2:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end
end