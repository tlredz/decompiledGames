local createVector = vector.create
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local currentCamera = workspace.CurrentCamera
local v = {}
local heartbeatConnection = nil
local v2 = {
	Brightness = 0,
	Contrast = 0,
	Saturation = 0,
	TintColor = Color3.new(1, 1, 1),
	Intensity = 0,
	Size = 0,
	Threshold = 1,
	BlurSize = 0
}
local clock = os.clock
local clamp = math.clamp
local max = math.max

local function getPosition(instance)
	local typeName = typeof(instance)

	if typeName == "Instance" then
		if instance:IsA("BasePart") then
			return instance.Position
		end

		if instance:IsA("Attachment") then
			return instance.WorldPosition
		end
	elseif typeName == "CFrame" then
		return instance.Position
	elseif typeName == "Vector3" then
		return instance
	end

	return createVector(0, 0, 0)
end

local function calculateIntensity(data, p, magnitude, lookVector, p2)
	if data.TotalDur <= p then
		return 0
	end

	local v3

	if p < data.FadeIn then
		v3 = p / data.FadeIn
	else
		v3 = p < data.SustainEnd and 1 or 1 - (p - data.SustainEnd) / data.FadeOut
	end

	local v5 = clamp(1 - magnitude / data.MaxDist, 0, 1)
	local v6

	if data.UseLook and magnitude / data.MaxDist > data.ProxRatio then
		v6 = clamp((lookVector:Dot(p2.Unit) - (1 - data.LookSens)) / data.LookSens, 0, 1)
	else
		v6 = 1
	end

	return clamp(v3, 0, 1) * v5 * v6
end

local function update()
	local now = clock()
	local cFrame = currentCamera.CFrame
	local position = cFrame.Position
	local lookVector = cFrame.LookVector

	for i = #v, 1, -1 do
		local v3 = v[i]
		local v4 = now - v3.StartTime
		local source = v3.Source
		local typeName = typeof(source)
		local position2

		if typeName == "Instance" then
			if source:IsA("BasePart") then
				position2 = source.Position
			else
				position2 = not source:IsA("Attachment") and createVector(0, 0, 0) or source.WorldPosition
			end
		elseif typeName == "CFrame" then
			position2 = source.Position
		else
			position2 = typeName ~= "Vector3" and createVector(0, 0, 0) or source
		end

		local v5 = position2 - position
		local magnitude = v5.Magnitude
		local lighting = v3.Lighting

		if v4 < lighting.TotalDur then
			local v6 = calculateIntensity(lighting, v4, magnitude, lookVector, v5)

			for _, instance in ipairs(lighting.Instances) do
				local instance2 = instance.Instance

				if not (instance2 and instance2.Parent) then
					continue
				end

				for k, goal in pairs(instance.Goals) do
					local v7 = v2[k] or 0

					if typeof(goal) == "number" then
						instance2[k] = v7 + (goal - v7) * v6
					else
						instance2[k] = v7:Lerp(goal, v6)
					end
				end
			end
		elseif #lighting.Instances > 0 then
			for _, instance in ipairs(lighting.Instances) do
				if instance.Instance then
					instance.Instance:Destroy()
				end
			end

			table.clear(lighting.Instances)
		end

		local shake = v3.Shake

		if shake.Enabled and v4 < shake.TotalDur and shared.addshake then
			local v6 = calculateIntensity(shake, v4, magnitude, lookVector, v5)

			if v6 > 0 then
				shared.addshake(shake.BaseIntensity * v6, shake.IgnoreReduced)
			end
		end

		if lighting.TotalDur <= v4 and (not shake.Enabled or shake.TotalDur <= v4) then
			table.remove(v, i)
		end
	end

	if #v == 0 then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end
end

return {
	Trigger = function(data)
		local instances = {}

		if data.Instances then
			for _, instance in ipairs(data.Instances) do
				local instance2 = Instance.new(instance.Class)
				instance2.Name = "VFX_Managed"

				for k in pairs(instance.Properties) do
					if v2[k] ~= nil then
						instance2[k] = v2[k]
					end
				end

				instance2.Parent = Lighting
				table.insert(instances, {
					Instance = instance2,
					Goals = instance.Properties
				})
			end
		end

		local shakeSettings = data.ShakeSettings
		local shake = {}

		if shakeSettings then
			shake.Enabled = true
			shake.BaseIntensity = shakeSettings.Intensity or data.CamShakeIntensity or 0
			shake.IgnoreReduced = shakeSettings.IgnoreReduced or data.IgnoreReduced or false
			shake.FadeIn = shakeSettings.FadeInTime or 0
			shake.Sustain = shakeSettings.SustainTime or 0
			shake.FadeOut = shakeSettings.FadeOutTime or 0.5
			local maxDistance = shakeSettings.MaxDistance or data.MaxDistance or 100
			shake.MaxDist = max(maxDistance, 1)
			local useLook

			if shakeSettings.RequiresLineOfSight == nil then
				useLook = data.RequiresLineOfSight or false
			else
				useLook = shakeSettings.RequiresLineOfSight
			end

			shake.UseLook = useLook
			shake.LookSens = shakeSettings.LookSensitivity or data.LookSensitivity or 0.5
			shake.ProxRatio = shakeSettings.ProximityOverrideRatio or 0.15
		else
			shake.Enabled = (data.CamShakeIntensity or 0) > 0
			shake.BaseIntensity = data.CamShakeIntensity or 0
			shake.IgnoreReduced = data.IgnoreReduced or false
			shake.FadeIn = data.FadeInTime or 0.5
			shake.Sustain = data.SustainTime or 0
			shake.FadeOut = data.FadeOutTime or 0.5
			local maxDistance = data.MaxDistance or 100
			shake.MaxDist = max(maxDistance, 1)
			shake.UseLook = data.RequiresLineOfSight or false
			shake.LookSens = data.LookSensitivity or 0.5
			shake.ProxRatio = 0.15
		end

		shake.SustainEnd = shake.FadeIn + shake.Sustain
		shake.TotalDur = shake.SustainEnd + shake.FadeOut
		local lighting = {
			Instances = instances,
			FadeIn = data.FadeInTime or 0.5,
			Sustain = data.SustainTime or 0,
			FadeOut = data.FadeOutTime or 0.5,
			MaxDist = 0,
			UseLook = 0,
			LookSens = 0,
			ProxRatio = 0.15
		}
		local maxDistance = data.MaxDistance or 100
		lighting.MaxDist = max(maxDistance, 1)
		lighting.UseLook = data.RequiresLineOfSight or false
		lighting.LookSens = data.LookSensitivity or 0.5
		lighting.SustainEnd = lighting.FadeIn + lighting.Sustain
		lighting.TotalDur = lighting.SustainEnd + lighting.FadeOut
		table.insert(v, {
			StartTime = clock(),
			Source = data.Source,
			Lighting = lighting,
			Shake = shake
		})

		if not heartbeatConnection then
			heartbeatConnection = RunService.Heartbeat:Connect(update)
		end
	end
}