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
	Name = "CrushingBlowController"
})

function controller.KnitStart(_)
	local v3 = {
		CurseBuild = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.DivergentFist.Crack, humanoidRootPart, game.SoundService.Effect)
			task.wait(0.3)
			v2:PlaySound(sounds.Misc.Swing.Fist, humanoidRootPart, game.SoundService.Effect)
		end,
		Crush = function(p, position)
			local clone = utils.Itadori.CrushingBlow:Clone()
			clone.Position = position
			clone.Parent = workspace.Effects
			TweenService:Create(clone.Air, TweenInfo.new(0.2), {
				Position = createVector(0, 0, 0)
			}):Play()
			TweenService:Create(clone.PointLight, TweenInfo.new(0.6), {
				Brightness = 0
			}):Play()
			clone.Flames:Emit(20)
			clone.Floor.Glow:Emit(1)
			clone.Floor.Ring:Emit(10)
			clone.Floor.Sparks:Emit(10)
			clone.Floor.Wind2:Emit(8)
			Debris:AddItem(clone, 1.5)
			v2:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)

			if localPlayer == p then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Burst = function(state)
			state.Ring.Enabled = false
			state.Attachment.Dust:Emit(20)
			state.Trail.Enabled = false
			state.Transparency = 1
			state.Attachment.Energy:Destroy()
			state.Attachment.Sparks:Emit(10)
			TweenService:Create(state.Attachment.PointLight, TweenInfo.new(0.5), {
				Brightness = 0
			}):Play()

			for _, child in state.Rocks:GetChildren() do
				local clone = child:Clone()
				clone.Anchored = false
				clone.WeldConstraint:Destroy()
				clone.Velocity = state.CFrame.LookVector * 60
				clone.Parent = state.Rocks
				task.delay(0.1, function()
					clone.CanCollide = true
					TweenService:Create(
						clone,
						TweenInfo.new(2, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							Size = createVector(0, 0, 0)
						}
					):Play()
					Debris:AddItem(clone, 2)
				end)
				child:Destroy()
			end
		end,
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CrushingBlow.Hit1, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Itadori.CrushingBlow.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
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
	v = Knit.GetService("CrushingBlowService")
	v2 = Knit.GetController("FXController")
end

return controller