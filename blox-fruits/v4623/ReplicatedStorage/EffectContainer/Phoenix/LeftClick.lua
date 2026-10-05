local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local vector2 = Vector3.new()
local inverse = CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local leftClickDash = FX:WaitForChild("PhoenixEffects").LeftClickDash
local leftClickWind = FX:WaitForChild("PhoenixEffects").LeftClickWind
local phoenixExplosion2 = FX:WaitForChild("PhoenixEffects").PhoenixExplosion2
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
local PlaySchemes = require(interpolationScheme:WaitForChild("PlaySchemes"))
local Shockwaves = require(script.Parent.Modules:WaitForChild("Shockwaves"))

local function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

local function StopBodyVelocity(char, instance)
	instance:Set(vector2)
	heartbeatLoopFor2(0.1, function(_)
		char.HumanoidRootPart.AssemblyLinearVelocity = vector2
	end, function()
		instance:Destroy()
	end)
	char.Humanoid.PlatformStand = false
end

return function(data)
	local player = data.player
	local victimRootParts = data.victimRootParts
	local char = data.char
	local origin = data.origin
	local explodePos = data.explodePos
	local humanoidRootPart = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart

	if not humanoidRootPart or (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1200 then
		return
	end

	local humanoid = char.Humanoid
	local stateEnabled = humanoid:GetStateEnabled(Enum.HumanoidStateType.FallingDown)
	local stateEnabled2 = humanoid:GetStateEnabled(Enum.HumanoidStateType.Ragdoll)

	if localPlayer == player then
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
	end

	local v = true
	local _ = data.syncedStartTime
	local syncedEndTime = data.syncedEndTime
	local heartbeatConnection = nil
	local RunService = game:GetService("RunService")
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		local serverTimeNow = Workspace:GetServerTimeNow()

		if syncedEndTime - 0.1 < serverTimeNow then
			if heartbeatConnection then
				heartbeatConnection:Disconnect()
				heartbeatConnection = nil
			end

			v = false

			if humanoidRootPart == nil then
				return
			end

			local clone = phoenixExplosion2:Clone()
			clone:SetPrimaryPartCFrame(CFrame.Angles(0, random:NextNumber(0, 6.283185307179586), 0) + explodePos)

			if (explodePos - Workspace.CurrentCamera.CFrame.Position).Magnitude < 240 then
				Util.CameraShaker:ShakeOnce(25, 25, 0.1, 0.8)
			end

			task.spawn(Shockwaves, explodePos, 9, 1, Color3.fromRGB(0, 197, 255), Color3.fromRGB(255, 200, 0))
			clone.Parent = _WorldOrigin
			destroyAfter(clone, PlaySchemes(clone:GetDescendants()) + 1)
		end
	end)
	local fireDir = data.fireDir
	local dashTime = data.dashTime
	local distanceForward = data.distanceForward
	local dragRadius = data.dragRadius
	local clone = leftClickDash:Clone()
	clone:SetPrimaryPartCFrame(CFrame.lookAt(Vector3.new(), fireDir) * inverse + humanoidRootPart.Position + createVector(
		0,
		5,
		0
	))
	clone.Parent = _WorldOrigin
	destroyAfter(clone, PlaySchemes(clone:GetDescendants()) + 1)
	local clone2 = leftClickWind:Clone()
	local inverse2 = CFrame.lookAt(Vector3.new(), createVector(0, -1, 0)):inverse()
	clone2:SetPrimaryPartCFrame(CFrame.lookAt(Vector3.new(), fireDir) * inverse2 + humanoidRootPart.Position - fireDir * 6)
	clone2.Parent = _WorldOrigin
	local playSchemes = PlaySchemes(clone2:GetDescendants())
	destroyAfter(clone2, playSchemes + 1)
	heartbeatLoopFor2(playSchemes, function()
		clone2:SetPrimaryPartCFrame(clone2.PrimaryPart.CFrame - clone2.PrimaryPart.CFrame.Position + humanoidRootPart.Position - fireDir * 6)
	end)
	local velocity = fireDir * (distanceForward / dashTime)
	local v5, v6

	if localPlayer == player then
		v5 = Util.BodyMover.new(char):Create("BodyVelocity", {
			Priority = 2,
			Velocity = velocity,
			MaxForce = createVector(1.2980742e33, 1.2980742e33, 1.2980742e33)
		})
		humanoidRootPart.CFrame = CFrame.lookAt(Vector3.new(), fireDir) * CFrame.Angles(-1.5707963267948966, 0, 0) + humanoidRootPart.Position
		v6 = Util.BodyMover.new(char):Create("BodyGyro", {
			Priority = 2,
			CFrame = humanoidRootPart.CFrame,
			MaxTorque = createVector(1.2980742e33, 1.2980742e33, 1.2980742e33)
		})
	else
		v6 = nil
	end

	if localPlayer == player then
		heartbeatLoopFor2(dashTime, function(_)
			v6.CFrame *= CFrame.Angles(0, 0.4, 0)
			humanoidRootPart.CFrame = v6.CFrame - v6.CFrame.Position + humanoidRootPart.CFrame.Position
		end)
	end

	local v7 = {}
	awaitHeartbeatLoopFor(dashTime, function()
		for k, part in pairs(victimRootParts) do
			if part == nil or typeof(part) ~= "Instance" or not part:IsA("BasePart") or not part:IsDescendantOf(Workspace) or part.Anchored then
				victimRootParts[k] = nil
			else
				local v8 = part.CFrame - part.CFrame.Position + (part.Position - humanoidRootPart.Position)

				if v8.Position.Magnitude < dragRadius and v7[part] == nil then
					v7[part] = v8
				end
			end
		end

		for k, v8 in pairs(v7) do
			if k and k:IsDescendantOf(Workspace) then
				if k and v then
					k.CFrame = v8 + humanoidRootPart.Position
				end
			else
				v7[k] = nil
			end
		end
	end)

	if v5 then
		StopBodyVelocity(char, v5)
	end

	if v6 then
		v6:Destroy()
	end

	if localPlayer == player then
		humanoidRootPart.CFrame = CFrame.lookAt(Vector3.new(), fireDir) + humanoidRootPart.Position
		local v8 = Util.BodyMover.new(char):Create("BodyGyro", {
			Priority = 2,
			CFrame = humanoidRootPart.CFrame,
			MaxTorque = createVector(1.2980742e33, 1.2980742e33, 1.2980742e33)
		})
		heartbeatLoopFor2(0.4, function(_)
			humanoidRootPart.AssemblyLinearVelocity = vector2
			v8.CFrame = CFrame.lookAt(Vector3.new(), fireDir)
		end, function()
			v8.CFrame = CFrame.lookAt(Vector3.new(), fireDir)
			v8:Destroy()
		end)
		task.wait(1)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, stateEnabled)
		humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, stateEnabled2)
	end
end