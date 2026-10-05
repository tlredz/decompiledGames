local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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
	Name = "PlasmaWaveController"
})

function quadraticBezier(p, p2, p3, p4)
	return (1 - p) ^ 2 * p2 + 2 * (1 - p) * p * p3 + p ^ 2 * p4
end

local function CubicBezier(p, p2, p3, p4, p5)
	return (1 - p) ^ 3 * p2 + 3 * (1 - p) ^ 2 * p * p3 + 3 * (1 - p) * p ^ 2 * p4 + p ^ 3 * p5
end

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance, parent)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Choso.Switch:Clone()
			clone.Parent = instance.Head
			TweenService:Create(clone, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Size = UDim2.new(15, 0, 15, 0)
			}):Play()
			local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
			TweenService:Create(clone.Eye1, tweenInfo, {
				Size = UDim2.new(0.3, 0, 0, 0),
				ImageTransparency = 1
			}):Play()
			TweenService:Create(clone.Eye2, tweenInfo, {
				Size = UDim2.new(0.6, 0, 0, 0),
				ImageTransparency = 1
			}):Play()
			TweenService:Create(clone.Eye3, tweenInfo, {
				Size = UDim2.new(0.3, 0, 0, 0),
				ImageTransparency = 1
			}):Play()
			Debris:AddItem(clone, 0.5)
			v2:PlaySound(sounds.Choso.PlasmaWave.Swarm, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude > 150 then
				return
			end

			local v4 = {}

			for _ = 1, 15 do
				local clone2 = utils.Choso.Convergence.Blood1:Clone()
				clone2.Trail.Lifetime = 1
				clone2.Parent = parent
				v4[clone2] = {
					Vector3.new(math.random(-130, 130) / 10, math.random(0, 120) / 10, math.random(-130, 130) / 10),
					(Vector3.new(math.random(-130, 130) / 10, math.random(0, 120) / 10, math.random(-130, 130) / 10))
				}
			end

			local numberValue = Instance.new("NumberValue", parent)
			TweenService:Create(
				numberValue,
				TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
				{
					Value = 0.2
				}
			):Play()
			task.delay(0.5, function()
				TweenService:Create(numberValue, TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
					Value = 0.45
				}):Play()
				task.wait(0.5)
				TweenService:Create(numberValue, TweenInfo.new(0.9, Enum.EasingStyle.Cubic, Enum.EasingDirection.In), {
					Value = 1
				}):Play()
				task.wait(0.1)

				for k, _ in v4 do
					k.ParticleEmitter.Enabled = false
				end

				task.wait(0.3)

				for k, _ in v4 do
					k.Trail.Lifetime = 0.2
				end
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if not parent.Parent then
					steppedConnection:Disconnect()
					return
				end

				for k, v5 in v4 do
					local value = numberValue.Value
					local v6 = v5[1]
					local v7 = v5[2]
					k.Position = (1 - value) ^ 3 * createVector(0, 2, 0) + 3 * (1 - value) ^ 2 * value * v6 + 3 * (1 - value) * value ^ 2 * v7 + value ^ 3 * createVector(
						0,
						0,
						-2.5
					)
				end
			end)
		end,
		Clap = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Choso.PiercingBlood.Clap, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Fire = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Choso.PlasmaWave:Clone()
			clone.CFrame = instance2:GetAttribute("BeamStartCFrame") * CFrame.new(0, 0, -62)
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects
			task.spawn(function()
				while instance2.Parent do
					clone.CFrame = instance2:GetAttribute("BeamStartCFrame") * CFrame.new(0, 0, -62)
					task.wait(0.1)
				end
			end)
			local v4 = v2:PlaySound(sounds.Choso.PlasmaWave.Fire, clone, game.SoundService.Effect)
			v2:PlaySound(sounds.Choso.PiercingBlood.Fire, humanoidRootPart, game.SoundService.Effect)
			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.Flash, TweenInfo.new(0.05), {
				Size = createVector(20, 20, 20)
			}):Play()
			TweenService:Create(clone.Flash.Weld, TweenInfo.new(0.05), {
				C1 = clone.Flash.Weld.C1 + createVector(0, 0, 10)
			}):Play()
			task.delay(0.05, function()
				TweenService:Create(clone.Flash, TweenInfo.new(0.2), {
					Size = createVector(0, 0, 50)
				}):Play()
				TweenService:Create(clone.Flash.Weld, TweenInfo.new(0.2), {
					C1 = clone.Flash.Weld.C1 + createVector(0, 0, 25)
				}):Play()
				Debris:AddItem(clone.Flash, 0.2)

				if (workspace.CurrentCamera.CFrame.Position - clone.Position).Magnitude < 180 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
					local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit)
					task.spawn(function()
						if _G.Settings.Flash ~= true then
							return
						end

						local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
						clone2.TintColor = Color3.new(1, 1, 1)
						clone2.Parent = game.Lighting
						task.wait(0.02)
						clone2.Brightness = 200
						clone2.Contrast = -1000
						task.wait(0.02)
						clone2:Destroy()
					end)

					repeat
						task.wait(0.1)
					until not instance2.Parent

					shakeSustain:StartFadeOut(0.5)
				end
			end)

			if localPlayer.Character == instance then
				TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(0.7, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						FieldOfView = 120
					}
				):Play()
			end

			clone.End.Position = createVector(0, 0, 60)
			TweenService:Create(clone.End, TweenInfo.new(0.2), {
				Position = createVector(0, 0, -60)
			}):Play()
			instance2:GetAttributeChangedSignal("BeamLength"):Connect(function()
				TweenService:Create(clone.End, TweenInfo.new(0.1), {
					Position = Vector3.new(0, 0, -instance2:GetAttribute("BeamLength") / 2)
				}):Play()
			end)
			task.delay(0.2, function()
				clone.Blood.Enabled = true
				clone.Burst.Enabled = true
			end)

			repeat
				task.wait()
			until not instance2.Parent

			if localPlayer.Character == instance then
				TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
					{
						FieldOfView = 70
					}
				):Play()
			end

			TweenService:Create(v4, TweenInfo.new(0.5), {
				Volume = 0
			}):Play()
			v2:PlaySound(sounds.Choso.BloodRain.End, clone, game.SoundService.Effect)
			clone.Weld.Enabled = false
			clone.Anchored = true

			for _, effect in clone:GetDescendants() do
				if effect:IsA("ParticleEmitter") then
					effect.Enabled = false
				elseif effect:IsA("Beam") then
					TweenService:Create(effect, TweenInfo.new(0.4), {
						Width0 = 0,
						Width1 = 0
					}):Play()
				end
			end

			task.wait(1.3)
			clone:Destroy()
		end,
		FinalHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hakari.OverLuck.Hit2, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Hakari.RoughHit:Clone()
			clone.Glow.Color = ColorSequence.new(Color3.fromRGB(150, 0, 0))
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(150, 0, 0))
			clone.Wind.Color = ColorSequence.new(Color3.fromRGB(150, 0, 0))
			clone.Wind2.Color = ColorSequence.new(Color3.fromRGB(150, 0, 0))
			clone.PointLight.Color = Color3.fromRGB(150, 0, 0)
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0
			}):Play()
			clone.Glow:Emit(1)
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		BeamClashing = function(instance, p)
			local clone = utils.Choso.PlasmaWaveClash:Clone()
			clone.Parent = workspace.Effects

			local function toggleParticles(enabled)
				for _, emitter in clone.Attachment0:GetChildren() do
					if emitter:IsA("ParticleEmitter") then
						emitter.Enabled = enabled
					end
				end
			end

			toggleParticles(true)

			while instance.Parent and p.Parent do
				clone.CFrame = instance:GetAttribute("BeamStartCFrame") * CFrame.new(
					0,
					0,
					-instance:GetAttribute("BeamLength")
				) * CFrame.Angles(0, 3.141592653589793, 0)
				task.wait()
			end

			toggleParticles(false)

			for _, child in clone:GetChildren() do
				TweenService:Create(child, TweenInfo.new(0.2), {
					Position = createVector(0, 0, 0)
				}):Play()
			end

			task.wait(0.2)
			clone:Destroy()
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
	v = Knit.GetService("PlasmaWaveService")
	v2 = Knit.GetController("FXController")
end

return controller