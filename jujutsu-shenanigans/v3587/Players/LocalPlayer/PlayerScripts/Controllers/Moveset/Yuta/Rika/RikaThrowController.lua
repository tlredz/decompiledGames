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
local controller = Knit.CreateController({
	Name = "RikaThrowController"
})

function controller.KnitStart(_)
	local v3 = {
		TrackCamera = function(instance, cameraSubject)
			v2:PlaySound(sounds.Yuta.Rika.ThrowStart, cameraSubject, game.SoundService.Effect)
			workspace.CurrentCamera.CameraSubject = cameraSubject

			while not instance:GetAttribute("Disabled") and instance.Parent do
				instance:FireServer(workspace.CurrentCamera.CFrame.LookVector)
				task.wait()
			end

			workspace.CurrentCamera.CameraSubject = localPlayer.Character.Humanoid
		end,
		Sniper = function(instance, instance2)
			local WAIT_INTERVAL = 0.04
			local humanoidRootPart = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			local clone = utils.Itadori.DivergentFist.BlackFlashHit:Clone()
			clone.Position = humanoidRootPart2.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			local clone2 = utils.Itadori.DivergentFist.FinisherDrag:Clone()
			clone2.Parent = humanoidRootPart2
			Debris:AddItem(clone2, 0.3)
			v2:Flash(instance, Color3.new(1, 0, 0))
			v2:PlaySound(sounds.Itadori.DivergentFist.BlackFlashHit, humanoidRootPart2, game.SoundService.Effect)
			v2:PlaySound(sounds.Yuta.BlackFlash.Land3, humanoidRootPart, game.SoundService.Music)
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

			if localPlayer.Character == instance2 or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)

				if _G.Settings.Flash ~= true then
					return
				end

				local clone3 = utils.Itadori.DivergentFist.BlackFlashCC:Clone()
				clone3.Parent = game.Lighting
				task.wait(WAIT_INTERVAL)
				clone3.TintColor = Color3.new(1, 1, 1)
				task.wait(WAIT_INTERVAL)
				clone3.Brightness = 200
				clone3.Contrast = -1000
				task.wait(WAIT_INTERVAL)
				clone3:Destroy()
			end
		end
	}
	RikaThrowService.Effects:Connect(function(p, ...)
		local v4 = v3[p]

		if not v4 then
			return
		end

		v4(...)
	end)
end

function controller.KnitInit(_)
	RikaThrowService = Knit.GetService("RikaThrowService")
	v = Knit.GetController("HitboxController")
	v2 = Knit.GetController("FXController")
end

return controller