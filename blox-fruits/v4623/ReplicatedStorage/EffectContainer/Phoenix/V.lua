local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local vector2 = Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
local inverse = CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local phoenixV = FX:WaitForChild("PhoenixEffects").PhoenixV
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
local PlaySchemes = require(interpolationScheme:WaitForChild("PlaySchemes"))

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
	local char = data.char
	local origin = data.origin
	local isTransformed = data.isTransformed
	local flyUpDistance = data.flyUpDistance
	local flyUpTime = data.flyUpTime
	local humanoidRootPart = char.HumanoidRootPart
	local humanoid = char.Humanoid

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1200 or isTransformed == false then
		return
	end

	local v = flyUpDistance / flyUpTime
	local velocity = createVector(0, 1, 0) * v
	local v3

	if localPlayer == player then
		humanoid.PlatformStand = true
		humanoid.Sit = false
		v3 = Util.BodyMover.new(char):Create("BodyVelocity", {
			Velocity = velocity,
			MaxForce = createVector(1.2980742e33, 1.2980742e33, 1.2980742e33)
		})
	end

	local clone = phoenixV:Clone()
	clone.Parent = _WorldOrigin
	local playSchemes = PlaySchemes(clone.Passive.Char:GetDescendants())
	destroyAfter(clone.Passive.Char, playSchemes + 1)
	local ray, v5, _ = Util.Ray(
		humanoidRootPart.Position + createVector(0, 10, 0),
		createVector(-0, -10, -0) + createVector(0, -1, 0) * flyUpDistance * 1.1,
		{ Workspace.Characters, Workspace.Enemies },
		false
	)

	if ray == nil then
		v5 = nil
	end

	if v5 then
		clone.Passive.Ground:SetPrimaryPartCFrame(CFrame.new(v5 + createVector(0, 0.7, 0)))
		local playSchemes2 = PlaySchemes(clone.Passive.Ground:GetDescendants())
		destroyAfter(clone.Passive.Ground, playSchemes2 + 1)
	end

	local lookVector = humanoidRootPart.CFrame.LookVector
	local v6

	if localPlayer == player then
		v6 = Util.BodyMover.new(char):Create("BodyGyro", {
			CFrame = humanoidRootPart.CFrame,
			MaxTorque = createVector(1.2980742e33, 1.2980742e33, 1.2980742e33)
		})
	else
		v6 = nil
	end

	awaitHeartbeatLoopFor(flyUpTime, function()
		clone.Passive.Char:SetPrimaryPartCFrame(CFrame.lookAt(
			humanoidRootPart.Position,
			humanoidRootPart.Position + lookVector * createVector(1, 0.1, 1)
		))

		if localPlayer == player then
			humanoid.PlatformStand = true
			humanoid.Sit = false
			v6.CFrame *= CFrame.Angles(0, 0.6, 0)
			humanoidRootPart.CFrame = v6.CFrame - v6.CFrame.Position + humanoidRootPart.CFrame.Position
		end
	end, function()
		clone.Passive.Char:SetPrimaryPartCFrame(CFrame.lookAt(
			humanoidRootPart.Position,
			humanoidRootPart.Position + humanoidRootPart.CFrame.LookVector * createVector(1, 0.1, 1)
		))
	end)

	if localPlayer == player then
		v6:Destroy()
		v3:Set(vector2)
		humanoidRootPart.CFrame = CFrame.lookAt(createVector(0, 0, 0), lookVector * createVector(1, 0.01, 1)) + humanoidRootPart.CFrame.Position
	end

	local lookVector2 = humanoidRootPart.CFrame.LookVector
	clone.Transform.Char:SetPrimaryPartCFrame(CFrame.lookAt(
		humanoidRootPart.Position,
		humanoidRootPart.Position + lookVector2 * createVector(1, 0.1, 1)
	))
	local playSchemes3 = PlaySchemes(clone.Transform.Char:GetDescendants())
	destroyAfter(clone.Transform.Char, playSchemes3 + 1)

	if v5 then
		clone.Transform.Ground:SetPrimaryPartCFrame(CFrame.new(v5) * inverse)
		local playSchemes2 = PlaySchemes(clone.Transform.Ground:GetDescendants())
		destroyAfter(clone.Transform.Ground, playSchemes2 + 1)

		if (v5 - Workspace.CurrentCamera.CFrame.Position).Magnitude < 200 then
			Util.CameraShaker:ShakeOnce(25, 25, 0.1, 0.8)
		end
	end

	awaitHeartbeatLoopFor(0.5, function()
		clone.Transform.Char:SetPrimaryPartCFrame(CFrame.lookAt(
			humanoidRootPart.Position,
			humanoidRootPart.Position + lookVector2 * createVector(1, 0.1, 1)
		))
	end)

	if localPlayer == player then
		humanoid.PlatformStand = false
		StopBodyVelocity(char, v3)
	end

	destroyAfter(clone, 3)
end