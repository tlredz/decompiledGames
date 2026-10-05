local createVector = vector.create
local _WorldOrigin = workspace:WaitForChild("_WorldOrigin")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Effect = require(game.ReplicatedStorage:WaitForChild("Effect"))
Effect.new("RingWind")
local Util = require(ReplicatedStorage:WaitForChild("Util"))
local FX = require(game.ReplicatedStorage.FX)
local _ = Util.Sound
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
return function(p)
	local origin = p.Origin

	if (origin.p - workspace.CurrentCamera.CFrame.p).magnitude > 800 then
		return
	end

	Util.Sound:Play("GenericExplosion3Fast", origin)
	local clone = game.ReplicatedStorage.Assets.Models.PesadoWave:Clone()
	clone.Size = createVector(1, 1, 1)
	clone.Transparency = 0
	clone.CFrame = origin
	local ray = Util.Ray
	local p2 = origin.p
	local v = { workspace.Characters, workspace._WorldOrigin, workspace.Enemies }
	local clone2

	if ray(p2, createVector(0, -10, 0), v) then
		clone2 = FX:WaitForChild("SandDust"):Clone()
		clone2.Drag = 3
		clone2.Parent = clone
	end

	local particleEmitter = clone.ParticleEmitter
	local particleEmitter2 = clone.ParticleEmitter2
	clone.Parent = _WorldOrigin
	TweenService:Create(clone.Mesh, TweenInfo.new(1.1, Enum.EasingStyle.Quad), {
		Scale = createVector(120, 120, 120)
	}):Play()
	TweenService:Create(clone, TweenInfo.new(1.1, Enum.EasingStyle.Quad), {
		Transparency = 1
	}):Play()
	local lastTime = tick()
	local total = 0

	while tick() - lastTime < 1.2 do
		local v2 = math.min(1, (tick() - lastTime) / 1.2)

		if v2 < 0.7 then
			particleEmitter.Speed = NumberRange.new(clone.Mesh.Scale.Y / 0.15)
			particleEmitter2.Speed = NumberRange.new(clone.Mesh.Scale.Y / 0.15)
			particleEmitter.Size = NumberSequence.new(v2 * 15 + 5)
			particleEmitter2.Size = NumberSequence.new(v2 * 15 + 5)

			if clone2 then
				clone2.Speed = NumberRange.new(clone.Mesh.Scale.Y / 0.25)
				clone2.Size = NumberSequence.new(v2 * 15 + 5)
			end
		else
			particleEmitter.Enabled = false
			particleEmitter2.Enabled = false

			if clone2 then
				clone2.Enabled = false
			end
		end

		if total <= v2 then
			total += 0.05555555555555555
			local cFrame = origin * CFrame.Angles(
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2,
				math.random() * 3.141592653589793 * 2
			)
			local clone3 = game.ReplicatedStorage.Assets.Models.SandSlash:Clone()
			clone3.CFrame = cFrame
			clone3.Parent = _WorldOrigin
			TweenService:Create(clone3, TweenInfo.new(0.25), {
				Transparency = 1,
				CFrame = cFrame * CFrame.Angles(0, 3.141592653589793, 0)
			}):Play()
			local tween = TweenService:Create(clone3.Mesh, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
				Scale = clone.Mesh.Scale
			})
			tween.Completed:Connect(function()
				clone3:Destroy()
			end)
			tween:Play()
		end

		RunService.RenderStepped:Wait()
	end

	clone:Destroy()
end