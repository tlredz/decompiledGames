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

return function(p)
	local player = p.player
	local hrp = p.hrp
	local currentCamera = Workspace.CurrentCamera

	if hrp == nil or hrp.Parent == nil or (hrp.Position - currentCamera.CFrame.Position).Magnitude > 800 then
		return
	end

	local clone = beatingHeart:Clone()
	clone.Parent = hrp.Parent
	destroyAfter(clone, 15)
	local heartPart = clone.HeartPart
	local children = heartPart.ResizeWithHeart:GetChildren()
	local v = 1

	-- equivalent calls inferred from this helper; original call sites unknown
	local function scaleHeart(p2)
		local v2 = p2 / v

		for _, v3 in ipairs(children) do
			ScaleParticle(v3, v2)
		end

		v = p2
	end

	scaleHeart(0.01) -- equivalent call inferred; original call site unknown

	for _, emitter in ipairs(heartPart:GetDescendants()) do
		if emitter:IsA("ParticleEmitter") then
			emitter.Enabled = true
		end
	end

	heartPart.Transparency = 1
	local connection = heartbeatLoopFor2(0.5, function(_, _, p2)
		heartPart.LightAttachment.PointLight.Brightness = p2 * 18
	end)

	local function endHeartbeat()
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
		heartbeatLoopFor2(0.5, function(_, _, p2)
			heartPart.LightAttachment.PointLight.Brightness = (1 - p2) * brightness
		end, function()
			heartPart.LightAttachment.PointLight.Brightness = 0
			heartPart.LightAttachment.PointLight.Enabled = false
		end)
		task.wait(3)

		if clone ~= nil and clone.Parent ~= nil then
			clone:Destroy()
		end
	end

	local v2 = 0

	local function fn()
		Util.Sound:Play("LoveV2SingleHeartbeat", hrp)
	end

	local connection2 = nil
	connection2 = heartbeatLoopFor2(10, function(p2)
		if hrp == nil or hrp.Parent == nil or hrp:GetAttribute("LoveZCharge") == false then
			connection2:Disconnect()
			connection2 = nil
			endHeartbeat()
		else
			if time() - v2 > 0.8 then
				task.spawn(fn)
				v2 = time()
			end

			local v3 = 1.25 * p2 - 0.2
			local v4 = math.sin(v3 * 2 * 3.141592653589793 + math.sin(v3 * 2 * 3.141592653589793) * 2) ^ 2
			scaleHeart(v4 * 0.75 + 0.75) -- equivalent call inferred; original call site unknown
			heartPart.CFrame = hrp.CFrame:ToWorldSpace(CFrame.new(
				0,
				0.177746773,
				-0.608093262,
				1,
				0,
				0,
				0,
				1,
				0,
				0,
				0,
				1
			))

			if localPlayer == player then
				currentCamera.FieldOfView = 70 - v4 * 4
			end
		end
	end, endHeartbeat)
end