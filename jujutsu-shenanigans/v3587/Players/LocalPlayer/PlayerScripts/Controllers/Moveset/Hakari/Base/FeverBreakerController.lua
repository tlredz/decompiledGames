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
local controller = Knit.CreateController({
	Name = "FeverBreakerController"
})

function controller.KnitStart(_)
	local v2 = {
		Startup = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:PlaySound(sounds.Hakari.FeverBreak.Swing, humanoidRootPart, game.SoundService.Effect)
		end,
		Swing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Twofold:Clone()
			clone.CFrame = humanoidRootPart.CFrame * CFrame.new(-1.25, -1, -3) * CFrame.Angles(
				-1.3962634015954636,
				0,
				0
			)
			clone.Transparency = 0.5
			clone.Parent = workspace.Effects
			clone.Swing2.Swing1:Emit(10)
			TweenService:Create(clone, TweenInfo.new(0.3), {
				CFrame = clone.CFrame + clone.CFrame.UpVector * 12,
				Size = createVector(0, 6, 0)
			}):Play()
			Debris:AddItem(clone, 0.4)
		end,
		Hit = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			local clone = utils.Gojo.Twofold.Sparks:Clone()
			clone.Parent = humanoidRootPart.RootAttachment
			clone:Emit(20)
			Debris:AddItem(clone, 0.4)
			v:Flash(instance, Color3.new(1, 1, 1))
			v:PlaySound(sounds.Hakari.FeverBreak.Hit1, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Hit2 = function(p, instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
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
			v:Flash(instance, Color3.new(1, 1, 1))
			v:PlaySound(sounds.Itadori.CraniumSmash.Hit2, humanoidRootPart, game.SoundService.Effect)

			if localPlayer == p or localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.HeavyHit)
			end
		end,
		Dash = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:PlaySound(sounds.Hakari.FeverBreak.Dash, humanoidRootPart, game.SoundService.Effect)

			if localPlayer.Character == instance then
				CameraShaker.CurrentShaker:Shake(CameraShaker.Presets.LightHit)
			end
		end,
		Spawn = function(data, color)
			local highlight = Instance.new("Highlight")
			highlight.FillTransparency = 0
			highlight.FillColor = Color3.new(2, 2, 2)
			highlight.OutlineColor = Color3.new(2, 2, 2)
			highlight.DepthMode = Enum.HighlightDepthMode.Occluded
			highlight.Parent = data.Doors

			if color then
				data.Doors.Door1.Color = color
				data.Doors.Door2.Color = color
				data.Doors.Door1.Stars.Color = ColorSequence.new(color)
				data.Doors.Door2.Stars.Color = ColorSequence.new(color)
			end

			data.Weld1.C1 = CFrame.new(-2, 0, 8) * CFrame.Angles(0, -1.5707963267948966, 0)
			data.Weld2.C1 = CFrame.new(-2, 0, 8) * CFrame.Angles(0, -1.5707963267948966, 3.141592653589793)
			TweenService:Create(data.Weld1, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
				C1 = CFrame.new(-2, 0, 2.4) * CFrame.Angles(0, -1.5707963267948966, 0)
			}):Play()
			TweenService:Create(data.Weld2, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
				C1 = CFrame.new(-2, 0, 2.4) * CFrame.Angles(0, -1.5707963267948966, 3.141592653589793)
			}):Play()
			TweenService:Create(highlight, TweenInfo.new(0.4), {
				FillTransparency = 1,
				OutlineTransparency = 1
			}):Play()
			v:PlaySound(sounds.Hakari.ShutterDoors.Spawn, data, game.SoundService.Effect)
			v:PlaySound(sounds.Hakari.ShutterDoors.Swing, data, game.SoundService.Effect)
			Debris:AddItem(highlight, 0.4)
			task.wait(0.2)
			data.Doors.Door1.Stars.Enabled = false
			data.Doors.Door2.Stars.Enabled = false
		end,
		Break = function(p, parent, _)
			local humanoidRootPart = p.HumanoidRootPart

			if not humanoidRootPart then
				return
			end

			v:PlaySound(sounds.Hakari.Counter.Slam, humanoidRootPart, game.SoundService.Effect)
			local clone = parent.Doors:Clone()
			clone.Parent = parent
			parent.Doors:Destroy()
			clone.Door1.Stars:Emit(20)
			clone.Door2.Stars:Emit(20)
			clone.Door1.CanCollide = true
			clone.Door2.CanCollide = true
			clone.Door1.Velocity = humanoidRootPart.CFrame.LookVector * 60 + humanoidRootPart.CFrame.RightVector * 20
			clone.Door2.Velocity = humanoidRootPart.CFrame.LookVector * 60 + humanoidRootPart.CFrame.RightVector * 20

			for _, descendant in clone:GetDescendants() do
				if descendant:IsA("BasePart") or descendant:IsA("Texture") then
					TweenService:Create(
						descendant,
						TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.In),
						{
							Transparency = 1
						}
					):Play()
				end
			end
		end,
		CrushSwing = function(instance)
			local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

			if not humanoidRootPart then
				return
			end

			v:PlaySound(sounds.Hakari.FeverBreak.CrushSwing, humanoidRootPart, game.SoundService.Effect)
		end
	}
	FeverBreakerService.Effects:Connect(function(p, ...)
		local v3 = v2[p]

		if not v3 then
			return
		end

		v3(...)
	end)
end

function controller.KnitInit(_)
	FeverBreakerService = Knit.GetService("FeverBreakerService")
	v = Knit.GetController("FXController")
end

return controller