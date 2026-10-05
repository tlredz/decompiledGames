local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
Vector3.new()
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
local inverse = CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local phoenixX = FX:WaitForChild("PhoenixEffects").PhoenixX
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local _ = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
local PlaySchemes = require(interpolationScheme:WaitForChild("PlaySchemes"))

local function RandomVectorOffsetBetween(p, p2, p3)
	return (CFrame.lookAt(Vector3.new(), p) * CFrame.Angles(0, 0, random:NextNumber(0, 6.283185307179586)) * CFrame.Angles(
		math.acos((random:NextNumber(math.cos(p3), (math.cos(p2))))),
		0,
		0
	)).LookVector
end

local function ScaleParticle(descendant, p)
	local keypoints = descendant.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	descendant.Size = NumberSequence.new(numberSequenceKeypoints)
	descendant.Speed = NumberRange.new(descendant.Speed.Min * p, descendant.Speed.Max * p)
	descendant.Acceleration *= p
end

local v = false

local function ExpandingForcefieldFX(attachment, radius)
	local v2 = 2 * radius * createVector(1, 1, 1)
	v = not v
	local part = Instance.new("Part")
	part.Anchored = true
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Shape = Enum.PartType.Ball
	part.CastShadow = false
	part.Material = Enum.Material.ForceField
	local color

	if v then
		color = Color3.fromRGB(0, 200, 255)
	else
		color = Color3.fromRGB(255, 200, 0)
	end

	part.Color = color
	part.Transparency = 0.7
	part.Size = createVector(1, 1, 1)
	part.CFrame = attachment.WorldCFrame
	part.Name = "PhoenixExpandingSphere"
	part.Parent = _WorldOrigin
	heartbeatLoopFor2(0.35, function(p)
		local v4 = p / 0.35
		part.Size = createVector(1, 1, 1) + (v2 - createVector(1, 1, 1)) * v4 ^ 0.27
		part.CFrame = attachment.WorldCFrame
		part.Transparency = v4 ^ 3
	end, function()
		part:Destroy()
	end)
end

return function(data)
	local char = data.char
	local radius = data.radius
	local phoenixXInUse = data.phoenixXInUse
	local humanoidRootPart = char.HumanoidRootPart

	if (humanoidRootPart.Position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1200 then
		return
	end

	local clone = phoenixX:Clone()
	clone:SetPrimaryPartCFrame(CFrame.new(humanoidRootPart.Position) * inverse + createVector(-0, -7.5, -0))
	local v2 = radius / 153.5

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:IsA("BasePart") then
			descendant:SetAttribute("SizeMultiplierGoal", descendant:GetAttribute("SizeMultiplierGoal") * v2)
			descendant:SetAttribute("SpeedInitial", descendant:GetAttribute("SpeedInitial") * v2)
			descendant:SetAttribute("SpeedGoal", descendant:GetAttribute("SpeedGoal") * v2)
		elseif descendant:IsA("ParticleEmitter") and not descendant:FindFirstAncestorWhichIsA("BasePart"):GetAttribute("SizeScalesEmitters") then
			ScaleParticle(descendant, v2)
		end
	end

	if char:FindFirstChild("PhoenixBF") ~= nil or char:FindFirstChild("HybridPhoenixBF") ~= nil then
		clone.HeatwaveMouthFX.Flames1:Destroy()
		clone.HeatwaveMouthFX.Flames2:Destroy()
		clone.HeatwaveMouthFX.Attachment.Swirl1:Destroy()
		clone.HeatwaveMouthFX.Attachment.Swirl2:Destroy()
	end

	clone.Parent = _WorldOrigin
	PlaySchemes(clone:GetDescendants())
	local energyChargeInit = clone.HeatwaveMouthFX.EnergyChargeInit
	local energyChargeLoop = clone.HeatwaveMouthFX.EnergyChargeLoop
	task.spawn(function()
		energyChargeInit = Util.Sound:Play(energyChargeInit:GetAttribute("SoundLocation"), energyChargeInit.Parent)
		energyChargeInit.Ended:Wait()
		energyChargeLoop = Util.Sound:Play(energyChargeLoop:GetAttribute("SoundLocation"), energyChargeLoop.Parent)
	end)
	local v3 = time()
	local heartbeatConnection = nil
	heartbeatConnection = RunService.Heartbeat:Connect(function()
		clone:SetPrimaryPartCFrame(CFrame.new(humanoidRootPart.Position) * inverse + createVector(-0, -7.5, -0))

		if time() - v3 > 0.2 then
			ExpandingForcefieldFX(clone.Waves.Attachment, radius)
			v3 = time()
		end

		if phoenixXInUse == nil or not phoenixXInUse:IsDescendantOf(Workspace) then
			heartbeatConnection:Disconnect()
			heartbeatConnection = nil

			for _, emitter in ipairs(clone:GetDescendants()) do
				if emitter:IsA("ParticleEmitter") then
					emitter.Enabled = false
				end
			end

			heartbeatLoopFor2(1, function(p)
				if energyChargeLoop.ClassName == "Sound" then
					energyChargeLoop.Volume = math.max(0, 1 - p)
				end
			end, function()
				if energyChargeLoop.ClassName == "Sound" then
					energyChargeLoop:Stop()
				else
					task.delay(2, function()
						energyChargeLoop:Stop()
					end)
				end
			end)
			task.wait(2)
			clone:Destroy()
		end
	end)
end