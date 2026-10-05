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
local v4 = nil
local controller = Knit.CreateController({
	Name = "LuckyRushdownController"
})

function controller.KnitStart(_)
	local v5 = {
		Dash = function(instance, parent, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:PlaySound(sounds.Itadori.Rush.Rush, humanoidRootPart, game.SoundService.Effect)
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
				numberValue.Value = 200 * p
				TweenService:Create(
					numberValue,
					TweenInfo.new(0.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out),
					{
						Value = 50 * p
					}
				):Play()

				repeat
					parent.Velocity = humanoidRootPart.CFrame.LookVector * numberValue.Value
					RunService.Stepped:Wait()
				until not (parent.Parent and humanoidRootPart.Parent)
			end
		end,
		Grab = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)
		end,
		Throw = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v6 = humanoidRootPart.CFrame * CFrame.new(2, 0, 0) * CFrame.Angles(0.3490658503988659, 0, 0)
			local clone = utils.Gojo.HardHit:Clone()
			clone.CFrame = v6 + v6.LookVector * 3.5
			clone.Parent = workspace.Effects
			clone.Dust:Emit(5)
			clone.Ring:Emit(5)
			clone.Sparks:Emit(10)
			Debris:AddItem(clone, 0.5)
			v3:PlaySound(sounds.Itadori.CursedStrikes.Startup, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Jump = function(p, p2)
			local humanoidRootPart = p2.Parent.Parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v6 = humanoidRootPart.CFrame.LookVector * 5

			if localPlayer.Character == humanoidRootPart.Parent then
				TweenService:Create(p2, TweenInfo.new(0.5), {
					P = 100000
				}):Play()

				repeat
					p2.Position = p.Position - v6
					task.wait()
				until not (p2.Parent and p)
			else
				repeat
					if v4.lastRecvServer[humanoidRootPart.Parent] ~= nil then
						v4.lastRecvServer[humanoidRootPart.Parent] = false
					end

					local v7 = humanoidRootPart.CFrame - humanoidRootPart.Position + p.Position - v6
					humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(v7, 0.15)
					task.wait()
				until not (p2.Parent and p)
			end

			TweenService:Create(p2, TweenInfo.new(0.5), {
				P = 100000
			}):Play()

			repeat
				p2.Position = p.Position - v6
				task.wait()
			until not (p2.Parent and p)
		end,
		JumpBurst = function(position)
			local clone = utils.Itadori.CrushingBlow:Clone()
			clone.Position = position
			clone.PointLight:Destroy()
			clone.Air:Destroy()
			clone.Parent = workspace.Effects
			clone.Floor.Wind2.Color = ColorSequence.new(Color3.new(0, 1, 0))
			clone.Floor.Sparks.Color = ColorSequence.new(Color3.new(0, 1, 0))
			clone.Floor.Ring:Emit(10)
			clone.Floor.Sparks:Emit(10)
			clone.Floor.Wind2:Emit(8)
			Debris:AddItem(clone, 1.5)
			v3:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)
		end,
		Hit = function(p, instance, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v3:Flash(instance, Color3.new(1, 1, 1))
			v3:PlaySound(sounds.Hakari.OverLuck.Hit1, humanoidRootPart, game.SoundService.Effect)
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

			if p2 then
				v3:PlaySound(sounds.Itadori.Rush.RushBreak, humanoidRootPart, game.SoundService.Effect)
				v3:Bleed(instance)
			end
		end
	}
	v.Effects:Connect(function(p, ...)
		local v6 = v5[p]

		if not v6 then
			return
		end

		v6(...)
	end)
end

function controller.KnitInit(_)
	v = Knit.GetService("LuckyRushdownService")
	v2 = Knit.GetController("HitboxController")
	v3 = Knit.GetController("FXController")
	v4 = Knit.GetController("JoinController")
end

return controller