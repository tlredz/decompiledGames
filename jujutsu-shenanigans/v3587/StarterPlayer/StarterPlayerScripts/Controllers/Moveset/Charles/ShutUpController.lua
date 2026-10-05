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
	Name = "ShutUpController"
})

function controller.KnitStart(_)
	local v3 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Charles.ShutUp.Swing, humanoidRootPart, game.SoundService.Effect)
		end,
		Throw = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Todo.Swing:Clone()
			clone.Weld.Part0 = humanoidRootPart
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.6)
			clone.Core.Wind:Emit(12)
			TweenService:Create(clone.Weld, TweenInfo.new(0.4), {
				C1 = clone.Weld.C1 * CFrame.Angles(0, -3.141592653589793, 0)
			}):Play()
			TweenService:Create(clone.Beam, TweenInfo.new(0.4), {
				Width0 = 0
			}):Play()
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Charles.StabWind:Clone()
			clone:PivotTo(humanoidRootPart.CFrame * CFrame.new(1, 1, 4) * CFrame.Angles(0, 2.792526803190927, 0))
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.3)
			TweenService:Create(clone.Shock, TweenInfo.new(0.15), {
				Size = createVector(0, 25, 0),
				Transparency = 1
			}):Play()
			TweenService:Create(clone.Shock2, TweenInfo.new(0.1), {
				Size = createVector(8, 0, 8),
				Transparency = 1,
				Position = clone.Shock2.Position + humanoidRootPart.CFrame.LookVector * 8
			}):Play()
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1), 1)
			v2:PlaySound(sounds.Charles.ShutUp.Stab, humanoidRootPart, game.SoundService.Effect)
			task.wait(0.7)
			v2:PlaySound(sounds.Charles.ShutUp.Throw, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit1 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1), 0.5)
			v2:PlaySound(sounds.Charles.ShutUp.Hit, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Hit2 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Charles.ShutUp.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Jump = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Twofold:Clone()
			clone.Size = createVector(24, 0, 24)
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(0, -6, -1) * CFrame.Angles(0, 0, 0)
			clone.Transparency = 0.5
			clone.Parent = workspace.Effects
			clone.Swing2.Swing1:Emit(10)
			TweenService:Create(clone, TweenInfo.new(0.3, Enum.EasingStyle.Exponential), {
				CFrame = clone.CFrame + clone.CFrame.UpVector * 5,
				Size = createVector(0, 15, 0)
			}):Play()
			Debris:AddItem(clone, 0.4)
			v2:PlaySound(sounds.Misc.Swing.Fist3, humanoidRootPart, game.SoundService.Effect)
		end,
		Crush = function(p, position)
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
			local clone2 = utils.Choso.CounterSwing.Shock:Clone()
			clone2.Size = createVector(6, 30, 6)
			clone2.CFrame = CFrame.new(position + createVector(0, 5, 0)) * CFrame.Angles(0, 0, 0)
			clone2.Parent = workspace.Effects
			Debris:AddItem(clone2, 0.2)
			TweenService:Create(clone2, TweenInfo.new(0.2), {
				Size = createVector(25, 0, 25),
				Transparency = 1,
				Position = clone2.Position - createVector(0, 10, 0)
			}):Play()
			v2:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)

			if localPlayer == p then
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
	v = Knit.GetService("ShutUpService")
	v2 = Knit.GetController("FXController")
end

return controller