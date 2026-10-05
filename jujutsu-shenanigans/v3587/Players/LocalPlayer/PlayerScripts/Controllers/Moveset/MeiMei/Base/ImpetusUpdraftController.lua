local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
game:GetService("RunService")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local localPlayer = game.Players.LocalPlayer
local replicatedStorage = game.ReplicatedStorage
local _ = replicatedStorage.Animations
local utils = replicatedStorage.Utils
local sounds = replicatedStorage.Sounds
local CameraShaker = require(replicatedStorage.Modules.CameraShaker)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "ImpetusUpdraftController"
})

function controller.KnitStart(_)
	local v3 = {
		Hit = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.MeiMei.SlashHit:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(1.25)
			Debris:AddItem(model, 0.1)
			clone.Parent = workspace.Effects
			clone.CFrame = CFrame.lookAlong(humanoidRootPart2.Position, humanoidRootPart.CFrame.LookVector) * CFrame.Angles(
				0,
				0,
				0.6108652381980153
			)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") and emitter.Lifetime == 0.15 then
					emitter.Lifetime = 0.25
				end
			end

			Debris:AddItem(clone, 0.5)
			v2:PlayParticles(clone)

			if p then
				v2:Bleed(instance2)
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.MeiMei.UpdraftHit, humanoidRootPart, game.SoundService.Effect)
		end,
		Slash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.MeiMei.UpdraftSlash, humanoidRootPart, game.SoundService.Effect)
			local raycastResult = workspace:Raycast(humanoidRootPart.Position, createVector(0, -6, 0), _G.MapParams)

			if raycastResult then
				local clone = replicatedStorage.Utils.MeiMei.Launch:Clone()
				clone.Position = raycastResult.Position
				v2:PlayParticles(clone)
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 0.5)
			end

			local clone = replicatedStorage.Utils.MeiMei.MeiMeiSlash:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.C0 = CFrame.Angles(0.3490658503988659, 0.17453292519943295, 0.13962634015954636)
			v2:PlayParticles(clone)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			local clone2 = replicatedStorage.Utils.MeiMei.Circling.SwingMesh:Clone()
			clone2.Transparency = 0.05
			clone2.Mesh.Scale = createVector(0.15, 1, 0.15)
			clone2.Mesh.VertexColor = createVector(1.5, 1.5, 2.25)
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Weld.C0 = CFrame.Angles(0.4363323129985824, -0.3490658503988659, -3.001966313430247) * CFrame.Angles(
				0,
				1.0471975511965976,
				0
			)
			TweenService:Create(clone2.Weld, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
				C0 = clone2.Weld.C0 * CFrame.Angles(0, 3.1066860685499065, 0)
			}):Play()
			TweenService:Create(clone2.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = createVector(0.5, 0.25, 0.5)
			}):Play()
			TweenService:Create(
				clone2.Mesh,
				TweenInfo.new(0.09999999999999999, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					VertexColor = createVector(0.5, 0.5, 0.75)
				}
			):Play()
			TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.15)
			local clone3 = replicatedStorage.Utils.MeiMei.Circling.WindMesh1:Clone()
			clone3.Decal.Transparency = 0.75
			clone3.Mesh.Scale = createVector(0.5, 0.5, 0.5)
			clone3.CFrame = humanoidRootPart.CFrame * CFrame.Angles(0.3490658503988659, -1.5707963267948966, 0) * CFrame.new(
				-2,
				0,
				0
			) * CFrame.Angles(math.rad((math.random(-180, 180))), 0, 0)
			clone3.Parent = workspace.Effects
			TweenService:Create(clone3, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				CFrame = clone3.CFrame * CFrame.new(10, 0, 0) * CFrame.Angles(90, 0, 0)
			}):Play()
			TweenService:Create(clone3.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Scale = createVector(0.75, 0.05, 0.05)
			}):Play()
			TweenService:Create(clone3.Decal, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Transparency = 1
			}):Play()
			Debris:AddItem(clone3, 0.15)
			task.wait(0.3)
			clone.Weld:Destroy()
			clone.Anchored = true
		end,
		Slash2 = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local playSound = v2:PlaySound(sounds.MeiMei.UpdraftSlash, humanoidRootPart, game.SoundService.Effect)
			playSound.PlaybackSpeed = math.random(80, 120) / 100
			local v4 = {
				CFrame.Angles(-0.8726646259971648, 0, 1.5707963267948966),
				CFrame.Angles(-0.8726646259971648, 0.3490658503988659, 1.3962634015954636),
				(CFrame.Angles(-0.8726646259971648, -0.2617993877991494, 1.7453292519943295))
			}
			local clone = replicatedStorage.Utils.MeiMei.MeiMeiSlash:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.C0 = v4[p]
			clone.Parent = workspace.Effects

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			Debris:AddItem(clone, 1)
			local clone2 = replicatedStorage.Utils.MeiMei.Circling.SwingMesh:Clone()
			clone2.Transparency = 0.05
			clone2.Mesh.Scale = createVector(0.15, 1, 0.15)
			clone2.Mesh.VertexColor = createVector(1.5, 1.5, 2.25)
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Weld.C0 = v4[p]
			TweenService:Create(clone2.Weld, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
				C0 = clone2.Weld.C0 * CFrame.Angles(0, 3.1066860685499065, 0)
			}):Play()
			TweenService:Create(clone2.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = createVector(0.5, 0.25, 0.5)
			}):Play()
			TweenService:Create(
				clone2.Mesh,
				TweenInfo.new(0.09999999999999999, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					VertexColor = createVector(0.5, 0.5, 0.75)
				}
			):Play()
			TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.15)
			task.wait(0.15)
			clone.Weld:Destroy()
			clone.Anchored = true
		end,
		Hit2 = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local v4 = {
				CFrame.Angles(0, 0, 1.5707963267948966),
				CFrame.Angles(0, 0.3490658503988659, 1.3962634015954636),
				(CFrame.Angles(0, -0.2617993877991494, 1.7453292519943295))
			}
			local clone = utils.MeiMei.SlashHit:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(1.25)
			Debris:AddItem(model, 0.1)
			clone.Parent = workspace.Effects
			clone.CFrame = CFrame.lookAlong(humanoidRootPart2.Position, humanoidRootPart.CFrame.LookVector) * v4[p]

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") and emitter.Lifetime == 0.15 then
					emitter.Lifetime = 0.25
				end
			end

			Debris:AddItem(clone, 0.5)
			v2:PlayParticles(clone)
			v2:Flash(instance2, Color3.new(1, 1, 1))
			local playSound = v2:PlaySound(sounds.MeiMei.UpdraftHit, humanoidRootPart, game.SoundService.Effect)
			playSound.PlaybackSpeed = math.random(80, 120) / 100

			if instance == localPlayer.Character or instance2 == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(p == 3 and CameraShaker.Presets.HeavyHit or CameraShaker.Presets.MediumHit)
			end
		end,
		Slash3 = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v4 = {
				CFrame.Angles(1.5707963267948966, -1.0471975511965976, 1.1344640137963142),
				CFrame.Angles(0.6108652381980153, 3.141592653589793, 0.4363323129985824),
				CFrame.Angles(1.5707963267948966, -1.0471975511965976, 1.1344640137963142),
				CFrame.Angles(0.6108652381980153, 3.141592653589793, 0.4363323129985824),
				(CFrame.Angles(0.6108652381980153, 3.141592653589793, 0))
			}
			local clone = replicatedStorage.Utils.MeiMei.MeiMeiSlash:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Weld.C0 = v4[p]
			clone.Parent = workspace.Effects

			for _, emitter in clone:GetDescendants() do
				if not emitter:IsA("ParticleEmitter") then
					continue
				end

				if p == 2 or p == 4 or p == 5 then
					emitter.RotSpeed = NumberRange.new((math.abs(emitter.RotSpeed.Max)))
				end

				emitter:Emit(emitter:GetAttribute("EmitCount"))
			end

			Debris:AddItem(clone, 1)
			local clone2 = replicatedStorage.Utils.MeiMei.Circling.SwingMesh:Clone()
			clone2.Transparency = 0.05
			clone2.Mesh.Scale = createVector(0.15, 1, 0.15)
			clone2.Mesh.VertexColor = createVector(1.5, 1.5, 2.25)
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Weld.C0 = v4[p]
			TweenService:Create(clone2.Weld, TweenInfo.new(0.15, Enum.EasingStyle.Linear), {
				C0 = clone2.Weld.C0 * CFrame.Angles(0, 3.1066860685499065, 0)
			}):Play()
			TweenService:Create(clone2.Mesh, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = createVector(0.5, 0.25, 0.5)
			}):Play()
			TweenService:Create(
				clone2.Mesh,
				TweenInfo.new(0.09999999999999999, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
				{
					VertexColor = createVector(0.5, 0.5, 0.75)
				}
			):Play()
			TweenService:Create(clone2, TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
				Transparency = 1
			}):Play()
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.15)
			task.wait(0.15)

			if clone:FindFirstChild("Weld") then
				clone.Weld:Destroy()
			end

			clone.Anchored = true
		end,
		Hit3 = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local v4 = {
				CFrame.Angles(1.5707963267948966, -1.0471975511965976, 1.1344640137963142),
				CFrame.Angles(0.6108652381980153, 3.141592653589793, 0.4363323129985824),
				CFrame.Angles(1.5707963267948966, -1.0471975511965976, 1.1344640137963142),
				CFrame.Angles(0.6108652381980153, 3.141592653589793, 0.4363323129985824),
				(CFrame.Angles(0.6108652381980153, 3.141592653589793, 0))
			}
			local clone = utils.MeiMei.SlashHit:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(1.25)
			Debris:AddItem(model, 0.1)
			clone.Parent = workspace.Effects
			clone.CFrame = CFrame.lookAlong(humanoidRootPart2.Position, humanoidRootPart.CFrame.LookVector) * v4[p]

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") and emitter.Lifetime == 0.15 then
					emitter.Lifetime = 0.25
				end
			end

			Debris:AddItem(clone, 0.5)
			v2:PlayParticles(clone)
			v2:Flash(instance2, Color3.new(1, 1, 1))
			local playSound = v2:PlaySound(sounds.MeiMei.UpdraftHit, humanoidRootPart, game.SoundService.Effect)
			playSound.PlaybackSpeed = math.random(80, 120) / 100

			if instance == localPlayer.Character or instance2 == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(p == 3 and CameraShaker.Presets.HeavyHit or CameraShaker.Presets.MediumHit)
			end
		end,
		Finisher = function(instance)
			if instance:GetAttribute("MeiBleeding") then
				return
			end

			instance:SetAttribute("MeiBleeding", true)
			v2:Bleed(instance)
		end
	}
	v.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("ImpetusUpdraftService")
	v2 = Knit.GetController("FXController")
end

return controller