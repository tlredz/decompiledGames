local createVector = vector.create
local TweenService = game:GetService("TweenService")
local _ = coroutine.resume
local _ = coroutine.create
local _WorldOrigin = workspace._WorldOrigin
local map = workspace.Map
local Debris = require(game.ReplicatedStorage.Util.Debris)
local Sound = require(game.ReplicatedStorage.Util.Sound)
local MasterClock = require(game.ReplicatedStorage.Util.MasterClock)

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(data, p)
	return (Vector3.new(data.X * p, data.Y * p, data.Z * p))
end

local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Whitelist
raycastParams.FilterDescendantsInstances = { map }
local v = {
	TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.45, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
	TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.In)
}

local function createEffect(cFrame, instance, p, p2)
	local clone = instance:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = cFrame
	clone.Parent = p2 or _WorldOrigin
	return clone
end

local ScaleParticle = require(game.ReplicatedStorage.Util.ScaleParticle)

for _, child in pairs(script.explosion.Attachment:GetChildren()) do
	ScaleParticle({
		Emitter = child,
		Scale = 0.7,
		Time = 0
	})
end

for _, child in pairs(script.explosion.PreAttachment:GetChildren()) do
	ScaleParticle({
		Emitter = child,
		Scale = 0.9,
		Time = 0
	})
end

return function(data)
	local root = data.Root
	local timestamp = data.Timestamp

	if (workspace.CurrentCamera.CFrame.Position - root.Position).magnitude > 600 then
		return
	end

	local clone = script.explosion:Clone()

	if data.Color then
		for _, emitter in pairs(clone:GetDescendants()) do
			if emitter:IsA("ParticleEmitter") and emitter.Name ~= "IN" and emitter.Name ~= "IN3" then
				emitter.Color = ColorSequence.new(data.Color:Lerp(Color3.fromRGB(255, 255, 255), 0))
			end
		end

		for _, child in pairs(clone.Attachment:GetChildren()) do
			ScaleParticle({
				Emitter = child,
				Scale = 2.5,
				Time = 0
			})
		end

		for _, child in pairs(clone.PreAttachment:GetChildren()) do
			ScaleParticle({
				Emitter = child,
				Scale = 2.5,
				Time = 0
			})
		end
	end

	local preAttachment = clone.PreAttachment
	preAttachment.Parent = root
	Debris:AddItem(preAttachment, 2)
	Sound:Play("ElectricWoosh", root)
	task.wait(1 - (MasterClock:GetTime() - timestamp))
	local cFrame = root.CFrame
	local position = root.Position
	clone.CFrame = cFrame
	clone.Parent = workspace._WorldOrigin
	Debris:AddItem(clone, 3)
	Sound:Play("ElectricStrike", cFrame)

	if (workspace.CurrentCamera.CFrame.Position - position).magnitude < 60 then
		local clone2 = script.ColorCorrection:Clone()
		clone2.TintColor = data.Color or clone2.TintColor
		clone2.Parent = game.Lighting
		Debris:AddItem(clone2, 1)
		TweenService:Create(clone2, v[2], {
			Brightness = 0,
			TintColor = Color3.new(1, 1, 1)
		}):Play()
		local Effect = require(game.ReplicatedStorage.Effect)
		Effect.new("ShakeCam"):replicate({
			2.5,
			4,
			0.1,
			0.75,
			createVector(0.3, 0.3, 0.3),
			createVector(1, 1, 1)
		})
	end

	for _, child in pairs(clone.Attachment:GetChildren()) do
		child:Emit(child:GetAttribute("EmitCount"))
	end

	local clone2 = script.Sphere:Clone()
	clone2.Name = clone2.Name
	clone2.CFrame = cFrame
	clone2.Parent = _WorldOrigin
	Debris:AddItem(clone2, 1)
	clone2.Color = data.Color or clone2.Color
	TweenService:Create(clone2, v[1], {
		Size = clone2.Size * 2.75,
		Transparency = 1
	}):Play()

	for _, child in pairs(preAttachment:GetChildren()) do
		child.Enabled = false
	end
end