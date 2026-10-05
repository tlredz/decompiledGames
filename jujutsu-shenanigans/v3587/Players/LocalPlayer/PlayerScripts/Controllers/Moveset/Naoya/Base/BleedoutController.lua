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
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "BleedoutController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Naoya.Bleedout.Startup, humanoidRootPart, game.SoundService.Effect)
		end,
		Stab = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Choso.CounterSwing:Clone()
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(1, -1, -4) * CFrame.Angles(0, 0.2617993877991494, 0))
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.3)
			clone.Shock.Size = createVector(10, 2, 10)
			TweenService:Create(clone.Shock, TweenInfo.new(0.15), {
				Size = createVector(0, 15, 0),
				Transparency = 1,
				Position = clone.Shock2.Position + humanoidRootPart.CFrame.LookVector * 3
			}):Play()
			TweenService:Create(clone.Shock2, TweenInfo.new(0.1), {
				Size = createVector(8, 0, 8),
				Transparency = 1,
				Position = clone.Shock2.Position + humanoidRootPart.CFrame.LookVector * 3
			}):Play()
			TweenService:Create(clone.Shockwave, TweenInfo.new(0.15), {
				Size = createVector(0, 10, 0),
				Transparency = 1,
				CFrame = clone.Shockwave.CFrame * CFrame.Angles(0, 3.12413936106985, 0)
			}):Play()
		end,
		Hit = function(p, instance, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))

			if p2 then
				v2:PlaySound(sounds.Misc.Bleed, humanoidRootPart, game.SoundService.Effect)
			else
				v2:PlaySound(sounds.Naoya.Bleedout.Hit, humanoidRootPart, game.SoundService.Effect)
			end

			for _ = 1, 5 do
				BloodyZee:Blood(instance.Torso.CFrame, math.random(5, 20), 25, 25)
			end

			if localPlayer.Character == instance or localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Hit2 = function(p, instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			for _ = 1, 20 do
				BloodyZee:Blood(instance.Torso.CFrame, math.random(5, 80), 25, 25)
			end

			if localPlayer.Character == instance or localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit2Freeze = function(p, instance)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			if _G.Settings.Gore == true then
				local clone = utils.Naoya.BleedFreeze.Attachment:Clone()
				clone.Parent = instance.Torso
				clone.Blood:Emit(100)
				task.delay(0.3, function()
					clone.Blood.TimeScale = 0.01
					task.wait(0.75)
					TweenService:Create(clone.Blood, TweenInfo.new(0.2), {
						TimeScale = 0.5
					}):Play()
				end)
			end

			if localPlayer.Character == instance or localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Throw = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Naoya.Bleedout.Throw, humanoidRootPart, game.SoundService.Effect)
		end,
		FinishingStab = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Naoya.Bleedout.FinisherStab, humanoidRootPart, game.SoundService.Effect)

			for _ = 1, 20 do
				BloodyZee:Blood(instance.Torso.CFrame, math.random(5, 80), 25, 25)
			end

			if localPlayer.Character == instance or localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Afterimages = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == p or localPlayer.Character == instance then
				TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(0.75, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						FieldOfView = 60
					}
				):Play()
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
				Debris:AddItem(colorCorrectionEffect, 2.2)
				colorCorrectionEffect.TintColor = Color3.fromRGB(0, 0, 0)
				task.delay(0.1, function()
					colorCorrectionEffect.TintColor = Color3.fromRGB(135, 167, 255)
					colorCorrectionEffect.Saturation = -0.5
					colorCorrectionEffect.Brightness = 0.2
					task.wait(0.65)
					TweenService:Create(colorCorrectionEffect, TweenInfo.new(0.2), {
						TintColor = Color3.fromRGB(255, 255, 255),
						Saturation = 0,
						Brightness = 0
					}):Play()
					TweenService:Create(
						workspace.CurrentCamera,
						TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut),
						{
							FieldOfView = 70
						}
					):Play()
				end)
				v2:PlaySound(sounds.Naoya.Bleedout.Afterimages, workspace, game.SoundService.Effect)
			else
				v2:PlaySound(sounds.Naoya.Bleedout.Afterimages, humanoidRootPart, game.SoundService.Effect)
			end

			for i = 1, 7 do
				local clone = utils.Damage.HitGlow:Clone()
				Debris:AddItem(clone, 1)
				clone.Parent = workspace.Effects
				local tweenInfo = TweenInfo.new(1 - i * 0.1)

				for _, child in clone:GetChildren() do
					child.Color = Color3.fromRGB(128, 126, 255)
					child.Transparency = 0.2
					child.Anchored = true
					child.CFrame = instance[child.Name].CFrame
					TweenService:Create(child, tweenInfo, {
						Transparency = 1
					}):Play()
				end

				task.wait(0.1)
			end
		end,
		Flash = function(self)
			if not self:FindFirstChild("HumanoidRootPart") then
				return
			end

			v2:Flash(self, Color3.new(1, 1, 1), 0.5)
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
	v = Knit.GetService("BleedoutService")
	v2 = Knit.GetController("FXController")
end

return controller