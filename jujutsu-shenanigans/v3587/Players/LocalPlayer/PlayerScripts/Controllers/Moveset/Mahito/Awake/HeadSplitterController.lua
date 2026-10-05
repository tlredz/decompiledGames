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
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "HeadSplitterController"
})

function controller.KnitStart(_)
	local v4 = {
		Weave = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if localPlayer.Character == instance or localPlayer.Character == p then
				local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
				Debris:AddItem(colorCorrectionEffect, 2)
				TweenService:Create(
					workspace.CurrentCamera,
					TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						FieldOfView = 50
					}
				):Play()
				TweenService:Create(
					colorCorrectionEffect,
					TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Saturation = -0.5
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
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							Saturation = 0
						}
					):Play()
					task.wait(0.6)

					if _G.Settings.Flash ~= true then
						return
					end

					local clone = utils.Mahito.WideSPStrike.ScreenSlash:Clone()
					clone.Base.Rotation = 90
					clone.Parent = p.Head
					TweenService:Create(clone.Base.Base2, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
						BackgroundTransparency = 1
					}):Play()
					TweenService:Create(clone.Base.Frame, TweenInfo.new(0.1), {
						BackgroundTransparency = 1
					}):Play()
					Debris:AddItem(clone, 0.3)
				end)
			end

			task.spawn(function()
				local tweenInfo = TweenInfo.new(0.5)

				for _ = 1, 30 do
					local clone = utils.Damage.HitGlow:Clone()
					Debris:AddItem(clone, 0.5)
					clone.Parent = workspace.Effects

					for _, child in clone:GetChildren() do
						child.Color = Color3.fromRGB(170, 170, 255)
						child.Anchored = true
						child.CFrame = instance[child.Name].CFrame
						TweenService:Create(child, tweenInfo, {
							Transparency = 1
						}):Play()
					end

					task.wait(0.075)
				end
			end)
			local clone = utils.Gojo.Teleport:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1.1)
			clone.Floor.Dust:Emit(30)
			v3:Flash(instance, Color3.fromRGB(170, 170, 255), 2)
			v3:PlaySound(sounds.Mahito.HeadSplit.Weave, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Mahito.DrillSplit.Leap, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Mahito.HeadSplit.Weave2, humanoidRootPart, game.SoundService.Effect)
			v3:PlaySound(sounds.Mahito.HeadSplit.Bass, humanoidRootPart, game.SoundService.Effect)
			task.delay(0.7, function()
				v3:PlaySound(sounds.Mahito.HeadSplit.What, p.HumanoidRootPart, game.SoundService.Voice)
			end)
			local clone2 = replicatedStorage.Utils.Itadori.EyeTrails:Clone()
			clone2.Weld.Part0 = instance.Head
			clone2.Parent = workspace.Effects
			clone2.Trail1.Trail.Lifetime = 0.7
			clone2.Trail2.Trail.Lifetime = 0.7
			clone2.Glow:Emit(1)
			task.delay(2.5, function()
				clone2.Trail1.Trail.Enabled = false
				clone2.Trail2.Trail.Enabled = false
				clone2.Eye1.Glow.Enabled = false
				clone2.Eye2.Glow.Enabled = false
				clone2.Sparks:Emit(15)
				Debris:AddItem(clone2, 0.7)
			end)
			task.wait(1.5)
			local clone3 = utils.Mahito.Sparks:Clone()
			clone3.Parent = instance.Torso
			TweenService:Create(clone3, TweenInfo.new(0.5), {
				Rate = 100
			}):Play()
			task.wait(0.5)
			clone3:Destroy()
			v3:PlaySound(sounds.Mahito.HeadSplit.Slash, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Itadori.Dismantle.Slash, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 150 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)

				if _G.Settings.Flash == true then
					local clone = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
					clone.TintColor = Color3.new(1, 1, 1)
					clone.Parent = game.Lighting
					task.wait(0.04)
					clone.Brightness = 200
					clone.Contrast = -1000
					task.wait(0.04)
					clone:Destroy()
				end
			end

			if p then
				v3:PlaySound(sounds.Mahito.DrillSplit.Drill, humanoidRootPart, game.SoundService.Effect)
				v3:Bleed(instance)
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
	v = Knit.GetService("HeadSplitterService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller