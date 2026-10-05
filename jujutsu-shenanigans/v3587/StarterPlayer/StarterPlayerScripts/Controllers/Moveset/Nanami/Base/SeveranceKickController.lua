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
	Name = "SeveranceKickController"
})

function controller.KnitStart(_)
	local v3 = {
		Swing = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(
				p and sounds.Nanami.SeveranceKick.WhooshBack or sounds.Nanami.SeveranceKick.WhooshFront,
				humanoidRootPart,
				game.SoundService.Effect
			)
		end,
		Whoosh = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local cFrame = humanoidRootPart.CFrame

			if p then
				cFrame = humanoidRootPart.CFrame * CFrame.Angles(0, 3.141592653589793, 0)
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			local model = Instance.new("Model")
			clone.Parent = model
			model:ScaleTo(0.7)
			Debris:AddItem(model, 0.2)
			clone.CFrame = cFrame * (p and CFrame.new(0, 0, -4) or CFrame.new(0, 0, -5))
			clone.Parent = workspace.Effects
			clone.Wind:Emit(10)
			clone.PointLight:Destroy()
			clone.Wind.Lifetime = NumberRange.new(0.9, 1.5)
			clone.Back1.Back.Size = NumberSequence.new(0)
			clone.Back2.Back.Size = NumberSequence.new(0)
			Debris:AddItem(clone, 3)
			local clone2 = utils.Choso.CounterSwing.Shock:Clone()
			clone2.Size = createVector(3, 15, 3)
			clone2.CFrame = cFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.2)
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = createVector(17.5, 0, 17.5),
				Transparency = 1,
				Position = clone2.Position + cFrame.LookVector * 10
			}):Play()
		end,
		Hit = function(instance, instance2, p, p2, p3)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			if instance == localPlayer.Character or instance2 == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end

			local clone = utils.Nanami.SeveranceHit:Clone()
			clone.Parent = workspace.Effects
			clone.CFrame = CFrame.lookAt(humanoidRootPart.Position, humanoidRootPart.Position + p3) * CFrame.new(
				0,
				0,
				-4
			)
			Debris:AddItem(clone, 1.2)
			local tweenInfo = TweenInfo.new(0.15, Enum.EasingStyle.Circular, Enum.EasingDirection.In)
			local tween = TweenService:Create(clone, tweenInfo, {
				Size = createVector(4, 4, 4),
				Transparency = 0
			})
			tween:Play()

			for _, child in clone.Beams:GetChildren() do
				TweenService:Create(child, tweenInfo, {
					Position = child.Position + createVector(0, 0, 9)
				}):Play()
			end

			v2:Flash(instance2, Color3.new(0.333333, 0.666667, 1), 0.2)
			v2:PlaySound(sounds.Nanami.CrossCut.Hit2, humanoidRootPart2, game.SoundService.Effect)
			local whooshBack = humanoidRootPart:FindFirstChild("WhooshBack") or humanoidRootPart:FindFirstChild("WhooshFront")

			if whooshBack then
				whooshBack.PlaybackSpeed = 0
			end

			if instance == localPlayer.Character or instance2 == localPlayer.Character then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end

			task.delay(p2 and 0.35 or 0.2, function()
				local tweenInfo2 = TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				tween:Cancel()
				clone.Transparency = 1

				for _, child in clone.Beams:GetChildren() do
					TweenService:Create(child, tweenInfo2, {
						Position = child.Position + createVector(0, 0, 25)
					}):Play()
					child.Beam.TextureSpeed = 4
					TweenService:Create(
						child.Beam,
						TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
						{
							Width0 = 0,
							Width1 = 0,
							TextureSpeed = 1
						}
					):Play()
				end

				clone.Hit.Sparks:Emit(10)
				clone.Hit.Wind2:Emit(6)
				TweenService:Create(clone.PointLight, TweenInfo.new(0.5), {
					Brightness = 0
				}):Play()
				TweenService:Create(clone, tweenInfo2, {
					CFrame = clone.CFrame + clone.CFrame.LookVector * 12
				}):Play()
				clone.Wind:Emit(6)
				clone.Back1.Back:Emit(1)
				clone.Back2.Back:Emit(1)
				TweenService:Create(clone.Back1, TweenInfo.new(0.4), {
					CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
				}):Play()
				TweenService:Create(clone.Back2, TweenInfo.new(0.4), {
					CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
				}):Play()
				local clone2 = utils.Choso.CounterSwing.Shock:Clone()
				clone2.Size = createVector(30, 6, 30)
				clone2.CFrame = clone.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, 0.4)
				TweenService:Create(clone2, TweenInfo.new(0.4), {
					Size = createVector(0, 30, 0),
					Transparency = 1,
					Position = clone2.Position + clone.CFrame.LookVector * 10
				}):Play()
				v2:Flash(instance2, Color3.new(0.333333, 0.666667, 1), 0.6)

				if whooshBack then
					whooshBack.PlaybackSpeed = 1
				end

				if p2 then
					v2:PlaySound(sounds.Nanami.SeveranceKick.HitBackStun, humanoidRootPart2, game.SoundService.Effect)
				else
					v2:PlaySound(
						p and sounds.Nanami.SeveranceKick.HitBack or sounds.Nanami.SeveranceKick.HitFront,
						humanoidRootPart2,
						game.SoundService.Effect
					)
				end

				if instance == localPlayer.Character or instance2 == localPlayer.Character then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.MediumHit)
				end
			end)
		end,
		ThrowableWind = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuta.PunchSwing, humanoidRootPart, game.SoundService.Effect)
		end,
		ThrowableHit = function(instance, _)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuta.MetalHit, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Hakari.Impact, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 150 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
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
	v = Knit.GetService("SeveranceKickService")
	v2 = Knit.GetController("FXController")
end

return controller