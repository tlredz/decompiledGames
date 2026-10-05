local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
local random = Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
Vector3.new()
local inverse = CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local skullX = FX:WaitForChild("SoulGuitarEffects").SkullX
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local interpolationScheme = ReplicatedStorage:WaitForChild("Common"):WaitForChild("InterpolationScheme")
local PlaySchemes = require(interpolationScheme:WaitForChild("PlaySchemes"))
local lightningBolt2 = Util.LightningBolt2
local attachmentPair = Util.AttachmentPair

if lightningBolt2.VERSION == nil or lightningBolt2.VERSION < 1.1 then
	error("LightningBolt: This module needs to be updated with the latest code provided in the framework2 team create place")
end

local function ScaleParticle(state, p)
	local keypoints = state.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p,
			keypoint.Envelope * p
		)
	end

	state.Size = NumberSequence.new(numberSequenceKeypoints)
	state.Speed = NumberRange.new(state.Speed.Min * p, state.Speed.Max * p)
	state.Acceleration *= p
end

local function Raycast(position, p)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { _WorldOrigin, Workspace.CurrentCamera }
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local raycastResult = Workspace:Raycast(position, p, raycastParams)

	for _ = 1, 5 do
		if not raycastResult then
			return nil
		end

		if raycastResult.Instance.CanCollide == true then
			return raycastResult
		end

		local filterDescendantsInstances = raycastParams.FilterDescendantsInstances
		table.insert(filterDescendantsInstances, raycastResult.Instance)
		raycastParams.FilterDescendantsInstances = filterDescendantsInstances
		raycastResult = Workspace:Raycast(position, p, raycastParams)
	end

	return nil
end

local particleEmitter = script:WaitForChild("ParticleEmitter")

local function teslaCoilBolt(skullTop, p: number)
	local position = skullTop.Position
	local v = p * random:NextNumber(0.8, 1.2)
	local raycast = Raycast(
		(CFrame.Angles(0, 6.283185307179586 * math.random(), 0) * CFrame.new(v, 0, 0) + position).Position,
		createVector(-0, -4, -0) * v
	)

	if raycast == nil then
		return
	end

	local v3 = attachmentPair.new(nil, nil)
	v3.attachment0.Parent = skullTop
	local lookVector = CFrame.lookAt(createVector(0, 0, 0), (raycast.Position - position) * createVector(1, 0.01, 1)):Lerp(
		CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)),
		random:NextNumber(0.1, 0.4)
	).LookVector
	local normal = raycast.Normal
	v3.attachment0.WorldAxis = lookVector
	v3.attachment1.WorldAxis = -normal
	v3.attachment0.Position = (raycast.Position - position).Unit * random:NextNumber(17, 20)
	v3.attachment1.WorldPosition = raycast.Position
	local clone = particleEmitter:Clone()
	clone.Parent = v3.attachment1
	local v4 = lightningBolt2.new(v3.attachment0, v3.attachment1, 2 * random:NextInteger(3, 4))
	v4.CurveSize0 = 5
	v4.CurveSize1 = v * random:NextNumber(0.4, 0.7)
	v4.Thickness = v * 0.02
	v4.MaxRadius = p * 0.1
	v4.Color = Color3.new(0.509804, 1, 0.509804)
	v4.PulseSpeed = 6
	local v5 = 4 * v4.Thickness
	local v6 = v * random:NextNumber(0.9, 1.9)
	task.delay(1 / v4.PulseSpeed, function()
		clone:Emit(2)
	end)
	heartbeatLoopFor2(0.19, function(p2, _, p3)
		v4.CurveSize0 = 5 + p3 * v6 * 1.8
		v4.Thickness = v5 * math.sin(29.4 * p2) ^ 2
	end)
	task.delay(0.2, function()
		task.wait(0.1)
		v4:Destroy()
		v3:destroy()
	end)
end

return function(data)
	local _ = data.player
	local hrp = data.hrp
	local origin = data.origin
	local chargeUpFor = data.chargeUpFor

	if (origin - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1250 then
		return
	end

	local lookVector = hrp.CFrame.LookVector
	local v = origin + createVector(0, 3, 0)
	local clone = skullX:Clone()
	clone:SetPrimaryPartCFrame(CFrame.lookAt(createVector(0, 0, 0), lookVector) * inverse + v)
	clone:SetPrimaryPartCFrame(clone.PrimaryPart.CFrame * CFrame.new(12, 0, 0))
	clone.Parent = _WorldOrigin

	for _, descendant in ipairs(clone:GetDescendants()) do
		if descendant:GetAttribute("TimeLength") then
			descendant:SetAttribute("TimeLength", chargeUpFor)
		end
	end

	PlaySchemes(clone:GetDescendants())
	destroyAfter(clone, chargeUpFor + 0.5)
	local cFrame = clone.PrimaryPart.CFrame
	local v2 = clone.PrimaryPart.CFrame * CFrame.new(0, 30, 0) * CFrame.Angles(0, 0, 0.5)
	heartbeatLoopFor2(chargeUpFor, function(_, _, p)
		if clone and clone.PrimaryPart then
			clone:SetPrimaryPartCFrame(cFrame:Lerp(v2, p))
		end
	end, function()
		if clone and clone.PrimaryPart then
			clone:SetPrimaryPartCFrame(v2)
			clone.SkullJaw.Transparency = 1
			clone.SkullTop.Transparency = 1

			for _, descendant in ipairs(clone.SkullTop:GetDescendants()) do
				if descendant.ClassName == "ParticleEmitter" then
					descendant.Enabled = false
				end
			end
		end
	end)
	local v3 = 0
	heartbeatLoopFor2(chargeUpFor * 0.7, function(p)
		if p - v3 > 0.05 then
			v3 = p
			teslaCoilBolt(clone.SkullTop, 50)
		end
	end)
end