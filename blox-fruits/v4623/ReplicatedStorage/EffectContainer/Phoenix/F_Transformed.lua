local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local vector2 = Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local fTalon = FX:WaitForChild("PhoenixEffects").FTalon
local fTrailPart = FX:WaitForChild("PhoenixEffects").FTrailPart
local fTrailShockwave = FX:WaitForChild("PhoenixEffects").FTrailShockwave
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
local PlaySchemes = require(interpolationScheme:WaitForChild("PlaySchemes"))

local function StopBodyVelocity(char, instance)
	instance:Set(vector2)
	heartbeatLoopFor2(0.1, function(_)
		if char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.AssemblyLinearVelocity = vector2
		end
	end, function()
		instance:Destroy()
	end)

	if char:FindFirstChild("Humanoid") then
		char.Humanoid.PlatformStand = false
	end
end

local function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

return function(data)
	local player = data.player
	local char = data.char
	local victim = data.victim
	local _ = data.distForward
	local distToVictim = data.distToVictim
	local timeToReachVictim = data.timeToReachVictim
	local timeLength = data.timeLength
	local slamAnimLength = data.slamAnimLength
	local dashDir = data.dashDir
	local origin = data.origin
	local dashSpeed = data.dashSpeed
	local offsetLength = data.offsetLength

	if (char.HumanoidRootPart.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1200 then
		return
	end

	local humanoidRootPart = char.HumanoidRootPart
	local humanoid = char.Humanoid
	local v

	if distToVictim then
		if data.isBoat then
			local _ = (victim.PrimaryPart or victim.HumanoidRootPart).CFrame
		end

		v = origin + dashDir * distToVictim - dashDir * offsetLength
	else
		v = nil
	end

	local function getIntersectPos()
		return v
	end

	local velocity = dashDir * (dashSpeed / timeLength)

	if victim == nil then
		timeToReachVictim = timeLength
	else
		velocity = dashDir * (dashSpeed / timeLength)
	end

	if localPlayer == player then
		humanoidRootPart.CFrame = CFrame.lookAt(vector2, dashDir) + humanoidRootPart.CFrame.Position
	end

	local duration = timeToReachVictim + (not victim and 0 or slamAnimLength) + 0.1
	local v4 = Util.BodyMover.new(char):Create("BodyVelocity", {
		Duration = duration,
		Priority = 2,
		Velocity = velocity,
		MaxForce = createVector(1.2980742e33, 1.2980742e33, 1.2980742e33)
	})
	local v5 = Util.BodyMover.new(char):Create("BodyGyro", {
		Duration = duration,
		Priority = 2,
		CFrame = humanoidRootPart.CFrame,
		MaxTorque = createVector(1.2980742e33, 1.2980742e33, 1.2980742e33)
	})
	task.delay(timeToReachVictim, function()
		v4:Set(vector2)
	end)
	local clone = fTrailPart:Clone()
	clone.CFrame = humanoidRootPart.CFrame
	clone.Parent = _WorldOrigin
	destroyAfter(clone, timeToReachVictim + 4)
	heartbeatLoopFor2(timeToReachVictim + (player == localPlayer and 0 or 0.5), function()
		if localPlayer == player then
			humanoid.PlatformStand = true
			humanoid.Sit = false
		end

		clone.CFrame = humanoidRootPart.CFrame
	end, function()
		if localPlayer == player then
			humanoid.PlatformStand = false
		end

		clone.CFrame = humanoidRootPart.CFrame

		for _, descendant in ipairs(clone:GetDescendants()) do
			if descendant.ClassName == "ParticleEmitter" then
				descendant.Enabled = false
			end
		end
	end)
	Util.Sound:Play(clone.FDash:GetAttribute("SoundLocation"), clone)
	task.spawn(function()
		local inverse = CFrame.lookAt(Vector3.new(), createVector(0, -1, 0)):inverse()
		local v7 = timeToReachVictim / 6

		for _ = 1, 6 do
			local clone2 = fTrailShockwave:Clone()
			clone2.CFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + dashDir) * inverse
			clone2.Parent = _WorldOrigin
			destroyAfter(clone2, PlaySchemes(clone2) + 1)
			Util.Sound:Play(clone2.FShockwave:GetAttribute("SoundLocation"), clone2)
			task.wait(v7)
		end
	end)
	task.wait(timeToReachVictim)
	heartbeatLoopFor2(0.2, function(_)
		if localPlayer == player then
			humanoid.PlatformStand = true
			humanoid.Sit = false
		end

		humanoidRootPart.AssemblyLinearVelocity = vector2
	end, function()
		if localPlayer == player then
			humanoid.PlatformStand = false
		end
	end)

	if victim == nil then
		StopBodyVelocity(char, v4)
		v5:Destroy()
	else
		local primaryPart = victim.PrimaryPart or victim:FindFirstChild("HumanoidRootPart")
		local humanoid2 = victim:FindFirstChild("Humanoid")
		local cFrame = humanoidRootPart.CFrame

		if localPlayer == player then
			humanoidRootPart.CFrame = cFrame - cFrame.Position + v
			v4:Set(createVector(0, 0, 0))
		end

		local clone2 = nil
		local inverse = CFrame.lookAt(Vector3.new(), createVector(-1, 0, 0)):inverse()
		local position = humanoidRootPart.Position
		heartbeatLoopFor2(slamAnimLength, function(p)
			if data.isBoat then
				v = v
				humanoidRootPart.CFrame = cFrame - cFrame.Position + v
			else
				humanoid2.PlatformStand = true
				humanoid2.Sit = false
				position = humanoidRootPart.Position
				local v7 = math.min(1, p / slamAnimLength)
				primaryPart.CFrame = CFrame.lookAt(position + dashDir * offsetLength * v7, position)
			end

			if clone2 then
				clone2:SetPrimaryPartCFrame(CFrame.lookAt(Vector3.new(), -dashDir) * inverse + v)
			end
		end, function()
			if not data.isBoat then
				primaryPart.CFrame = CFrame.lookAt(position + dashDir * offsetLength, position)
			end

			if clone2 then
				clone2:SetPrimaryPartCFrame(CFrame.lookAt(Vector3.new(), -dashDir) * inverse + v)
			end
		end)
		clone2 = fTalon:Clone()
		local v7 = CFrame.lookAt(v, v + dashDir) * inverse
		clone2:SetPrimaryPartCFrame(v7)
		clone2.Parent = _WorldOrigin
		local playSchemes = PlaySchemes(clone2:GetDescendants())
		destroyAfter(clone2, playSchemes + 2)
		task.wait(slamAnimLength)
		StopBodyVelocity(char, v4)
		v5:Destroy()

		if localPlayer == player then
			humanoid.PlatformStand = false
		end

		if not data.isBoat then
			humanoid2.PlatformStand = false
		end

		if (humanoidRootPart.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 240 then
			Util.CameraShaker:ShakeOnce(25, 25, 0.1, 0.8)
		end
	end

	if localPlayer == player then
		humanoid.PlatformStand = false
	end
end