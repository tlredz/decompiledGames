local createVector = vector.create
local Knit = require(game.ReplicatedStorage.Knit.Knit)
game:GetService("UserInputService")
local RunService = game:GetService("RunService")
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
	Name = "GarageSaleController"
})

function controller.KnitStart(_)
	local v4 = {
		Start = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Reggie.GarageSaleFire, humanoidRootPart, game.SoundService.Effect)
		end,
		Interp = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Reggie.ReceiptBurn:Clone()
			clone.Parent = workspace.Effects
			clone.Anchored = true
			clone.CFrame = instance:FindFirstChild("ReceiptStack") and instance.ReceiptStack.CFrame or instance2.CFrame
			v3:PlayParticles(clone)
			Debris:AddItem(clone, 3)
			local v5 = humanoidRootPart.CFrame * CFrame.new(0, 1, 0)

			if instance2.Name == "Fridge" then
				local clone2 = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
				local model = Instance.new("Model")
				clone2.Parent = model
				model:ScaleTo(0.8)
				Debris:AddItem(model, 0.2)
				clone2.CFrame = v5 * CFrame.new(0, 0, -6)
				clone2.Parent = workspace.Effects
				clone2.Wind.Lifetime = NumberRange.new(0.4, 1)
				clone2.Wind:Emit(20)
				clone2.PointLight:Destroy()
				v3:PlaySound(sounds.Reggie.CouponBurn, humanoidRootPart, game.SoundService.Effect)
			end

			local clone2 = utils.Itadori.DivergentFist.BlackFlashLaunch:Clone()
			local model = Instance.new("Model")
			clone2.Parent = model
			model:ScaleTo(0.3)
			Debris:AddItem(model, 0.2)
			clone2.CFrame = v5 * CFrame.new(0, 0, -math.random(4, 16))
			clone2.Parent = workspace.Effects
			clone2.Wind:Emit(2)
			clone2.PointLight:Destroy()
			clone2.Wind.Lifetime = NumberRange.new(0.25, 0.8)
			clone2.Back1.Back.Size = NumberSequence.new(0)
			clone2.Back2.Back.Size = NumberSequence.new(0)
			Debris:AddItem(clone2, 3)
			local cFrame = instance2.CFrame
			local lastTime = tick()
			local positionChangedConnection = instance2:GetPropertyChangedSignal("Position"):Connect(function()
				cFrame = instance2.CFrame
				lastTime = tick()
			end)
			local steppedConnection = nil
			steppedConnection = RunService.Stepped:Connect(function()
				if instance2.Parent and instance2:GetAttribute("Speed") ~= nil then
					workspace:BulkMoveTo(
						{ instance2 },
						{ cFrame + cFrame.LookVector * (instance2:GetAttribute("Speed") * (tick() - lastTime)) },
						Enum.BulkMoveMode.FireCFrameChanged
					)
					return
				end

				steppedConnection:Disconnect()
				positionChangedConnection:Disconnect()
			end)
		end,
		Break = function(instance)
			for _ = 1, 3 do
				local clone = utils.Hiromi.GavelShard:Clone()
				clone.Position = (instance.CFrame * CFrame.new((Vector3.new(
					(math.random() - 0.5) * instance.Size.X,
					(math.random() - 0.5) * instance.Size.Y,
					(math.random() - 0.5) * instance.Size.Z
				)))).Position
				clone.Size *= instance.Size.Magnitude / 5
				clone.Color = instance.Color
				clone.Velocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
				clone.RotVelocity = Vector3.new(math.random(-50, 50), math.random(-50, 50), math.random(-50, 50))
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 2)
				task.delay(1, function()
					TweenService:Create(clone, TweenInfo.new(1), {
						Size = createVector(0, 0, 0)
					}):Play()
				end)
			end

			local v5 = sounds.Reggie.GarageSale:GetChildren()[math.random(1, #sounds.Reggie.GarageSale:GetChildren())]

			if instance.Name == "Fridge" then
				v5 = sounds.Reggie["Metal" .. math.random(1, 2)]
			end

			local v6 = v3:PlaySound(v5, instance, game.SoundService.Effect)
			v6:Stop()
			v6.PlayOnRemove = true
			v6:Destroy()
		end,
		Hit = function(instance, instance2, p, _)
			if not (instance:FindFirstChild("HumanoidRootPart") and instance2:FindFirstChild("HumanoidRootPart")) then
				return
			end

			v3:Flash(instance2, Color3.new(1, 1, 1))

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(p and CameraShaker.Presets.HeavyHit or CameraShaker.Presets.LightHit)
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
	v = Knit.GetService("GarageSaleService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller