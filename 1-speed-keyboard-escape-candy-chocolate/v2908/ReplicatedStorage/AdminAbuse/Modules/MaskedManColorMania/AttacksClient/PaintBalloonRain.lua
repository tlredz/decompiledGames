local createVector = vector.create
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientDebris = require(script.Parent.ClientDebris)
local ImpactFx = require(ReplicatedStorage.AdminAbuse.Modules.ChichineBossRoom.AttacksClient.ImpactFx)
local v = {}
local flag = false
local thread = nil
local v2 = nil

-- equivalent calls inferred from this helper; original call sites unknown
local function track(result)
	table.insert(v, result)
end

local function getSplashTemplate()
	if v2 and v2.Parent then
		return v2
	end

	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local maskedManColorMania = adminAbuse and adminAbuse:FindFirstChild("MaskedManColorMania")
	local VFX = maskedManColorMania and maskedManColorMania:FindFirstChild("VFX")
	local splash = VFX and VFX:FindFirstChild("Splash")

	if splash then
		v2 = splash
		return splash
	end

	warn("[MaskedManColorMania] PaintBalloonRain: Splash VFX not found in RS.AdminAbuse.MaskedManColorMania.VFX")
	return nil
end

local function playSplashVfx(position: Vector3, value: number?)
	local splashTemplate = getSplashTemplate()

	if not splashTemplate then
		return
	end

	local v3 = value or 1
	local success, result = pcall(function()
		return splashTemplate:Clone()
	end)

	if not (success and result) then
		return
	end

	if result:IsA("BasePart") then
		result.Size *= v3
		result.CFrame = CFrame.new(position)
		result.Anchored = true
		result.CanCollide = false
		result.CanQuery = false
		result.CastShadow = false
		result.Parent = workspace
	elseif result:IsA("Model") then
		result:ScaleTo(v3)
		result:PivotTo(CFrame.new(position))

		for _, part in result:GetDescendants() do
			if not part:IsA("BasePart") then
				continue
			end

			part.Anchored = true
			part.CanCollide = false
			part.CanQuery = false
			part.CastShadow = false
		end

		result.Parent = workspace
	elseif result:IsA("Attachment") then
		local part = Instance.new("Part")
		part.Anchored = true
		part.CanCollide = false
		part.CanQuery = false
		part.Transparency = 1
		part.Size = createVector(1, 1, 1)
		part.CFrame = CFrame.new(position)
		part.Parent = workspace
		result.Parent = part
		result = part
	else
		result.Parent = workspace
	end

	for _, emitter in result:GetDescendants() do
		if emitter:IsA("ParticleEmitter") then
			emitter:Emit(emitter:GetAttribute("EmitCount") or 40)
		end
	end

	Debris:AddItem(result, 3)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function stopCameraFollow()
	if flag then
		RunService:UnbindFromRenderStep("PaintBalloonRainCameraFollow")
		flag = false
	end

	if thread then
		pcall(task.cancel, thread)
		thread = nil
	end
end

local function bindCameraFollow(instance, p: number)
	stopCameraFollow() -- equivalent call inferred; original call site unknown
	RunService:BindToRenderStep(
		"PaintBalloonRainCameraFollow",
		Enum.RenderPriority.Camera.Value + 1,
		function(p2: number)
			if not instance.Parent then
				return
			end

			local currentCamera = Workspace.CurrentCamera

			if not currentCamera then
				return
			end

			local v3 = currentCamera.CFrame + createVector(0, 10, 0)
			currentCamera.CFrame = v3:Lerp(CFrame.lookAt(v3.Position, instance.Position), 1 - math.exp(-p2 / 0.35))
		end
	)
	flag = true
	local v3 = math.max(0, p - 0.4)
	thread = task.delay(v3, stopCameraFollow)
end

local PaintBalloonRain = {}

function PaintBalloonRain.PaintBalloonDrop(data)
	local x = data.x or 0
	local y = data.y or 0
	local z = data.z or 0
	local landY = data.landY or y
	local fallTime = data.fallTime or 1.2
	local radius = data.radius or 7
	local _ = data.follow == true
	local adminAbuse = ReplicatedStorage:FindFirstChild("AdminAbuse")
	local maskedManColorMania = adminAbuse and adminAbuse:FindFirstChild("MaskedManColorMania")
	local paintBalloonModel = maskedManColorMania and maskedManColorMania.Assets:FindFirstChild("PaintBalloonModel")

	if not paintBalloonModel then
		warn("[MaskedManColorMania] PaintBalloonRain: PaintBalloonModel not found in RS.AdminAbuse.MaskedManColorMania.Assets")
		return
	end

	local success, result = pcall(function()
		return paintBalloonModel:Clone()
	end)

	if not (success and result) then
		return
	end

	result.Anchored = true
	result.CanCollide = false
	result.CanQuery = false
	result.CastShadow = false
	result.CFrame = CFrame.new(x, y, z)
	result.Parent = ClientDebris()
	track(result) -- equivalent call inferred; original call site unknown
	local tween = TweenService:Create(result, TweenInfo.new(fallTime, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Position = Vector3.new(x, landY, z)
	})
	local v3 = math.random(1, 3) * 360 * (math.random(0, 1) == 0 and -1 or 1)
	local v4 = math.random(1, 3) * 360 * (math.random(0, 1) == 0 and -1 or 1)
	local tween2 = TweenService:Create(
		result,
		TweenInfo.new(fallTime, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut),
		{
			Orientation = result.Orientation + Vector3.new(v3, 0, v4)
		}
	)
	tween:Play()
	tween2:Play()
	local flag2 = false

	local function onLand()
		if flag2 then
			return
		end

		flag2 = true
		pcall(function()
			result:Destroy()
		end)
		local v5 = radius * 2
		ImpactFx.sounds(x, landY, z)
		ImpactFx.shake(x, landY, z, v5 * 2.5)
		playSplashVfx(Vector3.new(x, landY, z), radius / 7 * 3)
	end

	tween.Completed:Once(onLand)
	task.delay(fallTime + 0.05, onLand)
end

function PaintBalloonRain.cleanup()
	stopCameraFollow() -- equivalent call inferred; original call site unknown

	for _, v3 in v do
		local v4 = v3
		pcall(function()
			v4:Destroy()
		end)
	end

	table.clear(v)
end

return PaintBalloonRain