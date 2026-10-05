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
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "OverLuckController"
})

function controller.KnitStart(_)
	local v4 = {
		Charge = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.fromRGB(85, 255, 127), 1)
			v3:PlaySound(sounds.Hakari.OverLuck.Charge, humanoidRootPart, game.SoundService.Effect)
		end,
		Dash = function(instance, parent, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Hakari.OverLuck.Dash, humanoidRootPart, game.SoundService.Effect)
			local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			clone.Dust:Emit(7)
			clone.Ring:Emit(7)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			Debris:AddItem(clone, 2)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
				local numberValue = Instance.new("NumberValue", parent)
				numberValue.Value = 50 * p
				parent:GetAttributeChangedSignal("Swing"):Connect(function()
					TweenService:Create(numberValue, TweenInfo.new(0.2), {
						Value = 25 * p
					}):Play()
					task.wait(0.2)
					TweenService:Create(
						numberValue,
						TweenInfo.new(0.5, Enum.EasingStyle.Circular, Enum.EasingDirection.In),
						{
							Value = 50 * p
						}
					):Play()
				end)

				repeat
					parent.Velocity = humanoidRootPart.CFrame.LookVector * numberValue.Value
					RunService.Stepped:Wait()
				until not (parent.Parent and humanoidRootPart.Parent)
			end
		end,
		Swing = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			if p == 1 then
				v3:PlaySound(sounds.Hakari.OverLuck.Speed2, humanoidRootPart, game.SoundService.Effect)
				v3:PlaySound(sounds.Misc.Swing.Fist2, humanoidRootPart, game.SoundService.Effect)
			else
				if p ~= 4 then
					v3:PlaySound(sounds.Misc.Swing.Fist3, humanoidRootPart, game.SoundService.Effect)
					return
				end

				v3:PlaySound(sounds.Misc.Swing.Fist2, humanoidRootPart, game.SoundService.Effect)
				v3:PlaySound(sounds.Hakari.OverLuck.Swing, humanoidRootPart, game.SoundService.Effect)
			end
		end,
		HeavySwing = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Itadori.CrushingBlow:Clone()
			clone.Air.Position = createVector(0, 40, 0)
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(p and -3 or 3, 0, 0) * CFrame.Angles(
				1.5707963267948966,
				0,
				0
			)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.PointLight.Color = Color3.fromRGB(85, 255, 127)
			TweenService:Create(clone.PointLight, TweenInfo.new(1), {
				Brightness = 0
			}):Play()

			if p then
				v3:PlaySound(sounds.Hakari.OverLuck.Speed1, humanoidRootPart, game.SoundService.Effect)
			end

			clone.Beam.Color = ColorSequence.new(Color3.fromRGB(85, 255, 127))
			clone.Floor.Sparks.Color = ColorSequence.new(Color3.fromRGB(85, 255, 127))
			clone.Floor.Ring:Emit(20)
			clone.Floor.Sparks:Emit(20)
			TweenService:Create(clone.Air, TweenInfo.new(0.15), {
				Position = createVector(0, 0, 0)
			}):Play()
			TweenService:Create(clone, TweenInfo.new(0.4), {
				CFrame = clone.CFrame + humanoidRootPart.CFrame.LookVector * 30
			}):Play()

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Hit = function(p, instance, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))

			if p2 == true then
				v3:PlaySound(sounds.Hakari.OverLuck.Hit1, humanoidRootPart, game.SoundService.Effect)
			elseif p2 == false then
				v3:PlaySound(sounds.Hakari.OverLuck.Hit2, humanoidRootPart, game.SoundService.Effect)
			else
				v3:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)
			end

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
	v = Knit.GetService("OverLuckService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
end

return controller