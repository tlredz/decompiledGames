local createVector = vector.create
local RunService = game:GetService("RunService")
local module = require("../mod/attributes")
local module2 = require("../mod/tween")
require("../types")
local module3 = require("../mod/utility")
local module4 = require("../pkg/Shake")
local v = {}
local identity = CFrame.identity

local function updateCamera()
	if #v == 0 then
		return
	end

	local currentCamera = workspace.CurrentCamera

	if not RunService:IsRunning() then
		currentCamera.CFrame *= identity:Inverse()
		local cFrame = currentCamera.CFrame
		local orientation, v2 = cFrame:ToOrientation()
		currentCamera.CFrame = CFrame.new(cFrame.Position) * CFrame.fromOrientation(orientation, v2, 0)
	end

	local identity2 = CFrame.identity
	local v2 = createVector(0, 0, 0)
	local v3 = {}

	for _, v4 in v do
		if v4.done then
			continue
		end

		v2 += v4.pos
		identity2 *= CFrame.Angles(v4.rot.x, v4.rot.y, v4.rot.z)
		table.insert(v3, v4)
	end

	v = v3
	local v4 = CFrame.new(v2) * identity2

	if not RunService:IsRunning() then
		identity = v4
	end

	currentCamera.CFrame *= v4
end

local heartbeatConnection = nil
local cFrame = nil
local CameraShake = {}

function CameraShake.init()
	if heartbeatConnection then
		return
	end

	if RunService:IsRunning() then
		heartbeatConnection = RunService.Heartbeat:Connect(function()
			if not cFrame then
				return
			end

			workspace.CurrentCamera.CFrame = cFrame
		end)
	end

	RunService:BindToRenderStep("forge_updateCameraShake", Enum.RenderPriority.Last.Value + 1, updateCamera)
end

function CameraShake.deinit()
	if heartbeatConnection then
		heartbeatConnection:Disconnect()
		heartbeatConnection = nil
	end

	RunService:UnbindFromRenderStep("forge_updateCameraShake")
end

function CameraShake.emit(instance, list)
	local emitDelay = module.get(instance, "EmitDelay", 0)
	local emitDuration = module.get(instance, "EmitDuration", 0)
	local falloff = module.get(instance, "Falloff", 30)
	local amplitude = module.get(instance, "Amplitude", 2.5)
	local frequency = module.get(instance, "Frequency", 0.2)
	local fadeInTime = module.get(instance, "FadeInTime", 0.3)
	local fadeOutTime = module.get(instance, "FadeOutTime", 2)
	local sustainTime = module.get(instance, "SustainTime", 1)
	local positionInfluence = module.get(instance, "PositionInfluence", createVector(1, 1, 1))
	local rotationInfluence = module.get(instance, "RotationInfluence", createVector(0.2, 0.2, 0.2))
	local speedStart = module.get(instance, "Speed_Start", 1)
	local speedEnd = module.get(instance, "Speed_End", 1)
	local sustain = emitDuration > 0
	local v3 = module4.new()
	v3.Sustain = sustain
	v3.Amplitude = amplitude
	v3.Frequency = frequency
	v3.FadeInTime = fadeInTime
	v3.FadeOutTime = fadeOutTime
	v3.SustainTime = sustainTime
	v3.PositionInfluence = positionInfluence
	v3.RotationInfluence = rotationInfluence
	local lerped = 1
	local total = 0

	function v3.TimeFunction()
		return total
	end

	if speedStart ~= speedEnd then
		table.insert(
			list,
			(module2.fromParams(
				module.get(instance, "Speed_Curve", module3.default_bezier),
				module.get(instance, "Speed_Duration", 0.1),
				function(p, p2)
					lerped = module3.lerp(speedStart, speedEnd, p)
					return p2
				end
			))
		)
	end

	table.insert(list, RunService.RenderStepped:Connect(function(dt)
		total += dt * lerped
	end))
	local v4 = {
		done = false,
		pos = createVector(0, 0, 0),
		rot = createVector(0, 0, 0)
	}
	task.wait(emitDelay)
	table.insert(v, v4)
	local thread = coroutine.running()
	v3:BindToRenderStep(module4.NextRenderName(), module3.RENDER_PRIORITY + list.depth, function(pos, rot, done)
		local currentCamera = workspace.CurrentCamera
		cFrame = currentCamera.CFrame
		local attachment = instance:FindFirstAncestorOfClass("Attachment") or instance:FindFirstAncestorWhichIsA("BasePart")

		if attachment then
			local transformedOriginExtents = module3.getTransformedOriginExtents(attachment)
			local position = transformedOriginExtents and transformedOriginExtents.Position or attachment.Position
			local v5 = 1 - math.clamp((currentCamera.CFrame.Position - position).Magnitude / falloff, 0, 1)
			pos *= v5
			rot *= v5
		end

		v4.pos = pos
		v4.rot = rot
		v4.done = done

		if done then
			cFrame = nil
			task.spawn(thread)
		end
	end)
	v3:Start()

	if sustain then
		task.wait(emitDuration)
		v3:StopSustain()
	end

	if not v4.done then
		coroutine.yield()
	end
end

return CameraShake