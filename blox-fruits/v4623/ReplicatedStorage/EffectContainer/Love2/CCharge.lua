local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local beatingHeart = FX:WaitForChild("LoveEffects").BeatingHeart
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor

local function ScaleParticle(p, p2)
	local keypoints = p.Size.Keypoints
	local numberSequenceKeypoints = {}

	for i, keypoint in ipairs(keypoints) do
		numberSequenceKeypoints[i] = NumberSequenceKeypoint.new(
			keypoint.Time,
			keypoint.Value * p2,
			keypoint.Envelope * p2
		)
	end

	p.Size = NumberSequence.new(numberSequenceKeypoints)
end

return function(data)
	local player = data.player
	local hrp = data.hrp
	local currentCamera = Workspace.CurrentCamera

	if hrp == nil or hrp.Parent == nil or (hrp.Position - currentCamera.CFrame.Position).Magnitude > 900 then
		return
	end

	local clone = beatingHeart:Clone()

	for _, emitter in ipairs(clone:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			ScaleParticle(emitter, 4)
		end
	end

	clone.Parent = hrp.Parent
	destroyAfter(clone, 15)
	local heartPart = clone.HeartPart
	local children = heartPart.ResizeWithHeart:GetChildren()
	local v = 1

	-- equivalent calls inferred from this helper; original call sites unknown
	local function scaleHeart(p)
		local v2 = p / v

		for _, v3 in ipairs(children) do
			ScaleParticle(v3, v2)
		end

		v = p
	end

	scaleHeart(0.01) -- equivalent call inferred; original call site unknown
	local clone2 = beatingHeart.Parent.CChargeVisual.LoveCChargeVisual:Clone()
	clone2.Inner.Size = NumberSequence.new(data.minRadius * 1.175)
	clone2.Outer.Size = NumberSequence.new(data.maxRadius * 1.175)
	clone2.Parent = Workspace.Terrain
	local v2 = Util.Sound:Play("LoveV2CInitCharge", heartPart)

	for _, emitter in ipairs(heartPart:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	heartPart.Transparency = 1
	heartPart.LightAttachment.PointLight.Range *= 4
	local connection = heartbeatLoopFor2(0.5, function(_, _, p)
		heartPart.LightAttachment.PointLight.Brightness = p * 18
	end)

	local function endHeartbeat()
		if v2 ~= nil and v2.Parent ~= nil then
			v2:Destroy()
		end

		if clone2 ~= nil and clone2.Parent ~= nil then
			clone2.Inner.Enabled = false
			clone2.Outer.Enabled = false
			clone2.Inner:Clear()
			clone2.Outer:Clear()
			destroyAfter(clone2, 2)
		end

		for _, emitter in ipairs(heartPart:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		heartPart.Transparency = 1
		currentCamera.FieldOfView = 70

		if connection ~= nil then
			connection:Disconnect()
		end

		local brightness = heartPart.LightAttachment.PointLight.Brightness
		heartbeatLoopFor2(0.5, function(_, _, p)
			heartPart.LightAttachment.PointLight.Brightness = (1 - p) * brightness
		end, function()
			heartPart.LightAttachment.PointLight.Brightness = 0
			heartPart.LightAttachment.PointLight.Enabled = false
		end)
		task.wait(3)

		if clone ~= nil and clone.Parent ~= nil then
			clone:Destroy()
		end
	end

	local v3 = 0

	local function fn()
		Util.Sound:Play("LoveV2SingleHeartbeat", hrp)
	end

	local connection2 = nil
	connection2 = heartbeatLoopFor2(10, function(p)
		if hrp == nil or hrp.Parent == nil or hrp:GetAttribute("LoveCCharge") == false then
			connection2:Disconnect()
			connection2 = nil
			endHeartbeat()
		else
			if time() - v3 > 0.8 then
				clone2.Inner:Emit(1)
				clone2.Outer:Emit(1)
				task.spawn(fn)
				v3 = time()
			end

			local v4 = 1.25 * p - 0.2
			local v5 = math.sin(v4 * 2 * 3.141592653589793 + math.sin(v4 * 2 * 3.141592653589793) * 2) ^ 2
			scaleHeart(v5 * 0.75 + 0.75) -- equivalent call inferred; original call site unknown
			heartPart.CFrame = hrp.CFrame:ToWorldSpace(CFrame.new(0, 9, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1))

			if localPlayer == player then
				currentCamera.FieldOfView = 70 - v5 * 4
			end

			clone2.CFrame = CFrame.new(hrp.Position)
			clone2.Inner.Size = NumberSequence.new(data.minRadius * 1.175 + (data.maxRadius - data.minRadius) * 1.175 * math.clamp(
				v4 / data.fullyChargedAt,
				0,
				1
			))
		end
	end, endHeartbeat)
end