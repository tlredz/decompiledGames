local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
game:GetService("RunService")
game:GetService("Lighting")
local _WorldOrigin = Workspace:WaitForChild("_WorldOrigin")
Random.new()
local Players = game:GetService("Players")
Players = Players.LocalPlayer
CFrame.lookAt(Vector3.new(), createVector(1, 0, 0)):inverse()
CFrame.lookAt(Vector3.new(), createVector(0, 1, 0)):inverse()
local FX = require(ReplicatedStorage:WaitForChild("FX"))
local iceStorm = FX:WaitForChild("IceEffects").IceStorm
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local _ = Util.Sound
local destroyAfter = Util.DestroyAfter
local heartbeatLoopFor = Util.HeartbeatLoopFor
local _ = heartbeatLoopFor.HeartbeatLoopFor
local _ = heartbeatLoopFor.AwaitHeartbeatLoopFor
local TweenService = game:GetService("TweenService")
local scaleParticle = Util.ScaleParticle

local function scaleNumberRange(p, p2)
	return NumberRange.new(p.Min * p2, p.Max * p2)
end

local function scaleAcceleration(p, p2)
	return p * p2
end

local v = {
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
	TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.In),
	TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
}

-- equivalent calls inferred from this helper; original call sites unknown
local function createEffect(originCF, nado, p)
	local clone = nado:Clone()
	clone.Name = p or clone.Name
	clone.CFrame = originCF
	clone.Parent = _WorldOrigin
	return clone
end

local vignetteService = Util.VignetteService

for _, emitter in pairs(iceStorm.nado:GetDescendants()) do
	if not emitter:IsA("ParticleEmitter") then
		continue
	end

	emitter.Rate *= 0.425
	scaleParticle({
		Emitter = emitter,
		Scale = 0.75,
		Time = 0
	})
end

return function(p)
	local char = p.char
	local originCF = p.originCF

	if char:FindFirstChildOfClass("Humanoid") == nil then
		return
	end

	local position = originCF.Position

	if (position - Workspace.CurrentCamera.CFrame.Position).Magnitude > 1200 then
		return
	end

	if char == game.Players.LocalPlayer.Character or (Workspace.CurrentCamera.CFrame.Position - position).magnitude < 90 then
		local clone = iceStorm.Blur:Clone()
		clone.Parent = game.Lighting
		TweenService:Create(clone, v[1], {
			Size = 7
		}):Play()
		local _ = Workspace.CurrentCamera
		Util.CameraShaker:ShakeOnce(5, 4, 0.35, 3)
		local vignette = vignetteService:CreateVignette({ iceStorm.ParticleEmitter:Clone() })
		vignette:UpdateEnabled(true)
		vignette:Enabled(true)
		task.delay(2.35, function()
			vignette:UpdateEnabled(false)
			vignette:Enabled(false)
			task.wait(0.4)
			vignette:Destroy()
			TweenService:Create(clone, v[2], {
				Size = 0
			}):Play()
			destroyAfter(clone, 0.6)
		end)
	end

	for i = 1, 3 do
		local effect = createEffect(originCF, iceStorm.nado) -- equivalent call inferred; original call site unknown
		Util.Sound:Play("Ice_tornado", effect)

		if i == 2 then
			effect.CFrame *= CFrame.Angles(0, 1.2076923076923076, 0)
		elseif i == 3 then
			effect.CFrame *= CFrame.Angles(0, -1.2076923076923076, 0)
		end

		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.MaxForce = createVector(100000, 100000, 100000)
		bodyVelocity.Velocity = effect.CFrame.lookVector * 50
		bodyVelocity.Parent = effect

		if i == 2 or i == 3 then
			effect.Attachment2.Position *= 0.5

			for _, emitter in ipairs(effect:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				emitter.Rate *= 0.325
				scaleParticle({
					Emitter = emitter,
					Scale = 0.5,
					Time = 0
				})
			end
		end

		local folder = effect
		task.delay(1.25, function()
			bodyVelocity:Destroy()
			folder.Anchored = true
			task.wait(1)

			for i2, emitter in ipairs(folder:GetDescendants()) do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				scaleParticle({
					Emitter = emitter,
					Scale = 0,
					Time = 0.7,
					EasingStyle = Enum.EasingStyle.Linear,
					EasingDirection = Enum.EasingDirection.Out
				})

				if emitter.Parent.Name == "Attachment2" or emitter.Name == "Snow" then
					emitter.Enabled = false
				end
			end

			destroyAfter(folder, 0.8)
		end)
	end
end