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
local BloodyZee = require(replicatedStorage.Modules.BloodyZee)
local SraikoVFX = require(replicatedStorage.Modules.SraikoVFX)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "InterrogateController"
})
local _ = SraikoVFX.Emit
local _ = SraikoVFX.Enabled
local _ = SraikoVFX.EmitMesh

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Todo.BruteForce.Start, humanoidRootPart, game.SoundService.Effect)
			v2:ArmFlash(instance["Left Arm"], Color3.fromRGB(129, 168, 203), 0.7)
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
		end,
		Dash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local model = Instance.new("Model")
			local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -1, 0)
			clone.Parent = model
			model.Parent = workspace.Effects
			model:ScaleTo(0.6)
			clone.Ring:Emit(7)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			Debris:AddItem(model, 2)
			local clone2 = utils.Itadori.Shock:Clone()
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = createVector(8, 0, 8),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 0.2)
			task.delay(0.1, function()
				local clone3 = utils.Itadori.Shock:Clone()
				clone3.CFrame = (humanoidRootPart.CFrame - humanoidRootPart.CFrame.Position + humanoidRootPart.Position) * CFrame.Angles(
					1.5707963267948966,
					0,
					0
				)
				clone3.Parent = workspace.Effects
				TweenService:Create(clone3, TweenInfo.new(0.2), {
					Size = createVector(8, 0, 8),
					Transparency = 1
				}):Play()
				Debris:AddItem(clone3, 0.2)
			end)
		end,
		TrueRagdoll = function(instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			v2:Flash(instance, Color3.new(0, 0.682353, 1), 3)
		end,
		FinalSwing = function(instance, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(20)
			clone.PointLight:Destroy()
			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			Debris:AddItem(clone, 3)

			if p2 then
				if localPlayer.Character == instance or localPlayer.Character == p then
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
					colorCorrectionEffect.Saturation = -1
					colorCorrectionEffect.Contrast = 10
					Debris:AddItem(colorCorrectionEffect, 1.5)
					TweenService:Create(
						workspace.CurrentCamera,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							FieldOfView = 35
						}
					):Play()
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
						{
							Saturation = -0.5,
							Contrast = 0
						}
					):Play()
					task.delay(1, function()
						TweenService:Create(
							workspace.CurrentCamera,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								FieldOfView = 70
							}
						):Play()
						TweenService:Create(
							colorCorrectionEffect,
							TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
							{
								Saturation = 0
							}
						):Play()
					end)
				end

				for _, emitter in clone:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.TimeScale = 0
					end
				end

				task.wait(1)

				for _, emitter in clone:GetDescendants() do
					if emitter:IsA("ParticleEmitter") then
						emitter.TimeScale = 1
					end
				end
			end

			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
			}):Play()
			local clone2 = utils.Choso.CounterSwing.Shock:Clone()
			clone2.Size = createVector(6, 30, 6)
			clone2.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.2)
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = createVector(25, 0, 25),
				Transparency = 1,
				Position = clone2.Position + humanoidRootPart.CFrame.LookVector * 10
			}):Play()
			v2:PlaySound(sounds.Mahito.Stockpile.Swing2, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Todo.BruteForce.Swing, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Ohno = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == instance or localPlayer.Character == p then
				TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						FieldOfView = 50
					}
				):Play()
				task.delay(1.5, function()
					TweenService:Create(
						workspace.CurrentCamera,
						TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
						{
							FieldOfView = 70
						}
					):Play()
				end)
			end

			local clone = utils.Mechamaru.Dust:Clone()
			clone.bigimpact:Destroy()
			clone.Smoke2:Destroy()
			clone.Position = humanoidRootPart.Position - createVector(0, 3, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2.5)

			for _, child in clone:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
				TweenService:Create(child, TweenInfo.new(0.4), {
					TimeScale = 0.1
				}):Play()
			end

			task.wait(1.5)

			for _, child in clone:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
				child.TimeScale = 1
			end
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 1))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Todo.BruteForce.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone2 = utils.Mechamaru.Dust:Clone()
			clone2.bigimpact:Destroy()
			clone2.Smoke2:Destroy()
			clone2.Position = humanoidRootPart.Position - createVector(0, 3, 0)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 2)

			for _, child in clone2:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			for _ = 1, 20 do
				BloodyZee:Blood(instance.Head.CFrame, math.random(5, 80), 25, 25)
			end

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 80 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Grab = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Nanami.Interrogate["Grab" .. p], humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 80 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Chat = function(p, text, playbackSpeed)
			if p.Head:FindFirstChild("HiromiText") then
				p.Head.HiromiText:Destroy()
			end

			local playSound = v2:PlaySound(sounds.Hiromi.DeadlySentence.Talk, p.Head, game.SoundService.Voice)
			playSound.PlaybackSpeed = playbackSpeed
			local clone = utils.Hiromi.DeadlySentencing.HiromiText:Clone()
			clone.TextLabel.Text = text
			clone.Parent = p.Head
			Debris:AddItem(clone, 1.5)
			task.delay(1, function()
				if not clone.Parent then
					return
				end

				TweenService:Create(clone.TextLabel, TweenInfo.new(0.5), {
					BackgroundTransparency = 1,
					TextTransparency = 1
				}):Play()
				TweenService:Create(clone.TextLabel.UIStroke, TweenInfo.new(0.5), {
					Transparency = 1
				}):Play()
			end)
		end,
		FinalHit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(85, 170, 255))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v2:Flash(instance, Color3.new(1, 1, 1))
			local clone2 = utils.Mechamaru.Dust:Clone()
			clone2.bigimpact:Destroy()
			clone2.Smoke2:Destroy()
			clone2.Position = humanoidRootPart.Position - createVector(0, 3, 0)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 2.5)

			for _, child in clone2:GetChildren() do
				child:Emit(child:GetAttribute("EmitCount"))
			end

			if p then
				v2:PlaySound(sounds.Nanami.Interrogate.FinisherHit, humanoidRootPart, game.SoundService.Effect)
				v2:PlaySound(sounds.Nanami.Interrogate.Freeze, humanoidRootPart, game.SoundService.Effect)

				if _G.Settings.Gore == true then
					local clone3 = utils.Naoya.BleedFreeze.Attachment:Clone()
					clone3.Parent = instance.Head
					clone3.Blood:Emit(100)
					task.delay(0.05, function()
						clone3.Blood.TimeScale = 0
						task.wait(0.95)
						clone3.Blood.TimeScale = 1

						for _ = 1, 20 do
							BloodyZee:Blood(instance.Head.CFrame, math.random(5, 80), 25, 25)
						end
					end)
				end

				for _, child in clone2:GetChildren() do
					child.TimeScale = 0
				end

				task.delay(1, function()
					for _, child in clone2:GetChildren() do
						child.TimeScale = 1
					end
				end)
			else
				v2:PlaySound(sounds.Nanami.Interrogate.Hit, humanoidRootPart, game.SoundService.Effect)

				for _ = 1, 20 do
					BloodyZee:Blood(instance.Head.CFrame, math.random(5, 80), 25, 25)
				end
			end

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 80 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end
		end,
		FinalHit2 = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(85, 170, 255))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Todo.BruteForce.Hit, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 80 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v5 = v4[p]

		if not v5 then
			return
		end

		v5(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("InterrogateService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller