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
	Name = "RapidPunchesController"
})

function controller.KnitStart(_)
	local v3 = {
		Hit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(
				sounds.Gojo.M1:FindFirstChild("Hit" .. math.random(1, 4)),
				humanoidRootPart,
				game.SoundService.Effect
			)
		end,
		FinalHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.M1:FindFirstChild("Hit4"), humanoidRootPart, game.SoundService.Effect)
		end,
		BlackFlashHit = function(instance, instance2)
			local WAIT_INTERVAL = 0.04

			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashHit:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			v2:Flash(instance2, Color3.new(1, 0, 0))
			v2:PlaySound(sounds.Itadori.DivergentFist.BlackFlashHit, humanoidRootPart, game.SoundService.Effect)
			clone.Wind2:Emit(8)
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()
			task.delay(0.1, function()
				clone.Blast:Emit(8)
				clone.Sparks:Emit(15)
				clone.Lightning:Emit(6)
				clone.Wind:Emit(7)
			end)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone2 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone2.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone2.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone2.Brightness = 200
				clone2.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone2:Destroy()
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
	v = Knit.GetService("RapidPunchesService")
	v2 = Knit.GetController("FXController")
end

return controller