local createVector = vector.create
local Presets = require(script.Presets)
local Shake = require(script.Shake)
local typeof2 = typeof
local clamp = math.clamp
local angles = CFrame.Angles
local new = CFrame.new
local min = math.min
local max = math.max
local v = Enum.RenderPriority.Camera.Value + 1

local function fn() end

local object = setmetatable({
	IsShaking = function()
		return false
	end
}, {
	__index = function()
		return fn
	end
})
local CamDriftFix = require(script.CamDriftFix)
local RunService = game:GetService("RunService")
local v2

if RunService:IsClient() then
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local DataValue = require(ReplicatedStorage.CAM.Client.Modules.DataValue)
	local SettingsKeys = require(ReplicatedStorage.CAM.Global.Subsets.Gameplay.SettingsKeys)
	v2 = DataValue.new(SettingsKeys.ScreenShake.Path, SettingsKeys.ScreenShake.Default, SettingsKeys.Scope)
else
	v2 = nil
end

-- equivalent calls inferred from this helper; original call sites unknown
local function shakeStrength()
	if v2 == nil then
		return 1
	end

	local v3 = v2:Get()

	if type(v3) == "number" then
		return (clamp(v3, 0, 1))
	end

	return 1
end

-- equivalent calls inferred from this helper; original call sites unknown
local function getCamera()
	return workspace.CurrentCamera
end

return function(instance, data)
	if data == nil and instance ~= nil then
		data = instance
		instance = nil
	end

	if data == nil then
		return
	end

	if typeof2(data) == "string" then
		data = Presets[data]
	end

	local v3 = shakeStrength() -- equivalent call inferred; original call site unknown

	if v3 <= 0 then
		return object
	end

	local v4 = nil
	local v5 = nil
	local v6 = nil

	if instance ~= nil then
		local typeName = typeof2(instance)

		if typeName == "CFrame" then
			v4 = true
		elseif typeName ~= "Vector3" then
			if typeName == "Instance" then
				if instance:IsA("BasePart") then
					v5 = true
				elseif instance:IsA("Attachment") then
					v6 = true
				else
					instance = nil
				end
			else
				instance = nil
			end
		end
	end

	local v7 = data.Amplitude == nil and 2.5 or data.Amplitude
	local v8 = shakeStrength() -- equivalent call inferred; original call site unknown
	local v9 = v7 * v8
	local v10 = data.PositionInfluence == nil and createVector(1, 1, 1) or data.PositionInfluence
	local v11 = data.RotationInfluence == nil and createVector(0.2, 0.2, 0.2) or data.RotationInfluence
	local v15 = max(v9 / 2, vector.magnitude(v10) / 2, vector.magnitude(v11) / 2, 1) * 25 + 85

	local function falloff(vector2: Vector3, p)
		local v16 = vector.magnitude(p.CFrame.Position - vector2)

		if data.MinDistance then
			v16 = min(data.MinDistance, v16)
		end

		local v18 = 1 - clamp(v16 / v15, 0, 1)

		if data.DistanceStretch then
			return v18 * data.DistanceStretch
		end

		return v18
	end

	-- equivalent calls inferred from this helper; original call sites unknown
	local function positionOf()
		if instance == nil then
			return nil
		end

		return (v4 or v5) and instance.Position or v6 and instance.WorldPosition or instance
	end

	local camera = getCamera() -- equivalent call inferred; original call site unknown
	local v16 = positionOf() -- equivalent call inferred; original call site unknown

	if camera ~= nil and v16 ~= nil then
		local v17 = vector.magnitude(camera.CFrame.Position - v16)

		if data.MinDistance then
			v17 = min(data.MinDistance, v17)
		end

		local v19 = 1 - clamp(v17 / v15, 0, 1)

		if data.DistanceStretch then
			v19 *= data.DistanceStretch
		end

		if v19 * v9 < 0.04 then
			return object
		end
	end

	local v17 = Shake.new()
	v17.FadeInTime = data.FadeInTime == nil and 0.3 or data.FadeInTime
	v17.Frequency = data.Frequency == nil and 0.2 or data.Frequency
	v17.Amplitude = data.Amplitude == nil and 2.5 or data.Amplitude
	v17.SustainTime = data.SustainTime == nil and 1 or data.SustainTime
	v17.FadeOutTime = data.FadeOutTime == nil and 2 or data.FadeOutTime
	v17.RotationInfluence = data.RotationInfluence == nil and createVector(0.2, 0.2, 0.2) or data.RotationInfluence
	v17.PositionInfluence = data.PositionInfluence == nil and createVector(1, 1, 1) or data.PositionInfluence
	local v18

	if typeof2(instance) == "Instance" then
		v18 = instance or nil
	else
		v18 = nil
	end

	local flag = false
	local ancestryChangedConnection = nil
	CamDriftFix.activate()

	-- equivalent calls inferred from this helper; original call sites unknown
	local function cleanup()
		if flag then
			return
		end

		flag = true

		if ancestryChangedConnection then
			ancestryChangedConnection:Disconnect()
			ancestryChangedConnection = nil
		end

		CamDriftFix.deactivate()
	end

	if v18 then
		ancestryChangedConnection = v18.AncestryChanged:Connect(function(_, parent)
			if parent == nil then
				if v17:IsShaking() then
					v17:Stop()
				end

				cleanup() -- equivalent call inferred; original call site unknown
			end
		end)
	end

	v17:BindToRenderStep(v17.NextRenderName(), v, function(p, data2, p2)
		if v18 and v18.Parent == nil then
			if v17:IsShaking() then
				v17:Stop()
			end

			cleanup() -- equivalent call inferred; original call site unknown
		else
			local camera2 = getCamera() -- equivalent call inferred; original call site unknown

			if camera2 == nil then
				return
			end

			local v19 = positionOf() -- equivalent call inferred; original call site unknown

			if v19 ~= nil then
				local v20 = vector.magnitude(camera2.CFrame.Position - v19)

				if data.MinDistance then
					v20 = min(data.MinDistance, v20)
				end

				local v22 = 1 - clamp(v20 / v15, 0, 1)

				if data.DistanceStretch then
					v22 *= data.DistanceStretch
				end

				if v22 <= 0 then
					if p2 then
						cleanup() -- equivalent call inferred; original call site unknown
					end

					return
				else
					p *= v22
					data2 *= v22
				end
			end

			camera2.CFrame *= new(p) * angles(data2.x, data2.y, data2.z)

			if p2 then
				cleanup() -- equivalent call inferred; original call site unknown
			end
		end
	end)
	v17:Start()
	return v17
end