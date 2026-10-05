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
local v3 = nil
local controller = Knit.CreateController({
	Name = "WhatAreYouAfterController"
})

function controller.KnitStart(_)
	local v4 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Hakari.FeverBreak.CrushSwing, humanoidRootPart, game.SoundService.Effect)
		end,
		Aerial = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")

			if not humanoid then
				return
			end

			local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
			bodyGyro.P = 10000
			bodyGyro.MaxTorque = createVector(40000, 40000, 40000)
			instance2.Position = humanoidRootPart.Position + createVector(0, 18, 0)
			humanoid.PlatformStand = true

			repeat
				local mouseTarget = v3:GetMouseTarget()
				bodyGyro.CFrame = instance2:GetAttribute("Aim") or CFrame.new(humanoidRootPart.Position, mouseTarget)
				task.wait()
			until not instance2.Parent

			bodyGyro:Destroy()
			humanoid.PlatformStand = false
		end,
		Crush = function(position)
			local clone = utils.Megumi.Mahoraga.Earthquake:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			clone.Air:Destroy()
			clone.PointLight:Destroy()
			TweenService:Create(clone.Floor.Ring2, TweenInfo.new(0.4), {
				TimeScale = 0.5
			}):Play()
			clone.Floor.Ring2:Emit(10)
			clone.Floor.Wind2:Emit(15)
			clone.Floor.Dust:Emit(100)
			Debris:AddItem(clone, 3)
			local cframe = CFrame.new(position)

			for _, child in utils.Misc.M.Awk.mokultMeh["3"]:GetChildren() do
				child:PivotTo(cframe)
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			v2:PlaySound(sounds.Mechamaru.AbsoluteDestruction.Slam, clone, game.SoundService.Effect)
			v2:PlaySound(sounds.Megumi.Mahoraga.Throw.Break, clone, game.SoundService.Effect)
			v2:DustBreak(position + createVector(0, 2, 0), createVector(0, 1, 0), 12, 35, 0.4, 1)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 180 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Dash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			for _, child in utils.Ryu.Launch:GetChildren() do
				child:PivotTo(humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0))
				Knit.GetController("MokouController"):ArcTween(child.Start, true)
			end

			v2:PlaySound(sounds.Hakari.OverLuck.Dash, humanoidRootPart, game.SoundService.Effect)

			for i = 1, 5 do
				task.delay(i * 0.06, function()
					local clone = utils.Itadori.Shock:Clone()
					clone.CFrame = CFrame.lookAlong(humanoidRootPart.Position, humanoidRootPart.Velocity) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					clone.Transparency = 0.3
					clone.Parent = workspace.Effects
					TweenService:Create(clone, TweenInfo.new(0.15), {
						Size = createVector(20, 0, 20),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone, 0.15)
				end)
			end
		end,
		Hit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Nanami.Interrogate.Hit, humanoidRootPart2, game.SoundService.Effect)
			v2:PlaySound(sounds.Naoya.Decisive.FirstHit, humanoidRootPart2, game.SoundService.Effect)
			task.delay(0.2, function()
				v2:PlaySound(sounds.Nanami.Dismember, humanoidRootPart2, game.SoundService.Effect)
			end)

			for _ = 1, 8 do
				BloodyZee:Blood(instance.Head.CFrame, math.random(5, 80), 25, 25)
			end

			for _ = 1, 8 do
				BloodyZee:Blood(instance2.Head.CFrame, math.random(5, 80), 25, 25)
			end

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.SnapOh)
				CameraShaker.CurrentShaker:ShakeSustain(CameraShaker.Presets.HeavyHit):StartFadeOut(1)
			elseif (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 100 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Hit2 = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Ryu.Dessert.Hit, humanoidRootPart2, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - humanoidRootPart.Position).Magnitude < 180 then
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
	v = Knit.GetService("WhatAreYouAfterService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller