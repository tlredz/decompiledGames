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
require(replicatedStorage.Modules.BloodyZee)
local v = nil
local v2 = nil
local v3 = nil
local controller = Knit.CreateController({
	Name = "MassBreakerController"
})

function controller.KnitStart(_)
	local v4 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v2:PlaySound(sounds.Yuki.Mass.Start, humanoidRootPart, game.SoundService.Effect)
		end,
		Dash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Choso.CounterSwing.Shock:Clone()
			clone.Size = createVector(6, 30, 6)
			clone.CFrame = humanoidRootPart.CFrame * CFrame.Angles(1.5707963267948966, 0, 0)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 0.2)
			TweenService:Create(clone, TweenInfo.new(0.2), {
				Size = createVector(25, 0, 25),
				Transparency = 1,
				Position = clone.Position + humanoidRootPart.CFrame.LookVector * 10
			}):Play()
			v2:PlaySound(sounds.Yuki.Mass.Miss, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Yuki.Mass.Dash, humanoidRootPart, game.SoundService.Effect)

			for i = 1, 4 do
				task.delay(i * 0.04, function()
					local clone2 = utils.Itadori.Shock:Clone()
					clone2.CFrame = CFrame.lookAlong(humanoidRootPart.Position, humanoidRootPart.Velocity) * CFrame.Angles(
						1.5707963267948966,
						0,
						0
					)
					clone2.Transparency = 0.3
					clone2.Parent = workspace.Effects
					TweenService:Create(clone2, TweenInfo.new(0.15), {
						Size = createVector(20, 0, 20),
						Transparency = 1
					}):Play()
					Debris:AddItem(clone2, 0.15)
				end)
			end
		end,
		Aerial = function(instance, instance2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local humanoid = instance:FindFirstChild("Humanoid")

			if not humanoid then
				return
			end

			local bodyGyro = Instance.new("BodyGyro", humanoidRootPart)
			bodyGyro.P = 10000
			bodyGyro.MaxTorque = createVector(40000, 40000, 40000)
			instance2.Position = humanoidRootPart.Position + createVector(0, 6, 0)
			humanoid.PlatformStand = true

			repeat
				local mouseTarget = v3:GetMouseTarget()
				bodyGyro.CFrame = instance2:GetAttribute("Aim") or CFrame.new(humanoidRootPart.Position, mouseTarget)
				task.wait()
			until not instance2.Parent

			bodyGyro:Destroy()
			humanoid.PlatformStand = false
		end,
		Hit = function(p, instance, p2)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Yuki.MassHit:Clone()
			clone.CFrame = CFrame.lookAlong(humanoidRootPart.Position, p2.LookVector)
			clone.Parent = workspace.Effects
			Debris:AddItem(clone, 1)

			for _, emitter in clone:GetDescendants() do
				if emitter:IsA("ParticleEmitter") then
					emitter:Emit(emitter:GetAttribute("EmitCount"))
				end
			end

			local clone2 = utils.Gojo.LapseBlue.LapseBlue.Grab:Clone()
			clone2.Size = createVector(40, 40, 40)
			clone2.Weld.Part0 = humanoidRootPart
			clone2.Parent = workspace.Effects
			local highlight = Instance.new("Highlight", clone2)
			highlight.FillTransparency = 1
			highlight.OutlineTransparency = 1
			clone2.Transparency = 50
			TweenService:Create(clone2, TweenInfo.new(0.4, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
				Size = createVector(0, 0, 0),
				Transparency = 1
			}):Play()
			Debris:AddItem(clone2, 0.4)
			v2:Flash(instance, Color3.new(1, 1, 1))
			v2:PlaySound(sounds.Yuki.Mass.Hit, humanoidRootPart, game.SoundService.Effect)
			v2:PlaySound(sounds.Yuki.Mass.Hit2, humanoidRootPart, game.SoundService.Effect)

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
	v = Knit.GetService("MassBreakerService")
	v2 = Knit.GetController("FXController")
	v3 = Knit.GetController("ToolController")
end

return controller