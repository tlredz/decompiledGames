local createVector = vector.create
local utilities = script.Parent.Parent.Utilities
local OuwmitShake = require(utilities.OuwmitShake)
local OuwmitUtility = require(utilities.OuwmitUtility)
local RunService = game:GetService("RunService")
local Tween = require(utilities.Tween)
local v = Enum.RenderPriority.Camera.Value + 1
local clamp = math.clamp
local max = math.max
local new = CFrame.new
local angles = CFrame.Angles
local CamDriftFix = require(utilities.CamDriftFix)

-- equivalent calls inferred from this helper; original call sites unknown
local function getCamera()
	return workspace.CurrentCamera
end

return function(instance, p)
	if instance == nil or instance.Parent == nil then
		return
	end

	local durationScale = OuwmitUtility.DurationScale(p)
	local v2 = OuwmitUtility.GetAttribute(instance, "EmitDelay", 0) * durationScale
	local v3 = OuwmitUtility.GetAttribute(instance, "EmitDuration", 0) * durationScale
	local attribute = OuwmitUtility.GetAttribute(instance, "Amplitude", 2.5)
	local attribute2 = OuwmitUtility.GetAttribute(instance, "Frequency", 0.2)
	local fadeInTime = OuwmitUtility.GetAttribute(instance, "FadeInTime", 0.3) * durationScale
	local fadeOutTime = OuwmitUtility.GetAttribute(instance, "FadeOutTime", 2) * durationScale
	local sustainTime = OuwmitUtility.GetAttribute(instance, "SustainTime", 1) * durationScale
	local attribute3 = OuwmitUtility.GetAttribute(instance, "PositionInfluence", createVector(1, 1, 1))
	local attribute4 = OuwmitUtility.GetAttribute(instance, "RotationInfluence", createVector(0.2, 0.2, 0.2))
	local attribute5 = OuwmitUtility.GetAttribute(instance, "Falloff", nil)
	local attribute6 = OuwmitUtility.GetAttribute(instance, "Speed_Start", 1)
	local attribute7 = OuwmitUtility.GetAttribute(instance, "Speed_End", 1)
	local sustain = v3 > 0
	local v8 = OuwmitShake.new()
	v8.Sustain = sustain
	v8.Amplitude = attribute
	v8.Frequency = attribute2
	v8.FadeInTime = fadeInTime
	v8.FadeOutTime = fadeOutTime
	v8.SustainTime = sustainTime
	v8.PositionInfluence = attribute3
	v8.RotationInfluence = attribute4
	local lerped = 1
	local total = 0

	function v8.TimeFunction()
		return total
	end

	if attribute6 ~= attribute7 then
		Tween.new(
			OuwmitUtility.GetAttribute(instance, "Speed_Curve", OuwmitUtility.default_bezier),
			OuwmitUtility.GetAttribute(instance, "Speed_Duration", 0.1) * durationScale,
			function(p2, p3)
				lerped = OuwmitUtility.lerp(attribute6, attribute7, p2)
				return p3
			end
		)
	end

	local function perform()
		if instance == nil or instance.Parent == nil then
			return
		end

		local attachment = instance:FindFirstAncestorOfClass("Attachment") or instance:FindFirstAncestorWhichIsA("BasePart")

		if attachment == nil then
			local model = instance:FindFirstAncestorWhichIsA("Model")

			if model == nil then
				attachment = nil
			else
				attachment = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart", true) or nil
			end
		end

		local v9

		if attachment == nil then
			v9 = false
		else
			v9 = attachment:IsA("Attachment") or false
		end

		local flag = false
		local renderSteppedConnection = nil
		local ancestryChangedConnection = nil
		local v10 = attribute5

		if not v10 then
			v10 = max(
				v8.Amplitude / 2,
				vector.magnitude(v8.PositionInfluence) / 2,
				vector.magnitude(v8.RotationInfluence) / 2,
				1
			) * 25 + 85
		end

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

			if renderSteppedConnection ~= nil then
				renderSteppedConnection:Disconnect()
				renderSteppedConnection = nil
			end

			CamDriftFix.deactivate()
		end

		if attachment then
			ancestryChangedConnection = attachment.AncestryChanged:Connect(function(_, parent)
				if parent == nil then
					if v8:IsShaking() then
						v8:Stop()
					end

					cleanup() -- equivalent call inferred; original call site unknown
				end
			end)
		end

		renderSteppedConnection = RunService.RenderStepped:Connect(function(dt)
			if v8:IsShaking() then
				total += dt * lerped
				return
			end

			cleanup() -- equivalent call inferred; original call site unknown
		end)
		v8:BindToRenderStep(OuwmitShake.NextRenderName(), v, function(p2, data, p3)
			if attachment and attachment.Parent == nil then
				if v8:IsShaking() then
					v8:Stop()
				end

				cleanup() -- equivalent call inferred; original call site unknown
			else
				local camera = getCamera() -- equivalent call inferred; original call site unknown

				if camera == nil then
					return
				end

				if attachment then
					local worldPosition = v9 and attachment.WorldPosition or attachment.Position
					local v12 = 1 - clamp(vector.magnitude(camera.CFrame.Position - worldPosition) / v10, 0, 1)
					p2 *= v12
					data *= v12
				end

				camera.CFrame *= new(p2) * angles(data.x, data.y, data.z)

				if p3 then
					cleanup() -- equivalent call inferred; original call site unknown
				end
			end
		end)
		v8:Start()

		if sustain then
			task.delay(v3, function()
				if not flag and v8:IsShaking() then
					v8:StopSustain()
				end
			end)
		end
	end

	if v2 == nil or not (v2 > 0) then
		perform()
	else
		task.delay(v2, perform)
	end
end