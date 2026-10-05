local createVector = vector.create
local RunService = game:GetService("RunService")
local module = require("../mod/tween")
local module2 = require("../mod/utility")
local module3 = require("../pkg/Shake")
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
	local attribute = module2.getAttribute(instance, "EmitDelay", 0)
	local attribute2 = module2.getAttribute(instance, "EmitDuration", 0)
	local attribute3 = module2.getAttribute(instance, "Falloff", 30)
	local attribute4 = module2.getAttribute(instance, "Amplitude", 2.5)
	local attribute5 = module2.getAttribute(instance, "Frequency", 0.2)
	local attribute6 = module2.getAttribute(instance, "FadeInTime", 0.3)
	local attribute7 = module2.getAttribute(instance, "FadeOutTime", 2)
	local attribute8 = module2.getAttribute(instance, "SustainTime", 1)
	local attribute9 = module2.getAttribute(instance, "PositionInfluence", createVector(1, 1, 1))
	local attribute10 = module2.getAttribute(instance, "RotationInfluence", createVector(0.2, 0.2, 0.2))
	local attribute11 = module2.getAttribute(instance, "Speed_Start", 1)
	local attribute12 = module2.getAttribute(instance, "Speed_End", 1)
	local sustain = attribute2 > 0
	local v3 = module3.new()
	v3.Sustain = sustain
	v3.Amplitude = attribute4
	v3.Frequency = attribute5
	v3.FadeInTime = attribute6
	v3.FadeOutTime = attribute7
	v3.SustainTime = attribute8
	v3.PositionInfluence = attribute9
	v3.RotationInfluence = attribute10
	local lerped = 1
	local total = 0

	function v3.TimeFunction()
		return total
	end

	if attribute11 ~= attribute12 then
		speedTween = module.fromParams(
			module2.getAttribute(instance, "Speed_Curve", module2.default_bezier),
			module2.getAttribute(instance, "Speed_Duration", 0.1),
			function(p, p2)
				lerped = module2.lerp(attribute11, attribute12, p)
				return p2
			end
		)
		table.insert(list, speedTween)
	end

	table.insert(list, RunService.RenderStepped:Connect(function(dt)
		total += dt * lerped
	end))
	local v4 = {
		done = false,
		pos = createVector(0, 0, 0),
		rot = createVector(0, 0, 0)
	}
	task.wait(attribute)
	table.insert(v, v4)
	local thread = coroutine.running()
	v3:BindToRenderStep(module3.NextRenderName(), module2.RENDER_PRIORITY + list.depth, function(pos, rot, done)
		local currentCamera = workspace.CurrentCamera
		cFrame = currentCamera.CFrame
		local attachment = instance:FindFirstAncestorOfClass("Attachment") or instance:FindFirstAncestorWhichIsA("BasePart")

		if attachment then
			local v5 = 1 - math.clamp(
				(currentCamera.CFrame.Position - (attachment:IsA("Attachment") and attachment.WorldPosition or attachment.Position)).Magnitude / attribute3,
				0,
				1
			)
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
		task.wait(attribute2)
		v3:StopSustain()
	end

	if not v4.done then
		coroutine.yield()
	end
end

return CameraShake