local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(ReplicatedStorage:WaitForChild("FX"))

local function hueShift(value: Color3, p: number, p2: number, p3: number)
	local HSV = value:ToHSV()
	return Color3.fromHSV((HSV + p) % 1, p2, p3)
end

local function scaleEmitter(emitter, p: number)
	local numberSequenceKeypoints = {}

	for _, keypoint in emitter.Size.Keypoints do
		local v = math.clamp(keypoint.Value * p, 0, 10)
		local v2 = math.clamp(keypoint.Envelope * p, 0, (math.min(v, 10 - v)))
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(keypoint.Time, v, v2))
	end

	emitter.Size = NumberSequence.new(numberSequenceKeypoints)
	emitter.Speed = NumberRange.new(emitter.Speed.Min * p, emitter.Speed.Max * p)
	emitter.Acceleration *= p
end

return function(data)
	local root = data.Root

	if typeof(root) ~= "Instance" or not root:IsA("BasePart") or (workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude > 1000 then
		return
	end

	local v = os.clock() + (data.Duration or 4)
	local thunderGodAura = root:FindFirstChild("ThunderGodAura")

	if thunderGodAura then
		thunderGodAura:SetAttribute("Until", v)
		return
	end

	local folder = Instance.new("Folder")
	folder.Name = "ThunderGodAura"
	folder:SetAttribute("Until", v)
	folder.Parent = root
	local v2 = (typeof(data.Scale) ~= "number" or not (data.Scale > 0)) and 1 or math.clamp(data.Scale, 0.125, 8)
	local clone = FX:WaitForChild("Lightning2").F.Assets.Phase0.HoldAura:Clone()

	if v2 ~= 1 then
		clone.Size *= v2
	end

	clone.CFrame = root.CFrame
	clone.Anchored = true
	clone.Parent = workspace._WorldOrigin
	local color

	if typeof(data.Color) == "Color3" then
		color = data.Color
	end

	for _, emitter in pairs(clone:GetDescendants()) do
		if not emitter:IsA("ParticleEmitter") then
			continue
		end

		if color then
			local HSV, v3, v4 = color:ToHSV()
			local colorSequenceKeypoints = {}

			for _, keypoint in pairs(emitter.Color.Keypoints) do
				local HSV2 = keypoint.Value:ToHSV()
				table.insert(
					colorSequenceKeypoints,
					ColorSequenceKeypoint.new(keypoint.Time, hueShift(keypoint.Value, HSV - HSV2, v3, v4))
				)
			end

			emitter.Color = ColorSequence.new(colorSequenceKeypoints)
		end

		if v2 ~= 1 then
			scaleEmitter(emitter, v2)
		end

		emitter.Enabled = true
	end

	task.spawn(function()
		while root.Parent and folder.Parent do
			local attribute = folder:GetAttribute("Until")

			if typeof(attribute) ~= "number" or attribute <= os.clock() then
				break
			end

			clone.CFrame = root.CFrame
			RunService.Heartbeat:Wait()
		end

		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") then
				emitter.Enabled = false
			end
		end

		if folder.Parent then
			folder:Destroy()
		end

		Util.Debris:AddItem(clone, 2)
	end)
end