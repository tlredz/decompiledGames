local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
game:GetService("TweenService")
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
	Name = "GushingWoundController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance, instance2, _)
			if not instance:FindFirstChild("HumanoidRootPart") then
				return
			end

			for _, part in instance2:GetChildren() do
				if not (part.Name ~= "Root" and part:IsA("BasePart")) then
					continue
				end

				local clone = utils.Reggie.ReceiptBurn:Clone()
				clone.Parent = workspace.Effects
				clone.Weld.Part0 = part
				Debris:AddItem(clone, 5)
				part.Destroying:Connect(function()
					clone.Anchored = true

					for i, child in clone.BurningPart:GetChildren() do
						child.Enabled = false
					end
				end)
			end
		end,
		Hit = function(instance, instance2, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))

			for _ = 1, 5 do
				BloodyZee:Blood(
					CFrame.lookAt(humanoidRootPart2.Position, humanoidRootPart.Position),
					math.random(5, 20),
					25,
					25
				)
			end

			local playSound = v3:PlaySound(sounds.Reggie.KnifeHit, humanoidRootPart2, game.SoundService.Effect)
			playSound.Volume = p and 0.3333333333333333 or 1

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
			end
		end,
		Interp = function(instance, p)
			local clone = utils.Reggie.ReceiptBurn:Clone()
			clone.Parent = workspace.Effects
			clone.Anchored = true
			clone.CFrame = instance.CFrame * CFrame.new(-3, 0, 0)
			v3:PlayParticles(clone)
			Debris:AddItem(clone, 3)
			local v5 = v3:PlaySound(sounds.Reggie.CouponBurn, instance, game.SoundService.Effect)
			v5:Stop()
			v5.PlayOnRemove = true
			v5.Volume = p and 0.3333333333333333 or 1
			v5:Destroy()
			local playSound = v3:PlaySound(sounds.Reggie.KnifeThrow, instance, game.SoundService.Effect)
			playSound.Volume = p and 0.3333333333333333 or 1
			local cFrame = instance.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance.CFrame
				lastTime = tick()
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if instance.Parent and instance:GetAttribute("Speed") ~= nil then
					workspace:BulkMoveTo(
						{ instance },
						{ cFrame + -cFrame.RightVector * (instance:GetAttribute("Speed") * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
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
	v = Knit.GetService("GushingWoundService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller