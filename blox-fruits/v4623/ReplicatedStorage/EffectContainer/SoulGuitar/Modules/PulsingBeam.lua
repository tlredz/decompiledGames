local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local heartbeatLoopFor = Util.HeartbeatLoopFor
local heartbeatLoopFor2 = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local skinnedCylinder = Util.SkinnedCylinder

local function NoiseBetween(p: number, p2: number, p3: number, p4: number, p5: number)
	return p4 + (p5 - p4) * (math.noise(p, p2, p3) + 0.5)
end

local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")

local function PulsingBeam(position, p, p2)
	local v = math.max(0, p - 0.5)
	local v3 = skinnedCylinder.new(_WorldOrigin, CFrame.new(position), createVector(20, 80, 20), p2)
	local maxX = v3.boneInstanceMap.maxX
	local maxY = v3.boneInstanceMap.maxY
	local boneInstanceMap = v3.boneInstanceMap
	local defaultBonePosMap = v3.defaultBonePosMap
	v3.cylinderPart.Color = Color3.fromRGB(121, 255, 143)
	local v4 = table.create(maxY, 0)

	for i in ipairs(v4) do
		v4[i] = (i - 1) / (maxY - 1)
	end

	for i = 1, defaultBonePosMap.maxY do
		for i2 = 1, defaultBonePosMap.maxX do
			defaultBonePosMap:set(i2, i, (defaultBonePosMap:get(i2, i) * createVector(1, 0, 1)).Unit)
			local get = boneInstanceMap:get(i2, i)
			get.Position = defaultBonePosMap:get(i2, i)
		end
	end

	CFrame.lookAt(createVector(0, 0, 0), createVector(0, 1, 0)):Inverse()
	local attachment = Instance.new("Attachment")
	local v5 = 0

	for _, child in ipairs(script.ParticleFolder:GetChildren()) do
		local clone = child:Clone()
		clone.Enabled = true
		clone.Parent = attachment
	end

	attachment.Parent = v3.cylinderPart
	v3.cylinderPart.Transparency = 0
	heartbeatLoopFor2(0.8, function(_, _, p3)
		v5 = p3 * 525
	end, function()
		v5 = 525
		v3.cylinderPart.Transparency = 0
	end)
	local currentCamera = workspace.CurrentCamera
	local v6 = 1
	heartbeatLoopFor2(p, function(p3, _, _)
		local v7 = createVector(0, 1, 0) * v5
		attachment.WorldPosition = position + v7 + (currentCamera.CFrame.Position - position - v7).Unit * 29.5 * 4 * v5 / 525

		for i = 1, maxY do
			local v8 = v4[i]
			local v9 = (math.cos(4 * v8 - p3 * 15) ^ 2 * 19 + 10.5) * (0.5 + (v8 - 0.8) ^ 2) * v6
			local v10 = v7 * v8

			for i2 = 1, maxX do
				local get = boneInstanceMap:get(i2, i)
				get.Position = v10 + defaultBonePosMap:get(i2, i) * v9
			end
		end
	end, function()
		v3:destroy()
	end)
	task.delay(v, function()
		for _, child in ipairs(attachment:GetChildren()) do
			child.Enabled = false
		end

		local transparency = v3.cylinderPart.Transparency
		heartbeatLoopFor2(0.5, function(_, _, p3)
			v6 = 1 - p3
			v3.cylinderPart.Transparency = transparency + (1 - transparency) * p3 ^ 0.5
		end, function()
			attachment:Destroy()
		end)
	end)
end

return PulsingBeam