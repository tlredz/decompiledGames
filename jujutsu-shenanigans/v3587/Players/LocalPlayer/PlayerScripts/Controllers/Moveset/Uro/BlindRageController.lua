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
require(replicatedStorage.Modules.StaticLightning)
require(replicatedStorage.Modules.LightningBeams)
local v = nil
local v2 = nil
local controller = Knit.CreateController({
	Name = "BlindRageController"
})

function controller.KnitStart(_)
	local v3 = {
		Fly = function(instance, instance2)
			local humanoidRootPart = instance.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")

			if not humanoid then
				return
			end

			task.spawn(function()
				local model = Instance.new("Model", workspace.Effects)
				local highlight = Instance.new("Highlight")
				highlight.FillTransparency = 1
				highlight.OutlineTransparency = 1
				highlight.Parent = model

				repeat
					task.wait(0.1)
					local clone = utils.Uro.Ring:Clone()
					clone.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
					clone.Parent = model
					clone.Attachment.Wind:Emit(2)
					TweenService:Create(clone, TweenInfo.new(0.5), {
						Size = clone.Size * 2,
						Transparency = 1
					}):Play()
					Debris:AddItem(clone, 0.5)
				until not instance2:IsDescendantOf(workspace.Characters)

				Debris:AddItem(model, 0.5)
			end)
			v2:PlaySound(sounds.Uro.BlindRage.Fly, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Ryu.NotInvited.Dash, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
				bodyGyro.P = 10000
				bodyGyro.MaxTorque = createVector(40000, 40000, 40000)
				instance2.Position = humanoidRootPart.Position + createVector(0, 12, 0)
				humanoid.PlatformStand = true

				repeat
					local cFrame = workspace.CurrentCamera.CFrame
					instance2.Position = humanoidRootPart.Position + cFrame.LookVector * 40
					bodyGyro.CFrame = cFrame
					task.wait()
				until not instance2.Parent

				humanoid.PlatformStand = false
				bodyGyro:Destroy()
			end
		end,
		Swing = function(p, p2)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			if p2 == 1 then
				v2:PlaySound(sounds.Uro.BlindRage.Swing1, humanoidRootPart, game.SoundService.Effect)
				return
			end

			v2:PlaySound(sounds.Uro.BlindRage.Swing2, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Uro.BlindRage.Swing3, humanoidRootPart, game.SoundService.Effect)
		end,
		Startup = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Uro.BlindRage.Swing3, humanoidRootPart, game.SoundService.Effect)
		end,
		Dash = function(p)
			local humanoidRootPart = p.HumanoidRootPart

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
			task.delay(0.05, function()
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
		Throw = function(p)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(2, 1, -5)
			clone.Parent = workspace.Effects
			clone.PointLight:Destroy()
			clone.Wind:Emit(20)
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
			v2:PlaySound(sounds.Uro.BlindRage.Throw, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Grab = function(instance, instance2)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 200 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Ryu.SecondHelping.Hit, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.fromRGB(255, 165, 165))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(30)
			clone.Wind2:Emit(7)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 60 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
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
	v = Knit.GetService("BlindRageService")
	v2 = Knit.GetController("FXController")
end

return controller