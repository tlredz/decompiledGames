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
	Name = "RoughEnergyController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.fromRGB(85, 255, 127), 0.5)
			v2:PlaySound(sounds.Hakari.OverLuck.Charge, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.AirPalm:Clone()
			clone.Parent = workspace.Effects
			clone:SetPrimaryPartCFrame(humanoidRootPart.CFrame * CFrame.new(0, 0, -4))
			v2:PlaySound(sounds.Itadori.DivergentFist.Swing, humanoidRootPart, game.SoundService.Effect)
			TweenService:Create(
				clone.Blast,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = createVector(13, 13, 0),
					CFrame = clone.Blast.CFrame + humanoidRootPart.CFrame.LookVector * 2,
					Transparency = 1
				}
			):Play()
			TweenService:Create(
				clone.Core,
				TweenInfo.new(0.3, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
				{
					Size = createVector(0, 10, 0),
					CFrame = clone.Core.CFrame + humanoidRootPart.CFrame.LookVector * 5,
					Transparency = 1
				}
			):Play()
			Debris:AddItem(clone, 0.6)
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Hakari.RoughHit:Clone()
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
		Dash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Hakari.EnergySurge.Swing, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Hakari.OverLuck.Speed1, humanoidRootPart, game.SoundService.Effect)

			for i = 1, 3 do
				task.delay(i * 0.075, function()
					local clone = utils.Itadori.Shock:Clone()
					clone.CFrame = CFrame.lookAlong(humanoidRootPart.Position, createVector(-0, -1, -0)) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					clone.Transparency = 0.3
					clone.Parent = workspace.Effects
					TweenService:Create(clone, TweenInfo.new(0.15), {
						Size = createVector(30, 0, 30),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone, 0.15)
				end)
			end
		end,
		Crush = function(_, position, p)
			local clone = utils.Hiromi.Shockwave:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			clone.CFrame *= CFrame.Angles(0, math.rad((math.random(-179, 179))), 0)
			TweenService:Create(clone.mesh.Mesh, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Scale = createVector(15, 0, 15)
			}):Play()
			TweenService:Create(clone.mesh.Decal, TweenInfo.new(0.5, Enum.EasingStyle.Exponential), {
				Transparency = 1
			}):Play()
			clone.Floor.Glow:Emit(1)
			clone.Floor.Ring:Emit(10)
			Debris:AddItem(clone, 1.5)

			if p then
				local clone2 = utils.Hakari.RoughImpact:Clone()
				clone2.Position = position
				clone2.Parent = workspace.Effects
				Debris:AddItem(clone2, 2)
				TweenService:Create(clone2.PointLight, TweenInfo.new(0.6), {
					Brightness = 0
				}):Play()
				clone2.Glow:Emit(1)
				clone2.Sparks:Emit(50)
				clone2.Wind2:Emit(7)
				TweenService:Create(clone2.Air, TweenInfo.new(0.2), {
					Position = createVector(0, 0, 0)
				}):Play()
				v2:PlaySound(sounds.Hakari.Shock, clone2, game.SoundService.Effect)
			end

			v2:PlaySound(sounds.Hakari.Impact, clone, game.SoundService.Effect)

			if (workspace.CurrentCamera.CFrame.Position - position).Magnitude < 150 then
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
	v = Knit.GetService("RoughEnergyService")
	v2 = Knit.GetController("FXController")
end

return controller