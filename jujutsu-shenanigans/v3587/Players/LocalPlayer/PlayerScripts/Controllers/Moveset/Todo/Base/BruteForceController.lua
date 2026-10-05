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
local v3 = nil
local controller = Knit.CreateController({
	Name = "BruteForceController"
})

function controller.KnitStart(_)
	local v4 = {
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Todo.BruteForce.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		UhOH = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Todo.Woosh, humanoidRootPart, game.SoundService.Music)
		end,
		Woosh = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone.Parent = workspace.Effects
			clone.Wind:Emit(20)

			if p then
				clone.Sparks:Emit(20)
				TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
					Brightness = 0
				}):Play()
				v3:PlaySound(sounds.Itadori.DivergentFist.BlackFlash, humanoidRootPart, game.SoundService.Effect)
			else
				clone.PointLight:Destroy()
			end

			clone.Back1.Back:Emit(1)
			clone.Back2.Back:Emit(1)
			TweenService:Create(clone.Back1, TweenInfo.new(2), {
				CFrame = clone.Back1.CFrame - clone.Back1.CFrame.LookVector * 20
			}):Play()
			TweenService:Create(clone.Back2, TweenInfo.new(2), {
				CFrame = clone.Back2.CFrame - clone.Back2.CFrame.LookVector * 20
			}):Play()
			Debris:AddItem(clone, 3)
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
			v3:PlaySound(sounds.Mahito.Stockpile.Swing2, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Todo.BruteForce.Swing, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit = function(p, instance)
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
			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Todo.BruteForce.Hit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		BlackFlashHit = function(instance, instance2, p)
			local WAIT_INTERVAL = 0.03
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.Todo.BlackFlashHit:Clone()
			clone.Position = humanoidRootPart2.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 2)
			v3:Flash(instance2, Color3.new(1, 0, 0), 2)
			v3:PlaySound(sounds.Mahito.BlackFlash, humanoidRootPart2, game.SoundService.Effect)
			task.delay(0.07, function()
				clone.Wind2:Emit(10)
				clone.Sparks:Emit(40)
				clone.Sparks2:Emit(30)
				clone.Lightning:Emit(10)
				TweenService:Create(clone, TweenInfo.new(0.1), {
					Size = createVector(18, 18, 18),
					Transparency = 1
				}):Play()
			end)

			if p then
				v3:PlaySound(sounds.Todo.Wapam, humanoidRootPart, game.SoundService.Music)
				v3:Bleed(instance2)
				task.delay(0.2, function()
					v3:PlaySound(sounds.Todo.WapamVoice, humanoidRootPart, game.SoundService.Voice)
				end)
			end

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)

				if _G.Settings.Flash == true then
					local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone2.Parent = game.Lighting
					task.wait(WAIT_INTERVAL)
					clone2.Brightness = 200
					clone2.Contrast = -1000
					task.wait(WAIT_INTERVAL)
					clone2.TintColor = Color3.new(1, 1, 1)
					clone2.Brightness = -200
					clone2.Contrast = 1000
					task.wait(WAIT_INTERVAL)
					clone2:Destroy()
				end

				if p then
					game.Lighting.ExposureCompensation = 2
					TweenService:Create(game.Lighting, TweenInfo.new(1), {
						ExposureCompensation = 0
					}):Play()
				end
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
	v = Knit.GetService("BruteForceService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller