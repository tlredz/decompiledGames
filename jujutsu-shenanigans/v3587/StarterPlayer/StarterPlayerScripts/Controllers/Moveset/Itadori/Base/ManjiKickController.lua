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
	Name = "ManjiKickController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			v2:PlaySound(sounds.Itadori.ManjiKick.Startup, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Fade = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Damage.HitGlow:Clone()

			if instance:GetScale() ~= 1 then
				clone:ScaleTo(instance:GetScale())
			end

			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.5)

			for _, child in clone:GetChildren() do
				local child2 = instance:FindFirstChild(child.Name)

				if child2 then
					child.CFrame = child2.CFrame
				end

				child.Color = Color3.new(0, 0, 0)
				child.Anchored = true
				child.Transparency = 0.1
				TweenService:Create(child, TweenInfo.new(0.5), {
					Transparency = 1
				}):Play()
			end

			v2:PlaySound(sounds.Itadori.ManjiKick.Dodge, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			v2:PlaySound(sounds.Itadori.ManjiKick.Swing, humanoidRootPart, game.SoundService.Effect)
		end,
		Slam = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")
			v2:PlaySound(sounds.Itadori.ManjiKick.Slam, humanoidRootPart, game.SoundService.Effect)
		end,
		Wheel = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.HardHit:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Ring.RotSpeed = NumberRange.new(300, 600)
			clone.Ring.Speed = NumberRange.new(0.1, 20)
			clone.Parent = workspace.Effects
			clone.Ring.Enabled = true
			task.delay(0.4, function()
				clone.Ring.Enabled = false
				Debris:AddItem(clone, 0.5)
			end)
			v2:PlaySound(sounds.Itadori.CursedStrikes.Spin, humanoidRootPart, game.SoundService.Effect)
		end,
		Crush = function(position)
			local clone = utils.Megumi.Mahoraga.Earthquake:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			clone.Air:Destroy()
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0
			}):Play()
			TweenService:Create(clone.Floor.Ring2, TweenInfo.new(0.4), {
				TimeScale = 0.5
			}):Play()
			clone.Floor.Ring2:Emit(10)
			clone.Floor.Wind2:Emit(15)
			clone.Floor.Dust:Emit(100)
			Debris:AddItem(clone, 3)
			local clone2 = utils.Megumi.Mahoraga.WorldSlash.mesh:Clone()
			clone2.Position = position
			clone2.Decal.Transparency = 0
			clone2.Mesh.Scale = createVector(1, 50, 1)
			clone2.Parent = clone
			TweenService:Create(clone2, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Size = createVector(30, 40, 30),
				CFrame = clone2.CFrame * CFrame.Angles(0, -3.12413936106985, 0)
			}):Play()
			TweenService:Create(clone2.Mesh, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Scale = createVector(25, 10, 25)
			}):Play()
			TweenService:Create(clone2.Decal, TweenInfo.new(1, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 1)
			v2:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, clone, game.SoundService.Effect)
			v2:PlaySound(sounds.Mahito.WideSPStrike.Crush, clone, game.SoundService.Effect)
			v2:PlaySound(sounds.Mahito.WideSPStrike.Crush2, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 180 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		AprilFools = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:PlaySound(sounds.Itadori.AprilFools.Surprise, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Yuki.RisingRage.Hit3, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
			end

			local clone = utils.Gojo.LapseBlue.LapseBlue.Grab:Clone()
			clone.Anchored = true
			clone.Position = instance2.Head.Position
			clone.Parent = workspace.Effects
			clone.Size = createVector(50, 50, 50)
			local highlight = Instance.new("Highlight", clone)
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			TweenService:Create(clone, TweenInfo.new(1, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
				Size = createVector(5, 5, 5),
				Transparency = 50
			}):Play()
			Debris:AddItem(clone, 1)

			for _, child in utils.Ryu.Launch:GetChildren() do
				child:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 1.2217304763960306, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			task.delay(4, function()
				v2:PlaySound(sounds.Itadori.AprilFools.Fah, humanoidRootPart, game.SoundService.Effect)
				v2:PlaySound(sounds.Itadori.AprilFools.Explosion2, humanoidRootPart, game.SoundService.Effect)
			end)
			task.delay(1, function()
				local clone2 = utils.Megumi.Mahoraga.Earthquake:Clone()
				clone2.Position = humanoidRootPart2.Position
				clone2.Parent = workspace.Effects
				clone2.Air:Destroy()
				clone2.PointLight:Destroy()
				TweenService:Create(clone2.Floor.Ring2, TweenInfo.new(0.4), {
					TimeScale = 0.5
				}):Play()
				clone2.Floor.Ring2:Emit(10)
				clone2.Floor.Wind2:Emit(15)
				clone2.Floor.Dust:Emit(100)
				Debris:AddItem(clone2, 3)
				local cframe = CFrame.new(humanoidRootPart2.Position)

				for _, child in utils.Misc.M.Awk.mokultMeh["3"]:GetChildren() do
					child:PivotTo(cframe)
					Knit.GetController("MokouController"):ArcTween(child.Start, true)
				end

				v2:PlaySound(sounds.Itadori.AprilFools.Explosion, clone2, game.SoundService.Effect)
				v2:PlaySound(sounds.Itadori.AprilFools.Bass, clone2, game.SoundService.Effect)
				v2:DustBreak(humanoidRootPart2.Position, createVector(0, 1, 0), 12, 35, 0.4, 1)

				if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart2.Position).Magnitude < 100 then
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
					local shakeSustain = CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.Snap)
					local colorCorrectionEffect = Instance.new("ColorCorrectionEffect", game.Lighting)
					colorCorrectionEffect.Contrast = 20
					colorCorrectionEffect.Saturation = -2
					TweenService:Create(
						colorCorrectionEffect,
						TweenInfo.new(3, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							Contrast = 0,
							Saturation = 0
						}
					):Play()
					Debris:AddItem(colorCorrectionEffect, 3)
					task.wait(3)
					CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
					shakeSustain:StartFadeOut(1)
				end
			end)
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
	v = Knit.GetService("ManjiKickService")
	v2 = Knit.GetController("FXController")
end

return controller