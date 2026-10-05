local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local vector2 = Vector3.new()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.MasterClock
local _ = Util.LightningBolt2
local promise = Util.Promise
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local awaitHeartbeatLoopFor = heartbeatLoopFor.AwaitHeartbeatLoopFor
local Shockwave = require(script.Parent.Modules.Shockwave)

local function lerp(p, p2, p3)
	return p2 + (p3 - p2) * p
end

local function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

local v = {
	"FakeHead",
	"HumanoidRootPart",
	"UpperTorso",
	"LowerTorso",
	"RightUpperArm",
	"RightLowerArm",
	"RightHand",
	"LeftUpperArm",
	"LeftLowerArm",
	"LeftHand",
	"RightUpperLeg",
	"RightLowerLeg",
	"RightFoot",
	"LeftUpperLeg",
	"LeftLowerLeg",
	"LeftFoot"
}

local function IsBodyPart(part)
	for _, v2 in next, v, nil do
		if v2 == part.Name then
			return true
		end
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function addGradientAfterShadow(char, timeToReachVictim)
	promise.try(function()
		local model = Instance.new("Model")
		model.Parent = _WorldOrigin
		local parts = {}

		for _, part in ipairs(char:GetChildren()) do
			if not (part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Transparency < 1 and IsBodyPart(part)) then
				continue
			end

			parts[#parts + 1] = part
		end

		awaitHeartbeatLoopFor(timeToReachVictim, function(_)
			local clones = {}

			for _, v2 in ipairs(parts) do
				local clone = v2:Clone()
				clone.Anchored = true
				clone.CanCollide = false
				clone:ClearAllChildren()
				clone.Parent = model
				clones[#clones + 1] = clone
			end

			heartbeatLoopFor2(0.5, function(p)
				for _, v2 in ipairs(clones) do
					v2.Transparency = p / 0.5
				end
			end, function()
				for _, v2 in ipairs(clones) do
					v2.Transparency = 1
				end
			end)
		end)
		promise.delay(1):await()
		model:Destroy()
	end)
end

return function(data)
	local char = data.char
	local victim = data.victim
	local distForward = data.distForward
	local _ = data.DistToVictim
	local timeToReachVictim = data.timeToReachVictim
	local timeLength = data.timeLength
	local slamAnimLength = data.slamAnimLength
	local dashDir = data.dashDir

	if (char.HumanoidRootPart.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1000 or victim and (typeof(victim) ~= "Instance" or not victim:FindFirstChild("HumanoidRootPart")) then
		return
	end

	local model = Instance.new("Model")
	model.Parent = _WorldOrigin

	if (char.HumanoidRootPart.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 240 then
		Util.CameraShaker:ShakeOnce(15, 25, 0.1, 0.8)
	end

	local velocity = dashDir * (distForward / timeLength)

	if victim == nil then
		timeToReachVictim = timeLength
	end

	char.Humanoid.PlatformStand = true
	char.HumanoidRootPart.CFrame = CFrame.lookAt(vector2, dashDir) + char.HumanoidRootPart.CFrame.Position
	local v3 = Util.BodyMover.new(char):Create("BodyVelocity", {
		Velocity = velocity,
		MaxForce = createVector(1.2980742e33, 1.2980742e33, 1.2980742e33)
	})

	if victim then
		heartbeatLoopFor2(timeToReachVictim + slamAnimLength, function(_)
			victim.HumanoidRootPart.CFrame = char.RightHand.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
				0,
				5,
				0
			)
		end, function()
			victim.HumanoidRootPart.CFrame = char.RightHand.CFrame * CFrame.Angles(-1.5707963267948966, 0, 0) * CFrame.new(
				0,
				5,
				0
			)
		end)
	end

	addGradientAfterShadow(char, timeToReachVictim) -- equivalent call inferred; original call site unknown
	promise.delay(timeToReachVictim):await()
	v3:Set(vector2)
	heartbeatLoopFor2(0.2, function(_)
		char.HumanoidRootPart.AssemblyLinearVelocity = vector2
	end, function()
		v3:Destroy()
	end)
	char.Humanoid.PlatformStand = false

	if victim ~= nil then
		promise.delay(slamAnimLength):await()
		local ray = Util.Ray
		local position = victim.HumanoidRootPart.Position
		local v4 = { Workspace.Characters, Workspace.Enemies }
		local _, v5 = ray(position, createVector(0, -12.5, 0), v4)
		local v6 = v5 - createVector(0, 2.5, 0)

		if (char.HumanoidRootPart.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude < 240 then
			Util.CameraShaker:ShakeOnce(25, 25, 0.1, 0.8)
		end

		promise.try(function()
			Shockwave(v6, 16)
		end)
		local clone = FX:WaitForChild("BuddhaEffects").ThunderSpike:Clone()
		clone.Size = createVector(120, 50.96, 120)
		clone.CFrame = CFrame.new(v6 + Vector3.new(0, clone.Size.Y, 0) * 0.5)
		clone.Parent = model
		heartbeatLoopFor2(0.5, function(p)
			local v7 = p / 0.5
			clone.Size = createVector(120, 50.96, 120) * (1 + 1 * v7)
			clone.CFrame = CFrame.new(v6 + Vector3.new(0, clone.Size.Y, 0) * 0.5)
			clone.Transparency = v7 ^ 3
		end, function()
			clone.Transparency = 1
		end)
		local part = Instance.new("Part")
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.Size = createVector(1, 1, 1)
		part.Shape = Enum.PartType.Ball
		part.CFrame = CFrame.new(v6)
		local attachment = Instance.new("Attachment", part)
		local attachment2 = Instance.new("Attachment", part)
		attachment.Position = createVector(0, -0.75, 0)
		attachment2.Position = createVector(0, 0.75, 0)
		local clone2 = script.Trail:Clone()
		clone2.Attachment0 = attachment
		clone2.Attachment1 = attachment2
		clone2.Parent = part
		awaitHeartbeatLoopFor(0.2, function(_, _)
			for _ = 1, 21 do
				local v7 = v6 + RandomVectorOffsetBetween(createVector(0, 1, 0), 0, 3.141592653589793) * 200
				local clone3 = part:Clone()
				clone3.CFrame = CFrame.new(v6)
				clone3.Parent = model
				local v10 = clone3
				heartbeatLoopFor2(0.1, function(p)
					local v11 = p / 0.1
					local v12 = v6
					clone3.CFrame = CFrame.new(v12 + (v7 - v12) * v11)
				end, function()
					v10:Destroy()
				end)
			end
		end)
		promise.delay(0.3):await()
		part:Destroy()
	end

	model:Destroy()
end