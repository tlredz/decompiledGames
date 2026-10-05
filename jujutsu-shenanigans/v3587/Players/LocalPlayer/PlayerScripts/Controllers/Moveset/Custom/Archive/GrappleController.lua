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
local LightningBeams = require(replicatedStorage.Modules.LightningBeams)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "GrappleController"
})

function controller.KnitStart(_)
	local v4 = {
		Jump = function(p, p2, p3)
			local humanoidRootPart = p2.Parent.Parent:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local v5 = p3 * 5

			if localPlayer.Character == humanoidRootPart.Parent then
				TweenService:Create(p2, TweenInfo.new(0.3), {
					P = 50000
				}):Play()

				repeat
					p2.Position = p.Position - v5
					humanoidRootPart.CFrame = CFrame.lookAlong(humanoidRootPart.Position, v5)
					task.wait()
				until not (p2.Parent and p)
			else
				repeat
					if v3.lastRecvServer[humanoidRootPart.Parent] ~= nil then
						v3.lastRecvServer[humanoidRootPart.Parent] = false
					end

					local v6 = CFrame.lookAlong(p.Position, v5) - v5
					humanoidRootPart.CFrame = humanoidRootPart.CFrame:Lerp(v6, 0.075)
					task.wait()
				until not (p2.Parent and p)
			end
		end,
		Grapple = function(instance, p, p2)
			local WAIT_INTERVAL = 0.05
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local gavel = instance.SetAssets:FindFirstChild("Gavel")

			if not gavel then
				return
			end

			local model = Instance.new("Model", gavel.Extensions)
			Debris:AddItem(model, 3)

			for _, part in gavel:GetChildren() do
				if part:IsA("BasePart") then
					part.Transparency = 1
				end
			end

			v2:PlaySound(sounds.Hiromi.Grapple.Fire, humanoidRootPart, game.SoundService.Effect)
			local v5 = LightningBeams.new(gavel.A, p2.RootAttachment, 5, model)
			v5.Color = Color3.fromRGB(90, 76, 66)
			v5.Material = Enum.Material.Wood
			v5.FadeLength = 0.01
			v5.PulseSpeed = 100
			v5.MaxRadius = 0
			v5.MinRadius = 0
			v5.AnimationSpeed = 10
			v5.MinThicknessMultiplier = 0.4
			v5.MaxThicknessMultiplier = 0.4
			local v6 = false

			while true do
				if p.Value == 2 and v6 == false then
					v5.MaxRadius = 0.5
					task.wait(WAIT_INTERVAL)
					v5.MaxRadius = 1
					task.wait(WAIT_INTERVAL)
					v5.MaxRadius = 3
					task.wait(WAIT_INTERVAL)
					v5.MaxRadius = 5
					task.wait(WAIT_INTERVAL)
					v5.MaxRadius = 6.5
					task.wait(WAIT_INTERVAL)
					v5.MaxRadius = 6.75
					task.wait(WAIT_INTERVAL)
					v5.MaxRadius = 5.5
					task.wait(WAIT_INTERVAL)
					v5.MaxRadius = 3
					task.wait(WAIT_INTERVAL)
					v5.MaxRadius = 1
					task.wait(WAIT_INTERVAL)
					v5.MaxRadius = 0
					v6 = true
				end

				task.wait()

				if p and p.Parent then
					continue
				end

				local clone = utils.Hiromi.GavelFire:Clone()
				clone.Position = p2.Position
				clone.Parent = workspace.Effects
				Debris:AddItem(clone, 0.1)
				v5.Attachment1 = clone.Attachment
				TweenService:Create(clone, TweenInfo.new(0.1), {
					Position = gavel.Position
				}):Play()
				task.wait(0.1)
				v5:Destroy()

				for _, part in gavel:GetChildren() do
					if part:IsA("BasePart") then
						part.Transparency = 0
					end
				end

				break
			end
		end,
		Grab = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoidRootPart2 = instance2:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart2 then
				return
			end

			v2:PlaySound(sounds.Hiromi.Grapple.Start, humanoidRootPart, game.SoundService.Effect)
			local clone = utils.Itadori.CounterHit.Feint:Clone()

			for _, child in clone:GetChildren() do
				child.Color = ColorSequence.new(Color3.fromRGB(255, 195, 134))
				child.TimeScale = 0.75
			end

			clone.Parent = humanoidRootPart2
			clone.Sparks:Emit(30)
			clone.Ring:Emit(6)
			Debris:AddItem(clone, 1)
		end,
		GrabHit = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Gojo.LapseBlue.Grab, humanoidRootPart, game.SoundService.Effect)
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Mahito.CrushingRushdown.DrillImpact:Clone()
			clone.Position = humanoidRootPart.Position
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)
			clone.Sparks.Color = ColorSequence.new(Color3.new(1, 1, 0.498039))
			clone.Wind.Color = clone.Sparks.Color
			clone.Wind2.Color = clone.Sparks.Color
			clone.Sparks:Emit(50)
			clone.Wind:Emit(7)
			clone.Wind2:Emit(7)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Hakari.EnergySurge.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.Snap)
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
	v = Knit.GetService("GrappleService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("JoinController")
end

return controller