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
local raycastParams = RaycastParams.new()
raycastParams.FilterType = Enum.RaycastFilterType.Include
raycastParams.FilterDescendantsInstances = { workspace.Map, workspace.Domains }
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "RushController"
})

function controller.KnitStart(_)
	local v4 = {
		Dash = function(instance, p)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Itadori.Rush.Rush, humanoidRootPart, game.SoundService.Effect)
			local clone = replicatedStorage.Utils.Itadori.RushWind:Clone()
			clone.CFrame = humanoidRootPart.CFrame
			clone.Parent = workspace.Effects
			clone.Dust:Emit(7)
			clone.Ring:Emit(7)
			clone.Dash1.Dash:Emit(1)
			clone.Dash2.Dash:Emit(1)
			Debris:AddItem(clone, 2)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(p and CameraShaker.Presets.LightHit or CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit = function(_, instance, instance2, p, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.M1:FindFirstChild("Hit1"), humanoidRootPart2, game.SoundService.Effect)
			v2:PlaySound(sounds.Itadori.Rush.RushHit, humanoidRootPart2, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			if localPlayer.Character ~= instance then
				repeat
					local v5 = 65 * task.wait()

					if not workspace:Raycast(humanoidRootPart.Position, p * v5, raycastParams) then
						humanoidRootPart.CFrame += p * v5
					end
				until not (humanoidRootPart.Parent and p2.Parent)
			end
		end,
		FinalHit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.M1:FindFirstChild("Hit2"), humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Itadori.Rush.RushBreak, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end

			task.wait(0.2)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.M1:FindFirstChild("Hit4"), humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		AerialHit = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:Flash(instance2, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart2, game.SoundService.Effect)
			v2:PlaySound(sounds.Itadori.Rush.RushLaunch, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance or localPlayer.Character == instance2 then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end

			local cframe = CFrame.new(
				humanoidRootPart2.Position,
				humanoidRootPart.CFrame * CFrame.new(0, -250, -40).Position
			)
			local clone = utils.Gojo.HardHit:Clone()
			clone.CFrame = cframe + cframe.LookVector * 4
			clone.Parent = workspace.Effects
			clone.Dust:Emit(5)
			clone.Ring:Emit(5)
			clone.Sparks:Emit(10)
			Debris:AddItem(clone, 0.5)
		end,
		Jump = function(p, p2)
			local humanoidRootPart = p2.Parent.Parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = humanoidRootPart.CFrame.LookVector * 5

			if localPlayer.Character == humanoidRootPart.Parent then
				TweenService:Create(p2, TweenInfo.new(0.5), {
					P = 100000
				}):Play()

				repeat
					p2.Position = p.Position - v5
					task.wait()
				until not (p2.Parent and p)
			else
				repeat
					if v3.lastRecvServer[humanoidRootPart.Parent] ~= nil then
						v3.lastRecvServer[humanoidRootPart.Parent] = false
					end

					local v6 = humanoidRootPart.CFrame - humanoidRootPart.Position + p.Position - v5
					humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(v6, 0.15)
					task.wait()
				until not (p2.Parent and p)
			end
		end,
		JumpBurst = function(position)
			local clone = utils.Itadori.CrushingBlow:Clone()
			clone.Position = position
			clone.PointLight:Destroy()
			clone.Air:Destroy()
			clone.Parent = workspace.Effects
			clone.Floor.Wind2.Color = ColorSequence.new(Color3.new(1, 0, 0))
			clone.Floor.Sparks.Color = ColorSequence.new(Color3.new(1, 0, 0))
			clone.Floor.Ring:Emit(10)
			clone.Floor.Sparks:Emit(10)
			clone.Floor.Wind2:Emit(8)
			Debris:AddItem(clone, 1.5)
			v2:PlaySound(sounds.Itadori.CrushingBlow.GroundImpact, clone, game.SoundService.Effect)
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
	v = Knit.GetService("RushService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("JoinController")
end

return controller